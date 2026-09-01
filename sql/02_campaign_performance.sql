-- ============================================================
-- 02 CAMPAIGN PERFORMANCE ANALYSIS
-- ============================================================
--
-- Objective:
-- Measure campaign-level recovery and payment conversion.
--
-- Attribution warning:
-- An account can potentially appear in multiple campaigns.
-- Therefore campaign-level recovery can contain attribution
-- overlap and must not automatically be summed as unique
-- total business recovery.
-- ============================================================


-- ------------------------------------------------------------
-- STEP 1: LOAD DAILY TARGETING DATA
-- ------------------------------------------------------------

CREATE OR REPLACE TABLE raw_daily_targeting AS

SELECT *

FROM read_csv_auto(
    '../data/raw/daily_targeting.csv'
);


-- ------------------------------------------------------------
-- STEP 2: LOAD PAYMENT DATA
-- ------------------------------------------------------------

CREATE OR REPLACE TABLE raw_payments AS

SELECT *

FROM read_csv_auto(
    '../data/raw/payments.csv'
);


-- ------------------------------------------------------------
-- STEP 3: INSPECT SCHEMAS
-- ------------------------------------------------------------

DESCRIBE raw_daily_targeting;

DESCRIBE raw_payments;


-- ------------------------------------------------------------
-- STEP 4: CREATE ACCOUNT-CAMPAIGN BASE
-- ------------------------------------------------------------
--
-- IMPORTANT:
-- Confirm the actual column names from DESCRIBE.
--
-- Expected logical fields:
-- account_id
-- campaign_id
-- ------------------------------------------------------------


CREATE OR REPLACE TABLE account_campaign_base AS

SELECT DISTINCT

    account_id,

    campaign_id

FROM raw_daily_targeting

WHERE account_id IS NOT NULL

    AND campaign_id IS NOT NULL;


-- ------------------------------------------------------------
-- STEP 5: CREATE CLEAN PAYMENTS
-- ------------------------------------------------------------
--
-- Replace column names below if the raw CSV uses
-- different names.
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

    AND payment_amount > 0;


-- ------------------------------------------------------------
-- STEP 6: ACCOUNT-LEVEL CAMPAIGN PAYMENT PERFORMANCE
-- ------------------------------------------------------------

CREATE OR REPLACE TABLE account_campaign_payment AS

SELECT

    ac.campaign_id,

    ac.account_id,

    COALESCE(
        SUM(
            cp.payment_amount
        ),
        0
    ) AS total_recovered,

    COUNT(
        cp.payment_amount
    ) AS payment_events,

    CASE

        WHEN COALESCE(
            SUM(
                cp.payment_amount
            ),
            0
        ) > 0

        THEN 1

        ELSE 0

    END AS paid_flag

FROM account_campaign_base ac

LEFT JOIN clean_payments cp

    ON ac.account_id =
       cp.account_id

GROUP BY

    ac.campaign_id,

    ac.account_id;


-- ------------------------------------------------------------
-- STEP 7: CAMPAIGN PERFORMANCE SUMMARY
-- ------------------------------------------------------------

CREATE OR REPLACE TABLE campaign_performance AS

SELECT

    campaign_id,

    COUNT(
        DISTINCT account_id
    ) AS targeted_accounts,

    SUM(
        paid_flag
    ) AS paying_accounts,

    SUM(
        total_recovered
    ) AS total_recovered,

    ROUND(

        SUM(
            paid_flag
        ) * 100.0

        /

        NULLIF(
            COUNT(
                DISTINCT account_id
            ),
            0
        ),

        2

    ) AS conversion_rate_pct,

    ROUND(

        SUM(
            total_recovered
        )

        /

        NULLIF(
            COUNT(
                DISTINCT account_id
            ),
            0
        ),

        2

    ) AS avg_recovery_per_target,

    ROUND(

        SUM(
            total_recovered
        )

        /

        NULLIF(
            SUM(
                paid_flag
            ),
            0
        ),

        2

    ) AS avg_recovery_per_payer

FROM account_campaign_payment

GROUP BY campaign_id;


-- ------------------------------------------------------------
-- STEP 8: VIEW CAMPAIGN RESULTS
-- ------------------------------------------------------------

SELECT *

FROM campaign_performance

ORDER BY total_recovered DESC;


-- ------------------------------------------------------------
-- STEP 9: CHECK MULTI-CAMPAIGN ATTRIBUTION RISK
-- ------------------------------------------------------------

SELECT

    COUNT(*) AS accounts_in_multiple_campaigns

FROM (

    SELECT

        account_id

    FROM account_campaign_base

    GROUP BY account_id

    HAVING COUNT(
        DISTINCT campaign_id
    ) > 1

) multi_campaign_accounts;


-- ------------------------------------------------------------
-- STEP 10: COMPARE ACTUAL VS ATTRIBUTED RECOVERY
-- ------------------------------------------------------------

SELECT

    (
        SELECT
            SUM(payment_amount)
        FROM clean_payments
    ) AS actual_unique_recovery,

    (
        SELECT
            SUM(total_recovered)
        FROM campaign_performance
    ) AS campaign_attributed_recovery;