/*
Canonical CBP demographic group dimension.
*/

CREATE TABLE dim_demographic_group (
    demographic_group_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    demographic_group_name VARCHAR(64) NOT NULL,
    PRIMARY KEY (demographic_group_id),
    UNIQUE KEY uq_dim_demographic_group_name (demographic_group_name)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;