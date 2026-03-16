/*
    Populate dim_ohss_metric from OHSS staging data.

    Each distinct (metric_name, measure_type) pair is inserted once
    into the OHSS metric dimension.
*/

INSERT IGNORE INTO dim_ohss_metric (metric_name, measure_type) -- IGNORE duplicate metric name and measure type combinations
SELECT DISTINCT
    TRIM(metric_name) AS metric_name,
    TRIM(measure_type) AS measure_type
FROM stg_ohss
WHERE metric_name IS NOT NULL
  AND TRIM(metric_name) <> ''
  AND measure_type IS NOT NULL
  AND TRIM(measure_type) <> ''; -- IGNORE records where metric name or measure type is NULL or empty after trimming