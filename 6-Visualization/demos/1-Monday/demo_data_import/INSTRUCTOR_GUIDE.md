# Demo: Connecting to Snowflake and Importing Data

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 1-Monday |
| **Topic** | Data Connectivity — Snowflake Gold Zone |
| **Type** | Hybrid (Concept + Implementation) |
| **Time** | ~20 minutes |
| **Prerequisites** | Power BI Desktop open, Snowflake credentials from Week 5 |

**Weekly Epic:** *Data Storytelling — From Warehouse to Insight with Power BI and Streamlit*

---

## Phase 1: The Concept (Whiteboard/Diagram)

**Time:** 5 mins

1. Open `diagrams/data-flow-week5-to-week6.mermaid`
2. Trace the full data pipeline:
   - **Week 5:** Raw data → Bronze → Silver → Gold (dbt transformations)
   - **Week 6:** Gold layer → Power BI Import → Interactive Dashboard
3. **Narrative:** *"Last week you built a star schema in Snowflake's GOLD layer. Today we complete the data storytelling journey — connecting Power BI to consume that warehouse."*

4. Open `diagrams/import-vs-directquery.mermaid`
5. Compare the two data connectivity modes:
   - **Import** — Data cached in Power BI memory. Fast queries. Needs scheduled refresh.
   - **DirectQuery** — Queries sent to Snowflake in real time. Always current. Source handles load.

> **Discussion Prompt:** *"For interactive dashboards with historical data, Import mode is usually the right choice. When would you choose DirectQuery instead?"*

---

## Phase 2: The Code (Live Implementation)

**Time:** 15 mins

### Step 1: Snowflake Connection (7 mins)

Reference the Week 5 tables we'll connect to:
| Table | Description | Approx Rows |
|-------|-------------|-------------|
| `GOLD.DIM_DATE` | Date dimension | ~15K |
| `GOLD.DIM_CUSTOMER` | Customer dimension | ~150K |
| `GOLD.DIM_PRODUCT` | Product dimension | ~200K |
| `GOLD.FCT_ORDER_LINES` | Fact table | ~6M |

1. Click **Get Data** > Search "Snowflake"
2. Select **Snowflake** connector
3. Enter connection details:
   ```
   Server: <account_identifier>.snowflakecomputing.com
   Warehouse: COMPUTE_WH
   ```
4. Choose **Import** mode
   - "Import is faster for interactive dashboards"
   - "DirectQuery is for real-time requirements"
5. Authenticate with Snowflake credentials
6. Navigate to **DEV_DB > GOLD schema**

### Step 2: Select Tables (5 mins)

1. Check the following tables:
   - `DIM_DATE`
   - `DIM_CUSTOMER`
   - `DIM_PRODUCT`
   - `FCT_ORDER_LINES`
2. Click **Transform Data** (do NOT click Load yet)
   - "Always preview before loading — especially with 6M rows"
3. In Power Query, show:
   - Row counts for each table
   - Column data types
   - First few rows preview
4. **Apply & Close** to load the data

### Step 3: Verify the Import (3 mins)

1. Switch to **Model View**
2. Point out that Power BI auto-detected some relationships
3. "But we need to verify they match our star schema design — that's Tuesday"

---

## Key Talking Points

- "This is the production pattern: dbt builds the GOLD layer, Power BI consumes it"
- "Import mode creates a snapshot — we'll configure refresh schedules Thursday"
- "Notice the column names came from Snowflake exactly as we defined them"

---

## Common Issues

| Issue | Solution |
|-------|----------|
| Snowflake connection timeout | Increase timeout in Advanced settings |
| "Driver not found" error | Install Snowflake ODBC driver |
| Slow import performance | Filter data, select fewer columns |
| Relationship not detected | Manually create in Model view (Tuesday) |

---

## Required Reading Reference

Before this demo, trainees should have read:
- `connecting-to-data-sources.md` — Connection types and authentication
- `importing-data.md` — Import vs DirectQuery deep dive
