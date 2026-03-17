/*
Story query 2.

Purpose:
- Break down encounters for one selected country in one selected state.
*/

USE db_mgmt;
SET NAMES utf8mb4;

SET @state_name = 'Texas';
SET @country_name = 'Venezuela';
SET @start_yyyymm = 202301;
SET @end_yyyymm = 202512;

SELECT
    ddg.demographic_group_name,
    f.title_of_authority,
    SUM(f.encounter_count) AS total_encounters
FROM fact_cbp_encounter AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
INNER JOIN dim_demographic_group AS ddg
    ON ddg.demographic_group_id = f.demographic_group_id
WHERE ds.state_name = @state_name
  AND dc.country_name = @country_name
  AND (f.year * 100 + f.month) BETWEEN @start_yyyymm AND @end_yyyymm
GROUP BY
    ddg.demographic_group_name,
    f.title_of_authority
ORDER BY
    total_encounters DESC,
    ddg.demographic_group_name,
    f.title_of_authority;