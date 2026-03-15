USE db_mgmt;

SET NAMES utf8mb4;

/*
Create all staging tables.

Assumption:
Run this script from the repository root so the SOURCE paths resolve
as written below.
*/

DROP TABLE IF EXISTS stg_ohss;

DROP TABLE IF EXISTS stg_dos_iv;

DROP TABLE IF EXISTS stg_dos_niv;

DROP TABLE IF EXISTS stg_cbp;

SOURCE sql/staging/ddl/create_stg_cbp.sql;
SOURCE sql/staging/ddl/create_stg_dos_niv.sql;
SOURCE sql/staging/ddl/create_stg_dos_iv.sql;
SOURCE sql/staging/ddl/create_stg_ohss.sql;