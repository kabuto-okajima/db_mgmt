/*
    Populate core mapping and dimension tables.

    This script is intended to orchestrate all core-level populate steps.
    At this stage, it loads only dimensions that can be populated directly
    from staging tables without manual country canonicalization.

    Additional populate scripts, such as those for dim_country and
    map_country_label, should be added here once their mapping logic is finalized.
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
