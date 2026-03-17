/*
Story query 6.

Purpose:
- Give one compact cross-dataset summary for one state and one country.
*/

USE db_mgmt;
SET NAMES utf8mb4;

SET @state_name = 'Texas';
SET @country_name = 'Venezuela';
SET @start_yyyymm = 202301;
SET @end_yyyymm = 202508;
SET @start_year = 2023;
SET @end_year = 2023;

SELECT
    'CBP' AS source_name,
    CONCAT(f.year, '-', LPAD(f.month, 2, '0')) AS period_label,
    'encounters' AS metric_name,
    SUM(f.encounter_count) AS metric_value
FROM fact_cbp_encounter AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
WHERE ds.state_name = @state_name
  AND dc.country_name = @country_name
  AND (f.year * 100 + f.month) BETWEEN @start_yyyymm AND @end_yyyymm
GROUP BY
    f.year,
    f.month

UNION ALL

SELECT
    'OHSS' AS source_name,
    CAST(f.year AS CHAR) AS period_label,
    dom.metric_name AS metric_name,
    ROUND(f.metric_value, 0) AS metric_value
FROM fact_ohss_state_metric AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_ohss_metric AS dom
    ON dom.metric_id = f.metric_id
WHERE ds.state_name = @state_name
  AND f.year BETWEEN @start_year AND @end_year
  AND dom.metric_name IN ('naturalizations', 'refugees')
  AND dom.measure_type = 'total'

UNION ALL

SELECT
    'NIV' AS source_name,
    CONCAT(f.year, '-', LPAD(f.month, 2, '0')) AS period_label,
    'issuances' AS metric_name,
    SUM(f.issuances) AS metric_value
FROM fact_dos_niv_issuance AS f
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
WHERE dc.country_name = @country_name
  AND (f.year * 100 + f.month) BETWEEN @start_yyyymm AND @end_yyyymm
GROUP BY
    f.year,
    f.month

UNION ALL

SELECT
    'IV' AS source_name,
    CONCAT(f.year, '-', LPAD(f.month, 2, '0')) AS period_label,
    'issuances' AS metric_name,
    SUM(f.issuances) AS metric_value
FROM fact_dos_iv_issuance AS f
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
WHERE dc.country_name = @country_name
  AND (f.year * 100 + f.month) BETWEEN @start_yyyymm AND @end_yyyymm
GROUP BY
    f.year,
    f.month

ORDER BY
    source_name,
    period_label,
    metric_name;
