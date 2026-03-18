from __future__ import annotations

import os
import re
from dataclasses import dataclass
from pathlib import Path

import pymysql

from .queries import CannedQuery, REPO_ROOT


ALLOWED_READ_COMMANDS = {"SELECT", "WITH", "SHOW", "DESCRIBE", "DESC", "EXPLAIN"}
BLOCKED_TOKENS = {
    "ALTER",
    "CALL",
    "CREATE",
    "DELETE",
    "DROP",
    "GRANT",
    "INSERT",
    "LOAD",
    "MERGE",
    "RENAME",
    "REPLACE",
    "REVOKE",
    "TRUNCATE",
    "UPDATE",
}
REQUIRED_DB_ENV_VARS = ("DB_HOST", "DB_PORT", "DB_USER", "DB_PASSWORD", "DB_NAME")


@dataclass(frozen=True)
class ConnectionSettings:
    host: str
    port: int
    user: str
    password: str
    database: str

    @classmethod
    def from_env(cls) -> "ConnectionSettings":
        values = _load_db_env(REPO_ROOT / ".env.local")
        missing = [name for name in REQUIRED_DB_ENV_VARS if name not in values]
        if missing:
            missing_list = ", ".join(missing)
            raise ValueError(
                f"Missing DB config: {missing_list}. "
                "Create .env.local from .env.example or export the variables."
            )

        try:
            port = int(values["DB_PORT"])
        except ValueError as exc:
            raise ValueError("DB_PORT must be an integer.") from exc

        return cls(
            host=values["DB_HOST"],
            port=port,
            user=values["DB_USER"],
            password=values["DB_PASSWORD"],
            database=values["DB_NAME"],
        )


@dataclass(frozen=True)
class QueryResult:
    columns: tuple[str, ...]
    rows: tuple[tuple[object, ...], ...]


def load_sql_text(path: str) -> str:
    with open(path, "r", encoding="utf-8") as handle:
        return handle.read()


def render_canned_sql(
    query: CannedQuery,
    overrides: dict[str, str | int],
    database_name: str,
) -> str:
    sql_text = load_sql_text(str(query.sql_path))
    sql_text = _replace_use_database(sql_text, database_name)

    rendered = sql_text
    for parameter in query.parameters:
        value = overrides.get(parameter.name, parameter.default)
        rendered = _replace_set_variable(rendered, parameter.name, value)

    return rendered


def execute_canned_query(
    query: CannedQuery,
    overrides: dict[str, str | int],
    settings: ConnectionSettings,
) -> QueryResult:
    return execute_sql_script(
        render_canned_sql(query, overrides, settings.database),
        settings,
    )


def execute_ad_hoc_query(sql_text: str, settings: ConnectionSettings) -> QueryResult:
    return execute_sql_script(sql_text, settings)


def execute_sql_script(sql_text: str, settings: ConnectionSettings) -> QueryResult:
    statements = split_sql_statements(sql_text)
    if not statements:
        raise ValueError("No SQL statements were found.")

    final_columns: tuple[str, ...] = ()
    final_rows: tuple[tuple[object, ...], ...] = ()

    connection = pymysql.connect(
        host=settings.host,
        port=settings.port,
        user=settings.user,
        password=settings.password,
        database=settings.database,
        charset="utf8mb4",
        autocommit=True,
    )
    try:
        with connection.cursor() as cursor:
            for statement in statements:
                cursor.execute(statement)
                if cursor.description:
                    final_columns = tuple(column[0] for column in cursor.description)
                    final_rows = tuple(tuple(row) for row in cursor.fetchall())
    finally:
        connection.close()

    return QueryResult(columns=final_columns, rows=final_rows)


def validate_read_only_sql(sql_text: str) -> None:
    statements = split_sql_statements(sql_text)
    if len(statements) != 1:
        raise ValueError("Ad hoc SQL must contain exactly one statement.")

    tokens = _extract_tokens(statements[0])
    if not tokens:
        raise ValueError("Could not find a SQL command to execute.")

    first_token = tokens[0]
    if first_token not in ALLOWED_READ_COMMANDS:
        allowed = ", ".join(sorted(ALLOWED_READ_COMMANDS))
        raise ValueError(f"Only read-style commands are allowed: {allowed}.")

    blocked = sorted(token for token in set(tokens) if token in BLOCKED_TOKENS)
    if blocked:
        raise ValueError(
            "Ad hoc SQL includes blocked write or schema-changing keywords: "
            + ", ".join(blocked)
            + "."
        )


