/*
Populate fact_ohss_state_year_population from OHSS staging data.

Design notes:
- Resolve state through the canonical dimension.
- Deduplicate the repeated staging population values down to the
  canonical state x year grain.
- Keep source_file only in staging as lineage metadata.
*/

INSERT IGNORE INTO fact_ohss_state_year_population (
    state_id,
    year,
    population
)
SELECT
    ds.state_id,
    s.year,
    MAX(s.population) AS population
FROM stg_ohss AS s
INNER JOIN dim_state AS ds
    ON ds.state_name = TRIM(s.state)
WHERE TRIM(s.state) <> ''
GROUP BY
    ds.state_id,
    s.year
HAVING COUNT(DISTINCT s.population) <= 1;
