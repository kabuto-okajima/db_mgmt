/*
    Populate dim_visa_class_niv from DOS NIV staging data.

    Each distinct NIV visa class code is inserted once into the
    NIV visa class dimension.
*/

INSERT IGNORE INTO dim_visa_class_niv (visa_class_code) -- IGNORE duplicate visa class codes
SELECT DISTINCT TRIM(visa_class) AS visa_class_code
FROM stg_dos_niv
WHERE visa_class IS NOT NULL
  AND TRIM(visa_class) <> ''; -- IGNORE records where visa class is NULL or empty after trimming