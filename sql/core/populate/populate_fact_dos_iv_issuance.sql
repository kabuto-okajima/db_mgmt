/*
Populate fact_dos_iv_issuance from DOS IV staging data.

Design notes:
- Resolve source-side FSC / place-of-birth labels through
  map_country_label.
- Aggregate after canonicalization because multiple source-side labels may
  resolve to the same canonical country.
- Keep source_file only in staging as lineage metadata.
*/

INSERT IGNORE INTO fact_dos_iv_issuance (
    year,
    month,
    basis,
    country_id,
    visa_class_iv_id,
    issuances
)
SELECT
    s.year,
    s.month,
    s.basis,
    mcl.country_id,
    dvciv.visa_class_iv_id,
    SUM(s.issuances) AS issuances
FROM stg_dos_iv AS s
INNER JOIN dim_visa_class_iv AS dvciv
    ON dvciv.visa_class_code = TRIM(s.visa_class)
INNER JOIN map_country_label AS mcl
    ON mcl.source_system = 'dos_iv'
   AND mcl.source_country_label = TRIM(s.fsc_or_place_of_birth)
   AND mcl.country_id IS NOT NULL
WHERE TRIM(s.fsc_or_place_of_birth) <> ''
  AND TRIM(s.visa_class) <> ''
GROUP BY
    s.year,
    s.month,
    s.basis,
    mcl.country_id,
    dvciv.visa_class_iv_id;