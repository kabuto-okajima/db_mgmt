# CLI
Minimal query CLI for the existing MySQL schema and `sql/analysis/*.sql`.

## Setup
```bash
cp .env.example .env.local
uv sync
```

`.env.local`
```env
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_NAME=db_mgmt
DB_PASSWORD=
```

## Commands
```bash
uv run python -m cli list

uv run python -m cli show story-cbp-top-citizenships-in-state-period

uv run python -m cli run story-cbp-top-citizenships-in-state-period --param state_name=Texas --param start_yyyymm=202301 --param end_yyyymm=202508
uv run python -m cli run story-cbp-country-breakdown-in-state --param state_name=Texas --param country_name=Venezuela --param start_yyyymm=202301 --param end_yyyymm=202508
uv run python -m cli run story-ohss-selected-metrics --param state_name=Texas --param start_year=2021 --param end_year=2023
uv run python -m cli run story-niv-selected-classes --param country_name=Venezuela --param start_yyyymm=202301 --param end_yyyymm=202508
uv run python -m cli run story-iv-basis-totals --param country_name=Venezuela --param start_yyyymm=202301 --param end_yyyymm=202508
uv run python -m cli run story-cross-dataset-summary --param state_name=Texas --param country_name=Venezuela --param start_yyyymm=202301 --param end_yyyymm=202508 --param start_year=2023 --param end_year=2023

uv run python -m cli sql --query "SELECT COUNT(*) FROM fact_cbp_encounter"
uv run python -m cli sql --file path/to/read_only_query.sql
```

## Notes
- `run` uses the canned queries defined in `sql/analysis/basic/` and `sql/analysis/storyline/`.
- `sql` accepts one read-only statement only.
