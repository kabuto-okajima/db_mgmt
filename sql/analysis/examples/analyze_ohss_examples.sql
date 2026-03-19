/*
OHSS-only analysis examples.

Purpose:
- Provide easy-to-read example queries for analyzing OHSS state outcomes.
- Assume the OHSS fact tables have already been created and populated.
- Start with simple state-year comparisons, then move to rankings and
  rate-based interpretation.

Notes:
- These queries use the OHSS fact tables and their related dimensions.
- They are intended for manual exploration in MySQL.
*/

USE db_mgmt;
SET NAMES utf8mb4;

/* ------------------------------------------------------------
Example 1
Annual total naturalizations by state.
This is the most basic OHSS query.
------------------------------------------------------------ */
SELECT
    ds.state_name,
    f.year,
    CAST(f.metric_value AS UNSIGNED) AS naturalizations_total
FROM fact_ohss_state_metric AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_ohss_metric AS dom
    ON dom.metric_id = f.metric_id
WHERE dom.metric_name = 'naturalizations'
  AND dom.measure_type = 'total'
ORDER BY
    f.year,
    naturalizations_total DESC,
    ds.state_name;

/* ------------------------------------------------------------
Example 2
README-style example:
Compare California, Florida, and New York in terms of
annual naturalizations and refugee arrivals.
------------------------------------------------------------ */
SELECT
    ds.state_name,
    f.year,
    dom.metric_name,
    CAST(f.metric_value AS UNSIGNED)
FROM fact_ohss_state_metric AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_ohss_metric AS dom
    ON dom.metric_id = f.metric_id
WHERE ds.state_name IN ('California', 'Florida', 'New York')
  AND dom.metric_name IN ('naturalizations', 'refugees')
  AND dom.measure_type = 'total'
ORDER BY
    ds.state_name,
    dom.metric_name,
    f.year;

/* ------------------------------------------------------------
Example 3
Top states for refugee arrivals in one year.
This is a simple ranking query for one OHSS metric.
------------------------------------------------------------ */
SELECT
    ds.state_name,
    CAST(f.metric_value AS UNSIGNED) AS refugees_total
FROM fact_ohss_state_metric AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_ohss_metric AS dom
    ON dom.metric_id = f.metric_id
WHERE dom.metric_name = 'refugees'
  AND dom.measure_type = 'total'
  AND f.year = 2023
ORDER BY
    refugees_total DESC,
    ds.state_name
LIMIT 10;

/* ------------------------------------------------------------
Example 4
Trend of multiple OHSS outcomes for one state.
This helps show how a state's profile changes over time.
------------------------------------------------------------ */
SELECT
    f.year,
    dom.metric_name,
    CAST(f.metric_value AS UNSIGNED)
FROM fact_ohss_state_metric AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_ohss_metric AS dom
    ON dom.metric_id = f.metric_id
WHERE ds.state_name = 'California'
  AND dom.metric_name IN (
      'lawful_permanent_residents',
      'naturalizations',
      'refugees',
      'asylees'
  )
  AND dom.measure_type = 'total'
ORDER BY
    dom.metric_name,
    f.year;

/* ------------------------------------------------------------
Example 5
Total versus per-million interpretation for one metric.
This is useful when comparing large and small states more fairly.
------------------------------------------------------------ */
SELECT
    ds.state_name,
    f.year,
    dom.measure_type,
    f.metric_value
FROM fact_ohss_state_metric AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_ohss_metric AS dom
    ON dom.metric_id = f.metric_id
WHERE ds.state_name IN ('California', 'Florida', 'New York')
  AND dom.metric_name = 'naturalizations'
  AND dom.measure_type IN ('total', 'per_million')
ORDER BY
    ds.state_name,
    f.year,
    dom.measure_type;

/* ------------------------------------------------------------
Example 6
Check ranking positions directly from the OHSS rank measures.
This uses the dataset's own rank variables rather than recomputing them.
------------------------------------------------------------ */
SELECT
    ds.state_name,
    f.year,
    CAST(f.metric_value AS UNSIGNED) AS naturalizations_rank
FROM fact_ohss_state_metric AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_ohss_metric AS dom
    ON dom.metric_id = f.metric_id
WHERE ds.state_name IN ('California', 'Florida', 'New York')
  AND dom.metric_name = 'naturalizations'
  AND dom.measure_type = 'rank'
ORDER BY
    f.year,
    naturalizations_rank,
    ds.state_name;

/* ------------------------------------------------------------
Example 7
Population context for one state across years.
This reads from the separate OHSS state-year population fact table.
------------------------------------------------------------ */
SELECT
    ds.state_name,
    fp.year,
    fp.population
FROM fact_ohss_state_year_population AS fp
INNER JOIN dim_state AS ds
    ON ds.state_id = fp.state_id
WHERE ds.state_name = 'Texas'
ORDER BY
    fp.year;

/* ------------------------------------------------------------
Example 8
Compare total and per-million refugee arrivals for one year.
This highlights the difference between volume and rate.
------------------------------------------------------------ */
SELECT
    ds.state_name,
    dom.measure_type,
    f.metric_value
FROM fact_ohss_state_metric AS f
INNER JOIN dim_state AS ds
    ON ds.state_id = f.state_id
INNER JOIN dim_ohss_metric AS dom
    ON dom.metric_id = f.metric_id
WHERE ds.state_name IN ('California', 'Florida', 'New York')
  AND dom.metric_name = 'refugees'
  AND dom.measure_type IN ('total', 'per_million')
  AND f.year = 2023
ORDER BY
    ds.state_name,
    dom.measure_type;
