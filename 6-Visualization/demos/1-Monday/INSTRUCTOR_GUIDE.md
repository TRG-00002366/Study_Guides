# Instructor Guide: Monday Demos

## Overview

**Day:** 1-Monday - Power BI Foundations and Data Connectivity

**Total Demo Time:** ~50 minutes

**Prerequisites:** Trainees have Snowflake accounts from Week 5, Power BI Desktop installed

---

## Demo 1: Power BI Desktop Setup and Interface Tour

**Time:** ~15 minutes

### Phase 1: Installation Verification (3 mins)
1. Confirm Power BI Desktop is installed (should be pre-done)
2. Launch the application
3. **Discussion:** "This is free to use - no license needed for building reports"

### Phase 2: Interface Tour (7 mins)
Walk through the three main views:

1. **Report View** (default)
   - Canvas for visualizations
   - Visualizations pane on the right
   - Fields pane showing data
   - Filters pane for slicers

2. **Data View** (table icon in left sidebar)
   - Spreadsheet-like data inspection
   - "Like viewing a DataFrame in Python"

3. **Model View** (diagram icon in left sidebar)
   - Relationship diagrams between tables
   - "This is where your Week 5 star schema knowledge comes in"

### Phase 3: Quick Sample Connection (5 mins)
1. Click **Get Data** > **More...**
2. Show the extensive list of connectors
3. Select **Sample Datasets** > **Sales and Marketing Sample**
4. Point out the auto-detected relationships

### Key Talking Points
- "Power BI Desktop is your development environment - like VS Code for dashboards"
- "The Service (online) is where you publish and share"
- "Three views match three phases: Model, Verify Data, Build Reports"

---

## Demo 2: Connecting to Snowflake Gold Zone

**Time:** ~20 minutes

### Phase 1: The Data Engineering Handoff (3 mins)
Before connecting, explain the narrative:

"Last week you built a star schema in Snowflake's GOLD layer. Today we complete the data storytelling journey - connecting Power BI to consume that warehouse."

Reference the Week 5 tables:
- `GOLD.DIM_DATE` - Date dimension (~15K rows)
- `GOLD.DIM_CUSTOMER` - Customer dimension (~150K rows)
- `GOLD.DIM_PRODUCT` - Product dimension (~200K rows)
- `GOLD.FCT_ORDER_LINES` - Fact table (~6M rows)

### Phase 2: Snowflake Connection (7 mins)
1. Click **Get Data** > Search "Snowflake"
2. Select **Snowflake** connector

3. **Enter connection details:**
   ```
   Server: <account_identifier>.snowflakecomputing.com
   Warehouse: COMPUTE_WH
   ```

4. **Choose Import mode** (explain why)
   - "Import is faster for interactive dashboards"
   - "DirectQuery is for real-time requirements"

5. **Authenticate** with Snowflake credentials

6. **Navigate to DEV_DB > GOLD schema**

### Phase 3: Select Tables (5 mins)
1. Check the following tables:
   - `DIM_DATE`
   - `DIM_CUSTOMER`
   - `DIM_PRODUCT`
   - `FCT_ORDER_LINES`

2. Click **Transform Data** (do NOT click Load yet)
   - "Always preview before loading - especially with 6M rows"

3. In Power Query, show:
   - Row counts for each table
   - Column data types
   - First few rows preview

4. **Apply & Close** to load the data

### Phase 4: Verify the Import (5 mins)
1. Switch to **Model View**
2. Point out that Power BI auto-detected some relationships
3. "But we need to verify they match our star schema design"

### Key Talking Points
- "This is the production pattern: dbt builds the GOLD layer, Power BI consumes it"
- "Import mode creates a snapshot - we'll configure refresh schedules Thursday"
- "Notice the column names came from Snowflake exactly as we defined them"

### Diagram: Data Flow
```
Week 5 Pipeline              Week 6 Visualization
----------------              -------------------
BRONZE.RAW_ORDERS
       |
       v
SILVER.ORDERS
       |
       v
GOLD.FCT_ORDER_LINES  ------>  Power BI Import
GOLD.DIM_*                      (VertipAQ Engine)
                                      |
                                      v
                               Interactive Dashboard
```

---

## Demo 3: Power Query Basics

**Time:** ~15 minutes

### Phase 1: Open Power Query Editor (2 mins)
1. Click **Transform Data** from Home ribbon
2. "Power Query is Excel's Get & Transform on steroids"
3. Point out the Applied Steps pane on the right

### Phase 2: Common Transformations (8 mins)

**Example 1: Rename Columns**
1. Select DIM_CUSTOMER query
2. Right-click CUSTOMER_NAME > Rename
3. Change to "Customer Name" (human-friendly)
4. Show the step added in Applied Steps

**Example 2: Change Data Types**
1. Select a numeric column
2. Click the type icon (ABC/123)
3. Change to appropriate type
4. "This is critical - wrong types break DAX calculations"

**Example 3: Filter Rows**
1. Select FCT_ORDER_LINES query
2. Click dropdown on ORDER_STATUS column
3. Uncheck "Cancelled" orders
4. "Filtering at source reduces data volume"

**Example 4: Add Calculated Column**
1. Click **Add Column** > **Custom Column**
2. Create a simple calculation:
   ```
   = [EXTENDED_PRICE] * (1 - [DISCOUNT_PCT])
   ```
3. Name it "Net Amount"
4. "This runs once during refresh, not every query"

### Phase 3: M Language Preview (5 mins)
1. Click **Advanced Editor**
2. Show the generated M code
3. "You don't need to write M, but understanding it helps debugging"

```m
let
    Source = Snowflake.Databases("account.snowflakecomputing.com","COMPUTE_WH"),
    DEV_DB_Database = Source{[Name="DEV_DB"]}[Data],
    GOLD_Schema = DEV_DB_Database{[Name="GOLD"]}[Data],
    DIM_CUSTOMER_Table = GOLD_Schema{[Name="DIM_CUSTOMER"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(DIM_CUSTOMER_Table,{{"CUSTOMER_NAME", "Customer Name"}})
in
    #"Renamed Columns"
```

4. **Close & Apply**

### Key Talking Points
- "Power Query is ETL inside Power BI - like mini Spark transformations"
- "Changes here happen during refresh, not at query time"
- "Always check Applied Steps - it's your transformation audit log"

---

## Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Snowflake connection timeout | Increase timeout in Advanced settings |
| "Driver not found" error | Install Snowflake ODBC driver |
| Slow import performance | Filter data, select fewer columns |
| Relationship not detected | Manually create in Model view (Tuesday) |
| Power Query changes not applied | Click "Close & Apply" |

---

## Transition to Tuesday

"Today we connected Power BI to Snowflake and saw the data. Tomorrow we'll:
1. Build proper relationships in the Model view (star schema in Power BI)
2. Write our first DAX measures to calculate business metrics
3. See how row and filter context work"

---

## Required Reading Reference

Before this demo, trainees should have read:
- `power-bi-introduction.md` - Platform overview
- `connecting-to-data-sources.md` - Connection concepts
- `importing-data.md` - Import vs DirectQuery
