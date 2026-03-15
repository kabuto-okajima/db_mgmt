/*
CBP staging table.

Design notes:
- Use a short surrogate primary key for InnoDB efficiency.
- Keep source_file as lineage metadata.
- Preserve search indexes aligned to likely filter patterns.
*/

CREATE TABLE stg_cbp (
    stg_cbp_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    year SMALLINT UNSIGNED NOT NULL,
    month TINYINT UNSIGNED NOT NULL,
    state VARCHAR(64) NOT NULL,
    land_border_region VARCHAR(64) NOT NULL,
    demographic_group VARCHAR(64) NOT NULL,
    nationality VARCHAR(128) NOT NULL,
    nationality_raw VARCHAR(128) NOT NULL,
    title_of_authority VARCHAR(64) NOT NULL,
    source_file VARCHAR(255) NOT NULL,
    encounter_count INT UNSIGNED NOT NULL,
    PRIMARY KEY (stg_cbp_id),
    KEY idx_stg_cbp_state_year_month (state, year, month),
    KEY idx_stg_cbp_nationality_year_month (nationality, year, month),
    KEY idx_stg_cbp_demographic_group (demographic_group),
    CONSTRAINT chk_stg_cbp_month CHECK (month BETWEEN 1 AND 12)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;