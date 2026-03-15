- `TRUNCATE TABLE stg_cbp`  
  Clears existing data before loading new data.

- `FIELDS TERMINATED BY ','`  
  Fields are separated by commas.

- `OPTIONALLY ENCLOSED BY '"'`  
  Allows fields to be enclosed in double quotes, which helps preserve commas inside field values.

- `IGNORE 1 LINES`  
  Skips the first row of the CSV file, which is the header row.

- `TRIM(@year)`  
  Removes leading and trailing whitespace from the raw input value.

- `NULLIF(TRIM(@year), '')`  
  Converts an empty string to `NULL` after trimming whitespace.

- `CAST(NULLIF(TRIM(@year), '') AS UNSIGNED)`  
  Converts the cleaned value to an unsigned integer, while treating blank values as `NULL`.

- `CAST(NULLIF(REPLACE(TRIM(@encounter_count), ',', ''), '') AS UNSIGNED)`  
  Removes surrounding whitespace, deletes comma separators from numeric text, converts empty strings to `NULL`, and casts the result to an unsigned integer.