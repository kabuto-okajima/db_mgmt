/*
DOS IV issuance fact table.

Design notes:
- Keep the grain at year x month x basis x canonical country x IV visa
  class.
- basis must remain in the fact because FSC and POB represent different
  source semantics.
- Use a unique key at the canonical business grain.
*/

CREATE TABLE fact_dos_iv_issuance (
    dos_iv_fact_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    year SMALLINT UNSIGNED NOT NULL,
    month TINYINT UNSIGNED NOT NULL,
    basis ENUM('FSC', 'POB') NOT NULL,
    country_id SMALLINT UNSIGNED NOT NULL,
    visa_class_iv_id SMALLINT UNSIGNED NOT NULL,
    issuances INT UNSIGNED NOT NULL,
    PRIMARY KEY (dos_iv_fact_id),
    UNIQUE KEY uq_fact_dos_iv_issuance_grain (
        year,
        month,
        basis,
        country_id,
        visa_class_iv_id
    ),
    KEY idx_fact_dos_iv_country_year_month (country_id, year, month),
    KEY idx_fact_dos_iv_visa_year_month (visa_class_iv_id, year, month),
    KEY idx_fact_dos_iv_basis_year_month (basis, year, month),
    CONSTRAINT fk_fact_dos_iv_issuance_country
        FOREIGN KEY (country_id) REFERENCES dim_country (country_id),
    CONSTRAINT fk_fact_dos_iv_issuance_visa_class
        FOREIGN KEY (visa_class_iv_id)
        REFERENCES dim_visa_class_iv (visa_class_iv_id),
    CONSTRAINT chk_fact_dos_iv_issuance_month CHECK (month BETWEEN 1 AND 12)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;