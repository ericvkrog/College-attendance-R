# Determinants of College Attendance in the U.S. (R, CPS ASEC)

This repository contains an empirical analysis of which adults in the United States attend college, using microdata from the 2024 Current Population Survey Annual Social and Economic Supplement (CPS ASEC).

The written paper in /report provides extended interpretation and context; the core analysis and results are fully reproducible via the R scripts.

The project examines how income, race, gender, marital status, and household role relate to:

- Years of education (continuous outcome; OLS regression), and  
- College attendance (binary outcome; logistic regression).

All analysis is implemented in R.

---

## Research Question

> How do income, race, gender, marital status, and household role predict whether an adult (25+) attends college and how many years of education they complete?

The sample is restricted to adults aged 25 and older so that educational attainment is mostly complete.

---

## Data

- Source: 2024 CPS ASEC microdata collected by the U.S. Census Bureau and Bureau of Labor Statistics.
- Sample size: ~95,000 adults aged 25+
- Unit of observation: Individual adult (25+).  
- Key variables:
  - Years of education (continuous)
  - College attendance indicator (binary)
  - Race (White, Black, American Indian, Asian, Pacific Islander, Multiracial, Other)
  - Sex (male/female)
  - Income (log-transformed as `log(income + 1)` to handle skew)
  - Marital status (married vs not)
  - Household role (head of household vs not)

The raw CPS ASEC microdata are not included in this repository due to size and licensing.  
To reproduce the analysis, you’ll need to download CPS ASEC 2024 and place it in the `data/` directory (see below).

---

## Methods

The analysis follows a standard data workflow: data ingestion, cleaning and feature engineering, model estimation, and visualization of results.

Two main model families are used:

1. OLS regression  
   - Outcome: years of education  
   - Predictors: race, log(income + 1), sex, marital status, head-of-household indicator  

2. Logistic regression  
   - Outcome: attended college (1 = yes, 0 = no)  
   - Two specifications:
     - Unadjusted: race only  
     - Adjusted: race + log(income + 1) + sex + marital status + head-of-household  

Key modeling choices:
- Log-transform of income to reduce skew and reflect diminishing marginal effects of higher income.
- Baseline/reference group in categorical variables:  
  White, male, unmarried, not head of household, and income = 0 (after transformation).

---
## Repository Structure

```text
College-attendance-R/
│
├── README.md                # Project overview 
├── data/
│   └── README_data.md       # Instructions for obtaining CPS ASEC 2024
├── scripts/
│   └── analysis.R           # Main R script: cleaning, modeling, and plots
├── report/
│   ├── paper.pdf            # Final written report
│   └── paper.docx           # Editable version of the report
└── output/
    └── figures/             # Saved plots (e.g., attendance by race, odds ratios)
```

## Reproducing the Analysis

1. Install R and required packages:
   ```r
   install.packages(c("readr","dplyr","ggplot2","psych","forcats","stargazer","broom","here"))
   ```
2.	Download the CPS ASEC 2024 person-level microdata (folder typically named asecpub24csv) and place it so this file exists:
`
data/asecpub24csv/pppub24.csv
`
	Raw CPS data is not included in this repository.

3. Run the main script:
   ```r
   source("scripts/analysis.R")
   ```
This will:

- Clean and prepare the dataset  
- Create indicators (college attendance, log income, household role, etc.)  
- Estimate OLS and logistic regression models  
- Produce and save plots under output/figures/

  ## Results
  
  	-	**Income** is strongly positively associated with college attendance, each one-unit increase in log(income + 1) is associated with a sizable increase in the odds of attending college.
	-	**Race** effects change substantially between unadjusted and adjusted models:
	-	In the unadjusted model, Black individuals appear less likely to attend college than White individuals.
	-	After controlling for income, gender, marital status, and household role, Black individuals show higher odds of attending college relative to White individuals, suggesting that raw racial gaps partly reflect underlying socioeconomic differences.
	-	**Women** have higher odds of attending college than men.
	-	**Married** individuals are more likely to have attended college than unmarried individuals.
	-	**Heads of household** are less likely to have attended college, consistent with higher non-school responsibilities.

These findings support the idea that educational attainment is shaped by more than just individual “effort” or ability; structural and socioeconomic factors play a major role.

## Limitations & Next Steps
- The CPS ASEC data are self-reported and cross-sectional, limiting causal interpretation.
- The analysis does not include academic performance measures (e.g., GPA) or field of study.
- Future extensions could examine cohort effects, graduation outcomes, or link educational attainment to labor-market outcomes.
