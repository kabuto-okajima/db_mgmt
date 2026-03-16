/*
    create_map_country_label.sql

    This table is intentionally modeled as a dictionary that resolves
    source-specific country-related labels into a canonical country_id.

    Design rationale:
    1. We intentionally do NOT introduce a surrogate key.
       The semantic identity of a row is already fully determined by
       (source_system, source_country_label).

    2. If a surrogate key were introduced, semantic duplicates would still
       be possible unless we also added:
           UNIQUE (source_system, source_country_label)
       For example, the following two rows would be duplicates in meaning:
           ('cbp', 'Brazil') -> 12
           ('cbp', 'Brazil') -> 12
       Therefore, the composite uniqueness would still be required, which
       means the surrogate key would not be the true business key.

    3. Since fact_* tables are not expected to reference this table directly,
       there is no practical need to add an artificial identifier solely for
       foreign-key convenience.

    4. In a database design course, redundancy and unnecessary attributes
       should be avoided unless they provide clear integrity or modeling value.
       In this case, an extra surrogate attribute would be redundant.

    5. The composite primary key also reflects the intended role of this table:
       it is a lookup / mapping dictionary, not a core business entity table.
*/

CREATE TABLE map_country_label (
    source_system ENUM('cbp', 'dos_niv', 'dos_iv') NOT NULL,
    source_country_label VARCHAR(128) NOT NULL,
    country_id SMALLINT UNSIGNED NULL,

    /*
        The primary key is intentionally defined on the natural identifier
        of the mapping itself.

        Meaning:
        - For a given source_system,
        - a given source_country_label
        - should appear at most once in the dictionary.
    */
    PRIMARY KEY (source_system, source_country_label),

    /*
        country_id is indexed because it may be used to inspect or validate
        which source-side labels resolve to the same canonical country.
    */
    KEY idx_map_country_label_country_id (country_id),

    /*
        country_id may remain NULL temporarily if a source-side label has not
        yet been resolved to a canonical country. This keeps the mapping table
        useful as a reviewable dictionary during data preparation.
    */
    CONSTRAINT fk_map_country_label_country
        FOREIGN KEY (country_id)
        REFERENCES dim_country (country_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;