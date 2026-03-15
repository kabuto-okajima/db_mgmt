-- 02_load_staging.sql
-- Loads all normalized staging CSVs into the four staging tables.

USE db_mgmt;

SOURCE sql/staging/load/load_stg_cbp.sql;
SOURCE sql/staging/load/load_stg_dos_niv.sql;
SOURCE sql/staging/load/load_stg_dos_iv.sql;
SOURCE sql/staging/load/load_stg_ohss.sql;
