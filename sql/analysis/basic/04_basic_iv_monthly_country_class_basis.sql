/*
Basic IV query.

Purpose:
- Explain the country x month x basis x IV class structure of the DOS IV
  fact.
- Show monthly issuances for one IV class with basis preserved.
*/

USE db_mgmt;
SET NAMES utf8mb4;

SET @iv_visa_class_code = 'IR1';
SET @start_yyyymm = 202301;
SET @end_yyyymm = 202512;

SELECT
    f.basis,
    f.year,
    f.month,
    dc.country_name,
    SUM(f.issuances) AS total_issuances
FROM fact_dos_iv_issuance AS f
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
INNER JOIN dim_visa_class_iv AS dvciv
    ON dvciv.visa_class_iv_id = f.visa_class_iv_id
WHERE dvciv.visa_class_code = @iv_visa_class_code
  AND (f.year * 100 + f.month) BETWEEN @start_yyyymm AND @end_yyyymm
GROUP BY
    f.basis,
    f.year,
    f.month,
    dc.country_name
ORDER BY
    f.basis,
    f.year,
    f.month,
    total_issuances DESC,
    dc.country_name;
