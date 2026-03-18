from __future__ import annotations

import argparse
from pathlib import Path

from .db import (
    QueryResult,
    execute_ad_hoc_query,
    execute_canned_query,
    ConnectionSettings,
    validate_read_only_sql,
)
from .queries import QUERY_BY_ID, QUERY_REGISTRY, CannedQuery


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    if not hasattr(args, "handler"):
        parser.print_help()
        return 1

    try:
        return args.handler(args)
    except (FileNotFoundError, ValueError) as exc:
        print(f"Error: {exc}")
        return 2
    except Exception as exc:  # pragma: no cover - keeps CLI errors readable
        print(f"Database error: {exc}")
        return 3


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="python -m cli",
        description="Minimal CLI for canned and ad hoc read-only queries over the db_mgmt MySQL schema.",
    )
    subparsers = parser.add_subparsers(dest="command")

    list_parser = subparsers.add_parser("list", help="List available canned queries.")
    list_parser.set_defaults(handler=handle_list)

    show_parser = subparsers.add_parser("show", help="Show metadata for a canned query.")
    show_parser.add_argument("query_id", help="Canned query ID.")
    show_parser.set_defaults(handler=handle_show)

    run_parser = subparsers.add_parser(
        "run",
        help="Execute a canned query.",
    )
    run_parser.add_argument("query_id", help="Canned query ID.")
    run_parser.add_argument(
        "--param",
        action="append",
        default=[],
        metavar="NAME=VALUE",
        help="Override a canned query parameter. Repeat as needed.",
    )
    run_parser.set_defaults(handler=handle_run)

    sql_parser = subparsers.add_parser(
        "sql",
        help="Execute a single ad hoc read-only SQL statement.",
    )
    sql_source = sql_parser.add_mutually_exclusive_group(required=True)
    sql_source.add_argument("--query", help="Ad hoc SQL text to execute.")
    sql_source.add_argument("--file", help="Path to a .sql file containing one read-only statement.")
    sql_parser.set_defaults(handler=handle_sql)

    return parser


def handle_list(_: argparse.Namespace) -> int:
    columns = ("query_id", "title", "sql_path", "parameters")
    rows = tuple(
        (
            query.query_id,
            query.title,
            query.relative_sql_path,
            ", ".join(parameter.name for parameter in query.parameters) or "-",
        )
        for query in QUERY_REGISTRY
    )
    _print_result(QueryResult(columns=columns, rows=rows))
    return 0


def handle_show(args: argparse.Namespace) -> int:
    query = _get_query(args.query_id)

    print(f"ID: {query.query_id}")
    print(f"Title: {query.title}")
    print(f"Description: {query.description}")
    print(f"SQL file: {query.relative_sql_path}")
    print("Parameters:")
    if query.parameters:
        for parameter in query.parameters:
            print(
                f"  - {parameter.name} ({parameter.value_type.__name__}, default={parameter.default}): "
                f"{parameter.description}"
            )
    else:
        print("  - none")
    return 0


def handle_run(args: argparse.Namespace) -> int:
    query = _get_query(args.query_id)
    overrides = _parse_param_overrides(query, args.param)
    settings = ConnectionSettings.from_env()
    result = execute_canned_query(query, overrides, settings)
    _print_result(result)
    return 0


def handle_sql(args: argparse.Namespace) -> int:
    sql_text = args.query if args.query is not None else Path(args.file).read_text(encoding="utf-8")
    validate_read_only_sql(sql_text)
    settings = ConnectionSettings.from_env()
    result = execute_ad_hoc_query(sql_text, settings)
    _print_result(result)
    return 0


def _get_query(query_id: str) -> CannedQuery:
    try:
        return QUERY_BY_ID[query_id]
    except KeyError as exc:
        available = ", ".join(query.query_id for query in QUERY_REGISTRY)
        raise ValueError(f"Unknown query ID {query_id!r}. Available IDs: {available}") from exc


def _parse_param_overrides(query: CannedQuery, raw_items: list[str]) -> dict[str, str | int]:
    parameter_map = {parameter.name: parameter for parameter in query.parameters}
    overrides: dict[str, str | int] = {}

    for item in raw_items:
        if "=" not in item:
            raise ValueError(f"Parameter override must be NAME=VALUE, got {item!r}.")
        name, raw_value = item.split("=", 1)
        name = name.strip()
        raw_value = raw_value.strip()
        if name not in parameter_map:
            allowed = ", ".join(parameter_map) or "none"
            raise ValueError(f"Unknown parameter {name!r} for {query.query_id}. Allowed: {allowed}")
        parameter = parameter_map[name]
        overrides[name] = _coerce_value(parameter.value_type, raw_value, name)

    return overrides


def _coerce_value(expected_type: type[str] | type[int], raw_value: str, name: str) -> str | int:
    if expected_type is int:
        try:
            return int(raw_value)
        except ValueError as exc:
            raise ValueError(f"Parameter {name!r} expects an integer, got {raw_value!r}.") from exc
    return raw_value


def _print_result(result: QueryResult) -> None:
    if not result.columns:
        print("Statement executed successfully.")
        return

    rows_as_strings = [tuple(_stringify(cell) for cell in row) for row in result.rows]
    widths = [
        min(
            48,
            max(len(column), *(len(row[index]) for row in rows_as_strings)) if rows_as_strings else len(column),
        )
        for index, column in enumerate(result.columns)
    ]

    line = "+-" + "-+-".join("-" * width for width in widths) + "-+"
    print(line)
    print("| " + " | ".join(_fit(result.columns[index], widths[index]) for index in range(len(result.columns))) + " |")
    print(line)
    for row in rows_as_strings:
        print("| " + " | ".join(_fit(row[index], widths[index]) for index in range(len(row))) + " |")
    print(line)
    print(f"{len(result.rows)} row(s)")


def _fit(value: str, width: int) -> str:
    if len(value) <= width:
        return value.ljust(width)
    return (value[: width - 3] + "...") if width >= 3 else value[:width]


def _stringify(value: object) -> str:
    if value is None:
        return "NULL"
    return str(value)
