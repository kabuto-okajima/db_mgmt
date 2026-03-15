-- load_stg_dos_niv.sql
-- Source file:
--   data/staging/dos_niv/dos_niv_nationality_visa_class_monthly.csv
-- Expected columns:
--   year, month, nationality, visa_class, issuances, source_file

USE db_mgmt;

TRUNCATE TABLE stg_dos_niv;

LOAD DATA LOCAL INFILE 'data/staging/dos_niv/dos_niv_nationality_visa_class_monthly.csv'
INTO TABLE stg_dos_niv
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @year,
    @month,
    @nationality,
    @visa_class,
    @issuances,
    @source_file
)
SET
    year        = CAST(NULLIF(TRIM(@year), '') AS UNSIGNED),
    month       = CAST(NULLIF(TRIM(@month), '') AS UNSIGNED),
    nationality = NULLIF(TRIM(@nationality), ''),
    visa_class  = NULLIF(TRIM(@visa_class), ''),
    issuances   = CAST(NULLIF(REPLACE(TRIM(@issuances), ',', ''), '') AS UNSIGNED),
    source_file = NULLIF(TRIM(@source_file), '');
