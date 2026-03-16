/*
Canonical geography dimension for country-like entities.

Design notes:
- Store canonical geography names only.
- Do not force source-specific aliases or special buckets into this table.
- Source-specific labels belong in map_country_name.
*/

CREATE TABLE dim_country (
    country_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    country_name VARCHAR(128) NOT NULL,
    PRIMARY KEY (country_id),
    UNIQUE KEY uq_dim_country_name (country_name)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;