#!/usr/bin/env python3
"""
Normalize OHSS State Immigration Data into SQL-friendly staging CSVs.

Inputs:
    data/raw/ohss/state_data_2013-2023_20250514_3.csv

Outputs:
    data/staging/ohss/ohss_state_annual_wide.csv
    data/staging/ohss/ohss_state_annual_long.csv
"""

from __future__ import annotations

from pathlib import Path
from typing import Dict, List

import pandas as pd

RAW_PATH = Path("data/raw/ohss/state_data_2013-2023_20250514_3.csv")
OUT_DIR = Path("data/staging/ohss")
WIDE_OUT_PATH = OUT_DIR / "ohss_state_annual_wide.csv"
LONG_OUT_PATH = OUT_DIR / "ohss_state_annual_long.csv"

COLUMN_MAP = {
    "State": "state",
    "Year": "year",
    "Population": "population",
    "Lawful Permanent Residents Total": "lawful_permanent_residents_total",
    "Lawful Permanent Residents Rank": "lawful_permanent_residents_rank",
    "Adjustments Total": "adjustments_total",
    "Adjustments Rank": "adjustments_rank",
    "New Arrivals Total": "new_arrivals_total",
    "New Arrivals Rank": "new_arrivals_rank",
    "Nonimmigrants Total": "nonimmigrants_total",
    "Nonimmigrants Rank": "nonimmigrants_rank",
    "Naturalizations Total": "naturalizations_total",
    "Naturalizations Rank": "naturalizations_rank",
    "Refugees Total": "refugees_total",
    "Refugees Rank": "refugees_rank",
    "Asylees Total": "asylees_total",
    "Asylees Rank": "asylees_rank",
    "Lawful Permanent Residents Per Million": "lawful_permanent_residents_per_million",
    "Lawful Permanent Residents Per Million Rank": "lawful_permanent_residents_per_million_rank",
    "Adjustments Per Million": "adjustments_per_million",
    "Adjustments Per Million Rank": "adjustments_per_million_rank",
    "New Arrivals Per Million": "new_arrivals_per_million",
    "New Arrivals Per Million Rank": "new_arrivals_per_million_rank",
    "Nonimmigrants Per Million": "nonimmigrants_per_million",
    "Nonimmigrants Per Million Rank": "nonimmigrants_per_million_rank",
    "Naturalizations Per Million": "naturalizations_per_million",
    "Naturalizations Per Million Rank": "naturalizations_per_million_rank",
    "Refugees Per Million": "refugees_per_million",
    "Refugees Per Million Rank": "refugees_per_million_rank",
    "Asylees Per Million": "asylees_per_million",
    "Asylees Per Million Rank": "asylees_per_million_rank",
}

METRICS = [
    "lawful_permanent_residents",
    "adjustments",
    "new_arrivals",
    "nonimmigrants",
    "naturalizations",
    "refugees",
    "asylees",
]

MEASURE_TYPES = [
    "total",
    "rank",
    "per_million",
    "per_million_rank",
]

INT_COLS = [
    "year",
    "population",
    "lawful_permanent_residents_total",
    "lawful_permanent_residents_rank",
    "adjustments_total",
    "adjustments_rank",
    "new_arrivals_total",
    "new_arrivals_rank",
    "nonimmigrants_total",
    "nonimmigrants_rank",
    "naturalizations_total",
    "naturalizations_rank",
    "refugees_total",
    "refugees_rank",
    "asylees_total",
    "asylees_rank",
    "lawful_permanent_residents_per_million_rank",
    "adjustments_per_million_rank",
    "new_arrivals_per_million_rank",
    "nonimmigrants_per_million_rank",
    "naturalizations_per_million_rank",
    "refugees_per_million_rank",
    "asylees_per_million_rank",
]

FLOAT_COLS = [
    "lawful_permanent_residents_per_million",
    "adjustments_per_million",
    "new_arrivals_per_million",
    "nonimmigrants_per_million",
    "naturalizations_per_million",
    "refugees_per_million",
    "asylees_per_million",
]


def resolve_raw_path() -> Path:
    if RAW_PATH.exists():
        return RAW_PATH

    candidates = sorted(Path("data/raw/ohss").glob("*.csv"))
    if not candidates:
        raise FileNotFoundError(
            "No OHSS CSV found. Expected data/raw/ohss/state_data_2013-2023_20250514_3.csv "
            "or any CSV under data/raw/ohss/."
        )
    return candidates[0]


def load_raw_csv(path: Path) -> pd.DataFrame:
    df = pd.read_csv(path)
    missing = [c for c in COLUMN_MAP if c not in df.columns]
    if missing:
        raise ValueError(f"Missing expected columns: {missing}")
    return df


