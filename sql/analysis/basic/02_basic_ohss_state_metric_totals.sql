/*
Basic OHSS query.

Purpose:
- Explain the state x year x metric structure of the OHSS metric fact.
- Show annual totals for major state-level immigration outcomes.
*/

USE db_mgmt;
SET NAMES utf8mb4;

SELECT
    ds.state_name,
    f.year,
    dom.metric_name,
    CAST(ROUND(f.metric_value, 0) AS UNSIGNED) AS metric_total
FROM fact_ohss_state_metric AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_ohss_metric AS dom
    ON dom.metric_id = f.metric_id
WHERE dom.metric_name IN (
        'naturalizations',
        'refugees',
        'asylees',
        'nonimmigrants'
    )
  AND dom.measure_type = 'total'
ORDER BY
    f.year,
    ds.state_name,
    dom.metric_name;
