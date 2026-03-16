/*
    Populate map_country_label from distinct source-side labels.

    For PoC simplicity, the same lightweight canonicalization rules used
    for dim_country are applied here. Labels that do not resolve to a
    canonical country remain NULL and can be reviewed separately.
*/

INSERT IGNORE INTO map_country_label (
    source_system,
    source_country_label,
    country_id
)
SELECT
    s.source_system,
    s.source_country_label,
    c.country_id
FROM (
    SELECT DISTINCT
        'cbp' AS source_system,
        TRIM(nationality) AS source_country_label,
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
            ELSE TRIM(nationality)
        END AS canonical_country_name
    FROM stg_cbp
    WHERE nationality IS NOT NULL
      AND TRIM(nationality) <> ''

    UNION

    SELECT DISTINCT
        'dos_niv' AS source_system,
        TRIM(nationality) AS source_country_label,
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
            ELSE TRIM(nationality)
        END AS canonical_country_name
    FROM stg_dos_niv
    WHERE nationality IS NOT NULL
      AND TRIM(nationality) <> ''

    UNION

    SELECT DISTINCT
        'dos_iv' AS source_system,
        TRIM(fsc_or_place_of_birth) AS source_country_label,
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
) AS s
LEFT JOIN dim_country c
  ON c.country_name = s.canonical_country_name;