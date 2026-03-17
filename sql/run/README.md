Open the MySQL client with the required options:
```
mysql --local-infile=1 --commands=ON --binary-mode=OFF -u root -p
```
Then create the database and staging tables:
```
SOURCE sql/run/00_create_database.sql;
SOURCE sql/run/01_create_staging.sql;
```
Then load the staging CSV files:
```
SOURCE sql/run/02_load_staging.sql;
```
Then create and populate the core schema:
```
SOURCE sql/run/03_create_core.sql;
SOURCE sql/run/04_populate_core.sql;
```
