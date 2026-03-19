/*
OHSS state metric fact table.

Design notes:
- Keep the grain at state x year x metric.
- Keep only metric values here; state-year population lives in a
  separate OHSS fact table.
- metric_id references the canonical metric dimension at the
  (metric_name, measure_type) grain.
*/

CREATE TABLE fact_ohss_state_metric (
    ohss_fact_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    state_id SMALLINT UNSIGNED NOT NULL,
    year SMALLINT UNSIGNED NOT NULL,
    metric_id SMALLINT UNSIGNED NOT NULL,
    metric_value DECIMAL(18, 6) NULL,
    PRIMARY KEY (ohss_fact_id),
    UNIQUE KEY uq_fact_ohss_state_metric_grain (
        state_id,
        year,
        metric_id
    ),
    KEY idx_fact_ohss_state_metric_state_year (state_id, year),
    KEY idx_fact_ohss_state_metric_metric_year (metric_id, year),
    CONSTRAINT fk_fact_ohss_state_metric_state
        FOREIGN KEY (state_id) REFERENCES dim_state (state_id),
    CONSTRAINT fk_fact_ohss_state_metric_metric
        FOREIGN KEY (metric_id) REFERENCES dim_ohss_metric (metric_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
