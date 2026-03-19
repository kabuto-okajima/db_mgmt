### why dim_state = 55
It is happening because dim_state is populated from the union of:
- CBP state
- OHSS state

From the CBP file you uploaded, there are 48 distinct values. Those are not just the 50 U.S. states. They include:
- District of Columbia
- Guam
- Northern Mariana Islands
- Puerto Rico
- U.S. Virgin Islands

At the same time, CBP is missing these 7 states:
- Arkansas
- Iowa
- Kansas
- Oklahoma
- South Dakota
- West Virginia
- Wyoming

So the union naturally becomes:
- 50 states
- District of Columbia
- 4 territories

which gives 55.



### map_country_label = 449
This is not strange. It is exactly what I would expect if the table stores source-qualified labels:

- CBP labels: 22
- DOS NIV labels: 209
- DOS IV labels: 218

Total: 22 + 209 + 218 = 449

### OHSS population normalization
The OHSS core schema now separates:
- `fact_ohss_state_year_population` at the `(state_id, year)` grain for `population`
- `fact_ohss_state_metric` at the `(state_id, year, metric_id)` grain for `metric_value`

This keeps the OHSS core layer aligned with the underlying functional dependencies.
