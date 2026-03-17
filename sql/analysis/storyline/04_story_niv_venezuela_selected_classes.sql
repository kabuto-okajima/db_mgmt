/*
Story query 4.

Purpose:
- Show NIV issuances for one selected country and a few visa classes.
*/

USE db_mgmt;
SET NAMES utf8mb4;

SET @country_name = 'Venezuela';
SET @start_yyyymm = 202301;
SET @end_yyyymm = 202512;

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
WHERE dc.country_name = @country_name
  AND dvcn.visa_class_code IN ('F1', 'B1/B2')
  AND (f.year * 100 + f.month) BETWEEN @start_yyyymm AND @end_yyyymm
GROUP BY
    f.year,
    f.month,
    dvcn.visa_class_code
ORDER BY
    f.year,
    f.month,
    dvcn.visa_class_code;