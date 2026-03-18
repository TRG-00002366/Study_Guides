# Instructor Guide: Monday Demos

## Overview
**Day:** 1-Monday - Data Warehouse Foundations & Snowflake Architecture  
**Total Demo Time:** ~45 minutes  
**Prerequisite:** Trainees have Snowflake Free Trial accounts

---

## Demo 1: Snowflake Setup & First Steps

**File:** `demo_snowflake_setup.sql`  
**Time:** ~25 minutes

### Phase 1: Context & Cost Control (5 mins)
1. Open Snowsight and connect
2. Run the context query to show current session
3. **CRITICAL:** Set AUTO_SUSPEND = 60 and explain why
4. Bridge: "Like setting spark.executor.instances conservatively"

### Phase 2: Exploring Sample Data (5 mins)
1. Switch to SNOWFLAKE_SAMPLE_DATA.TPCH_SF1
2. Run COUNT(*) on ORDERS - emphasize sub-second response
3. Bridge: "On Spark, you'd still be waiting for cluster warm-up"

### Phase 3: Creating Your Own Playground (10 mins)
1. Create DEV_DB database
2. Create SANDBOX schema
3. Create a simple test table
4. Verify everything works

### Phase 4: UI Tour (5 mins)
1. Show Query History
2. Show Database browser
3. Show Warehouse management
4. Point out the AUTO_SUSPEND setting

### Key Talking Points
- "No Docker, no installation - it just works"
- "Virtual Warehouse = EMR cluster that starts in 2 seconds"
- "USE statements = SparkSession configuration"

---

## Demo 2: Medallion Architecture Overview

**File:** `demo_medallion_overview.sql`  
**Time:** ~20 minutes

### Phase 1: Concept Talk (5 mins)
Before running SQL, explain the three layers verbally:
- BRONZE = Raw landing zone
- SILVER = Cleansed and typed
- GOLD = Business-ready aggregates

### Phase 2: Create Schema Structure (5 mins)
1. Create BRONZE, SILVER, GOLD schemas
2. Explain that these are just organizational containers

### Phase 3-5: Create Layer Tables (10 mins)
1. BRONZE.RAW_ORDERS with VARIANT column
   - Bridge: "Like spark.read.json() without a schema"
2. SILVER.ORDERS with typed columns
   - Bridge: "Like defining a StructType schema"
3. GOLD.DAILY_REVENUE with aggregated metrics
   - Bridge: "This is what your BI tool connects to"

### Whiteboard Drawing
Draw the data flow:
```
BRONZE.RAW_ORDERS
       |
       v (cleanse + type)
SILVER.ORDERS
       |
       v (aggregate)
GOLD.DAILY_REVENUE
```

### Key Talking Points
- "Medallion is an architecture PATTERN, not a Snowflake feature"
- "Data gains quality as it flows through layers"
- "We'll load actual data tomorrow"

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Query hangs | Trainee forgot to USE WAREHOUSE |
| Permission denied | Need ACCOUNTADMIN role for creating databases |
| Table already exists | Use CREATE OR REPLACE |
| Warehouse using credits | Verify AUTO_SUSPEND is set |

---

## Transition to Tuesday
"Today we created the structure. Tomorrow we'll actually load data into Bronze using COPY INTO and internal stages."
