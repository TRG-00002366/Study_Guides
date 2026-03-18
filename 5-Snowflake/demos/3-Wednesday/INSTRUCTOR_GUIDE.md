# Instructor Guide: Wednesday Demos

## Overview
**Day:** 3-Wednesday - Advanced Snowflake Features & Schema Design  
**Total Demo Time:** ~100 minutes  
**Prerequisites:** Tuesday demos completed, BRONZE/SILVER/GOLD schemas with sample data, SNOWFLAKE_SAMPLE_DATA access

---

## Demo 1: User-Defined Functions

**File:** `demo_udf_creation.sql`  
**Time:** ~20 minutes

### Key Points
1. SQL UDFs - fastest, compile to native operations
2. JavaScript UDFs - for complex string/logic
3. Test UDFs with SNOWFLAKE_SAMPLE_DATA
4. Avoid UDFs in WHERE clauses (blocks pruning)

### Talking Points
- "SQL UDFs are like Spark's built-in functions - fast"
- "JavaScript UDFs are like Spark Python UDFs but without serialization overhead"
- "Parameters are UPPERCASE in JavaScript UDFs"

---

## Demo 2: Snowpipe Setup (Conceptual)

**File:** `demo_snowpipe_setup.sql`  
**Time:** ~15 minutes

### Important Note
DO NOT attempt real S3 integration - it will derail the lesson with IAM configuration.

**This is a CONCEPTUAL demo.** No actual files are loaded. The goal is to understand Snowpipe syntax and architecture, not to execute a working pipeline.

### Key Points
1. Snowpipe = continuous, event-driven loading
2. AUTO_INGEST = TRUE in production with S3 events
3. Manual trigger with ALTER PIPE REFRESH
4. 1-2 minute latency from file arrival

### Talking Points
- "Snowpipe is like a Kafka consumer for files"
- "In production, you'd configure S3 event notifications"
- "Serverless - you pay per file, not for always-on compute"

---

## Demo 3: Streams and Tasks (KEY LESSON)

**File:** `demo_streams_tasks.sql`  
**Time:** ~25 minutes

### This is Critical
This demo connects to their Kafka and Airflow knowledge. Take time here.

### Key Points
1. Stream = Kafka offset tracking for tables
2. Task = Airflow task defined in SQL
3. WHEN SYSTEM$STREAM_HAS_DATA() = sensor
4. Tasks are SUSPENDED by default - must RESUME
5. EXECUTE TASK for manual testing
6. Chain tasks with AFTER clause (like Airflow >>)

### Talking Points
- "A Stream is like a Kafka offset - tracks what's processed"
- "A Task is like an Airflow task in pure SQL"
- "This is how you build Bronze->Silver->Gold automation"

### Whiteboard Drawing
```
INSERT INTO BRONZE.RAW_EVENTS
         |
         v
    [STREAM detects new rows]
         |
         v
    [TASK fires when stream has data]
         |
         v
INSERT INTO SILVER.PROCESSED_EVENTS
```

---

## Demo 4: TPC-H Data Modeling Exploration

**File:** `demo_tpch_data_modeling.sql`  
**Time:** ~20 minutes

### Key Points
1. TPC-H is a standard benchmark schema - great for learning
2. Uses SNOWFLAKE SCHEMA pattern (normalized, hierarchical)
3. Hierarchy: REGION -> NATION -> CUSTOMER/SUPPLIER
4. ORDERS is header fact, LINEITEM is detail fact
5. Cardinality increases from dimensions to facts

### Talking Points
- "This is a snowflake schema - the modeling pattern, not the product!"
- "Notice how REGION -> NATION -> CUSTOMER requires 2 JOINs"
- "LINEITEM is 6M rows because it's the lowest grain"
- "We'll flatten this into a star schema for our Gold layer"

### Whiteboard Drawing
```
REGION (5 rows)
   |
   v
NATION (25 rows)
   |
   +-------+-------+
   |               |
   v               v
CUSTOMER       SUPPLIER
(150K)          (10K)
   |               |
   v               |
ORDERS         PARTSUPP
(1.5M)          (800K)
   |               |
   v               |
LINEITEM ------+
(6M rows)
```

---

## Demo 5: Star Schema Design

**File:** `demo_star_schema.sql`  
**Time:** ~20 minutes

### Key Points
1. Date dimension - every star schema needs one
2. Customer dimension from sample data
3. Fact table with measures and foreign keys
4. Show analytical queries joining all three

### Talking Points
- "This is the Gold layer - pre-joined, dashboard-ready"
- "Date dimension lets you GROUP BY year, quarter without date functions"
- "BI tools are optimized for this pattern"

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Stream shows no data | Stream created AFTER data was inserted |
| Task doesn't run | Tasks are SUSPENDED by default, use ALTER TASK RESUME |
| EXECUTE TASK fails | Check WAREHOUSE is specified and running |
| JavaScript UDF errors | Use ES5 syntax (var, not let/const) |

---

## Transition to Thursday
"Today we learned advanced Snowflake features. Tomorrow we pivot to dbt - the transformation tool that sits on top of Snowflake. It's like Airflow for SQL."
