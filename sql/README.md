## `sql/` Directory Structure

```
sql/
├── staging/
│   ├── ddl/
│   │   ├── create_stg_cbp.sql
│   │   ├── create_stg_dos_niv.sql
│   │   ├── create_stg_dos_iv.sql
│   │   └── create_stg_ohss.sql
│   └── load/
│       ├── load_stg_cbp.sql
│       ├── load_stg_dos_niv.sql
│       ├── load_stg_dos_iv.sql
│       └── load_stg_ohss.sql
├── core/
│   ├── ddl/
│   │   ├── create_dim_state.sql
│   │   ├── create_dim_country.sql
│   │   ├── create_map_country_name.sql
│   │   ├── create_dim_demographic_group.sql
│   │   ├── create_dim_visa_class_niv.sql
│   │   ├── create_dim_visa_class_iv.sql
│   │   ├── create_dim_ohss_metric.sql
│   │   ├── create_fact_cbp_encounter.sql
│   │   ├── create_fact_dos_niv_issuance.sql
│   │   ├── create_fact_dos_iv_issuance.sql
│   │   └── create_fact_ohss_state_metric.sql
│   └── populate/
│       ├── populate_dim_state.sql
│       ├── populate_map_country_name.sql
│       ├── populate_dim_country.sql
│       ├── populate_dim_demographic_group.sql
│       ├── populate_dim_visa_class_niv.sql
│       ├── populate_dim_visa_class_iv.sql
│       ├── populate_dim_ohss_metric.sql
│       ├── populate_fact_cbp_encounter.sql
│       ├── populate_fact_dos_niv_issuance.sql
│       ├── populate_fact_dos_iv_issuance.sql
│       └── populate_fact_ohss_state_metric.sql
└── run/
    ├── 01_create_staging.sql
    ├── 02_load_staging.sql
    ├── 03_create_core.sql
    └── 04_populate_core.sql
```



## `sql/` Directory Explanation

### `sql/staging/`
SQL for loading normalized CSV outputs into staging tables.  
These tables stay close to the staging files produced by the Python scripts.

#### `sql/staging/ddl/`
`CREATE TABLE` statements for the four staging tables.

#### `sql/staging/load/`
SQL scripts for loading CSV data into the staging tables.

---

### `sql/core/`
SQL for the main relational schema used in MySQL.  
This layer contains the normalized database structure built from staging data.

#### `sql/core/ddl/`
`CREATE TABLE` statements for dimension, mapping, and fact tables.  
Primary keys, foreign keys, and unique constraints can be defined here.

#### `sql/core/populate/`
`INSERT ... SELECT ...` scripts that move data from staging tables into core tables.

---

### `sql/run/`
Ordered SQL runner scripts for building the database step by step.

- `01_create_staging.sql` — create all staging tables
- `02_load_staging.sql` — load all staging CSV data
- `03_create_core.sql` — create all core tables
- `04_populate_core.sql` — populate dimensions, mappings, and fact tables
