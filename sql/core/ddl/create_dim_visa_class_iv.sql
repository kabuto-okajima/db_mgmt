/*
DOS immigrant visa class dimension.

Design note:
- Keep NIV and IV visa classes in separate dimensions because the same code
  can mean different things across the two source systems.
*/

CREATE TABLE dim_visa_class_iv (
    visa_class_iv_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    visa_class_code VARCHAR(64) NOT NULL,
    PRIMARY KEY (visa_class_iv_id),
    UNIQUE KEY uq_dim_visa_class_iv_code (visa_class_code)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;