/*
DOS NIV-only analysis examples.

Purpose:
- Provide easy-to-read example queries for analyzing DOS NIV issuance.
- Assume fact_dos_niv_issuance has already been created and populated.
- Start with simple monthly comparisons, then move to rankings.

Notes:
- These queries use only the DOS NIV fact and its related dimensions.
- They are intended for manual exploration in MySQL.
*/

USE db_mgmt;
SET NAMES utf8mb4;

/* ------------------------------------------------------------
Example 1
Monthly total NIV issuances by nationality.
A basic query to see which countries have the largest volume.
------------------------------------------------------------ */
SELECT
    dc.country_name,
    f.year,
    f.month,
    SUM(f.issuances) AS total_issuances
FROM fact_dos_niv_issuance AS f
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
Compare monthly F1 and B1/B2 issuance trends for
India, China, and Brazil.
------------------------------------------------------------ */
SELECT
    dc.country_name,
    dvcn.visa_class_code,
    f.year,
    f.month,
    SUM(f.issuances) AS total_issuances
FROM fact_dos_niv_issuance AS f
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
INNER JOIN dim_visa_class_niv AS dvcn
    ON dvcn.visa_class_niv_id = f.visa_class_niv_id
WHERE dc.country_name IN ('India', 'China', 'Brazil')
  AND dvcn.visa_class_code IN ('F1', 'B1/B2')
GROUP BY
    dc.country_name,
    dvcn.visa_class_code,
    f.year,
    f.month
ORDER BY
    dc.country_name,
    dvcn.visa_class_code,
    f.year,
    f.month;

/* ------------------------------------------------------------
Example 3
Top NIV classes for one nationality across the full period.
Useful for understanding the class mix of a single country.
------------------------------------------------------------ */
SELECT
    dvcn.visa_class_code,
    SUM(f.issuances) AS total_issuances
FROM fact_dos_niv_issuance AS f
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
INNER JOIN dim_visa_class_niv AS dvcn
    ON dvcn.visa_class_niv_id = f.visa_class_niv_id
WHERE dc.country_name = 'Japan'
GROUP BY
    dvcn.visa_class_code
ORDER BY
    total_issuances DESC,
    dvcn.visa_class_code
LIMIT 10;

/* ------------------------------------------------------------
Example 4
Top nationalities for one NIV class across the full period.
Useful for identifying which countries dominate a class such as F1.
------------------------------------------------------------ */
SELECT
    dc.country_name,
    SUM(f.issuances) AS total_issuances
FROM fact_dos_niv_issuance AS f
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
INNER JOIN dim_visa_class_niv AS dvcn
    ON dvcn.visa_class_niv_id = f.visa_class_niv_id
WHERE dvcn.visa_class_code = 'F1'
GROUP BY
    dc.country_name
ORDER BY
    total_issuances DESC,
    dc.country_name
LIMIT 10;

/* ------------------------------------------------------------
Example 5
Monthly class mix for one nationality.
This shows how issuance composition changes over time.
------------------------------------------------------------ */
SELECT
    f.year,
    f.month,
    dvcn.visa_class_code,
    SUM(f.issuances) AS total_issuances
FROM fact_dos_niv_issuance AS f
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
INNER JOIN dim_visa_class_niv AS dvcn
    ON dvcn.visa_class_niv_id = f.visa_class_niv_id
WHERE dc.country_name = 'China'
GROUP BY
    f.year,
    f.month,
    dvcn.visa_class_code
ORDER BY
    f.year,
    f.month,
    total_issuances DESC,
    dvcn.visa_class_code;

/* ------------------------------------------------------------
Example 6
Year-over-year monthly trend for one nationality and one class.
This is a compact trend query for a specific analytical slice.
------------------------------------------------------------ */
SELECT
    f.year,
    f.month,
    SUM(f.issuances) AS total_issuances
FROM fact_dos_niv_issuance AS f
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
INNER JOIN dim_visa_class_niv AS dvcn
    ON dvcn.visa_class_niv_id = f.visa_class_niv_id
WHERE dc.country_name = 'Brazil'
  AND dvcn.visa_class_code = 'B1/B2'
GROUP BY
    f.year,
    f.month
ORDER BY
    f.year,
    f.month;