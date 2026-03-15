/*
OHSS staging table in long format.

Design notes:
- Use a surrogate primary key for consistency across staging tables.
- Keep source_file as lineage metadata.
- Prevent duplicate rows within the same source file at the table grain.
- Keep secondary indexes aligned to likely analytical filters.
*/

CREATE TABLE stg_ohss (
    stg_ohss_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    state VARCHAR(64) NOT NULL,
    year SMALLINT UNSIGNED NOT NULL,
    population INT UNSIGNED NULL,
    source_file VARCHAR(255) NOT NULL,
    metric_name ENUM(
        'lawful_permanent_residents',
        'adjustments',
        'new_arrivals',
        'nonimmigrants',
        'naturalizations',
        'refugees',
        'asylees'
    ) NOT NULL,
    measure_type ENUM(
        'total',
        'rank',
        'per_million',
        'per_million_rank'
    ) NOT NULL,
    metric_value DECIMAL(18, 6) NULL,
    PRIMARY KEY (stg_ohss_id),
    UNIQUE KEY uq_stg_ohss_source_grain (
        source_file,
        state,
        year,
        metric_name,
        measure_type
    ),
    KEY idx_stg_ohss_metric_measure_year (
        metric_name,
        measure_type,
        year
    ),
    KEY idx_stg_ohss_state_year (state, year)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;