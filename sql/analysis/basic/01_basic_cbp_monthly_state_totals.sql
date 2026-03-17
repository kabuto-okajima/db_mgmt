/*
Basic CBP query.

Purpose:
- Explain the base analytical grain of the CBP fact.
- Show monthly encounter totals by state.
*/

USE db_mgmt;
SET NAMES utf8mb4;

SELECT
    ds.state_name,
    f.year,
    f.month,
    SUM(f.encounter_count) AS total_encounters
FROM fact_cbp_encounter AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
GROUP BY
    ds.state_name,
    f.year,
    f.month
ORDER BY
    f.year,
    f.month,
    total_encounters DESC,
    ds.state_name
LIMIT 100;
