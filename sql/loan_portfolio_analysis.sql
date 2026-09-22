-- ============================================================
-- LOAN PORTFOLIO ANALYSIS
-- Author: <YOUR NAME HERE>
-- Dataset: Lending Club Loan Data (public dataset, Kaggle)
-- Tool: MySQL Workbench
-- Works against the single `loan_analysis.loans` table.
-- ============================================================

USE loan_analysis;

-- ------------------------------------------------------------
-- SECTION 0: SANITY CHECK
-- ------------------------------------------------------------
SELECT * FROM loans LIMIT 10;
DESCRIBE loans;


-- ------------------------------------------------------------
-- SECTION 1: PORTFOLIO OVERVIEW
-- ------------------------------------------------------------

-- 1.1 Total loan applications
SELECT COUNT(*) AS total_applications FROM loans;

-- 1.2 Portfolio split by grade
SELECT
    grade,
    COUNT(*) AS applications,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM loans), 2) AS pct_of_portfolio
FROM loans
GROUP BY grade
ORDER BY applications DESC;

-- 1.3 Portfolio split by purpose
SELECT purpose, COUNT(*) AS applications
FROM loans
GROUP BY purpose
ORDER BY applications DESC;

-- 1.4 Average loan size and average interest rate
SELECT
    ROUND(AVG(loan_amount), 2)   AS avg_loan_amount,
    ROUND(AVG(interest_rate), 3) AS avg_interest_rate
FROM loans;

-- 1.5 Loan status breakdown
SELECT status, COUNT(*) AS applications
FROM loans
GROUP BY status
ORDER BY applications DESC;

-- 1.6 Top 10 states by total dollars loaned
SELECT state, SUM(loan_amount) AS total_loaned
FROM loans
GROUP BY state
ORDER BY total_loaned DESC
LIMIT 10;


-- ------------------------------------------------------------
-- SECTION 2: RISK & DEFAULT ANALYSIS
-- ------------------------------------------------------------

-- 2.1 Default rate by state
SELECT
    state,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN status = 'Charged Off' THEN 1 ELSE 0 END) AS defaults,
    ROUND(
        SUM(CASE WHEN status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS default_rate_pct
FROM loans
GROUP BY state
ORDER BY default_rate_pct DESC;

-- 2.2 Reusable procedure: rate of any status, by state
DELIMITER $$
CREATE PROCEDURE DefaultRateByState(IN target_status VARCHAR(50))
BEGIN
    SELECT
        state,
        COUNT(*) AS total_loans,
        SUM(CASE WHEN status = target_status THEN 1 ELSE 0 END) AS matching_loans,
        ROUND(
            SUM(CASE WHEN status = target_status THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
            2
        ) AS matching_rate_pct
    FROM loans
    GROUP BY state
    ORDER BY matching_rate_pct DESC;
END$$
DELIMITER ;

CALL DefaultRateByState('Charged Off');
CALL DefaultRateByState('Fully Paid');

-- 2.3 Average loan size by grade
SELECT grade, ROUND(AVG(loan_amount), 2) AS avg_loan_amount
FROM loans
GROUP BY grade
ORDER BY avg_loan_amount DESC;

-- 2.4 Average interest rate by grade (already numeric, no cleanup needed)
SELECT grade, ROUND(AVG(interest_rate), 2) AS avg_interest_rate
FROM loans
GROUP BY grade
ORDER BY avg_interest_rate DESC;

-- 2.5 Top 10 riskiest borrowers by debt-to-income ratio
SELECT loan_id, debt_to_income, annual_income, loan_amount
FROM loans
ORDER BY debt_to_income DESC
LIMIT 10;

-- 2.6 Fully paid vs charged off comparison
SELECT
    status,
    COUNT(*) AS loans,
    ROUND(AVG(loan_amount), 2)    AS avg_loan_amount,
    ROUND(AVG(annual_income), 2)  AS avg_income,
    ROUND(AVG(debt_to_income), 2) AS avg_dti
FROM loans
WHERE status IN ('Fully Paid', 'Charged Off')
GROUP BY status;

-- 2.7 Ranked VIEW of state-level risk, using a window function
CREATE VIEW state_risk_ranking AS
SELECT
    state,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN status = 'Charged Off' THEN 1 ELSE 0 END) AS defaults,
    ROUND(
        SUM(CASE WHEN status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS default_rate_pct,
    DENSE_RANK() OVER (
        ORDER BY SUM(CASE WHEN status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) DESC
    ) AS risk_rank
FROM loans
GROUP BY state;

SELECT * FROM state_risk_ranking;


-- ------------------------------------------------------------
-- SECTION 3: BORROWER PROFILING
-- ------------------------------------------------------------

-- 3.1 Average income by home ownership type
SELECT
    home_ownership,
    ROUND(AVG(annual_income), 2) AS avg_income,
    COUNT(*) AS borrowers
FROM loans
GROUP BY home_ownership
ORDER BY avg_income DESC;

-- 3.2 Verified vs non-verified borrowers
SELECT
    verification_status,
    COUNT(*) AS borrowers,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
    ROUND(AVG(annual_income), 2) AS avg_income
FROM loans
GROUP BY verification_status;

-- 3.3 Average income by state
SELECT state, ROUND(AVG(annual_income), 2) AS avg_income, COUNT(*) AS borrowers
FROM loans
GROUP BY state
ORDER BY avg_income DESC;

-- 3.4 Total dollars funded by purpose (top 10)
SELECT purpose, ROUND(SUM(funded_amount), 2) AS total_funded
FROM loans
GROUP BY purpose
ORDER BY total_funded DESC
LIMIT 10;

-- 3.5 Monthly installment trend over time
SELECT
    issue_date,
    COUNT(*) AS loans_issued,
    ROUND(AVG(installment), 2) AS avg_installment
FROM loans
GROUP BY issue_date
ORDER BY issue_date;

-- 3.6 Single-loan lookup by ID
DELIMITER $$
CREATE PROCEDURE LoanProfile(IN target_loan_id INT)
BEGIN
    SELECT * FROM loans WHERE loan_id = target_loan_id;
END$$
DELIMITER ;

-- Grab a real loan_id from your data first, e.g.:
-- SELECT loan_id FROM loans LIMIT 1;
CALL LoanProfile(1077501);  -- swap in a real loan_id from your own data


-- ------------------------------------------------------------
-- SECTION 4: ONE-CALL STATE DASHBOARD
-- ------------------------------------------------------------
DELIMITER $$
CREATE PROCEDURE StateDashboard(IN target_state VARCHAR(10))
BEGIN
    SELECT
        state,
        COUNT(*) AS total_loans,
        ROUND(SUM(funded_amount), 2) AS total_funded,
        ROUND(AVG(loan_amount), 2)   AS avg_loan_amount,
        ROUND(AVG(annual_income), 2) AS avg_income
    FROM loans
    WHERE state = target_state
    GROUP BY state;

    SELECT grade, COUNT(*) AS loans
    FROM loans
    WHERE state = target_state
    GROUP BY grade
    ORDER BY loans DESC;

    SELECT purpose, COUNT(*) AS loans
    FROM loans
    WHERE state = target_state
    GROUP BY purpose
    ORDER BY loans DESC
    LIMIT 5;

    SELECT status, COUNT(*) AS loans
    FROM loans
    WHERE state = target_state
    GROUP BY status
    ORDER BY loans DESC;
END$$
DELIMITER ;

CALL StateDashboard('CA');
