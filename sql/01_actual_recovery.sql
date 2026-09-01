-- ============================================================
-- 01 ACTUAL RECOVERY RECONSTRUCTION
-- ============================================================
--
-- Objective:
-- Reconstruct actual recovery from payment transactions.
-- Only valid positive payments are included.
--
-- Grain:
-- One row per account
-- ============================================================


-- ------------------------------------------------------------
-- STEP 1: LOAD PAYMENT DATA
-- ------------------------------------------------------------

CREATE OR REPLACE TABLE raw_payments AS

SELECT *

FROM read_csv_auto(
    '../data/raw/payments.csv'
);


-- ------------------------------------------------------------
-- STEP 2: INSPECT PAYMENT DATA
-- ------------------------------------------------------------

DESCRIBE raw_payments;


-- ------------------------------------------------------------
-- STEP 3: CREATE CLEAN PAYMENT DATA
-- ------------------------------------------------------------
--
-- IMPORTANT:
-- After running DESCRIBE, confirm the actual column names.
-- If required, replace:
--
-- account_id
-- payment_amount
-- payment_time
--
-- with the exact names from your dataset.
-- ------------------------------------------------------------


CREATE OR REPLACE TABLE clean_payments AS

SELECT

    account_id,

    CAST(
        payment_amount
        AS DOUBLE
    ) AS payment_amount,

    CAST(
        payment_time
        AS TIMESTAMP
    ) AS payment_time

FROM raw_payments

WHERE account_id IS NOT NULL

    AND payment_amount IS NOT NULL

    AND payment_amount > 0

    AND payment_time IS NOT NULL;


-- ------------------------------------------------------------
-- STEP 4: ACCOUNT-LEVEL ACTUAL RECOVERY
-- ------------------------------------------------------------

CREATE OR REPLACE TABLE account_recovery AS

SELECT

    account_id,

    SUM(
        payment_amount
    ) AS total_recovered,

    COUNT(*) AS number_of_payments,

    MIN(
        payment_time
    ) AS first_payment_time,

    MAX(
        payment_time
    ) AS last_payment_time

FROM clean_payments

GROUP BY account_id;


-- ------------------------------------------------------------
-- STEP 5: VALIDATION SUMMARY
-- ------------------------------------------------------------

SELECT

    COUNT(*) AS valid_payment_events,

    COUNT(
        DISTINCT account_id
    ) AS paying_accounts,

    SUM(
        payment_amount
    ) AS total_actual_recovery,

    MIN(
        payment_time
    ) AS first_payment_date,

    MAX(
        payment_time
    ) AS last_payment_date

FROM clean_payments;


-- ------------------------------------------------------------
-- STEP 6: VIEW TOP RECOVERED ACCOUNTS
-- ------------------------------------------------------------

SELECT *

FROM account_recovery

ORDER BY total_recovered DESC

LIMIT 20;