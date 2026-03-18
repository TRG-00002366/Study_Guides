# Principal Engineer's Guidance: Week 5 (Snowflake & dbt)

> **Document Purpose:** Strategic technical direction for the **Instructor Demo Agent**. This guidance ensures demos are practical, cost-effective, and pedagogically sound for trainees transitioning from Spark/Kafka/Airflow to Snowflake.

---

## Audience Profile & Context

**Who They Are:**
- Junior Data Engineers completing a 7-week bootcamp
- **Completed training in:** Python, SQL, PySpark (Weeks 1-2), Kafka (Week 3), Airflow (Week 4)
- **Zero experience with:** Snowflake, cloud data warehouses, dbt

**The Mental Model Shift:**
The trainees are coming from an "infrastructure-heavy" mindset where they manually configure Spark clusters, manage Kafka brokers, and deploy Airflow on Docker. Snowflake will feel almost suspiciously easy. Frame this week as: *"What if someone else managed all that infrastructure, and you just wrote SQL?"*

---

## General Strategy

### The "Spark Without the Headache" Narrative

Position Snowflake as the natural evolution of their Spark SQL knowledge. They already understand:
- DataFrames and SQL queries (Spark SQL)
- Separation of compute and storage (Spark on S3)
- Job scheduling and dependencies (Airflow DAGs)
- Event-driven processing (Kafka)

Snowflake builds on all of these but eliminates operational overhead.

### Cost Optimization Mandate

> **CRITICAL:** All demos must operate within a Snowflake Free Trial (30 days, $400 credits).

**Required Resource Strategy:**

| Resource Type | Use This | NOT This |
|---------------|----------|----------|
| **Query Data** | `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1` | Creating large custom datasets |
| **File Loading** | Internal named stages + UI upload | External S3/Azure with credentials |
| **Warehouse Size** | `X-SMALL` with `AUTO_SUSPEND = 60` | Larger warehouses left running |
| **dbt Target** | Personal dev schema (`DBT_<username>`) | Shared production schemas |

**Credit-Saving Commands to Include in EVERY Demo:**
```sql
-- ALWAYS show this pattern
ALTER WAREHOUSE COMPUTE_WH SET 
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;
```

---

## 1-Monday: Data Warehouse Foundations & Snowflake Architecture

### Demo: `demo_snowflake_setup.sql`

**The Gotcha:**
- Trainees will try to run queries before selecting a warehouse, then wonder why nothing happens.
- Case sensitivity: `MyTable` and `MYTABLE` are the same unless double-quoted.
- The Snowflake UI trial defaults to a `COMPUTE_WH` that is ALREADY RUNNING. Costs start immediately.

**The Bridge (Spark Analogies):**

| Snowflake Concept | Spark Equivalent | Instructor Script |
|-------------------|------------------|-------------------|
| Virtual Warehouse | Spark cluster (driver + executors) | "Think of a warehouse as an EMR cluster that starts in 2 seconds instead of 5 minutes." |
| Database | Spark catalog/database | "Same concept, different platform." |
| Schema | Spark database namespace | "Identical to Spark SQL schemas." |
| `USE WAREHOUSE` | `SparkSession` config | "Like setting your Spark master, but simpler." |

**The Data Strategy:**
- Do NOT load any custom data yet.
- Use `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS` for all query examples.
- Show the shared database in the UI: explain that this is "data someone else loaded" (like a managed dataset).

**Demo Script Recommendations:**
```sql
-- 1. Start with context setting (emphasize this is their "session")
USE ROLE ACCOUNTADMIN;  -- Only for setup, explain role hierarchy briefly
USE WAREHOUSE COMPUTE_WH;
USE DATABASE SNOWFLAKE_SAMPLE_DATA;
USE SCHEMA TPCH_SF1;

-- 2. CRITICAL: Show the cost-saving settings
ALTER WAREHOUSE COMPUTE_WH SET AUTO_SUSPEND = 60;

-- 3. First query - show how fast it runs
SELECT COUNT(*) FROM ORDERS;  -- ~1.5M rows, returns in <1 second

-- 4. Create their own playground
CREATE DATABASE IF NOT EXISTS DEV_DB;
CREATE SCHEMA IF NOT EXISTS DEV_DB.SANDBOX;
```

