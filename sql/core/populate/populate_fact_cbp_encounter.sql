/*
Populate fact_cbp_encounter from CBP staging data.

Design notes:
- Resolve source-side nationality labels through map_country_label.
- Aggregate after canonicalization because multiple source-side labels may
  resolve to the same canonical country.
- Keep source_file only in staging as lineage metadata.
*/

INSERT IGNORE INTO fact_cbp_encounter (
    year,
    month,
    state_id,
    country_id,
    demographic_group_id,
    land_border_region,
    title_of_authority,
    encounter_count
)
SELECT
    s.year,
    s.month,
    ds.state_id,
    mcl.country_id,
    ddg.demographic_group_id,
    TRIM(s.land_border_region) AS land_border_region,
    TRIM(s.title_of_authority) AS title_of_authority,
    SUM(s.encounter_count) AS encounter_count
FROM stg_cbp AS s
INNER JOIN dim_state AS ds
    ON ds.state_name = TRIM(s.state) 
INNER JOIN dim_demographic_group AS ddg
    ON ddg.demographic_group_name = TRIM(s.demographic_group)
INNER JOIN map_country_label AS mcl
    ON mcl.source_system = 'cbp'
   AND mcl.source_country_label = TRIM(s.nationality)
   AND mcl.country_id IS NOT NULL
WHERE TRIM(s.state) <> ''
  AND TRIM(s.demographic_group) <> ''
  AND TRIM(s.nationality) <> ''
  AND TRIM(s.land_border_region) <> ''
  AND TRIM(s.title_of_authority) <> ''
GROUP BY
    s.year,
    s.month,
    ds.state_id,
    mcl.country_id,
    ddg.demographic_group_id,
    TRIM(s.land_border_region),
    TRIM(s.title_of_authority);