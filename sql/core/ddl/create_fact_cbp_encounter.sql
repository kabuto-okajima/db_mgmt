/*
CBP encounter fact table.

Design notes:
- Keep the grain at year x month x state x canonical country x
  demographic group x land_border_region x title_of_authority.
- Use canonical foreign keys for state, country, and demographic group.
- Keep land_border_region because it is part of the source-side
  analytical grain and is not yet represented by a separate dimension in
  the current core schema.
*/

CREATE TABLE fact_cbp_encounter (
    cbp_fact_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    year SMALLINT UNSIGNED NOT NULL,
    month TINYINT UNSIGNED NOT NULL,
    state_id SMALLINT UNSIGNED NOT NULL,
    country_id SMALLINT UNSIGNED NOT NULL,
    demographic_group_id SMALLINT UNSIGNED NOT NULL,
    land_border_region VARCHAR(64) NOT NULL,
    title_of_authority VARCHAR(64) NOT NULL,
    encounter_count INT UNSIGNED NOT NULL,
    PRIMARY KEY (cbp_fact_id),
    UNIQUE KEY uq_fact_cbp_encounter_grain (
        year,
        month,
        state_id,
        country_id,
        demographic_group_id,
        land_border_region,
        title_of_authority
    ),
    KEY idx_fact_cbp_encounter_state_year_month (state_id, year, month),
    KEY idx_fact_cbp_encounter_country_year_month (country_id, year, month),
    KEY idx_fact_cbp_encounter_demo_year_month (
        demographic_group_id,
        year,
        month
    ),
    CONSTRAINT fk_fact_cbp_encounter_state
        FOREIGN KEY (state_id) REFERENCES dim_state (state_id),
    CONSTRAINT fk_fact_cbp_encounter_country
        FOREIGN KEY (country_id) REFERENCES dim_country (country_id),
    CONSTRAINT fk_fact_cbp_encounter_demographic_group
        FOREIGN KEY (demographic_group_id)
        REFERENCES dim_demographic_group (demographic_group_id),
    CONSTRAINT chk_fact_cbp_encounter_month CHECK (month BETWEEN 1 AND 12)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;