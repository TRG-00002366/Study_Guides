-- =============================================================================
-- DEMO: Automated Bronze → Silver → Gold Pipeline (Streams & Tasks)
-- Day: 3-Wednesday
-- Duration: ~20 minutes
-- Prerequisites: DEV_DB database, COMPUTE_WH warehouse
-- =============================================================================
--
-- PURPOSE:
-- This demo shows how Streams and Tasks work together to build a fully
-- automated incremental pipeline. Unlike manual execution, here we RESUME
-- the tasks and watch Snowflake process data end-to-end automatically.
--
-- KEY CONCEPT:
-- You write the SQL ONCE inside a Task. Snowflake runs it FOREVER on schedule.
-- No human intervention needed — like a mini Airflow DAG built into Snowflake.
--
-- PIPELINE:
--   BRONZE (raw data) → Stream detects changes
--        → Task 1: cleanse & extract → SILVER (processed)
--            → Task 2: aggregate → GOLD (summary)
-- =============================================================================


-- =============================================================================
-- STEP 1: SETUP — Create Schemas and Tables
-- =============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEV_DB;

-- Speed up warehouse suspend for cost savings during demo
ALTER WAREHOUSE COMPUTE_WH SET AUTO_SUSPEND = 60;

-- Create all three layers
CREATE SCHEMA IF NOT EXISTS BRONZE;
CREATE SCHEMA IF NOT EXISTS SILVER;
CREATE SCHEMA IF NOT EXISTS GOLD;

