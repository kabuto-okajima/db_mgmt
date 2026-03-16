/*
    Populate dim_country from actual source usage with lightweight
    canonicalization rules.

    This script keeps the country dimension simple for PoC purposes:
    most labels are preserved as-is, while a small number of known
    aliases (e.g., "Great Britain and Northern Ireland" to "United Kingdom") 
    and non-country buckets are handled explicitly.
*/

INSERT IGNORE INTO dim_country (country_name)
SELECT DISTINCT canonical_country_name
FROM (
    SELECT
        CASE
            WHEN TRIM(nationality) IN ('Other', 'Unknown', 'No Nationality') THEN NULL
            WHEN TRIM(nationality) = 'Bahamas, The' THEN 'Bahamas'
            WHEN TRIM(nationality) = 'Bosnia-Herzegovina' THEN 'Bosnia and Herzegovina'
            WHEN TRIM(nationality) IN ('Burma', 'Myanmar (Burma)') THEN 'Myanmar'
            WHEN TRIM(nationality) IN ('China - mainland', 'China - mainland born') THEN 'China'
            WHEN TRIM(nationality) = 'Congo, Democratic Republic of the' THEN 'Democratic Republic of the Congo'
            WHEN TRIM(nationality) = 'Congo, Republic of the' THEN 'Republic of the Congo'
            WHEN TRIM(nationality) = 'Great Britain and Northern Ireland' THEN 'United Kingdom'
            WHEN TRIM(nationality) IN (
                'Hong Kong S.A.R.',
                'Hong Kong-BNO',
                'British National Overseas (Hong Kong) Passport'
            ) THEN 'Hong Kong'
            WHEN TRIM(nationality) = 'Korea, North' THEN 'North Korea'
            WHEN TRIM(nationality) = 'Korea, South' THEN 'South Korea'
            WHEN TRIM(nationality) = 'Macau S.A.R.' THEN 'Macau'
            WHEN TRIM(nationality) = 'Micronesia, Federated States of' THEN 'Federated States of Micronesia'
            WHEN TRIM(nationality) = 'Palestinian Authority Travel Document' THEN NULL
            ELSE TRIM(nationality) -- Preserve as-is if not in known exceptions
        END AS canonical_country_name
    FROM stg_cbp
    WHERE nationality IS NOT NULL
      AND TRIM(nationality) <> ''

    UNION

    SELECT
        CASE
            WHEN TRIM(nationality) IN (
                '*Non-Nationality Based Issuances',
                'Other',
                'Unknown',
                'No Nationality'
            ) THEN NULL
            WHEN TRIM(nationality) = 'Bahamas, The' THEN 'Bahamas'
            WHEN TRIM(nationality) = 'Bosnia-Herzegovina' THEN 'Bosnia and Herzegovina'
            WHEN TRIM(nationality) IN ('Burma', 'Myanmar (Burma)') THEN 'Myanmar'
            WHEN TRIM(nationality) IN ('China - mainland', 'China - mainland born') THEN 'China'
            WHEN TRIM(nationality) = 'Congo, Democratic Republic of the' THEN 'Democratic Republic of the Congo'
            WHEN TRIM(nationality) = 'Congo, Republic of the' THEN 'Republic of the Congo'
            WHEN TRIM(nationality) = 'Great Britain and Northern Ireland' THEN 'United Kingdom'
            WHEN TRIM(nationality) IN (
                'Hong Kong S.A.R.',
                'Hong Kong-BNO',
                'British National Overseas (Hong Kong) Passport'
            ) THEN 'Hong Kong'
            WHEN TRIM(nationality) = 'Korea, North' THEN 'North Korea'
            WHEN TRIM(nationality) = 'Korea, South' THEN 'South Korea'
            WHEN TRIM(nationality) = 'Macau S.A.R.' THEN 'Macau'
            WHEN TRIM(nationality) = 'Micronesia, Federated States of' THEN 'Federated States of Micronesia'
            WHEN TRIM(nationality) = 'Palestinian Authority Travel Document' THEN NULL
            ELSE TRIM(nationality)
        END AS canonical_country_name
    FROM stg_dos_niv
    WHERE nationality IS NOT NULL
      AND TRIM(nationality) <> ''

    UNION

    SELECT
        CASE
            WHEN TRIM(fsc_or_place_of_birth) IN (
                '*Non-Nationality Based Issuances',
                'Other',
                'Unknown',
                'No Nationality'
            ) THEN NULL
            WHEN TRIM(fsc_or_place_of_birth) = 'Bahamas, The' THEN 'Bahamas'
            WHEN TRIM(fsc_or_place_of_birth) = 'Bosnia-Herzegovina' THEN 'Bosnia and Herzegovina'
            WHEN TRIM(fsc_or_place_of_birth) IN ('Burma', 'Myanmar (Burma)') THEN 'Myanmar'
            WHEN TRIM(fsc_or_place_of_birth) IN ('China - mainland', 'China - mainland born') THEN 'China'
            WHEN TRIM(fsc_or_place_of_birth) = 'Cocos Islands' THEN 'Cocos (Keeling) Islands'
            WHEN TRIM(fsc_or_place_of_birth) = 'Congo, Democratic Republic of the' THEN 'Democratic Republic of the Congo'
            WHEN TRIM(fsc_or_place_of_birth) = 'Congo, Republic of the' THEN 'Republic of the Congo'
            WHEN TRIM(fsc_or_place_of_birth) = 'Great Britain and Northern Ireland' THEN 'United Kingdom'
            WHEN TRIM(fsc_or_place_of_birth) IN (
                'Hong Kong S.A.R.',
                'Hong Kong-BNO',
                'British National Overseas (Hong Kong) Passport'
            ) THEN 'Hong Kong'
            WHEN TRIM(fsc_or_place_of_birth) = 'Korea, North' THEN 'North Korea'
            WHEN TRIM(fsc_or_place_of_birth) = 'Korea, South' THEN 'South Korea'
            WHEN TRIM(fsc_or_place_of_birth) = 'Macau S.A.R.' THEN 'Macau'
            WHEN TRIM(fsc_or_place_of_birth) = 'Micronesia, Federated States of' THEN 'Federated States of Micronesia'
            WHEN TRIM(fsc_or_place_of_birth) = 'Palestinian Authority Travel Document' THEN NULL
            ELSE TRIM(fsc_or_place_of_birth)
        END AS canonical_country_name
    FROM stg_dos_iv
    WHERE fsc_or_place_of_birth IS NOT NULL
      AND TRIM(fsc_or_place_of_birth) <> ''
) AS x
WHERE canonical_country_name IS NOT NULL;