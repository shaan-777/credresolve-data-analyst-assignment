-- ============================================================
-- 03 DATA QUALITY & ATTRIBUTION CHECKS
-- ============================================================
--
-- Objective:
-- Identify data quality and attribution issues that can affect
-- reported recovery performance and campaign measurement.
-- ============================================================


-- ============================================================
-- CHECK 1: MISSING VALUES IN KEY PAYMENT FIELDS
-- ============================================================

SELECT
    COUNT(*) AS total_payment_rows,

    SUM(
        CASE
            WHEN account_id IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_account_id

FROM raw_payments;


-- ============================================================
-- CHECK 2: INVALID / NON-POSITIVE PAYMENTS
-- ============================================================
--
-- Replace payment_amount with the actual column name if needed.
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    SUM(
        CASE
            WHEN payment_amount IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_payment_amount,

    SUM(
        CASE
            WHEN payment_amount <= 0 THEN 1
            ELSE 0
        END
    ) AS non_positive_payment_amount

FROM raw_payments;


-- ============================================================
-- CHECK 3: DUPLICATE PAYMENT RECORDS
-- ============================================================

SELECT
    COUNT(*) AS duplicate_groups,

    SUM(
        duplicate_count - 1
    ) AS duplicate_rows

FROM (

    SELECT
        account_id,
        payment_amount,
        payment_time,

        COUNT(*) AS duplicate_count

    FROM raw_payments

    GROUP BY
        account_id,
        payment_amount,
        payment_time

    HAVING COUNT(*) > 1

) duplicates;


-- ============================================================
-- CHECK 4: ACCOUNTS IN MULTIPLE CAMPAIGNS
-- ============================================================

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


-- ============================================================
-- CHECK 5: PERCENTAGE OF MULTI-CAMPAIGN ACCOUNTS
-- ============================================================

WITH account_campaign_counts AS (

    SELECT
        account_id,

        COUNT(
            DISTINCT campaign_id
        ) AS campaign_count

    FROM account_campaign_base

    GROUP BY account_id

)

SELECT

    COUNT(*) AS total_targeted_accounts,

    SUM(
        CASE
            WHEN campaign_count > 1 THEN 1
            ELSE 0
        END
    ) AS multi_campaign_accounts,

    ROUND(

        SUM(
            CASE
                WHEN campaign_count > 1 THEN 1
                ELSE 0
            END
        )
        * 100.0
        /
        COUNT(*),

        2

    ) AS multi_campaign_pct

FROM account_campaign_counts;


-- ============================================================
-- CHECK 6: REPEAT TARGETING
-- ============================================================

SELECT

    COUNT(*) AS repeated_account_campaign_pairs

FROM (

    SELECT

        account_id,
        campaign_id

    FROM raw_daily_targeting

    GROUP BY

        account_id,
        campaign_id

    HAVING COUNT(*) > 1

) repeated_targeting;


-- ============================================================
-- CHECK 7: ACTUAL RECOVERY VS CAMPAIGN-ATTRIBUTED RECOVERY
-- ============================================================

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
    ) AS campaign_attributed_recovery,

    (
        SELECT
            SUM(total_recovered)
        FROM campaign_performance
    )
    -
    (
        SELECT
            SUM(payment_amount)
        FROM clean_payments
    ) AS potential_attribution_overlap;


-- ============================================================
-- CHECK 8: PAYMENT RECOVERY CONCENTRATION
-- ============================================================

SELECT

    COUNT(
        DISTINCT account_id
    ) AS paying_accounts,

    SUM(
        payment_amount
    ) AS total_actual_recovery,

    AVG(
        payment_amount
    ) AS average_payment_amount,

    MAX(
        payment_amount
    ) AS maximum_single_payment

FROM clean_payments;


-- ============================================================
-- CHECK 9: CAMPAIGNS WITH ZERO PAYING ACCOUNTS
-- ============================================================

SELECT

    campaign_id,

    targeted_accounts,

    paying_accounts,

    total_recovered

FROM campaign_performance

WHERE paying_accounts = 0

ORDER BY targeted_accounts DESC;


-- ============================================================
-- CHECK 10: FINAL ATTRIBUTION WARNING
-- ============================================================

SELECT
    'Campaign-attributed recovery should not be summed as unique business recovery when accounts belong to multiple campaigns.'
    AS data_quality_warning;