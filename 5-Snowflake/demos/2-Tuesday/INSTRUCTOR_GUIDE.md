# Instructor Guide: Tuesday Demos

## Overview
**Day:** 2-Tuesday - SnowSQL Operations & Data Loading  
**Total Demo Time:** ~55 minutes  
**Prerequisites:** Monday demos completed, DEV_DB exists with Medallion schemas

---

## Demo 1: SnowSQL Operations

**File:** `demo_snowsql_operations.sql`  
**Time:** ~15 minutes

### Key Points
1. Verify connection context with SELECT CURRENT_*()
2. Basic queries against SNOWFLAKE_SAMPLE_DATA  
3. Joins work exactly like Spark SQL
4. Query history available via INFORMATION_SCHEMA

### Talking Points
- "SnowSQL is like spark-shell or pyspark REPL"
- "If you know Spark SQL, you know this syntax"
- "Meta-commands (!) are like IPython magic commands"

---

## Demo 2: Data Loading with COPY INTO

**File:** `demo_data_loading.sql`  
**Time:** ~25 minutes

### Pre-Demo Setup
Create sample CSV file (sample_orders.csv):
```csv
order_id,customer_id,order_date,amount,status
O001,C100,2024-01-15,150.00,completed
O002,C101,2024-01-16,275.50,pending
O003,C100,2024-01-17,89.99,completed
```

### Key Points
1. FILE FORMAT = spark.read options
2. STAGE = managed bucket (internal) or S3 pointer (external)
3. COPY INTO = spark.read().write() parallelized
4. ON_ERROR = CONTINUE like Spark corrupt record handling
5. VARIANT for semi-structured JSON

### Talking Points
- "COPY INTO is the workhorse - like spark.read but parallelized automatically"
- "Internal stages = no AWS credentials needed for learning"
- "File formats are reusable - define once, use everywhere"

---

## Demo 3: Tables and Views

**File:** `demo_tables_views.sql`  
**Time:** ~15 minutes

### Key Points
1. Three table types: PERMANENT, TRANSIENT, TEMPORARY
2. Time Travel with AT (OFFSET => -N) syntax
3. UNDROP TABLE for recovery
4. CLONE for instant copies
5. SECURE VIEW hides definition

### Wow Moment
Show Time Travel: update a row, then query with AT (OFFSET => -60) to see the old value.

### Talking Points
- "Time Travel is BUILT-IN - no Delta Lake setup required"
- "Like git for your data, out of the box"
- "Use TRANSIENT for staging to save costs"

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| PUT command fails in Snowsight | PUT only works in SnowSQL CLI, use UI upload instead |
| File not found in stage | LIST @STAGE_NAME to verify file location |
| COPY INTO loads 0 rows | Check file format matches actual file structure |
| Time Travel shows same data | Wait longer (at least 60 seconds between changes) |

---

## Transition to Wednesday
"Today we loaded data and learned about table types. Tomorrow we'll cover advanced features: UDFs, Snowpipe, Streams & Tasks, and dimensional modeling."
