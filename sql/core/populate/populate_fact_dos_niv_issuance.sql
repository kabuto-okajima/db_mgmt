/*
Populate fact_dos_niv_issuance from DOS NIV staging data.

Design notes:
- Resolve source-side nationality labels through map_country_label.
- Aggregate after canonicalization because multiple source-side labels may
  resolve to the same canonical country.
- Keep source_file only in staging as lineage metadata.
*/

INSERT IGNORE INTO fact_dos_niv_issuance (
    year,
    month,
    country_id,
    visa_class_niv_id,
    issuances
)
SELECT
    s.year,
    s.month,
    mcl.country_id,
    dvcn.visa_class_niv_id,
    SUM(s.issuances) AS issuances
FROM stg_dos_niv AS s
INNER JOIN dim_visa_class_niv AS dvcn
    ON dvcn.visa_class_code = TRIM(s.visa_class)
INNER JOIN map_country_label AS mcl
    ON mcl.source_system = 'dos_niv'
   AND mcl.source_country_label = TRIM(s.nationality)
   AND mcl.country_id IS NOT NULL
WHERE TRIM(s.nationality) <> ''
  AND TRIM(s.visa_class) <> ''
GROUP BY
    s.year,
    s.month,
    mcl.country_id,
    dvcn.visa_class_niv_id;