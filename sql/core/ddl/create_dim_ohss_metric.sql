/*
OHSS metric dimension at the metric_name x measure_type grain.

Design notes:
- The natural key is the pair (metric_name, measure_type).
- Keep this as a dimension so fact rows use a surrogate key and the metric
  domain stays controlled in one place.
*/

CREATE TABLE dim_ohss_metric (
    metric_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    metric_name VARCHAR(64) NOT NULL,
    measure_type VARCHAR(32) NOT NULL,
    PRIMARY KEY (metric_id),
    UNIQUE KEY uq_dim_ohss_metric_name_type (metric_name, measure_type)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;