# loan-portfolio-analysis

A SQL-based data analysis project evaluating credit risk, portfolio composition, and borrower profiles using a public lending dataset. This repository features advanced MySQL implementations, including window functions, views, and reusable stored procedures for financial reporting.

## Overview

This project uses MySQL to explore structural portfolio risk patterns, borrower behavior distributions, and geographic metrics to support risk-management assessments.

## Business Questions Answered

* **Portfolio Metrics:** What does the global lending portfolio composition look like when broken down by loan grade and purpose?
* **Risk Hotspots:** Which specific states and credit grades carry the highest concentration of default risks?
* **Verification Impact:** How do the default rates and loan volumes of verified borrowers compare against non-verified borrowers?
* **Debt Profiling:** Which consumer profiles present the highest debt-to-income (DTI) ratios and financial stress signals?
* **State Performance:** How can operational stakeholders pull a comprehensive financial health dashboard (KPIs, status mix, purposes) for any single state on demand?

## Tools & Dataset

* **SQL Engine:** MySQL & MySQL Workbench (used for staging, pipeline transformations, EDA, and stored procedure creation).
* **Dataset Source:** Lending Club Loan Data (Kaggle), monitoring essential metrics such as `loan_amount`, `interest_rate`, `verification_status`, and `debt_to_income`.

## Project Structure

```text
├── sql/
│   ├── create_and_load.sql          
│   ├── build_clean_loans_table.sql  
│   └── loan_portfolio_analysis.sql  
├── LICENSE                          
└── README.md                        
```

## Analytical Highlights

* **Staging & ETL Pipeline:** Implements a text-staging layer to parse messy raw inputs safely, applying `NULLIF()` filters and trimming mechanisms before type-casting numeric and decimal columns.
* **Advanced Querying:** Employs `DENSE_RANK()` window functions within custom views to calculate dynamic geographic risk indices across state lines.
* **On-Demand Reporting:** Features a custom `StateDashboard()` procedure that outputs a complete, single-call metrics summary (KPIs, grade mixes, and loan statuses) for any queried state.

## Getting Started

1. Clone or download the repository to your local machine.
2. Download the Lending Club dataset from Kaggle.
3. Open MySQL Workbench, connect to your local server instance, and set up your workspace environment:
   ```sql
   CREATE DATABASE loan_analysis;
   USE loan_analysis;
   ```
4. Run the scripts inside the `sql/` directory sequentially:
   * First, execute `create_and_load.sql` to stage your raw data.
   * Next, run `build_clean_loans_table.sql` to generate your sanitized analytics tables.
   * Finally, open `loan_portfolio_analysis.sql` to run the individual core analytics sections and dashboard procedures.