def coerce_nullable_int(series: pd.Series) -> pd.Series:
    return pd.to_numeric(series, errors="coerce").astype("Int64")


def coerce_float(series: pd.Series) -> pd.Series:
    return pd.to_numeric(series, errors="coerce").astype(float)


def build_wide(df: pd.DataFrame, source_file: str) -> pd.DataFrame:
    wide = df.rename(columns=COLUMN_MAP).copy()

    wide["state"] = wide["state"].astype(str).str.strip()

    for col in INT_COLS:
        wide[col] = coerce_nullable_int(wide[col])

    for col in FLOAT_COLS:
        wide[col] = coerce_float(wide[col])

    wide["source_file"] = source_file

    ordered_cols = [
        "state",
        "year",
        "population",
        "lawful_permanent_residents_total",
        "lawful_permanent_residents_rank",
        "lawful_permanent_residents_per_million",
        "lawful_permanent_residents_per_million_rank",
        "adjustments_total",
        "adjustments_rank",
        "adjustments_per_million",
        "adjustments_per_million_rank",
        "new_arrivals_total",
        "new_arrivals_rank",
        "new_arrivals_per_million",
        "new_arrivals_per_million_rank",
        "nonimmigrants_total",
        "nonimmigrants_rank",
        "nonimmigrants_per_million",
        "nonimmigrants_per_million_rank",
        "naturalizations_total",
        "naturalizations_rank",
        "naturalizations_per_million",
        "naturalizations_per_million_rank",
        "refugees_total",
        "refugees_rank",
        "refugees_per_million",
        "refugees_per_million_rank",
        "asylees_total",
        "asylees_rank",
        "asylees_per_million",
        "asylees_per_million_rank",
        "source_file",
    ]

    wide = wide[ordered_cols].sort_values(["state", "year"]).reset_index(drop=True)

    dupes = wide.duplicated(subset=["state", "year"], keep=False)
    if dupes.any():
        raise ValueError(
            "Duplicate state-year rows found in OHSS wide output:\n"
            f"{wide.loc[dupes].to_string(index=False)}"
        )

    return wide


def build_long(wide: pd.DataFrame) -> pd.DataFrame:
    records: List[Dict[str, object]] = []

    for row in wide.itertuples(index=False):
        base = {
            "state": row.state,
            "year": row.year,
            "population": row.population,
            "source_file": row.source_file,
        }

        for metric in METRICS:
            for measure_type in MEASURE_TYPES:
                col = f"{metric}_{measure_type}"
                records.append(
                    {
                        **base,
                        "metric_name": metric,
                        "measure_type": measure_type,
                        "metric_value": getattr(row, col),
                    }
                )

    long = pd.DataFrame(records)
    long["metric_value"] = pd.to_numeric(long["metric_value"], errors="coerce")

    long = long.sort_values(
        ["state", "year", "metric_name", "measure_type"]
    ).reset_index(drop=True)

    dupes = long.duplicated(
        subset=["state", "year", "metric_name", "measure_type"],
        keep=False,
    )
    if dupes.any():
        raise ValueError(
            "Duplicate state-year-metric-measure rows found in OHSS long output:\n"
            f"{long.loc[dupes].to_string(index=False)}"
        )

    return long


def print_null_summary(wide: pd.DataFrame) -> None:
    nullable_cols = [c for c in INT_COLS + FLOAT_COLS if wide[c].isna().any()]
    if not nullable_cols:
        print("[NULL SUMMARY] none")
        return

    print("[NULL SUMMARY]")
    for col in nullable_cols:
        print(f"  - {col}: {int(wide[col].isna().sum())} nulls")


def main() -> None:
    raw_path = resolve_raw_path()
    source_file = raw_path.name

    df = load_raw_csv(raw_path)
    wide = build_wide(df, source_file=source_file)
    long = build_long(wide)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    wide.to_csv(WIDE_OUT_PATH, index=False)
    long.to_csv(LONG_OUT_PATH, index=False)

    print(f"[READ] {raw_path}")
    print(f"[WROTE WIDE] {WIDE_OUT_PATH}")
    print(f"[WROTE LONG] {LONG_OUT_PATH}")
    print(f"[WIDE ROWS] {len(wide):,}")
    print(f"[LONG ROWS] {len(long):,}")
    print(f"[STATES] {wide['state'].nunique()}")
    print(f"[YEARS] {wide['year'].min()}-{wide['year'].max()}")
    print_null_summary(wide)


if __name__ == "__main__":
    main()
