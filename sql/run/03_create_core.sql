USE db_mgmt;
SET NAMES utf8mb4;

/*
Create core dimensions, mapping, and fact tables.

Reason:
- The project explicitly separates source semantics across datasets.
- Facts should be created only after the canonical dimensions and
  source-label mapping rules are stable.
*/

DROP TABLE IF EXISTS fact_ohss_state_metric;
DROP TABLE IF EXISTS fact_dos_iv_issuance;
DROP TABLE IF EXISTS fact_dos_niv_issuance;
DROP TABLE IF EXISTS fact_cbp_encounter;

DROP TABLE IF EXISTS dim_ohss_metric;
DROP TABLE IF EXISTS dim_visa_class_iv;
DROP TABLE IF EXISTS dim_visa_class_niv;
DROP TABLE IF EXISTS dim_demographic_group;
DROP TABLE IF EXISTS map_country_label;
DROP TABLE IF EXISTS dim_country;
DROP TABLE IF EXISTS dim_state;

SOURCE sql/core/ddl/create_dim_state.sql;
SOURCE sql/core/ddl/create_dim_country.sql;
SOURCE sql/core/ddl/create_dim_demographic_group.sql;
SOURCE sql/core/ddl/create_dim_visa_class_niv.sql;
SOURCE sql/core/ddl/create_dim_visa_class_iv.sql;
SOURCE sql/core/ddl/create_dim_ohss_metric.sql;
SOURCE sql/core/ddl/create_map_country_label.sql;

SOURCE sql/core/ddl/create_fact_cbp_encounter.sql;
SOURCE sql/core/ddl/create_fact_dos_niv_issuance.sql;
SOURCE sql/core/ddl/create_fact_dos_iv_issuance.sql;
SOURCE sql/core/ddl/create_fact_ohss_state_metric.sql;