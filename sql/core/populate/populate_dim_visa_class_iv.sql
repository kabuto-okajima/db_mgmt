/*
    Populate dim_visa_class_iv from DOS IV staging data.

    Each distinct IV visa class code is inserted once into the
    IV visa class dimension.
*/

INSERT IGNORE INTO dim_visa_class_iv (visa_class_code) -- IGNORE duplicate visa class codes
SELECT DISTINCT TRIM(visa_class) AS visa_class_code
FROM stg_dos_iv
WHERE visa_class IS NOT NULL
  AND TRIM(visa_class) <> ''; -- IGNORE records where visa class is NULL or empty after trimming