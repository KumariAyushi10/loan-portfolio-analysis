USE loan_analysis;


SELECT * FROM loans LIMIT 10;
DESCRIBE loans;


SELECT COUNT(*) AS total_applications FROM loans;


SELECT
    grade,
    COUNT(*) AS applications,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM loans), 2) AS pct_of_portfolio
FROM loans
GROUP BY grade
ORDER BY applications DESC;


SELECT purpose, COUNT(*) AS applications
FROM loans
GROUP BY purpose
ORDER BY applications DESC;


SELECT
    ROUND(AVG(loan_amount), 2)   AS avg_loan_amount,
    ROUND(AVG(interest_rate), 3) AS avg_interest_rate
FROM loans;


SELECT status, COUNT(*) AS applications
FROM loans
GROUP BY status
ORDER BY applications DESC;


SELECT state, SUM(loan_amount) AS total_loaned
FROM loans
GROUP BY state
ORDER BY total_loaned DESC
LIMIT 10;



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


SELECT grade, ROUND(AVG(loan_amount), 2) AS avg_loan_amount
FROM loans
GROUP BY grade
ORDER BY avg_loan_amount DESC;


SELECT grade, ROUND(AVG(interest_rate), 2) AS avg_interest_rate
FROM loans
GROUP BY grade
ORDER BY avg_interest_rate DESC;


SELECT loan_id, debt_to_income, annual_income, loan_amount
FROM loans
ORDER BY debt_to_income DESC
LIMIT 10;


SELECT
    status,
    COUNT(*) AS loans,
    ROUND(AVG(loan_amount), 2)    AS avg_loan_amount,
    ROUND(AVG(annual_income), 2)  AS avg_income,
    ROUND(AVG(debt_to_income), 2) AS avg_dti
FROM loans
WHERE status IN ('Fully Paid', 'Charged Off')
GROUP BY status;


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



SELECT
    home_ownership,
    ROUND(AVG(annual_income), 2) AS avg_income,
    COUNT(*) AS borrowers
FROM loans
GROUP BY home_ownership
ORDER BY avg_income DESC;


SELECT
    verification_status,
    COUNT(*) AS borrowers,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
    ROUND(AVG(annual_income), 2) AS avg_income
FROM loans
GROUP BY verification_status;


SELECT state, ROUND(AVG(annual_income), 2) AS avg_income, COUNT(*) AS borrowers
FROM loans
GROUP BY state
ORDER BY avg_income DESC;


SELECT purpose, ROUND(SUM(funded_amount), 2) AS total_funded
FROM loans
GROUP BY purpose
ORDER BY total_funded DESC
LIMIT 10;


SELECT
    issue_date,
    COUNT(*) AS loans_issued,
    ROUND(AVG(installment), 2) AS avg_installment
FROM loans
GROUP BY issue_date
ORDER BY issue_date;


DELIMITER $$
CREATE PROCEDURE LoanProfile(IN target_loan_id INT)
BEGIN
    SELECT * FROM loans WHERE loan_id = target_loan_id;
END$$
DELIMITER ;


CALL LoanProfile(1077501);  



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
