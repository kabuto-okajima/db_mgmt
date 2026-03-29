/*
Story query 7.

Purpose:
- Rank states by selected OHSS total metrics for one target year.
*/

USE db_mgmt;
SET NAMES utf8mb4;

SET @target_year = 2023;

SELECT
    ds.state_name,
    f.year,
    dom.metric_name,
    CAST(ROUND(SUM(f.metric_value), 0) AS UNSIGNED) AS metric_total
FROM fact_ohss_state_metric AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_ohss_metric AS dom
    ON dom.metric_id = f.metric_id
WHERE dom.metric_name IN ('naturalizations', 'refugees')
  AND dom.measure_type = 'total'
  AND f.year = @target_year
GROUP BY
    ds.state_name,
    f.year,
    dom.metric_name
ORDER BY
    dom.metric_name,
    metric_total DESC,
    ds.state_name;