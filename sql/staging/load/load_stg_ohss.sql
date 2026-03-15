-- load_stg_ohss.sql
-- Source file:
--   data/staging/ohss/ohss_state_annual_long.csv
-- Expected columns:
--   state, year, population, source_file, metric_name, measure_type, metric_value

USE db_mgmt;

TRUNCATE TABLE stg_ohss;

LOAD DATA LOCAL INFILE 'data/staging/ohss/ohss_state_annual_long.csv'
INTO TABLE stg_ohss
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @state,
    @year,
    @population,
    @source_file,
    @metric_name,
    @measure_type,
    @metric_value
)
SET
    state        = NULLIF(TRIM(@state), ''),
    year         = CAST(NULLIF(TRIM(@year), '') AS UNSIGNED),
    population   = CAST(NULLIF(REPLACE(TRIM(@population), ',', ''), '') AS UNSIGNED),
    source_file  = NULLIF(TRIM(@source_file), ''),
    metric_name  = NULLIF(TRIM(@metric_name), ''),
    measure_type = NULLIF(TRIM(@measure_type), ''),
    metric_value = CAST(NULLIF(REPLACE(TRIM(@metric_value), ',', ''), '') AS DECIMAL(18,6));
