# Data Architecture

```mermaid
flowchart TD

    A[Raw CSV Data] --> B[Python Data Loading]

    B --> C[Data Quality Checks]

    C --> D[Clean & Standardized Data]

    D --> E[Golden Datasets]

    E --> F[Actual Recovery Analysis]

    E --> G[Campaign Performance Analysis]

    E --> H[Attribution & Data Quality Analysis]

    F --> I[Executive Metrics]

    G --> I

    H --> I

    I --> J[₹10 Cr Investment Recommendation]

    E --> K[SQL Analysis Repository]

    I --> L[Executive Dashboard]

    J --> L

    H --> L

    L --> M[Executive Memo / Final Recommendations]




### Architecture flow

```text
Raw CSVs
   ↓
Python Loading
   ↓
Data Quality Checks
   ↓
Clean / Standardized Data
   ↓
Golden Datasets
   ↓
Analysis
   ├── Actual Recovery
   ├── Campaign Performance
   └── Attribution Issues
   ↓
Executive Metrics
   ↓
₹10 Cr Recommendation
   ↓
Dashboard + Executive Memo