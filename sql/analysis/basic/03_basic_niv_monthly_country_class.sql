/*
Basic NIV query.

Purpose:
- Explain the country x month x NIV class structure of the DOS NIV fact.
- Show monthly issuances for one visa class across countries.
*/

USE db_mgmt;
SET NAMES utf8mb4;

SET @visa_class_code = 'F1';
SET @start_yyyymm = 202301;
SET @end_yyyymm = 202508;

SELECT
    f.year,
    f.month,
    dc.country_name,
    SUM(f.issuances) AS total_issuances
FROM fact_dos_niv_issuance AS f
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
INNER JOIN dim_visa_class_niv AS dvcn
    ON dvcn.visa_class_niv_id = f.visa_class_niv_id
WHERE dvcn.visa_class_code = @visa_class_code
  AND (f.year * 100 + f.month) BETWEEN @start_yyyymm AND @end_yyyymm
GROUP BY
    f.year,
    f.month,
    dc.country_name
ORDER BY
    f.year,
    f.month,
    total_issuances DESC,
    dc.country_name;
