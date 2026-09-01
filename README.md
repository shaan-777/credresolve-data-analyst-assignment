# CredResolve Data Analyst Assignment
https://credresolve-dashboard.streamlit.app/
## Objective

This project reconstructs actual collections recovery performance, investigates campaign attribution and data-quality issues, validates the reported 11% improvement, and recommends deployment of a ₹10 Cr investment.

---

## Key Findings

- **23,344 accounts** were targeted.
- **Actual reconstructed recovery:** approximately **₹187.89 Cr**.
- **Campaign-attributed recovery:** approximately **₹279.11 Cr**.
- Campaign-attributed recovery is approximately **1.49x** actual recovery.
- **Measured improvement:** **2.99%**.
- **Reported improvement:** **11%**.
- The reported improvement exceeds the measured result by approximately **8.01 percentage points**.
- **56.70% of targeted accounts** were assigned to multiple campaigns.
- Approximately **₹9.12 Cr of campaign-attributed payment overlap** was identified.

---

## Recommendation

The ₹10 Cr investment should be selectively allocated toward campaigns with strong recovery and conversion performance.

However, campaign-attributed recovery should not be used as a direct measure of incremental campaign impact until payment attribution is made mutually exclusive.

The recommended attribution methodology is:

1. Match each payment to the customer account.
2. Identify eligible campaign contact events before payment.
3. Apply a predefined attribution window.
4. Attribute each payment to only one campaign.
5. Measure incremental recovery against a baseline or control group.

---

## Project Structure

```text
notebooks/
    01_data_profiling.ipynb
    Main analysis and reconstruction workflow

data/raw/
    Original source dataset

data/golden/
    Clean analytical datasets and executive metrics

sql/
    SQL analysis queries

dashboard/
    Streamlit executive dashboard

docs/
    Architecture and executive memo

reports/
    Data-quality and attribution findings
