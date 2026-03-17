## `sql/` Directory Structure

```text
sql/
├── README.md
├── analysis/
│   ├── basic/
│   │   ├── 01_basic_cbp_monthly_state_totals.sql
│   │   ├── 02_basic_ohss_state_metric_totals.sql
│   │   ├── 03_basic_niv_monthly_country_class.sql
│   │   └── 04_basic_iv_monthly_country_class_basis.sql
│   ├── examples/
│   │   ├── analyze_cbp_examples.sql
│   │   ├── analyze_dos_iv_examples.sql
│   │   ├── analyze_dos_niv_examples.sql
│   │   └── analyze_ohss_examples.sql
│   └── storyline/
│       ├── 01_story_cbp_top_citizenships_in_state_period.sql
│       ├── 02_story_cbp_venezuela_breakdown_in_texas.sql
│       ├── 03_story_ohss_texas_selected_metrics.sql
│       ├── 04_story_niv_venezuela_selected_classes.sql
│       ├── 05_story_iv_venezuela_basis_totals.sql
│       └── 06_story_cross_dataset_texas_venezuela_summary.sql
├── core/
│   ├── README.md
│   ├── ddl/
│   │   ├── create_dim_country.sql
│   │   ├── create_dim_demographic_group.sql
│   │   ├── create_dim_ohss_metric.sql
│   │   ├── create_dim_state.sql
│   │   ├── create_dim_visa_class_iv.sql
│   │   ├── create_dim_visa_class_niv.sql
│   │   ├── create_fact_cbp_encounter.sql
│   │   ├── create_fact_dos_iv_issuance.sql
│   │   ├── create_fact_dos_niv_issuance.sql
│   │   ├── create_fact_ohss_state_metric.sql
│   │   └── create_map_country_label.sql
│   └── populate/
│       ├── populate_dim_country.sql
│       ├── populate_dim_demographic_group.sql
│       ├── populate_dim_ohss_metric.sql
│       ├── populate_dim_state.sql
│       ├── populate_dim_visa_class_iv.sql
│       ├── populate_dim_visa_class_niv.sql
│       ├── populate_fact_cbp_encounter.sql
│       ├── populate_fact_dos_iv_issuance.sql
│       ├── populate_fact_dos_niv_issuance.sql
│       ├── populate_fact_ohss_state_metric.sql
│       └── populate_map_country_label.sql
├── run/
│   ├── README.md
│   ├── 00_create_database.sql
│   ├── 01_create_staging.sql
│   ├── 02_load_staging.sql
│   ├── 03_create_core.sql
│   └── 04_populate_core.sql
└── staging/
    ├── ddl/
    │   ├── README.md
    │   ├── create_stg_cbp.sql
    │   ├── create_stg_dos_iv.sql
    │   ├── create_stg_dos_niv.sql
    │   └── create_stg_ohss.sql
    └── load/
        ├── README.md
        ├── load_stg_cbp.sql
        ├── load_stg_dos_iv.sql
        ├── load_stg_dos_niv.sql
        └── load_stg_ohss.sql
```

## `sql/` Directory Explanation

### `sql/staging/`
SQL for the raw staging layer. These scripts create tables that closely mirror the cleaned CSV outputs and then load those files into MySQL.

#### `sql/staging/ddl/`
`CREATE TABLE` statements for the four staging tables:
- CBP
- DOS NIV
- DOS IV
- OHSS

This folder also contains a short README with notes about the DDL choices.

#### `sql/staging/load/`
`LOAD DATA LOCAL INFILE` scripts for importing the staging CSV files into MySQL.

This folder also contains a short README explaining common loading clauses and transformations.

---

### `sql/core/`
SQL for the normalized relational schema used after staging data has been loaded.

#### `sql/core/ddl/`
`CREATE TABLE` statements for dimensions, mapping tables, and fact tables.

#### `sql/core/populate/`
`INSERT ... SELECT ...` scripts that populate the core tables from staging data.

`sql/core/README.md` contains notes about expected row counts and design choices for some core tables.

---

### `sql/run/`
Ordered runner scripts for building the database in sequence.

- `00_create_database.sql` - create the target database and switch to it
- `01_create_staging.sql` - create all staging tables
- `02_load_staging.sql` - load all staging CSV data
- `03_create_core.sql` - create all core tables
- `04_populate_core.sql` - populate dimensions, mappings, and fact tables

`sql/run/README.md` shows the expected MySQL client setup and the recommended order for running these scripts.

---

### `sql/analysis/`
Query scripts used after the warehouse is populated.

#### `sql/analysis/basic/`
Small foundational analysis queries for each dataset, useful for checking totals and understanding the grain of the data.

#### `sql/analysis/examples/`
General-purpose example queries grouped by source dataset.

#### `sql/analysis/storyline/`
Numbered queries that build a cross-dataset narrative, including the Texas and Venezuela-focused summary flow.
