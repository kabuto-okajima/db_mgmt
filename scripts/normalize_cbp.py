#!/usr/bin/env python3

from __future__ import annotations

import re
from pathlib import Path

import pandas as pd

RAW_PATH = Path("data/raw/cbp/nationwide-encounters-fy23-fy26-jan-state.csv")
OUT_PATH = Path("data/staging/cbp/cbp_encounters_state_monthly.csv")

MONTH_MAP = {
    "JAN": 1,
    "FEB": 2,
    "MAR": 3,
    "APR": 4,
    "MAY": 5,
    "JUN": 6,
    "JUL": 7,
    "AUG": 8,
    "SEP": 9,
    "OCT": 10,
    "NOV": 11,
    "DEC": 12,
}

DEMOGRAPHIC_MAP = {
    "FMUA": "Family Units",
    "UAC": "Unaccompanied Children",
    "Accompanied Minors": "Accompanied Minors",
    "Single Adults": "Single Adults",
}

STATE_MAP = {
    "AL": "Alabama",
    "AK": "Alaska",
    "AZ": "Arizona",
    "AR": "Arkansas",
    "CA": "California",
    "CO": "Colorado",
    "CT": "Connecticut",
    "DE": "Delaware",
    "DC": "District of Columbia",
    "FL": "Florida",
    "GA": "Georgia",
    "HI": "Hawaii",
    "ID": "Idaho",
    "IL": "Illinois",
    "IN": "Indiana",
    "IA": "Iowa",
    "KS": "Kansas",
    "KY": "Kentucky",
    "LA": "Louisiana",
    "ME": "Maine",
    "MD": "Maryland",
    "MA": "Massachusetts",
    "MI": "Michigan",
    "MN": "Minnesota",
    "MS": "Mississippi",
    "MO": "Missouri",
    "MT": "Montana",
    "NE": "Nebraska",
    "NV": "Nevada",
    "NH": "New Hampshire",
    "NJ": "New Jersey",
    "NM": "New Mexico",
    "NY": "New York",
    "NC": "North Carolina",
    "ND": "North Dakota",
    "OH": "Ohio",
    "OK": "Oklahoma",
    "OR": "Oregon",
    "PA": "Pennsylvania",
    "RI": "Rhode Island",
    "SC": "South Carolina",
    "SD": "South Dakota",
    "TN": "Tennessee",
    "TX": "Texas",
    "UT": "Utah",
    "VT": "Vermont",
    "VA": "Virginia",
    "WA": "Washington",
    "WV": "West Virginia",
    "WI": "Wisconsin",
    "WY": "Wyoming",
    "GU": "Guam",
    "MP": "Northern Mariana Islands",
    "PR": "Puerto Rico",
    "VI": "U.S. Virgin Islands",
}


def parse_fiscal_year(value: str) -> int:
    m = re.search(r"(\d{4})", str(value))
    if not m:
        raise ValueError(f"Could not parse fiscal year from: {value}")
    return int(m.group(1))


def derive_calendar_year(fiscal_year: int, month: int) -> int:
    return fiscal_year - 1 if month in (10, 11, 12) else fiscal_year


def normalize_nationality(value: str) -> str:
    text = str(value).strip()
    mapping = {
        "CHINA, PEOPLES REPUBLIC OF": "China",
        "MEXICO": "Mexico",
        "BRAZIL": "Brazil",
        "CANADA": "Canada",
        "INDIA": "India",
        "COLOMBIA": "Colombia",
        "HONDURAS": "Honduras",
        "NICARAGUA": "Nicaragua",
        "PERU": "Peru",
        "PHILIPPINES": "Philippines",
        "ROMANIA": "Romania",
        "RUSSIA": "Russia",
        "TURKEY": "Turkey",
        "UKRAINE": "Ukraine",
        "CUBA": "Cuba",
        "ECUADOR": "Ecuador",
        "GUATEMALA": "Guatemala",
        "HAITI": "Haiti",
        "VENEZUELA": "Venezuela",
        "OTHER": "Other",
    }
    return mapping.get(text, text.title())


def normalize_state(value: str) -> str:
    text = str(value).strip()
    upper = text.upper()
    return STATE_MAP.get(upper, text)


def main() -> None:
    df = pd.read_csv(RAW_PATH)

    df = df.rename(
        columns={
            "Fiscal Year": "fiscal_year_raw",
            "Month (abbv)": "month_abbr",
            "Land Border Region": "land_border_region",
            "State": "state_raw",
            "Demographic": "demographic_group",
            "Citizenship": "nationality_raw",
            "Title of Authority": "title_of_authority",
            "Encounter Count": "encounter_count",
        }
    )

    fiscal_year = df["fiscal_year_raw"].apply(parse_fiscal_year)
    df["month"] = df["month_abbr"].astype(str).str.strip().str.upper().map(MONTH_MAP)

    if df["month"].isna().any():
        bad_values = sorted(df.loc[df["month"].isna(), "month_abbr"].dropna().unique())
        raise ValueError(f"Unknown month abbreviations found: {bad_values}")

    df["month"] = df["month"].astype(int)
    df["year"] = [
        derive_calendar_year(fy, m) for fy, m in zip(fiscal_year, df["month"])
    ]

    df["state"] = df["state_raw"].apply(normalize_state)
    df["demographic_group"] = (
        df["demographic_group"]
        .astype(str)
        .str.strip()
        .map(lambda x: DEMOGRAPHIC_MAP.get(x, x))
    )

    df["nationality_raw"] = df["nationality_raw"].astype(str).str.strip()
    df["nationality"] = df["nationality_raw"].apply(normalize_nationality)

    df["encounter_count"] = (
        df["encounter_count"].astype(str).str.replace(",", "", regex=False).astype(int)
    )

    df["source_file"] = RAW_PATH.name

    key_cols = [
        "year",
        "month",
        "state",
        "land_border_region",
        "demographic_group",
        "nationality",
        "nationality_raw",
        "title_of_authority",
        "source_file",
    ]

    out = (
        df.groupby(key_cols, as_index=False, dropna=False)["encounter_count"]
        .sum()
        .sort_values(
            [
                "year",
                "month",
                "state",
                "demographic_group",
                "nationality",
                "title_of_authority",
            ]
        )
        .reset_index(drop=True)
    )

    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    out.to_csv(OUT_PATH, index=False)

    print(f"[WROTE] {OUT_PATH}")
    print(f"[ROWS] {len(out):,}")


if __name__ == "__main__":
    main()
