-- Build a clean, properly-typed table from the raw text staging table.
-- Run this whole script in one go (Ctrl+Shift+Enter).

DROP TABLE IF EXISTS loan_analysis.loans;

CREATE TABLE loan_analysis.loans AS
SELECT
    CAST(NULLIF(TRIM(id), '') AS UNSIGNED)                                   AS loan_id,
    CAST(NULLIF(TRIM(member_id), '') AS UNSIGNED)                           AS borrower_id,
    CAST(NULLIF(TRIM(loan_amnt), '') AS DECIMAL(12,2))                      AS loan_amount,
    CAST(NULLIF(TRIM(funded_amnt), '') AS DECIMAL(12,2))                    AS funded_amount,
    term,
    -- int_rate arrives as text like "13.56%" -> strip the % and convert
    CAST(NULLIF(REPLACE(TRIM(int_rate), '%', ''), '') AS DECIMAL(6,3))      AS interest_rate,
    CAST(NULLIF(TRIM(installment), '') AS DECIMAL(12,2))                    AS installment,
    grade,
    sub_grade,
    emp_title,
    emp_length,
    home_ownership,
    CAST(NULLIF(TRIM(annual_inc), '') AS DECIMAL(14,2))                     AS annual_income,
    verification_status,
    issue_d                                                                  AS issue_date,
    loan_status                                                              AS status,
    purpose,
    addr_state                                                               AS state,
    CAST(NULLIF(TRIM(dti), '') AS DECIMAL(6,2))                             AS debt_to_income
FROM loan_analysis.raw_loans;

-- Quick sanity check
SELECT COUNT(*) AS total_rows FROM loan_analysis.loans;
SELECT * FROM loan_analysis.loans LIMIT 10;
DESCRIBE loan_analysis.loans;
