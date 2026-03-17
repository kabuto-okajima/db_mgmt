/*
CBP-only analysis examples.

Purpose:
- Provide easy-to-read example queries for analyzing CBP encounters only.
- Assume fact_cbp_encounter has already been created and populated.
- Keep the examples simple first, then move to slightly richer breakdowns.

Notes:
- These queries use only the CBP fact and its related dimensions.
- They are intended for manual exploration in MySQL, not for ETL orchestration.
*/

USE db_mgmt;
SET NAMES utf8mb4;

/* ------------------------------------------------------------
Example 1
Monthly total encounters by state.
This is the most basic "where is encounter volume concentrated?" query.
------------------------------------------------------------ */
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
LIMIT 1000;

/* ------------------------------------------------------------
Example 2
README-style example:
Compare monthly encounters involving Venezuelan nationals
in Texas versus Arizona.
------------------------------------------------------------ */
SELECT
    f.year,
    f.month,
    ds.state_name,
    SUM(f.encounter_count) AS venezuelan_encounters
FROM fact_cbp_encounter AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
WHERE ds.state_name IN ('Texas', 'Arizona')
  AND dc.country_name = 'Venezuela'
GROUP BY
    ds.state_name,
    f.year,
    f.month
ORDER BY
    f.year,
    f.month,
    ds.state_name;

/* ------------------------------------------------------------
Example 3
Top nationalities in a given state across the full period.
This helps identify which citizenship groups dominate encounters
in a specific state.
------------------------------------------------------------ */
SELECT
    dc.country_name,
    SUM(f.encounter_count) AS total_encounters
FROM fact_cbp_encounter AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
WHERE ds.state_name = 'Texas'
GROUP BY
    dc.country_name
ORDER BY
    total_encounters DESC,
    dc.country_name
LIMIT 10;

/* ------------------------------------------------------------
Example 4
Demographic composition for one state by month.
This shows whether encounter patterns differ across demographic groups.
------------------------------------------------------------ */
SELECT
    f.year,
    f.month,
    ddg.demographic_group_name,
    SUM(f.encounter_count) AS total_encounters
FROM fact_cbp_encounter AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_demographic_group AS ddg
    ON ddg.demographic_group_id = f.demographic_group_id
WHERE ds.state_name = 'Texas'
GROUP BY
    f.year,
    f.month,
    ddg.demographic_group_name
ORDER BY
    f.year,
    f.month,
    total_encounters DESC,
    ddg.demographic_group_name;

/* ------------------------------------------------------------
Example 5
Authority-type breakdown for a nationality within one state.
This is useful when checking whether the same nationality is associated
with different enforcement authorities.
------------------------------------------------------------ */
SELECT
    f.title_of_authority,
    SUM(f.encounter_count) AS total_encounters
FROM fact_cbp_encounter AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
WHERE ds.state_name = 'Texas'
  AND dc.country_name = 'Venezuela'
GROUP BY
    f.title_of_authority
ORDER BY
    total_encounters DESC,
    f.title_of_authority;

/* ------------------------------------------------------------
Example 6
Land border region breakdown for one state and one nationality.
This helps show where encounters are concentrated geographically
inside the CBP source semantics.
------------------------------------------------------------ */
SELECT
    f.land_border_region,
    SUM(f.encounter_count) AS total_encounters
FROM fact_cbp_encounter AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
WHERE ds.state_name = 'Texas'
  AND dc.country_name = 'Venezuela'
GROUP BY
    f.land_border_region
ORDER BY
    total_encounters DESC,
    f.land_border_region;

/* ------------------------------------------------------------
Example 7
Top states for a nationality across the whole period.
This is a simple ranking query for one canonical country.
------------------------------------------------------------ */
SELECT
    ds.state_name,
    SUM(f.encounter_count) AS total_encounters
FROM fact_cbp_encounter AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
WHERE dc.country_name = 'Venezuela'
GROUP BY
    ds.state_name
ORDER BY
    total_encounters DESC,
    ds.state_name
LIMIT 10;

/* ------------------------------------------------------------
Example 8
Year-over-year monthly trend for one state and one nationality.
This is useful for checking whether the same calendar month behaves
differently across years.
------------------------------------------------------------ */
SELECT
    f.year,
    f.month,
    SUM(f.encounter_count) AS total_encounters
FROM fact_cbp_encounter AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
WHERE ds.state_name = 'Texas'
  AND dc.country_name = 'Venezuela'
GROUP BY
    f.year,
    f.month
ORDER BY
    f.year,
    f.month;