def split_sql_statements(sql_text: str) -> list[str]:
    statements: list[str] = []
    current: list[str] = []
    index = 0
    length = len(sql_text)
    in_single = False
    in_double = False
    in_backtick = False
    in_line_comment = False
    in_block_comment = False

    while index < length:
        char = sql_text[index]
        next_char = sql_text[index + 1] if index + 1 < length else ""

        if in_line_comment:
            if char == "\n":
                in_line_comment = False
                current.append(char)
            index += 1
            continue

        if in_block_comment:
            if char == "*" and next_char == "/":
                in_block_comment = False
                index += 2
            else:
                index += 1
            continue

        if not (in_single or in_double or in_backtick):
            if char == "#" or (char == "-" and next_char == "-" and _is_mysql_dash_comment(sql_text, index)):
                in_line_comment = True
                index += 1 if char == "#" else 2
                continue
            if char == "/" and next_char == "*":
                in_block_comment = True
                index += 2
                continue

        if char == "\\" and (in_single or in_double) and index + 1 < length:
            current.append(char)
            current.append(sql_text[index + 1])
            index += 2
            continue

        if char == "'" and not (in_double or in_backtick):
            in_single = not in_single
            current.append(char)
            index += 1
            continue

        if char == '"' and not (in_single or in_backtick):
            in_double = not in_double
            current.append(char)
            index += 1
            continue

        if char == "`" and not (in_single or in_double):
            in_backtick = not in_backtick
            current.append(char)
            index += 1
            continue

        if char == ";" and not (in_single or in_double or in_backtick):
            statement = "".join(current).strip()
            if statement:
                statements.append(statement)
            current = []
            index += 1
            continue

        current.append(char)
        index += 1

    trailing = "".join(current).strip()
    if trailing:
        statements.append(trailing)

    return statements


def _replace_use_database(sql_text: str, database_name: str) -> str:
    return re.sub(
        r"(?im)^\s*USE\s+`?[\w]+`?\s*;\s*$",
        f"USE `{database_name}`;",
        sql_text,
    )


def _replace_set_variable(sql_text: str, variable_name: str, value: str | int) -> str:
    pattern = re.compile(
        rf"(?im)^(\s*SET\s+@{re.escape(variable_name)}\s*=\s*)(.+?)(\s*;\s*)$"
    )
    match = pattern.search(sql_text)
    if match is None:
        raise ValueError(f"Could not find SET @{variable_name} in the SQL source.")
    return pattern.sub(
        lambda matched: f"{matched.group(1)}{_to_sql_literal(value)}{matched.group(3)}",
        sql_text,
        count=1,
    )


def _to_sql_literal(value: str | int) -> str:
    if isinstance(value, int):
        return str(value)
    escaped = value.replace("\\", "\\\\").replace("'", "''")
    return f"'{escaped}'"


def _extract_tokens(sql_text: str) -> list[str]:
    masked = _mask_sql_text(sql_text)
    return re.findall(r"[A-Z_]+", masked.upper())


def _mask_sql_text(sql_text: str) -> str:
    chars: list[str] = []
    index = 0
    length = len(sql_text)
    in_single = False
    in_double = False
    in_backtick = False
    in_line_comment = False
    in_block_comment = False

    while index < length:
        char = sql_text[index]
        next_char = sql_text[index + 1] if index + 1 < length else ""

        if in_line_comment:
            if char == "\n":
                in_line_comment = False
                chars.append("\n")
            else:
                chars.append(" ")
            index += 1
            continue

        if in_block_comment:
            if char == "*" and next_char == "/":
                chars.extend("  ")
                in_block_comment = False
                index += 2
            else:
                chars.append(" ")
                index += 1
            continue

        if not (in_single or in_double or in_backtick):
            if char == "#" or (char == "-" and next_char == "-" and _is_mysql_dash_comment(sql_text, index)):
                in_line_comment = True
                chars.append(" ")
                index += 1 if char == "#" else 2
                continue
            if char == "/" and next_char == "*":
                in_block_comment = True
                chars.extend("  ")
                index += 2
                continue

        if char == "\\" and (in_single or in_double) and index + 1 < length:
            chars.extend("  ")
            index += 2
            continue

        if char == "'" and not (in_double or in_backtick):
            in_single = not in_single
            chars.append(" ")
            index += 1
            continue

        if char == '"' and not (in_single or in_backtick):
            in_double = not in_double
            chars.append(" ")
            index += 1
            continue

        if char == "`" and not (in_single or in_double):
            in_backtick = not in_backtick
            chars.append(" ")
            index += 1
            continue

        chars.append(" " if (in_single or in_double or in_backtick) else char)
        index += 1

    return "".join(chars)


def _is_mysql_dash_comment(sql_text: str, index: int) -> bool:
    third_char = sql_text[index + 2] if index + 2 < len(sql_text) else ""
    return third_char == "" or third_char.isspace()


def _load_db_env(env_path: Path) -> dict[str, str]:
    values = _read_env_file(env_path)
    for name in REQUIRED_DB_ENV_VARS:
        if name in os.environ:
            values[name] = os.environ[name]
    return values


def _read_env_file(env_path: Path) -> dict[str, str]:
    if not env_path.exists():
        return {}

    values: dict[str, str] = {}
    for raw_line in env_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            raise ValueError(f"Invalid line in {env_path.name}: {raw_line}")
        key, value = line.split("=", 1)
        values[key.strip()] = _strip_optional_quotes(value.strip())
    return values


def _strip_optional_quotes(value: str) -> str:
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
        return value[1:-1]
    return value
