/*
Story query 3.

Purpose:
- Show key OHSS outcomes for one state over a selected year range.
*/

USE db_mgmt;
SET NAMES utf8mb4;

SET @state_name = 'Texas';
SET @start_year = 2023;
SET @end_year = 2025;

SELECT
    f.year,
    dom.metric_name,
    dom.measure_type,
    CASE
        WHEN dom.measure_type = 'per_million' THEN ROUND(f.metric_value, 2)
        ELSE ROUND(f.metric_value, 0)
    END AS metric_value
FROM fact_ohss_state_metric AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_ohss_metric AS dom
    ON dom.metric_id = f.metric_id
WHERE ds.state_name = @state_name
  AND f.year BETWEEN @start_year AND @end_year
  AND dom.metric_name IN ('naturalizations', 'refugees', 'asylees')
  AND dom.measure_type IN ('total', 'per_million')
ORDER BY
    f.year,
    dom.metric_name,
    dom.measure_type;