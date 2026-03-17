/*
Story query 1.

Purpose:
- Find the top citizenships encountered in one state over one period.
*/

USE db_mgmt;
SET NAMES utf8mb4;

SET @state_name = 'Texas';
SET @start_yyyymm = 202301;
SET @end_yyyymm = 202512;

SELECT
    dc.country_name,
    SUM(f.encounter_count) AS total_encounters
FROM fact_cbp_encounter AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
WHERE ds.state_name = @state_name
  AND (f.year * 100 + f.month) BETWEEN @start_yyyymm AND @end_yyyymm
GROUP BY
    dc.country_name
ORDER BY
    total_encounters DESC,
    dc.country_name
LIMIT 10;