-- ── Bronze: Raw landing table ──
CREATE OR REPLACE TABLE BRONZE.CUSTOMER_ORDERS (
    order_id       STRING,
    customer_name  STRING,
    product        STRING,
    quantity        INT,
    unit_price     DECIMAL(10,2),
    order_status   STRING,
    region         STRING,
    created_at     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ── Silver: Cleaned & enriched ──
CREATE OR REPLACE TABLE SILVER.ORDERS_CLEANED (
    order_id       STRING,
    customer_name  STRING,
    product        STRING,
    quantity        INT,
    unit_price     DECIMAL(10,2),
    total_amount   DECIMAL(12,2),     -- quantity × unit_price
    order_status   STRING,
    region         STRING,
    processed_at   TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ── Gold: Business-ready aggregates ──
CREATE OR REPLACE TABLE GOLD.REGIONAL_SALES_SUMMARY (
    region          STRING,
    total_orders    INT,
    total_revenue   DECIMAL(14,2),
    avg_order_value DECIMAL(10,2),
    last_updated    TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

SELECT 'STEP 1 COMPLETE: All tables created across Bronze, Silver, Gold.' AS status;


-- =============================================================================
-- STEP 2: CREATE A STREAM — CDC Tracking on Bronze Table
-- =============================================================================

-- "A Stream is like a Kafka offset. It tracks which rows are new/changed
--  since the last time we consumed them."

CREATE OR REPLACE STREAM BRONZE.ORDERS_STREAM 
    ON TABLE BRONZE.CUSTOMER_ORDERS
    APPEND_ONLY = TRUE
    COMMENT = 'Tracks new inserts to CUSTOMER_ORDERS for incremental processing';

-- APPEND_ONLY = TRUE means we only care about new INSERTs (not updates/deletes).
-- This is the most common pattern for Bronze landing tables.

SELECT 'STEP 2 COMPLETE: Stream created on Bronze table.' AS status;


-- =============================================================================
-- STEP 3: CREATE TASK 1 — Bronze → Silver (Root Task)
-- =============================================================================

-- "This task checks every 1 minute: if the stream has new data, it cleanses
--  the records and writes them to Silver. Think of it as an Airflow task
--  with a sensor built in."

CREATE OR REPLACE TASK SILVER.CLEAN_ORDERS_TASK
    WAREHOUSE = COMPUTE_WH
    SCHEDULE  = '1 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('BRONZE.ORDERS_STREAM')
AS
INSERT INTO SILVER.ORDERS_CLEANED (
    order_id, customer_name, product, quantity, unit_price,
    total_amount, order_status, region, processed_at
)
SELECT
    order_id,
    INITCAP(TRIM(customer_name))       AS customer_name,    -- Standardize name
    UPPER(TRIM(product))               AS product,          -- Standardize product
    quantity,
    unit_price,
    quantity * unit_price               AS total_amount,     -- Derived column
    UPPER(TRIM(order_status))          AS order_status,     -- Standardize status
    UPPER(TRIM(region))                AS region,           -- Standardize region
    CURRENT_TIMESTAMP()
FROM BRONZE.ORDERS_STREAM;
-- Stream is automatically consumed after this DML completes

SELECT 'STEP 3 COMPLETE: Root task CLEAN_ORDERS_TASK created (Bronze → Silver).' AS status;


-- =============================================================================
-- STEP 4: CREATE TASK 2 — Silver → Gold (Child Task)
-- =============================================================================

-- "This child task runs AFTER the parent completes — just like task1 >> task2
--  in Airflow. It aggregates Silver data into Gold."

CREATE OR REPLACE TASK SILVER.AGGREGATE_SALES_TASK
    WAREHOUSE = COMPUTE_WH
    AFTER SILVER.CLEAN_ORDERS_TASK       -- Runs only after parent succeeds
AS
MERGE INTO GOLD.REGIONAL_SALES_SUMMARY tgt
USING (
    SELECT
        region,
        COUNT(*)             AS total_orders,
        SUM(total_amount)    AS total_revenue,
        AVG(total_amount)    AS avg_order_value
    FROM SILVER.ORDERS_CLEANED
    GROUP BY region
) src
ON tgt.region = src.region
WHEN MATCHED THEN UPDATE SET
    total_orders    = src.total_orders,
    total_revenue   = src.total_revenue,
    avg_order_value = src.avg_order_value,
    last_updated    = CURRENT_TIMESTAMP()
WHEN NOT MATCHED THEN INSERT (region, total_orders, total_revenue, avg_order_value, last_updated)
    VALUES (src.region, src.total_orders, src.total_revenue, src.avg_order_value, CURRENT_TIMESTAMP());

SELECT 'STEP 4 COMPLETE: Child task AGGREGATE_SALES_TASK created (Silver → Gold).' AS status;


-- =============================================================================
-- STEP 5: RESUME TASKS — Activate the Pipeline
-- =============================================================================

-- "Tasks are SUSPENDED by default. To start the automation:
--  CRITICAL: Resume CHILD tasks FIRST, then the ROOT task!"

-- Step 5a: Resume child first
ALTER TASK SILVER.AGGREGATE_SALES_TASK RESUME;

-- Step 5b: Resume root task (starts the scheduler)
ALTER TASK SILVER.CLEAN_ORDERS_TASK RESUME;

-- Verify both are running
SHOW TASKS IN DATABASE DEV_DB;

SELECT 'STEP 5 COMPLETE: Both tasks RESUMED. Pipeline is now LIVE!' AS status;


-- =============================================================================
-- STEP 6: FEED THE PIPELINE — Insert Data into Bronze
-- =============================================================================

-- "Now we simply insert data into Bronze. The pipeline does the rest.
--  No EXECUTE TASK, no manual SQL — it's fully automated."

-- ── Batch 1: Initial orders ──
INSERT INTO BRONZE.CUSTOMER_ORDERS (order_id, customer_name, product, quantity, unit_price, order_status, region)
VALUES
    ('ORD-001', '  john smith  ', 'laptop', 2, 999.99, 'completed', 'east'),
    ('ORD-002', 'JANE DOE',      'mouse',  5, 29.99,  'completed', 'west'),
    ('ORD-003', 'bob Johnson',   'Keyboard', 3, 79.99, 'pending',  'east'),
    ('ORD-004', 'Alice Williams', 'MONITOR', 1, 449.99, 'completed', 'central'),
    ('ORD-005', 'charlie BROWN', 'headset', 4, 89.99,  'completed', 'west');

SELECT 'STEP 6 COMPLETE: 5 orders inserted into Bronze.' AS status;

-- Confirm the stream has captured the new rows
SELECT 'Stream has captured these new rows:' AS info;
SELECT * FROM BRONZE.ORDERS_STREAM;


-- =============================================================================
-- STEP 7: WAIT AND VERIFY — Watch the Automation
-- =============================================================================

-- "The task scheduler checks every 1 minute. Let's wait ~60-90 seconds,
--  then check each layer."

-- ┌─────────────────────────────────────────────────────────────────┐
-- │  ⏳  WAIT ~60-90 SECONDS BEFORE RUNNING THE QUERIES BELOW     │
-- │     The task scheduler needs time to pick up and process       │
-- │     the data through the pipeline.                             │
-- └─────────────────────────────────────────────────────────────────┘

-- Check Silver layer — should have 5 cleaned records
SELECT '── SILVER LAYER (Cleaned Orders) ──' AS layer;
SELECT * FROM SILVER.ORDERS_CLEANED ORDER BY order_id;

-- Check Gold layer — should have 3 regions with aggregated totals
SELECT '── GOLD LAYER (Regional Sales Summary) ──' AS layer;
SELECT * FROM GOLD.REGIONAL_SALES_SUMMARY ORDER BY total_revenue DESC;

-- "Notice:
--  • Names are standardized (INITCAP)
--  • Products are uppercased
--  • total_amount is calculated
--  • Gold has aggregates per region
--  ALL of this happened AUTOMATICALLY. We only inserted into Bronze!"


-- =============================================================================
-- STEP 8: ADD MORE DATA — Prove Incremental Processing
-- =============================================================================

-- "Let's add more data. The pipeline will pick it up in the next cycle
--  WITHOUT re-processing old records. That's the power of Streams!"

-- ── Batch 2: More orders ──
INSERT INTO BRONZE.CUSTOMER_ORDERS (order_id, customer_name, product, quantity, unit_price, order_status, region)
VALUES
    ('ORD-006', 'david Lee',     'tablet',  2, 599.99, 'completed', 'east'),
    ('ORD-007', 'emma wilson',   'laptop',  1, 999.99, 'completed', 'central'),
    ('ORD-008', 'frank garcia',  'mouse',  10, 29.99,  'completed', 'west');

SELECT 'STEP 8 COMPLETE: 3 more orders inserted. Wait ~60-90 seconds...' AS status;

-- ┌─────────────────────────────────────────────────────────────────┐
-- │  ⏳  WAIT ~60-90 SECONDS AGAIN, THEN RUN THE QUERIES BELOW    │
-- └─────────────────────────────────────────────────────────────────┘

-- Silver should now have 8 total records (5 old + 3 new)
SELECT '── SILVER LAYER (After Batch 2) ──' AS layer;
SELECT * FROM SILVER.ORDERS_CLEANED ORDER BY order_id;
SELECT COUNT(*) AS silver_row_count FROM SILVER.ORDERS_CLEANED;

-- Gold should show updated aggregates
SELECT '── GOLD LAYER (After Batch 2) ──' AS layer;
SELECT * FROM GOLD.REGIONAL_SALES_SUMMARY ORDER BY total_revenue DESC;


-- =============================================================================
-- STEP 9: MONITOR — Check Task Execution History
-- =============================================================================

-- "You can monitor task runs just like checking Airflow task logs."

-- Task run history for the root task
SELECT
    NAME,
    STATE,
    SCHEDULED_TIME,
    COMPLETED_TIME,
    ERROR_MESSAGE
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    SCHEDULED_TIME_RANGE_START => DATEADD('hour', -1, CURRENT_TIMESTAMP())
))
ORDER BY SCHEDULED_TIME DESC
LIMIT 10;

-- View the full DAG structure
SELECT 
    NAME,
    STATE,
    SCHEDULE,
    PREDECESSORS,
    CONDITION
FROM TABLE(INFORMATION_SCHEMA.TASK_DEPENDENTS(
    TASK_NAME => 'SILVER.CLEAN_ORDERS_TASK',
    RECURSIVE => TRUE
));


-- =============================================================================
-- STEP 10: CLEANUP — Suspend Tasks and Drop Objects
-- =============================================================================

-- "Always suspend PARENT first, then children — reverse of resume order."

-- Suspend tasks (stop automation)
ALTER TASK SILVER.CLEAN_ORDERS_TASK SUSPEND;
ALTER TASK SILVER.AGGREGATE_SALES_TASK SUSPEND;

SELECT 'STEP 10 COMPLETE: Tasks suspended. Pipeline is stopped.' AS status;

-- Uncomment below to fully clean up:
-- DROP TASK IF EXISTS SILVER.AGGREGATE_SALES_TASK;
-- DROP TASK IF EXISTS SILVER.CLEAN_ORDERS_TASK;
-- DROP STREAM IF EXISTS BRONZE.ORDERS_STREAM;
-- DROP TABLE IF EXISTS GOLD.REGIONAL_SALES_SUMMARY;
-- DROP TABLE IF EXISTS SILVER.ORDERS_CLEANED;
-- DROP TABLE IF EXISTS BRONZE.CUSTOMER_ORDERS;


-- =============================================================================
-- SUMMARY: Bronze → Silver → Gold Automated Pipeline
-- =============================================================================
--
-- WHAT WE BUILT:
--
--   BRONZE.CUSTOMER_ORDERS  (Raw data lands here)
--          │
--          ▼
--   BRONZE.ORDERS_STREAM    (Detects new rows — like a Kafka offset)
--          │
--          ▼
--   CLEAN_ORDERS_TASK       (Every 1 min, IF stream has data)
--   • Standardizes names     │
--   • Calculates totals      │
--   • Writes to Silver       │
--          │                  ▼
--   SILVER.ORDERS_CLEANED   (Clean, enriched data)
--          │
--          ▼
--   AGGREGATE_SALES_TASK    (Runs AFTER parent task completes)
--   • Aggregates by region   │
--   • MERGE into Gold        │
--          │                  ▼
--   GOLD.REGIONAL_SALES_SUMMARY  (Business-ready metrics)
--
--
-- KEY TAKEAWAYS:
--
-- 1. You write SQL ONCE inside a Task → Snowflake runs it FOREVER
-- 2. Streams track changes incrementally (no re-processing old data)
-- 3. WHEN SYSTEM$STREAM_HAS_DATA() = only run when there's work to do
-- 4. AFTER clause = chain tasks into a DAG (like Airflow >>)
-- 5. Resume order: CHILD first, then ROOT
-- 6. Suspend order: ROOT first, then CHILD
-- 7. No EXECUTE TASK needed — the scheduler handles everything
-- =============================================================================
