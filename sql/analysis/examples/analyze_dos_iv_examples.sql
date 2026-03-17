/*
DOS IV-only analysis examples.

Purpose:
- Provide easy-to-read example queries for analyzing DOS IV issuance.
- Assume fact_dos_iv_issuance has already been created and populated.
- Start with simple comparisons, then move to rankings and basis splits.

Notes:
- These queries use only the DOS IV fact and its related dimensions.
- They are intended for manual exploration in MySQL.
*/

USE db_mgmt;
SET NAMES utf8mb4;

/* ------------------------------------------------------------
Example 1
Monthly total IV issuances by country.
A basic query to see which countries have the largest volume.
------------------------------------------------------------ */
SELECT
    dc.country_name,
    f.year,
    f.month,
    SUM(f.issuances) AS total_issuances
FROM fact_dos_iv_issuance AS f
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
GROUP BY
    dc.country_name,
    f.year,
    f.month
ORDER BY
    f.year,
    f.month,
    total_issuances DESC,
    dc.country_name;

/* ------------------------------------------------------------
Example 2
README-style example:
Compare immigrant visa issuance across family-sponsored classes
and employment-based classes for Japan, China, and South Korea.
------------------------------------------------------------ */
SELECT
    dc.country_name,
    dvciv.visa_class_code,
    f.year,
    f.month,
    SUM(f.issuances) AS total_issuances
FROM fact_dos_iv_issuance AS f
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
INNER JOIN dim_visa_class_iv AS dvciv
    ON dvciv.visa_class_iv_id = f.visa_class_iv_id
WHERE dc.country_name IN ('Japan', 'China', 'South Korea')
  AND dvciv.visa_class_code IN (
      'F1', 'F2A', 'F2B', 'F3', 'F4',
      'E1', 'E2', 'E3', 'E4', 'E5'
  )
GROUP BY
    dc.country_name,
    dvciv.visa_class_code,
    f.year,
    f.month
ORDER BY
    dc.country_name,
    dvciv.visa_class_code,
    f.year,
    f.month;

/* ------------------------------------------------------------
Example 3
Top IV classes for one country across the full period.
Useful for understanding the class mix of a single country.
------------------------------------------------------------ */
SELECT
    dvciv.visa_class_code,
    SUM(f.issuances) AS total_issuances
FROM fact_dos_iv_issuance AS f
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
INNER JOIN dim_visa_class_iv AS dvciv
    ON dvciv.visa_class_iv_id = f.visa_class_iv_id
WHERE dc.country_name = 'China'
GROUP BY
    dvciv.visa_class_code
ORDER BY
    total_issuances DESC,
    dvciv.visa_class_code
LIMIT 10;

/* ------------------------------------------------------------
Example 4
Top countries for one IV class across the full period.
Useful for identifying which countries dominate a class such as IR1.
------------------------------------------------------------ */
SELECT
    dc.country_name,
    SUM(f.issuances) AS total_issuances
FROM fact_dos_iv_issuance AS f
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
INNER JOIN dim_visa_class_iv AS dvciv
    ON dvciv.visa_class_iv_id = f.visa_class_iv_id
WHERE dvciv.visa_class_code = 'IR1'
GROUP BY
    dc.country_name
ORDER BY
    total_issuances DESC,
    dc.country_name
LIMIT 10;

/* ------------------------------------------------------------
Example 5
Basis comparison for one country and one IV class.
This shows whether FSC and POB produce different counts.
------------------------------------------------------------ */
SELECT
    f.basis,
    f.year,
    f.month,
    SUM(f.issuances) AS total_issuances
FROM fact_dos_iv_issuance AS f
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
INNER JOIN dim_visa_class_iv AS dvciv
    ON dvciv.visa_class_iv_id = f.visa_class_iv_id
WHERE dc.country_name = 'Japan'
  AND dvciv.visa_class_code = 'F1'
GROUP BY
    f.basis,
    f.year,
    f.month
ORDER BY
    f.basis,
    f.year,
    f.month;

/* ------------------------------------------------------------
Example 6
Monthly class mix for one country under one basis.
This makes the IV basis dimension easier to interpret.
------------------------------------------------------------ */
SELECT
    f.year,
    f.month,
    dvciv.visa_class_code,
    SUM(f.issuances) AS total_issuances
FROM fact_dos_iv_issuance AS f
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
INNER JOIN dim_visa_class_iv AS dvciv
    ON dvciv.visa_class_iv_id = f.visa_class_iv_id
WHERE dc.country_name = 'South Korea'
  AND f.basis = 'FSC'
GROUP BY
    f.year,
    f.month,
    dvciv.visa_class_code
ORDER BY
    f.year,
    f.month,
    total_issuances DESC,
    dvciv.visa_class_code;