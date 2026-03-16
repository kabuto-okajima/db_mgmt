/*
    Populate dim_demographic_group from CBP staging data.

    Each distinct demographic group label is inserted once into the
    canonical demographic group dimension.
*/

INSERT IGNORE INTO dim_demographic_group (demographic_group_name) -- IGNORE duplicate demographic groups
SELECT DISTINCT TRIM(demographic_group) AS demographic_group_name
FROM stg_cbp
WHERE demographic_group IS NOT NULL
  AND TRIM(demographic_group) <> ''; -- IGNORE demographic groups that are NULL or empty after trimming