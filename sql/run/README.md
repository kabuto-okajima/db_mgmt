Open the MySQL client with the required options:
```
mysql --commands=ON --binary-mode=OFF -u root -p db_mgmt
```
Then run the staging DDL script:
```
SOURCE sql/run/00_create_databases.sql;
SOURCE sql/run/01_create_staging.sql;
```
To allow LOAD DATA LOCAL INFILE, enable local_infile temporarily:
```
SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';
```
Then run the staging load script:
```
SOURCE sql/run/02_load_staging.sql;
```