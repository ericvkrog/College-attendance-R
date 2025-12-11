# Who Goes to College? Educational Attainment Analysis in R

This repository contains an empirical analysis of which adults in the United States attend college, using microdata from the 2024 Current Population Survey Annual Social and Economic Supplement (CPS ASEC).

The project examines how income, race, gender, marital status, and household role relate to:

- Years of education (continuous outcome; OLS regression), and  
- College attendance*(binary outcome; logistic regression).

All analysis is implemented in R.

---

## Research Question

> How do income, race, gender, marital status, and household role predict whether an adult (25+) attends college and how many years of education they complete?

The sample is restricted to adults aged 25 and older so that educational attainment is mostly complete.

---

## Data

- Source: 2024 CPS ASEC microdata collected by the U.S. Census Bureau and Bureau of Labor Statistics.  
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
