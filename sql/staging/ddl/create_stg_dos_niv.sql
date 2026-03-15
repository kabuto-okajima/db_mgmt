/*
DOS NIV staging table.

Design notes:
- Use a surrogate primary key for a compact clustered index.
- Keep source_file as lineage metadata.
- Prevent duplicate rows within the same source file at the table grain.
*/

CREATE TABLE stg_dos_niv (
    stg_dos_niv_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    year SMALLINT UNSIGNED NOT NULL,
    month TINYINT UNSIGNED NOT NULL,
    nationality VARCHAR(128) NOT NULL,
    visa_class VARCHAR(64) NOT NULL,
    issuances INT UNSIGNED NOT NULL,
    source_file VARCHAR(255) NOT NULL,
    PRIMARY KEY (stg_dos_niv_id),
    UNIQUE KEY uq_stg_dos_niv_source_grain (
        source_file,
        year,
        month,
        nationality,
        visa_class
    ),
    KEY idx_stg_dos_niv_nationality_year_month (nationality, year, month),
    KEY idx_stg_dos_niv_visa_class_year_month (visa_class, year, month),
    CONSTRAINT chk_stg_dos_niv_month CHECK (month BETWEEN 1 AND 12)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;