#!/usr/bin/env python3
"""fetch_dos_iv.py

Download DOS Monthly Immigrant Visa (IV) Issuances Excel files for:
    IV Issuances by FSC or Place of Birth and Visa Class

This script scrapes the official Travel.State.Gov page to discover the monthly
Excel links (so we don't hardcode URLs), then downloads the files for a
specified date range.

Inputs (none):
    - Scrapes the monthly IV issuances page.

Outputs:
    - data/raw/dos_iv/YYYY-MM_dos_iv_fsc_pob_visa_class.xlsx

Usage:
    python scripts/fetch_dos_iv.py

Dependencies:
    pip install requests beautifulsoup4
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from datetime import date
from pathlib import Path
from typing import Dict, Iterator, Tuple
from urllib.parse import urljoin

import requests
from bs4 import BeautifulSoup

PAGE_URL = (
    "https://travel.state.gov/content/travel/en/legal/visa-law0/"
    "visa-statistics/immigrant-visa-statistics/"
    "monthly-immigrant-visa-issuances.html"
)

OUTPUT_DIR = Path("data/raw/dos_iv")

# Match the NIV range you used previously.
START = (2022, 10)
END = (2025, 8)

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (X11; Linux x86_64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/123.0 Safari/537.36"
    )
}


@dataclass(frozen=True)
class MonthlyFile:
    year: int
    month: int
    month_name: str
    title: str
    url: str


MONTH_LOOKUP = {
    "January": 1,
    "February": 2,
    "March": 3,
    "April": 4,
    "May": 5,
    "June": 6,
    "July": 7,
    "August": 8,
    "September": 9,
    "October": 10,
    "November": 11,
    "December": 12,
}


def month_range(
    start: Tuple[int, int], end: Tuple[int, int]
) -> Iterator[Tuple[int, int]]:
    sy, sm = start
    ey, em = end

    current = date(sy, sm, 1)
    stop = date(ey, em, 1)

    while current <= stop:
        yield current.year, current.month
        if current.month == 12:
            current = date(current.year + 1, 1, 1)
        else:
            current = date(current.year, current.month + 1, 1)


def normalize_text(text: str) -> str:
    text = text.replace("\u2013", "-").replace("\u2014", "-").replace("\xa0", " ")
    return re.sub(r"\s+", " ", text).strip()


def parse_month_year_from_title(title: str) -> Tuple[int, int, str]:
    """Example title:
    'October 2022 - IV Issuances by FSC or Place of Birth and Visa Class'
    """
    m = re.match(
        r"^([A-Za-z]+)\s+(\d{4})\s+-\s+IV Issuances by FSC or Place of Birth and Visa Class$",
        title,
    )
    if not m:
        raise ValueError(f"Could not parse month/year from title: {title}")

    month_name = m.group(1)
    year = int(m.group(2))

    if month_name not in MONTH_LOOKUP:
        raise ValueError(f"Unknown month name: {month_name}")

    return year, MONTH_LOOKUP[month_name], month_name


def scrape_excel_links(session: requests.Session) -> Dict[Tuple[int, int], MonthlyFile]:
    resp = session.get(PAGE_URL, headers=HEADERS, timeout=60)
    resp.raise_for_status()

    soup = BeautifulSoup(resp.text, "html.parser")
    found: Dict[Tuple[int, int], MonthlyFile] = {}

    for li in soup.find_all("li"):
        anchors = li.find_all("a", href=True)
        if not anchors:
            continue

        title_anchor = None
        excel_anchor = None

        for a in anchors:
            label = normalize_text(a.get_text(" ", strip=True))

            if "IV Issuances by FSC or Place of Birth and Visa Class" in label:
                title_anchor = a

            if "excel" in label.lower():
                excel_anchor = a

        if title_anchor is None or excel_anchor is None:
            continue

        title = normalize_text(title_anchor.get_text(" ", strip=True))

        # Keep only the FSC/POB series, not "Post and Visa Class".
        if "IV Issuances by FSC or Place of Birth and Visa Class" not in title:
            continue
        if "Post and Visa Class" in title:
            continue

        try:
            year, month, month_name = parse_month_year_from_title(title)
        except ValueError:
            continue

        url = urljoin(PAGE_URL, excel_anchor["href"])
        found[(year, month)] = MonthlyFile(
            year=year,
            month=month,
            month_name=month_name,
            title=title,
            url=url,
        )

    return found


def download_file(session: requests.Session, url: str, destination: Path) -> None:
    with session.get(url, headers=HEADERS, stream=True, timeout=180) as resp:
        resp.raise_for_status()
        destination.parent.mkdir(parents=True, exist_ok=True)
        with open(destination, "wb") as f:
            for chunk in resp.iter_content(chunk_size=1024 * 1024):
                if chunk:
                    f.write(chunk)


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    with requests.Session() as session:
        links = scrape_excel_links(session)

        expected = list(month_range(START, END))
        print(f"Expected months: {len(expected)}")
        print(f"Discovered monthly Excel links on page: {len(links)}")

        for year, month in expected:
            mf = links.get((year, month))

            if mf is None:
                print(f"[MISSING ON PAGE] {year}-{month:02d}")
                continue

            filename = f"{year}-{month:02d}_dos_iv_fsc_pob_visa_class.xlsx"
            out_path = OUTPUT_DIR / filename

            if out_path.exists():
                print(f"[SKIP] {filename} already exists")
                continue

            try:
                print(f"[DOWNLOAD] {mf.title}")
                print(f"           {mf.url}")
                download_file(session, mf.url, out_path)
                print(f"[OK] {out_path}")
            except requests.HTTPError as e:
                status = e.response.status_code if e.response is not None else "unknown"
                print(f"[HTTP {status}] Failed: {mf.url}")
            except Exception as e:
                print(f"[ERROR] {mf.url} -> {e}")


if __name__ == "__main__":
    main()
