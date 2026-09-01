# ============================================================
# CREDRESOLVE - COLLECTIONS PERFORMANCE EXECUTIVE DASHBOARD
# ============================================================

import streamlit as st
import pandas as pd
from pathlib import Path


# ------------------------------------------------------------
# PAGE CONFIG
# ------------------------------------------------------------

st.set_page_config(
    page_title="Collections Performance Dashboard",
    page_icon="📊",
    layout="wide"
)


# ------------------------------------------------------------
# DATA PATHS
# ------------------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent.parent

GOLDEN_DIR = BASE_DIR / "data" / "golden"


# ------------------------------------------------------------
# LOAD DATA
# ------------------------------------------------------------

@st.cache_data
def load_data():

    executive_metrics = pd.read_csv(
        GOLDEN_DIR / "golden_executive_metrics.csv"
    )

    campaign_performance = pd.read_csv(
        GOLDEN_DIR / "golden_campaign_performance.csv"
    )

    campaign_pre_post = pd.read_csv(
        GOLDEN_DIR / "golden_campaign_pre_post.csv"
    )

    investment = pd.read_csv(
        GOLDEN_DIR / "golden_investment_recommendation.csv"
    )

    data_quality = pd.read_csv(
        GOLDEN_DIR / "golden_data_quality_summary.csv"
    )

    return (
        executive_metrics,
        campaign_performance,
        campaign_pre_post,
        investment,
        data_quality
    )


(
    executive_metrics,
    campaign_performance,
    campaign_pre_post,
    investment,
    data_quality
) = load_data()


# ------------------------------------------------------------
# TITLE
# ------------------------------------------------------------

st.title("📊 Collections Recovery Performance Dashboard")

st.caption(
    "Actual Recovery Reconstruction | Campaign Performance | "
    "Attribution Validation | ₹10 Cr Investment Recommendation"
)


# ============================================================
# EXECUTIVE KPIs
# ============================================================

st.subheader("Executive Summary")


# Convert executive metrics into dictionary

metric_map = dict(
    zip(
        executive_metrics.iloc[:, 0],
        executive_metrics.iloc[:, 1]
    )
)


# Display first four metrics dynamically

metrics_list = list(metric_map.items())[:4]


if len(metrics_list) >= 4:

    col1, col2, col3, col4 = st.columns(4)

    columns = [
        col1,
        col2,
        col3,
        col4
    ]

    for column, (metric, value) in zip(
        columns,
        metrics_list
    ):

        if isinstance(value, float):

            display_value = f"{value:,.2f}"

        else:

            display_value = f"{value:,}"

        column.metric(
            metric,
            display_value
        )


# ============================================================
# CAMPAIGN PERFORMANCE
# ============================================================

st.divider()

st.subheader("Campaign Performance")


top_campaigns = (
    campaign_performance
    .sort_values(
        "total_recovered",
        ascending=False
    )
    .head(10)
)


st.bar_chart(
    top_campaigns.set_index(
        "campaign_id"
    )[
        "total_recovered"
    ]
)


st.dataframe(
    top_campaigns,
    use_container_width=True
)


# ============================================================
# CAMPAIGN CONVERSION
# ============================================================

st.divider()

st.subheader("Campaign Conversion Rate")


conversion_df = (
    campaign_performance
    .sort_values(
        "conversion_rate_pct",
        ascending=False
    )
    .head(10)
)


st.bar_chart(
    conversion_df.set_index(
        "campaign_id"
    )[
        "conversion_rate_pct"
    ]
)


# ============================================================
# PRE VS POST
# ============================================================

st.divider()

st.subheader("Recovery Before vs After Campaign Targeting")


if "period" in campaign_pre_post.columns:

    pre_post_chart = (
        campaign_pre_post
        .groupby("period")
        .sum(
            numeric_only=True
        )
    )

    st.bar_chart(
        pre_post_chart
    )

else:

    st.dataframe(
        campaign_pre_post,
        use_container_width=True
    )


# ============================================================
# ₹10 CR INVESTMENT RECOMMENDATION
# ============================================================

st.divider()

st.subheader("₹10 Cr Recommended Investment Allocation")


investment_top = (
    investment
    .sort_values(
        "recommended_investment_cr",
        ascending=False
    )
    .head(10)
)


st.bar_chart(
    investment_top.set_index(
        "campaign_id"
    )[
        "recommended_investment_cr"
    ]
)


st.dataframe(
    investment_top,
    use_container_width=True
)


# ============================================================
# DATA QUALITY RISKS
# ============================================================

st.divider()

st.subheader("⚠️ Data Quality & Attribution Risks")


st.dataframe(
    data_quality,
    use_container_width=True
)


# ============================================================
# FINAL BUSINESS INSIGHT
# ============================================================

st.divider()

st.subheader("Key Interpretation")


st.info(
    """
    Actual recovery should be measured from unique valid payment events.
    Campaign-level recovery may overstate performance when the same
    account appears in multiple campaigns. Investment decisions should
    therefore prioritize campaigns with strong recovery performance
    while applying deterministic attribution rules.
    """
)