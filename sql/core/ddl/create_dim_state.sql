/*
Canonical U.S. state / district / territory dimension.

Design notes:
- Keep exactly one row per canonical place name used by the project.
- Use the two-letter postal code when available.
- Keep type small and controlled so downstream facts cannot invent categories.
*/

CREATE TABLE dim_state (
    state_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    state_name VARCHAR(64) NOT NULL,
    PRIMARY KEY (state_id),
    UNIQUE KEY uq_dim_state_name (state_name)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;