**Instructor Talking Points:**
- "Notice you didn't install anything. No Docker. No Spark. It just works."
- "That query scanned 1.5 million rows in under a second. On Spark, you'd still be waiting for the cluster to warm up."

---

### Demo: `demo_medallion_overview.sql`

**The Gotcha:**
- Trainees may think Medallion is a Snowflake-specific concept. Clarify it's an architecture pattern applicable to any data platform.
- They already know Bronze/Silver/Gold from the written content; the demo should be hands-on, not theoretical.

**The Bridge:**
- "Remember how in Spark you'd read from S3, transform, then write back? Same flow, just organized as Bronze, Silver, Gold."

**The Data Strategy:**
- Create EMPTY table structures to illustrate the concept.
- Use VARIANT for Bronze (showing they don't need to define schema upfront).
- No actual data loading yet; that's Tuesday.

**Demo Script Recommendations:**
```sql
USE DATABASE DEV_DB;

-- Create Medallion schemas
CREATE SCHEMA IF NOT EXISTS BRONZE;
CREATE SCHEMA IF NOT EXISTS SILVER;
CREATE SCHEMA IF NOT EXISTS GOLD;

-- Bronze: Raw data (schema-on-read, like landing zone)
CREATE TABLE BRONZE.RAW_ORDERS (
    ingestion_ts TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_file STRING,
    raw_data VARIANT  -- "This is like reading JSON in Spark without a schema"
);

-- Silver: Cleansed, typed
CREATE TABLE SILVER.ORDERS (
    order_id STRING NOT NULL,
    customer_id STRING,
    order_date DATE,
    amount DECIMAL(12,2)
);

-- Gold: Business-ready aggregates
CREATE TABLE GOLD.DAILY_REVENUE (
    report_date DATE,
    total_orders INTEGER,
    total_revenue DECIMAL(14,2)
);
```

**Instructor Talking Points:**
- "Bronze uses VARIANT. This is like reading JSON with `spark.read.json()` without specifying a schema."
- "Silver is where you add types and constraints. Like when you define a Spark schema."
- "Gold is your final aggregates, ready for BI tools."

---

## 2-Tuesday: SnowSQL Operations & Data Loading

### Demo: `demo_snowsql_operations.sql`

**The Gotcha:**
- SnowSQL installation can be finicky on Windows. Have a backup plan (use Snowsight web UI).
- Connection strings are confusing: account identifiers vary by region.
- Trainees will forget to set a warehouse and queries will hang.

**The Bridge:**
- "SnowSQL is like `spark-shell` or `pyspark` REPL, but for Snowflake."
- The `!` prefix for meta-commands is similar to magic commands in IPython.

**The Data Strategy:**
- Query `SNOWFLAKE_SAMPLE_DATA` only.
- Do NOT attempt to connect to external cloud storage.

**Demo Script Recommendations:**
```sql
-- Show in SnowSQL CLI (or Snowsight as backup)

-- Check context
SELECT CURRENT_WAREHOUSE(), CURRENT_DATABASE(), CURRENT_SCHEMA();

-- Basic queries against sample data
USE DATABASE SNOWFLAKE_SAMPLE_DATA;
USE SCHEMA TPCH_SF1;

SELECT * FROM CUSTOMER LIMIT 10;

-- Aggregation (bridge to Spark SQL)
SELECT 
    C_MKTSEGMENT,
    COUNT(*) AS customer_count,
    AVG(C_ACCTBAL) AS avg_balance
FROM CUSTOMER
GROUP BY C_MKTSEGMENT
ORDER BY customer_count DESC;

-- "This is exactly like Spark SQL, right?"
```

---

### Demo: `demo_data_loading.sql`

**The Gotcha:**
- Trainees will want to connect to S3/Azure immediately. DO NOT DO THIS on Day 2.
- External stage setup involves IAM roles and will derail the lesson.
- The PUT command only works from SnowSQL CLI, not the web UI.

**The Bridge:**
- "COPY INTO is like `spark.read.csv().write.saveAsTable()` but the warehouse does the heavy lifting."
- Stages are like "S3 buckets that Snowflake manages for you."

**The Data Strategy:**
- Use the **Snowsight UI file upload** for the demo (drag and drop).
- Create a small sample CSV file (5-10 rows) beforehand.
- Alternative: Use an internal named stage with PUT from SnowSQL.

**Demo Script Recommendations:**
```sql
USE DATABASE DEV_DB;
USE SCHEMA BRONZE;

-- Create a file format (like defining Spark read options)
CREATE OR REPLACE FILE FORMAT CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
    FIELD_OPTIONALLY_ENCLOSED_BY = '"';

-- Create an internal stage (managed by Snowflake, no AWS credentials)
CREATE OR REPLACE STAGE INTERNAL_STAGE
    FILE_FORMAT = CSV_FORMAT;

-- OPTION 1: If using SnowSQL CLI
-- PUT file://C:\data\sample_orders.csv @INTERNAL_STAGE;

-- OPTION 2: Use Snowsight UI to upload file to stage
-- Show the UI: Data > Databases > DEV_DB > BRONZE > Stages > Upload

-- Create target table
CREATE OR REPLACE TABLE SAMPLE_ORDERS (
    order_id STRING,
    customer_id STRING,
    order_date STRING,
    amount STRING
);

-- Load the data
COPY INTO SAMPLE_ORDERS
FROM @INTERNAL_STAGE
FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT)
ON_ERROR = 'CONTINUE';

-- Verify
SELECT * FROM SAMPLE_ORDERS;
```

**Instructor Talking Points:**
- "Notice we used an INTERNAL stage. No AWS credentials, no IAM roles. For production, you'd use external stages, but for learning, this is simpler."
- "COPY INTO is the workhorse. It's like `spark.read` but Snowflake parallelizes it automatically."
- "ON_ERROR = CONTINUE is like Spark's corrupt record handling. It logs errors but keeps loading."

---

### Demo: `demo_tables_views.sql`

**The Gotcha:**
- Transient vs Temporary vs Permanent table differences are subtle.
- Trainees will forget that TEMPORARY tables disappear when the session ends.
- Time Travel is a new concept; don't go too deep, just show it exists.

**The Bridge:**
- "Transient tables are like Spark temp views that persist across sessions."
- "Permanent tables with Time Travel are like having automatic file versioning in S3."

**Demo Script Recommendations:**
```sql
USE DATABASE DEV_DB;
USE SCHEMA SILVER;

-- Permanent table (default, has Time Travel and Fail-Safe)
CREATE TABLE ORDERS_PERMANENT (
    order_id STRING,
    amount DECIMAL(10,2)
);

-- Transient table (reduced storage costs, 1-day Time Travel, no Fail-Safe)
CREATE TRANSIENT TABLE ORDERS_TRANSIENT (
    order_id STRING,
    amount DECIMAL(10,2)
);

-- Temporary table (session-scoped, like Spark temp view)
CREATE TEMPORARY TABLE ORDERS_TEMP (
    order_id STRING,
    amount DECIMAL(10,2)
);

-- Insert some data
INSERT INTO ORDERS_PERMANENT VALUES ('O001', 100.00);
UPDATE ORDERS_PERMANENT SET amount = 150.00 WHERE order_id = 'O001';

-- Time Travel: See the old value (WOW moment for Spark users)
SELECT * FROM ORDERS_PERMANENT AT (OFFSET => -60);  -- 60 seconds ago

-- Create a view
CREATE VIEW V_HIGH_VALUE_ORDERS AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
WHERE O_TOTALPRICE > 100000;
```

**Instructor Talking Points:**
- "Time Travel is built-in. No Delta Lake setup, no manual versioning. Just query the past."
- "Use TRANSIENT for staging data you don't need to recover. Cheaper."
- "TEMPORARY tables are like Spark's `createTempView()` but they survive query boundaries within a session."

---

## 3-Wednesday: Advanced Snowflake Features & Schema Design

### Demo: `demo_udf_creation.sql`

**The Gotcha:**
- JavaScript UDFs require ES5 syntax (no arrow functions, no let/const in older behavior).
- Python UDFs require specifying the runtime version.
- UDFs on large datasets can be slow compared to native SQL.

**The Bridge:**
- "Remember Spark UDFs? Same concept, but you write them in SQL, JavaScript, or Python."
- "Unlike Spark, you don't have to worry about serialization overhead as much."

**The Data Strategy:**
- Use `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER` for testing UDFs.

**Demo Script Recommendations:**
```sql
USE DATABASE DEV_DB;
USE SCHEMA SILVER;

-- SQL UDF (simplest, fastest)
CREATE OR REPLACE FUNCTION CENTS_TO_DOLLARS(cents NUMBER)
RETURNS DECIMAL(12,2)
AS
$$
    cents / 100.0
$$;

-- Test it
SELECT CENTS_TO_DOLLARS(15099);  -- Returns 150.99

-- JavaScript UDF (for complex string logic)
CREATE OR REPLACE FUNCTION MASK_EMAIL(email STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
    if (EMAIL === null) return null;
    var parts = EMAIL.split('@');
    if (parts.length !== 2) return EMAIL;
    var masked = parts[0].substring(0, 2) + '***@' + parts[1];
    return masked;
$$;

-- Test on real data
SELECT 
    C_NAME,
    C_PHONE,
    MASK_EMAIL(C_NAME || '@example.com') AS masked_email  -- Fake email for demo
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
LIMIT 5;
```

**Instructor Talking Points:**
- "SQL UDFs compile down to native Snowflake operations. Super fast."
- "JavaScript UDFs are for when SQL can't express what you need. Like Spark's Python UDFs."
- "Avoid UDFs in WHERE clauses when possible. They block query optimization."

---

### Demo: `demo_snowpipe_setup.sql`

**The Gotcha:**
- Full Snowpipe setup requires cloud event notifications (SQS, Event Grid).
- DO NOT attempt a real S3 integration in this demo. It will take 30+ minutes to configure IAM.
- Show the concept conceptually, then do a manual trigger.

**The Bridge:**
- "Snowpipe is like a Kafka consumer that's always running, watching for new files."
- "Remember Spark Structured Streaming's file source? Same idea, but managed by Snowflake."

**The Data Strategy:**
- Create the pipe definition to show syntax.
- Use `ALTER PIPE ... REFRESH` to manually trigger (simulates file arrival).
- Skip the cloud notification setup entirely.

**Demo Script Recommendations:**
```sql
USE DATABASE DEV_DB;
USE SCHEMA BRONZE;

-- Create a stage (internal, no cloud credentials)
CREATE OR REPLACE STAGE PIPE_STAGE
    FILE_FORMAT = (TYPE = 'JSON');

-- Target table for Snowpipe
CREATE OR REPLACE TABLE STREAMING_EVENTS (
    event_time TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    raw_data VARIANT
);

-- Create the pipe (AUTO_INGEST = FALSE for demo simplicity)
CREATE OR REPLACE PIPE EVENTS_PIPE
    AUTO_INGEST = FALSE  -- Would be TRUE in production with cloud events
AS
COPY INTO STREAMING_EVENTS (raw_data)
FROM @PIPE_STAGE
FILE_FORMAT = (TYPE = 'JSON');

-- Show pipe status
SELECT SYSTEM$PIPE_STATUS('EVENTS_PIPE');

-- In production, files landing in stage would trigger the pipe
-- For demo, we manually refresh
-- ALTER PIPE EVENTS_PIPE REFRESH;

-- Explain: "In production, you'd set AUTO_INGEST = TRUE and configure
-- S3 event notifications. The pipe runs continuously, loading files
-- within seconds of arrival. It's like a Kafka consumer for files."
```

**Instructor Talking Points:**
- "AUTO_INGEST = FALSE means we trigger manually. With TRUE, Snowflake watches S3 for new files."
- "This is similar to how you'd use Kafka Connect to watch for new files, but zero infrastructure."
- "In the real world, you'd connect this to S3 events. We skip that to focus on concepts."

---

### Demo: `demo_streams_tasks.sql`

**The Gotcha:**
- Tasks are created SUSPENDED by default. Trainees will forget to resume them.
- Stream + Task combinations require careful ordering (create stream, then task).
- Tasks can run on a schedule OR trigger on stream data; show both.

**The Bridge (CRITICAL for this demo):**

| Snowflake Concept | Known Equivalent | Instructor Script |
|-------------------|------------------|-------------------|
| Stream | Kafka consumer offset | "A Stream tracks what rows you've already processed, like a Kafka offset." |
| Task | Airflow Task | "A Task is like one step in an Airflow DAG, but defined in SQL." |
| Task DAG | Airflow DAG | "You can chain Tasks together, just like Airflow task dependencies." |

**The Data Strategy:**
- Create a simple source table in BRONZE.
- Create a Stream to track changes.
- Create a Task to process changes into SILVER.
- MANUALLY EXECUTE the task (don't wait for scheduler).

**Demo Script Recommendations:**
```sql
USE DATABASE DEV_DB;
USE WAREHOUSE COMPUTE_WH;

-- Source table (Bronze)
CREATE OR REPLACE TABLE BRONZE.RAW_EVENTS (
    event_id STRING,
    event_type STRING,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Stream: Tracks changes (like a Kafka offset)
CREATE OR REPLACE STREAM BRONZE.RAW_EVENTS_STREAM ON TABLE BRONZE.RAW_EVENTS;

-- Target table (Silver)
CREATE OR REPLACE TABLE SILVER.PROCESSED_EVENTS (
    event_id STRING,
    event_type STRING,
    processed_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Task: Processes stream data (like an Airflow task)
CREATE OR REPLACE TASK PROCESS_EVENTS_TASK
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = '1 MINUTE'  -- Or use: AFTER parent_task
    WHEN SYSTEM$STREAM_HAS_DATA('BRONZE.RAW_EVENTS_STREAM')
AS
INSERT INTO SILVER.PROCESSED_EVENTS (event_id, event_type, processed_at)
SELECT event_id, event_type, CURRENT_TIMESTAMP()
FROM BRONZE.RAW_EVENTS_STREAM
WHERE METADATA$ACTION = 'INSERT';

-- CRITICAL: Task is suspended by default!
-- ALTER TASK PROCESS_EVENTS_TASK RESUME;

-- For demo, keep it suspended and execute manually
-- EXECUTE TASK PROCESS_EVENTS_TASK;

-- Insert test data
INSERT INTO BRONZE.RAW_EVENTS (event_id, event_type) VALUES
    ('E001', 'click'),
    ('E002', 'purchase'),
    ('E003', 'view');

-- Show the stream has data
SELECT * FROM BRONZE.RAW_EVENTS_STREAM;

-- Execute the task manually
EXECUTE TASK PROCESS_EVENTS_TASK;

-- Check Silver table
SELECT * FROM SILVER.PROCESSED_EVENTS;

-- Stream is now empty (consumed)
SELECT * FROM BRONZE.RAW_EVENTS_STREAM;
```

**Instructor Talking Points:**
- "The Stream is like having a Kafka offset on your table. It knows what's new."
- "The Task fires when the Stream has data. Like an Airflow sensor, but built into the database."
- "EXECUTE TASK lets us test without waiting. In production, the scheduler handles it."

---

### Demo: `demo_star_schema.sql`

**The Gotcha:**
- Trainees may overcomplicate with too many dimensions.
- Surrogate keys (integer keys) vs natural keys (business keys) confuses beginners.
- Start simple: one fact, two dimensions.

**The Bridge:**
- "This is exactly like Spark DataFrame joins, but with intentional denormalization for speed."

**The Data Strategy:**
- Use `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1` tables as source.
- Build simplified dimensions and facts from the sample data.

**Demo Script Recommendations:**
```sql
USE DATABASE DEV_DB;
USE SCHEMA GOLD;

-- Date dimension (every star schema needs one)
CREATE OR REPLACE TABLE DIM_DATE AS
SELECT
    TO_NUMBER(TO_CHAR(date_day, 'YYYYMMDD')) AS date_key,
    date_day AS full_date,
    DAYNAME(date_day) AS day_name,
    MONTH(date_day) AS month_num,
    MONTHNAME(date_day) AS month_name,
    QUARTER(date_day) AS quarter,
    YEAR(date_day) AS year
FROM (
    SELECT DATEADD('day', SEQ4(), '2020-01-01')::DATE AS date_day
    FROM TABLE(GENERATOR(ROWCOUNT => 1826))  -- 5 years
);

-- Customer dimension
CREATE OR REPLACE TABLE DIM_CUSTOMER AS
SELECT 
    C_CUSTKEY AS customer_key,
    C_NAME AS customer_name,
    C_MKTSEGMENT AS market_segment,
    C_NATIONKEY AS nation_key
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

-- Orders fact table
CREATE OR REPLACE TABLE FCT_ORDERS AS
SELECT
    O_ORDERKEY AS order_key,
    TO_NUMBER(TO_CHAR(O_ORDERDATE, 'YYYYMMDD')) AS date_key,
    O_CUSTKEY AS customer_key,
    O_TOTALPRICE AS order_amount,
    O_ORDERSTATUS AS order_status
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS;

-- Analytical query (the payoff)
SELECT
    d.year,
    d.quarter,
    c.market_segment,
    COUNT(f.order_key) AS total_orders,
    SUM(f.order_amount) AS total_revenue
FROM FCT_ORDERS f
JOIN DIM_DATE d ON f.date_key = d.date_key
JOIN DIM_CUSTOMER c ON f.customer_key = c.customer_key
GROUP BY d.year, d.quarter, c.market_segment
ORDER BY d.year, d.quarter, total_revenue DESC;
```

**Instructor Talking Points:**
- "This is the Gold layer. Pre-joined, pre-aggregated, ready for dashboards."
- "The date dimension lets you slice by year, quarter, month without date functions in every query."
- "Notice the query uses simple equi-joins. BI tools love this pattern."

---

## 4-Thursday: dbt Fundamentals (Pair Programming Day)

### Demo: `demo_dbt_init/`

**The Gotcha:**
- Python environment issues are common. Have a backup virtual environment ready.
- `dbt init` asks interactive questions; know the answers in advance.
- Profiles.yml location varies by OS (~/.dbt/ on Unix, %USERPROFILE%\.dbt\ on Windows).

**The Bridge:**
- "dbt is like Airflow for SQL transformations. You define dependencies, it figures out the order."
- "The ref() function is like joining DataFrames in Spark, but dbt manages the lineage."

**The Data Strategy:**
- Connect to the same DEV_DB used all week.
- Use BRONZE.RAW_EVENTS as the source (created in earlier demos).
- Each trainee gets their own schema: `DBT_<username>`.

**Setup Instructions for Instructor:**
```bash
# Create virtual environment
python -m venv dbt_env
source dbt_env/bin/activate  # or dbt_env\Scripts\activate on Windows

# Install dbt-snowflake
pip install dbt-snowflake

# Initialize project
dbt init snowflake_training

# Answer prompts:
# - database: DEV_DB
# - schema: DBT_INSTRUCTOR  (each trainee uses DBT_<their_name>)
# - warehouse: COMPUTE_WH
# - role: leave default or ACCOUNTADMIN
# - threads: 4
```

**profiles.yml (show this on screen):**
```yaml
snowflake_training:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <account_identifier>  # e.g., abc12345.us-east-1
      user: <username>
      password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
      database: DEV_DB
      schema: DBT_INSTRUCTOR
      warehouse: COMPUTE_WH
      role: ACCOUNTADMIN
      threads: 4
```

**Instructor Talking Points:**
- "Each of you will have your own schema so you don't step on each other."
- "The profiles.yml is like your Airflow connections. Keep it out of Git."
- "dbt run compiles your SQL and executes it. Like Airflow running a DAG."

---

### Demo: `demo_dbt_models.sql` & `demo_dbt_sources.yml`

**The Gotcha:**
- Source freshness checks require a timestamp column.
- Mismatched source names cause confusing errors.
- The `{{ ref() }}` syntax will feel weird to SQL-only developers.

**The Bridge:**
- "Sources are like Airflow external task sensors. They represent data you didn't create."
- "ref() is like a Spark DataFrame reference. dbt knows the dependency."

**Demo Script Recommendations (in dbt project):**

**models/staging/sources.yml:**
```yaml
version: 2

sources:
  - name: bronze
    database: DEV_DB
    schema: BRONZE
    tables:
      - name: raw_events
        description: "Raw events from the streaming pipeline"
        columns:
          - name: event_id
            description: "Unique event identifier"
```

**models/staging/stg_events.sql:**
```sql
-- models/staging/stg_events.sql
WITH source AS (
    SELECT * FROM {{ source('bronze', 'raw_events') }}
)

SELECT
    event_id,
    UPPER(event_type) AS event_type,  -- Simple transformation
    created_at
FROM source
WHERE event_id IS NOT NULL
```

**Run and verify:**
```bash
dbt run --select stg_events
dbt test --select stg_events
```

**Instructor Talking Points:**
- "sources.yml declares external tables. Like documentation that dbt can validate."
- "stg_events.sql is a SELECT statement. dbt handles CREATE TABLE for you."
- "This is the Silver layer in dbt terms: staging models."

---

### Demo: `demo_dbt_tests.yml`

**The Gotcha:**
- Test errors can be cryptic. Show how to read test failure output.
- `relationships` test requires the referenced model to exist.
- Custom tests in tests/ directory return rows that FAIL (opposite of typical assertions).

**The Bridge:**
- "dbt tests are like Spark DataFrame assertions or data contracts."
- "Think of them as Airflow's data quality checks built into the pipeline."

**Demo Script Recommendations:**

**models/staging/staging.yml:**
```yaml
version: 2

models:
  - name: stg_events
    description: "Staged events from bronze layer"
    columns:
      - name: event_id
        description: "Unique event identifier"
        tests:
          - unique
          - not_null
      
      - name: event_type
        description: "Type of event"
        tests:
          - not_null
          - accepted_values:
              values: ['CLICK', 'PURCHASE', 'VIEW']
```

```bash
dbt test --select stg_events
```

**Instructor Talking Points:**
- "Tests run after the model builds. Like post-execution checks in Airflow."
- "unique and not_null are built-in. accepted_values is for categorical validation."
- "When a test fails, dbt gives you the query to debug. Run it in Snowflake."

---

## 5-Friday: dbt Transformations & Use Cases

### Demo: `demo_dbt_transformations.sql`

**The Gotcha:**
- Incremental models are confusing on first exposure. Start with table, then show incremental.
- Jinja templating syntax errors are hard to debug. Use `dbt compile` first.
- The `is_incremental()` macro returns False on first run.

**The Bridge:**
- "Incremental models are like Spark's merge into Delta Lake. Append-only or upsert."
- "Jinja is like f-strings in Python but for SQL. You can loop and branch."

**Demo Script Recommendations:**

**models/marts/fct_event_counts.sql (incremental):**
```sql
-- models/marts/fct_event_counts.sql
{{
    config(
        materialized='incremental',
        unique_key='event_date'
    )
}}

WITH events AS (
    SELECT * FROM {{ ref('stg_events') }}
    {% if is_incremental() %}
        WHERE created_at > (SELECT MAX(last_updated) FROM {{ this }})
    {% endif %}
)

SELECT
    DATE_TRUNC('day', created_at)::DATE AS event_date,
    event_type,
    COUNT(*) AS event_count,
    CURRENT_TIMESTAMP() AS last_updated
FROM events
GROUP BY 1, 2
```

**Run sequence:**
```bash
# First run: full build
dbt run --select fct_event_counts

# Add new data to source, then:
dbt run --select fct_event_counts  # Only new data processed

# Force full refresh
dbt run --select fct_event_counts --full-refresh
```

**Instructor Talking Points:**
- "First run builds the whole table. Subsequent runs only process new data."
- "is_incremental() returns True only on subsequent runs. First run is always full."
- "This is how you handle terabyte-scale fact tables without reprocessing everything."

---

### Demo: `demo_dbt_materializations.sql`

**The Gotcha:**
- Ephemeral models don't create tables. Trainees will wonder where they went.
- View vs Table performance implications aren't obvious.

**Demo comparison:**

```sql
-- View (default for staging)
{{ config(materialized='view') }}
SELECT * FROM {{ source('bronze', 'raw_events') }}

-- Table (for marts)
{{ config(materialized='table') }}
SELECT * FROM {{ ref('stg_events') }}

-- Incremental (for large facts)
{{ config(materialized='incremental', unique_key='id') }}
...

-- Ephemeral (CTE only, not materialized)
{{ config(materialized='ephemeral') }}
SELECT * FROM {{ ref('dim_date') }}
```

**Instructor Talking Points:**
- "Views are cheap but slow for complex queries. Use for staging."
- "Tables are fast but require storage. Use for marts."
- "Incremental is the sweet spot for large tables. Process only deltas."
- "Ephemeral is for pure logic reuse. No table created."

---

### Demo: `demo_dbt_docs.sh`

**The Gotcha:**
- `dbt docs serve` requires port 8080 by default. May conflict with other services.
- The lineage graph is the "wow" moment. Make sure it loads properly.

**Commands:**
```bash
# Generate documentation
dbt docs generate

# Serve locally (opens browser)
dbt docs serve --port 8081

# Key things to show:
# 1. The model definitions
# 2. The column descriptions
# 3. THE LINEAGE GRAPH (click the icon in the bottom-right)
```

**Instructor Talking Points:**
- "This is auto-generated from your YAML descriptions and SQL."
- "The lineage graph is like Airflow's Graph View but for data transformations."
- "Share this with your stakeholders. They can trace data from source to dashboard."

---

## Summary: Key Analogies Reference

| Snowflake/dbt | Spark/Kafka/Airflow | Quick Explanation |
|---------------|---------------------|-------------------|
| Virtual Warehouse | Spark Cluster | On-demand compute, scales up/down |
| `COPY INTO` | `spark.read...write` | Bulk load from files |
| VARIANT | DataFrame from JSON | Schema-on-read for semi-structured |
| Stream | Kafka consumer offset | Tracks what's been processed |
| Task | Airflow Task | Scheduled SQL execution |
| Task DAG | Airflow DAG | Chained task dependencies |
| Snowpipe | Kafka Connect | Event-driven file ingestion |
| dbt model | Spark transformation | SQL-based data transformation |
| dbt ref() | DataFrame join | Dependency declaration |
| dbt Source | External Task Sensor | Reference to external data |
| dbt Test | Data quality check | Assertions on your data |

---

## Handoff to Instructor Demo Agent

The guidance above provides strategic direction for each demo. When generating the actual demo scripts:

1. **Include Cost Controls:** Every SQL file should start with `ALTER WAREHOUSE ... AUTO_SUSPEND = 60`
2. **Use Sample Data:** Default to `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1` unless creating custom tables
3. **Add Bridge Comments:** Include inline comments like `-- Like spark.read, but managed`
4. **Fail Gracefully:** Use `CREATE OR REPLACE` and `IF NOT EXISTS` to make demos re-runnable
5. **Include Instructor Scripts:** Add commented talking points and explanations

Generate the 16 demo files following this guidance.
