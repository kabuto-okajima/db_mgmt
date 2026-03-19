# Schema Definitions, Functional Dependencies, and BCNF Justification

## Overview

This document summarizes the core schema, its main non-trivial functional dependencies (FDs), and a concise BCNF justification for each relation.

The OHSS portion is decomposed into two relations:

- `fact_ohss_state_metric(state_id, year, metric_id, metric_value)`
- `fact_ohss_state_year_population(state_id, year, population)`

This decomposition avoids mixing two different grains in one table. Metric values depend on `(state_id, year, metric_id)`, while population depends on `(state_id, year)`. Because these dependencies are represented in separate relations, and because every determinant in each relation is a candidate key, the schema is in BCNF.

**Note:** This document focuses on the semantic candidate keys and the main non-trivial FDs used in the normalization argument. Surrogate auto-increment IDs may also be unique in the implementation, but they are not the main basis of the BCNF justification.

---

## 1. `dim_country(country_id, country_name)`

**Candidate keys**
- `country_id`
- `country_name`

**Functional dependencies**
- `country_id -> country_name`
- `country_name -> country_id`

**BCNF justification**  
Both determinants are candidate keys, since each uniquely identifies the other attribute. Therefore, every non-trivial FD has a superkey on the left-hand side, so the relation is in BCNF.

---

## 2. `dim_demographic_group(demographic_group_id, demographic_group_name)`

**Candidate keys**
- `demographic_group_id`
- `demographic_group_name`

**Functional dependencies**
- `demographic_group_id -> demographic_group_name`
- `demographic_group_name -> demographic_group_id`

**BCNF justification**  
Each determinant uniquely identifies the other attribute, so both are candidate keys. Since every non-trivial FD is determined by a candidate key, the relation is in BCNF.

---

## 3. `dim_ohss_metric(metric_id, metric_name, measure_type)`

**Candidate keys**
- `metric_id`
- `(metric_name, measure_type)`

**Functional dependencies**
- `metric_id -> metric_name, measure_type`
- `(metric_name, measure_type) -> metric_id`

**BCNF justification**  
`metric_id` uniquely identifies the semantic metric definition, and the pair `(metric_name, measure_type)` is also unique. Since every non-trivial FD has a candidate key as its determinant, the relation is in BCNF.

---

## 4. `dim_state(state_id, state_name)`

**Candidate keys**
- `state_id`
- `state_name`

**Functional dependencies**
- `state_id -> state_name`
- `state_name -> state_id`

**BCNF justification**  
Each attribute uniquely identifies the other, so both are candidate keys. Therefore, all non-trivial FDs are determined by superkeys, and the relation is in BCNF.

---

## 5. `dim_visa_class_iv(visa_class_iv_id, visa_class_code)`

**Candidate keys**
- `visa_class_iv_id`
- `visa_class_code`

**Functional dependencies**
- `visa_class_iv_id -> visa_class_code`
- `visa_class_code -> visa_class_iv_id`

**BCNF justification**  
The surrogate identifier and the visa class code each uniquely identify a row. Because every non-trivial FD is determined by a candidate key, the relation is in BCNF.

---

## 6. `dim_visa_class_niv(visa_class_niv_id, visa_class_code)`

**Candidate keys**
- `visa_class_niv_id`
- `visa_class_code`

**Functional dependencies**
- `visa_class_niv_id -> visa_class_code`
- `visa_class_code -> visa_class_niv_id`

**BCNF justification**  
The surrogate identifier and the visa class code each function as candidate keys. Since every determinant in a non-trivial FD is a candidate key, the relation is in BCNF.

---

## 7. `map_country_label(source_system, source_country_label, country_id)`

**Candidate keys**
- `(source_system, source_country_label)`

**Functional dependencies**
- `(source_system, source_country_label) -> country_id`

**BCNF justification**  
A source-specific country label is interpreted only within its source system, so the pair `(source_system, source_country_label)` is the semantic key. The only non-trivial FD is determined by that key, so the relation is in BCNF.

---

## 8. `fact_cbp_encounter(year, month, state_id, country_id, demographic_group_id, land_border_region, title_of_authority, encounter_count)`

**Candidate keys**
- `(year, month, state_id, country_id, demographic_group_id, land_border_region, title_of_authority)`

**Functional dependencies**
- `(year, month, state_id, country_id, demographic_group_id, land_border_region, title_of_authority) -> encounter_count`

**BCNF justification**  
The fact table is defined at the grain of one CBP encounter count per full dimensional combination. Since the measure `encounter_count` depends on the full grain and not on any proper subset of it, the determinant is a candidate key and the relation is in BCNF.

---

## 9. `fact_dos_iv_issuance(year, month, basis, country_id, visa_class_iv_id, issuances)`

**Candidate keys**
- `(year, month, basis, country_id, visa_class_iv_id)`

**Functional dependencies**
- `(year, month, basis, country_id, visa_class_iv_id) -> issuances`

**BCNF justification**  
The table’s grain is one IV issuance count per month, basis, country, and visa class combination. Because the measure `issuances` is determined only by that full grain, every non-trivial FD is determined by a candidate key, so the relation is in BCNF.

---

## 10. `fact_dos_niv_issuance(year, month, country_id, visa_class_niv_id, issuances)`

**Candidate keys**
- `(year, month, country_id, visa_class_niv_id)`

**Functional dependencies**
- `(year, month, country_id, visa_class_niv_id) -> issuances`

**BCNF justification**  
The table records one NIV issuance count per month, country, and visa class combination. Since `issuances` depends on the full grain and not on a smaller determinant, the relation is in BCNF.

---

## 11. `fact_ohss_state_metric(state_id, year, metric_id, metric_value)`

**Candidate keys**
- `(state_id, year, metric_id)`

**Functional dependencies**
- `(state_id, year, metric_id) -> metric_value`

**BCNF justification**  
This table stores one OHSS metric value per state, year, and metric. Because `metric_value` depends on the full `(state_id, year, metric_id)` combination, and no smaller determinant defines the row, the relation is in BCNF.

---

## 12. `fact_ohss_state_year_population(state_id, year, population)`

**Candidate keys**
- `(state_id, year)`

**Functional dependencies**
- `(state_id, year) -> population`

**BCNF justification**  
Population is stored at the separate state-year grain, so one row represents one population value for a given state and year. Since `population` depends exactly on `(state_id, year)`, the determinant is a candidate key and the relation is in BCNF.