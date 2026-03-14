# Project Purpose
This database is designed to organize U.S. immigration information across four dimensions:
1. State-level enforcement pressure (e.g., encounters by state, month, and citizenship)
2. Nationality-level temporary visa issuance (e.g., F-1 visa issuance by nationality)
3. Nationality-level immigrant visa issuance
4. State-level immigration outcomes (e.g., I-94 nonimmigrant arrivals, naturalizations, and refugee arrivals)

Using these four datasets together, **the project provides a structured view** of immigration that separates irregular encounters, nonimmigrant visa issuance, immigrant visa issuance, and state-level outcomes such as naturalizations, refugee arrivals, and asylum grants.


# What this Project Can Do
## Using each Dataset Independently
### 1. Compare Enforcement Activity Across States
The CBP dataset makes it possible to analyze how encounter volume differs by **state, month, citizenship, demographic group, and authority type**.  
Example: compare monthly encounters involving Venezuelan nationals in Texas versus Arizona.
### 2. Compare Lawful Temporary Entry Patterns by Nationality
The DOS nonimmigrant visa dataset supports analysis of **monthly visa issuance by nationality and visa class**.  
Example: compare monthly F-1 and B1/B2 issuance trends for India, China, and Brazil.
### 3. Compare Immigrant Visa Patterns by Country and Class
The DOS immigrant visa dataset supports analysis of **monthly immigrant visa issuance by foreign state of chargeability or place of birth and visa class**.  
Example: Compare immigrant visa issuance across family-sponsored classes and employment-based classes for chargeability groups such as Japan, China, and South Korea.
### 4. Compare State-Level Immigration Outcomes
The OHSS state flat file supports analysis of **state-based immigration indicators** such as LPRs, I-94 nonimmigrant arrivals, naturalizations, refugee arrivals, and asylum grants across ten years.  
Example: compare California, Florida, and New York in terms of annual naturalizations and refugee arrivals.


## What Becomes Possible When the Four Datasets Are Used Together
The value of this database is not that it creates a single measure of “immigration,” but that it allows different parts of the system to be viewed side by side.
For example, it can be used to answer questions such as:
- **Which states experience high encounter volume, and do those same states also show high lawful immigration outcomes?**
- **How do nationality-level temporary visa patterns differ from immigrant visa patterns?**
- **Do changes in visa issuance by nationality coincide with changes in encounter patterns involving the same citizenship groups?**
- **How do states differ in the balance between enforcement-side pressure and longer-term immigration outcomes such as naturalization or LPR acquisition?**
For example:
- use **CBP** to observe rising monthly encounters involving a given citizenship group in a specific state,
- use **DOS NIV** to see whether temporary visa issuance for that nationality is rising or falling,
- use **DOS IV** to assess whether immigrant visa issuance is concentrated in different classes,
- and use **OHSS** to determine whether the same state shows high annual levels of lawful immigration outcomes.
## What this Project Does Not Do
This Project does **not** allow you to:
- measure total “legal immigration by state × nationality × month” in one unified table,
	- monthly vs. yearly
		- CBP: monthly
		- OHSS: yearly
	- no country/nationality information in OHSS
	- no state information in DOS IV, NIV datasets
- the meaning of country/nationality differs across the datasets
	- CBP: nationality/citizenship associated with the encounter
	- DOS_NIV: nationality
	- DOS_IV: chargeability or place of birth



# Dataset Sources
> - Ingest at least 4 structured data sets from at least 2 repositories
> 	- Must represent multiple facets of chosen issue
> 	- Able to aggregate the data based on at least three aspects
> 	- Must clearly identify the data used

## CBP — Nationwide Encounters by State
https://www.cbp.gov/document/stats/nationwide-encounters
CBP National Encounters
"FY23 - FY26 (FYTD) Nationwide Encounters by State - January"
> FYTD: Fiscal Year to date
> CBP fiscal year starts from Oct 1, ends on Sep 30 in the next year.
> e.g., ) **FY 2023** runs from **Oct 1, 2022 to Sep 30, 2023**

Data Range:
- FROM: 2022, October
- TO: 2026, January
```
Fiscal Year,Month Grouping,Month (abbv),Component,Land Border Region,Area of Responsibility,AOR (Abbv),Demographic,Citizenship,Title of Authority,Encounter Type,Encounter Count

2023,FYTD,DEC,Office of Field Operations,Northern Land Border,Boston Field Office,Boston,Accompanied Minors,BRAZIL,Title 42,Expulsions,3

2023,FYTD,DEC,Office of Field Operations,Northern Land Border,Boston Field Office,Boston,Accompanied Minors,CANADA,Title 42,Expulsions,1

2023,FYTD,DEC,Office of Field Operations,Northern Land Border,Boston Field Office,Boston,Accompanied Minors,CANADA,Title 8,Inadmissibles,1
```

