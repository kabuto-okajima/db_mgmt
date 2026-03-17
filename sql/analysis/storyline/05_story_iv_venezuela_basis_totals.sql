/*
Story query 5.

Purpose:
- Show IV issuances for one selected country by month and basis.
*/

USE db_mgmt;
SET NAMES utf8mb4;

SET @country_name = 'Venezuela';
SET @start_yyyymm = 202301;
SET @end_yyyymm = 202508;

SELECT
    f.year,
    f.month,
    f.basis,
    SUM(f.issuances) AS total_issuances
FROM fact_dos_iv_issuance AS f
INNER JOIN dim_country AS dc
    ON dc.country_id = f.country_id
WHERE dc.country_name = @country_name
  AND (f.year * 100 + f.month) BETWEEN @start_yyyymm AND @end_yyyymm
GROUP BY
    f.year,
    f.month,
    f.basis
ORDER BY
    f.year,
    f.month,
    f.basis;
