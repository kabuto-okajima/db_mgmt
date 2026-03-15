-- load_stg_cbp.sql
-- Source file:
--   data/staging/cbp/cbp_encounters_state_monthly.csv
-- Expected columns:
--   year, month, state, land_border_region, demographic_group,
--   nationality, nationality_raw, title_of_authority, source_file, encounter_count

USE db_mgmt;

TRUNCATE TABLE stg_cbp; 

LOAD DATA LOCAL INFILE 'data/staging/cbp/cbp_encounters_state_monthly.csv'
INTO TABLE stg_cbp
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @year,
    @month,
    @state,
    @land_border_region,
    @demographic_group,
    @nationality,
    @nationality_raw,
    @title_of_authority,
    @source_file,
    @encounter_count
)
SET
    year               = CAST(NULLIF(TRIM(@year), '') AS UNSIGNED),
    month              = CAST(NULLIF(TRIM(@month), '') AS UNSIGNED),
    state              = NULLIF(TRIM(@state), ''),
    land_border_region = NULLIF(TRIM(@land_border_region), ''),
    demographic_group  = NULLIF(TRIM(@demographic_group), ''),
    nationality        = NULLIF(TRIM(@nationality), ''),
    nationality_raw    = NULLIF(TRIM(@nationality_raw), ''),
    title_of_authority = NULLIF(TRIM(@title_of_authority), ''),
    source_file        = NULLIF(TRIM(@source_file), ''),
    encounter_count    = CAST(NULLIF(REPLACE(TRIM(@encounter_count), ',', ''), '') AS UNSIGNED);
