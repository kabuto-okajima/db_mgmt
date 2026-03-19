/*
OHSS state-year population fact table.

Design notes:
- Keep the grain at state x year.
- Store population separately from metric values so the OHSS core schema
  matches the functional dependency (state_id, year) -> population.
*/

CREATE TABLE fact_ohss_state_year_population (
    ohss_state_year_population_fact_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    state_id SMALLINT UNSIGNED NOT NULL,
    year SMALLINT UNSIGNED NOT NULL,
    population INT UNSIGNED NULL,
    PRIMARY KEY (ohss_state_year_population_fact_id),
    UNIQUE KEY uq_fact_ohss_state_year_population_grain (
        state_id,
        year
    ),
    KEY idx_fact_ohss_state_year_population_year_state (year, state_id),
    CONSTRAINT fk_fact_ohss_state_year_population_state
        FOREIGN KEY (state_id) REFERENCES dim_state (state_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
