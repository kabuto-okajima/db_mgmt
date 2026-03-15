/*
DOS IV staging table.

Design notes:
- Use a surrogate primary key for a compact clustered index.
- Keep source_file as lineage metadata.
- Prevent duplicate rows within the same source file at the table grain.
*/

CREATE TABLE stg_dos_iv (
    stg_dos_iv_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    year SMALLINT UNSIGNED NOT NULL,
    month TINYINT UNSIGNED NOT NULL,
    basis ENUM('FSC', 'POB') NOT NULL,
    fsc_or_place_of_birth VARCHAR(128) NOT NULL,
    visa_class VARCHAR(64) NOT NULL,
    issuances INT UNSIGNED NOT NULL,
    source_file VARCHAR(255) NOT NULL,
    PRIMARY KEY (stg_dos_iv_id),
    UNIQUE KEY uq_stg_dos_iv_source_grain (
        source_file,
        year,
        month,
        basis,
        fsc_or_place_of_birth,
        visa_class
    ),
    KEY idx_stg_dos_iv_place_year_month (
        fsc_or_place_of_birth,
        year,
        month
    ),
    KEY idx_stg_dos_iv_visa_class_year_month (visa_class, year, month),
    KEY idx_stg_dos_iv_basis_year_month (basis, year, month),
    CONSTRAINT chk_stg_dos_iv_month CHECK (month BETWEEN 1 AND 12)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;