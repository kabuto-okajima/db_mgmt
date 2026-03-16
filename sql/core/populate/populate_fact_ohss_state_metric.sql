/*
Populate fact_ohss_state_metric from OHSS staging data.

Design notes:
- Resolve state and metric through the canonical dimensions.
- Keep population because the current core schema does not yet have a
  separate state-year table to store it.
- Keep source_file only in staging as lineage metadata.
*/

INSERT IGNORE INTO fact_ohss_state_metric (
    state_id,
    year,
    population,
    metric_id,
    metric_value
)
SELECT DISTINCT
    ds.state_id,
    s.year,
    s.population,
    dom.metric_id,
    s.metric_value
FROM stg_ohss AS s
INNER JOIN dim_state AS ds
    ON ds.state_name = TRIM(s.state)
INNER JOIN dim_ohss_metric AS dom
    ON dom.metric_name = TRIM(s.metric_name)
   AND dom.measure_type = TRIM(s.measure_type)
WHERE TRIM(s.state) <> '';