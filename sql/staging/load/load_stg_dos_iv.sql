-- load_stg_dos_iv.sql
-- Source file:
--   data/staging/dos_iv/dos_iv_fsc_or_place_of_birth_visa_class_monthly.csv
-- Expected columns:
--   year, month, basis, fsc_or_place_of_birth, visa_class, issuances, source_file

USE db_mgmt;

TRUNCATE TABLE stg_dos_iv;

LOAD DATA LOCAL INFILE 'data/staging/dos_iv/dos_iv_fsc_or_place_of_birth_visa_class_monthly.csv'
INTO TABLE stg_dos_iv
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @year,
    @month,
    @basis,
    @fsc_or_place_of_birth,
    @visa_class,
    @issuances,
    @source_file
)
SET
    year                  = CAST(NULLIF(TRIM(@year), '') AS UNSIGNED),
    month                 = CAST(NULLIF(TRIM(@month), '') AS UNSIGNED),
    basis                 = NULLIF(TRIM(@basis), ''),
    fsc_or_place_of_birth = NULLIF(TRIM(@fsc_or_place_of_birth), ''),
    visa_class            = NULLIF(TRIM(@visa_class), ''),
    issuances             = CAST(NULLIF(REPLACE(TRIM(@issuances), ',', ''), '') AS UNSIGNED),
    source_file           = NULLIF(TRIM(@source_file), '');