## DOS — Monthly Nonimmigrant Visa Issuances by Nationality and Visa Class
https://travel.state.gov/content/travel/en/legal/visa-law0/visa-statistics/nonimmigrant-visa-statistics/monthly-nonimmigrant-visa-issuances.html?trk=public_post_comment-text
- Excel available since 2022 Oct
- It provides only monthly file
	- Scraping -> convert to CSV -> aggregate

2025 August Data:

| Nationality | Visa Class | Issuances |
| ----------- | ---------- | --------- |
| Afghanistan | B1/B2      | 1         |
| Afghanistan | G4         | 9         |
| Albania     | A1         | 3         |
| Albania     | A2         | 7         |
| Albania     | B1/B2      | 1,223     |
| Albania     | C1/D       | 6         |
| Albania     | F1         | 38        |
| Albania     | F2         | 3         |
| Albania     | G2         | 7         |
| Albania     | G4         | 2         |
| Albania     | G5         | 1         |
| Albania     | H1B        | 7         |
| Albania     | H4         | 2         |
| Albania     | I          | 1         |
| Albania     | J1         | 15        |
| Albania     | K1         | 2         |

## DOS — Monthly Immigrant Visa Issuances by FSC or Place of Birth and Visa Class
https://travel.state.gov/content/travel/en/legal/visa-law0/visa-statistics/immigrant-visa-statistics/monthly-immigrant-visa-issuances.html?fs=e&s=cl
- Excel available since 2023 Jan
- It provides only monthly file
	- Scraping -> convert to CSV -> aggregate

> `F1` Difference in NIV and IV datasets:
> NIV (Non-Immigration Visa)'s `F1`: F1 Student visa.
> This dataset (IV)'s `F1`: Certain Family Members of U.S. Citizens

2025 August Data:

| Foreign State of Chargeability or Place of Birth | Visa Class | Issuances |
| ------------------------------------------------ | ---------- | --------- |
| Afghanistan                                      | CR1        | 30        |
| Afghanistan                                      | DV         | 1         |
| Afghanistan                                      | F2A        | 1         |
| Afghanistan                                      | IR1        | 56        |
| Afghanistan                                      | IR2        | 18        |
| Afghanistan                                      | IR5        | 96        |
| Afghanistan                                      | SI1        | 1         |
| Afghanistan                                      | SI2        | 1         |
| Afghanistan                                      | SI3        | 4         |
| Afghanistan                                      | SQ1        | 238       |
| Afghanistan                                      | SQ2        | 189       |
| Afghanistan                                      | SQ3        | 556       |
| Afghanistan                                      | SW         | 3         |
| Albania                                          | CR1        | 10        |
| Albania                                          | DV         | 80        |
| Albania                                          | E2         | 1         |
| Albania                                          | F1         | 7         |
| Albania                                          | F2A        | 10        |


## OHSS — State Immigration Data Flat File (FY 2013–2023)
https://ohss.dhs.gov/topics/immigration/state-immigration-data

```
State,Year,Population,Lawful Permanent Residents Total,Lawful Permanent Residents Rank,Adjustments Total,Adjustments Rank,New Arrivals Total,New Arrivals Rank,Nonimmigrants Total,Nonimmigrants Rank,Naturalizations Total,Naturalizations Rank,Refugees Total,Refugees Rank,Asylees Total,Asylees Rank,Lawful Permanent Residents Per Million,Lawful Permanent Residents Per Million Rank,Adjustments Per Million,Adjustments Per Million Rank,New Arrivals Per Million,New Arrivals Per Million Rank,Nonimmigrants Per Million,Nonimmigrants Per Million Rank,Naturalizations Per Million,Naturalizations Per Million Rank,Refugees Per Million,Refugees Per Million Rank,Asylees Per Million,Asylees Per Million Rank

Alabama,2013,4830081,3850,35,2150,34,1700,34,126750,35,1810,39,130,42,20,36,796.674,49,444.713,48,351.961,48,26240.761,44,374.942,49,26.708,43,4.762,46

Alabama,2014,4841799,3690,35,2050,34,1640,37,141340,34,1270,42,110,43,10,40,761.081,48,422.57,47,338.511,47,29191.009,43,261.473,51,22.099,44,2.891,47

Alabama,2015,4852347,3930,35,2100,36,1830,35,151470,34,2830,32,110,43,30,40,809.505,49,432.574,48,376.931,49,31215.822,43,584.047,47,21.639,43,5.358,43
```

