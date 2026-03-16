/*
    Populate dim_state from distinct state values found in staging tables.

    State names are collected from all relevant sources and inserted once
    into the canonical state dimension.
*/

INSERT IGNORE INTO dim_state (state_name)
SELECT DISTINCT x.state_name
FROM (
    SELECT TRIM(state) AS state_name
    FROM stg_cbp
    WHERE state IS NOT NULL
      AND TRIM(state) <> ''

    UNION

    SELECT TRIM(state) AS state_name
    FROM stg_ohss
    WHERE state IS NOT NULL
      AND TRIM(state) <> '' -- IGNORE state values that are NULL or empty after trimming
) AS x;