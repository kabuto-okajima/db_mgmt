/*
DOS NIV issuance fact table.

Design notes:
- Keep the grain at year x month x canonical country x NIV visa class.
- Use a unique key at the canonical business grain.
- Keep the visa class in a separate dimension because NIV and IV codes
  can overlap semantically.
*/

CREATE TABLE fact_dos_niv_issuance (
    dos_niv_fact_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    year SMALLINT UNSIGNED NOT NULL,
    month TINYINT UNSIGNED NOT NULL,
    country_id SMALLINT UNSIGNED NOT NULL,
    visa_class_niv_id SMALLINT UNSIGNED NOT NULL,
    issuances INT UNSIGNED NOT NULL,
    PRIMARY KEY (dos_niv_fact_id),
    UNIQUE KEY uq_fact_dos_niv_issuance_grain (
        year,
        month,
        country_id,
        visa_class_niv_id
    ),
    KEY idx_fact_dos_niv_country_year_month (country_id, year, month),
    KEY idx_fact_dos_niv_visa_year_month (visa_class_niv_id, year, month),
    CONSTRAINT fk_fact_dos_niv_issuance_country
        FOREIGN KEY (country_id) REFERENCES dim_country (country_id),
    CONSTRAINT fk_fact_dos_niv_issuance_visa_class
        FOREIGN KEY (visa_class_niv_id)
        REFERENCES dim_visa_class_niv (visa_class_niv_id),
    CONSTRAINT chk_fact_dos_niv_issuance_month CHECK (month BETWEEN 1 AND 12)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;