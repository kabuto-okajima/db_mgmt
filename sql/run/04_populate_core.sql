/*
    Populate core dimensions, mappings, and facts.

    This script orchestrates the full core-layer load after staging data
    has already been created and populated.
*/

USE db_mgmt;
SET NAMES utf8mb4;

SOURCE sql/core/populate/populate_dim_state.sql;
SOURCE sql/core/populate/populate_dim_demographic_group.sql;
SOURCE sql/core/populate/populate_dim_visa_class_niv.sql;
SOURCE sql/core/populate/populate_dim_visa_class_iv.sql;
SOURCE sql/core/populate/populate_dim_ohss_metric.sql;
SOURCE sql/core/populate/populate_dim_country.sql;
SOURCE sql/core/populate/populate_map_country_label.sql;

SOURCE sql/core/populate/populate_fact_cbp_encounter.sql;
SOURCE sql/core/populate/populate_fact_dos_niv_issuance.sql;
SOURCE sql/core/populate/populate_fact_dos_iv_issuance.sql;
SOURCE sql/core/populate/populate_fact_ohss_state_year_population.sql;
SOURCE sql/core/populate/populate_fact_ohss_state_metric.sql;
