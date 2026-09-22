# loan-portfolio-analysis
A SQL-based analysis of a public loan dataset — exploring portfolio composition, default risk by state, borrower profiling, and reusable stored procedures for on-demand reporting.

## Overview

This project answers a set of business questions about a lending portfolio using
MySQL: what does the portfolio look like, which states/grades carry the most risk,
how do verified vs non-verified borrowers compare, and which borrowers carry the
highest debt-to-income ratio.

## Tools Used

| Tool | Purpose |
|------|---------|
| MySQL / MySQL Workbench | All querying — staging, cleaning, EDA, risk analysis, stored procedures, views, window functions |

## Dataset

- **Source:** [Lending Club Loan Data](https://www.kaggle.com/datasets) (public Kaggle dataset)
- **Table used:** `loans` (built from the raw CSV — see "How the data was prepared" below)
- **Key fields:** loan_id, borrower_id, loan_amount, funded_amount, interest_rate, installment, grade, sub_grade, emp_title, emp_length, home_ownership, annual_income, verification_status, issue_date, status, purpose, state, debt_to_income

> Download the dataset from Kaggle yourself and load it into your own MySQL schema —
> see "Getting Started" below.

## Project Structure

\```
loan-portfolio-analysis/
├── README.md
├── LICENSE
└── sql/
    ├── create_and_load.sql          <- Step 1: staging table + raw CSV import
    ├── build_clean_loans_table.sql  <- Step 2: cleans & types the data into `loans`
    └── loan_portfolio_analysis.sql  <- Step 3: the actual analysis (EDA, risk, procedures, views)
\```

## Getting Started

1. Install MySQL Server + MySQL Workbench.
2. Download the Lending Club dataset from Kaggle.
3. Create a schema called `loan_analysis` in Workbench.
4. Run `sql/create_and_load.sql` to stage and load the raw CSV as text (avoids
   type-mismatch import errors on messy real-world data).
5. Run `sql/build_clean_loans_table.sql` to convert the staged data into a clean,
   properly-typed `loans` table.
6. Run `sql/loan_portfolio_analysis.sql` section by section to explore the data.

## How the Data Was Prepared

The raw Lending Club CSV has 140+ columns, many irrelevant to this analysis, and
several fields (like `int_rate`) stored as text with a `%` sign, plus blank values
in numeric columns that break naive type casting. To handle this reliably:

1. **Stage everything as text** into a `raw_loans` table — nothing can fail on a
   type mismatch if every column accepts any string.
2. **Cast and clean** into a proper `loans` table — numeric columns converted with
   `NULLIF(..., '')` guards so blanks become real `NULL`s instead of crashing the
   conversion, and `int_rate` has its `%` stripped before casting to a decimal.

## What's in the Analysis Script

- **Section 1 — Portfolio Overview:** totals, grade/purpose breakdowns, top states by loan volume
- **Section 2 — Risk & Default Analysis:** default rate by state, a reusable `DefaultRateByState()` procedure, a ranked `state_risk_ranking` view using `DENSE_RANK()`
- **Section 3 — Borrower Profiling:** income by home ownership, verified vs non-verified comparison, monthly installment trends, a `LoanProfile()` lookup procedure
- **Section 4 — One-Call State Dashboard:** a single `StateDashboard()` procedure returning four result sets (KPIs, grade mix, top purposes, status mix) for any state

## Author
**Kumari Ayushi**
Data Analyst in training — SQL
