-- =============================================================================
-- DEMO: dbt Materializations
-- Day: 5-Friday
-- Duration: ~15 minutes
-- Purpose: Understand when to use each materialization strategy
-- =============================================================================
--
-- INSTRUCTOR NOTES:
-- Materialization = how dbt persists your model in the database
-- Each has tradeoffs between compute cost, storage cost, and query speed.
--
-- KEY POINT: "Choose the right materialization based on model size,
-- query frequency, and how often data changes."
-- =============================================================================


-- =============================================================================
-- MATERIALIZATION TYPES
-- =============================================================================

-- 1. VIEW (default for staging)
-- - Creates a SQL view (no data stored)
-- - Computes at query time
-- - Good for: staging models, light transformations

/*
-- models/staging/stg_customers.sql
{{
    config(
        materialized='view'
    )
}}

SELECT
    customer_id,
    UPPER(customer_name) AS customer_name,
    created_at
FROM {{ source('bronze', 'raw_customers') }}
*/

-- In Snowflake, this creates:
-- CREATE VIEW DEV_DB.DBT_INSTRUCTOR.STG_CUSTOMERS AS (SELECT ...)


-- =============================================================================

-- 2. TABLE
-- - Creates a physical table (data stored)
-- - Drops and recreates on each run
-- - Good for: mart tables, complex aggregations, frequently queried data

/*
-- models/marts/dim_customers.sql
{{
    config(
        materialized='table'
    )
}}

SELECT
    customer_id,
    customer_name,
    segment,
    lifetime_value
FROM {{ ref('stg_customers') }}
*/

-- In Snowflake, this creates:
-- CREATE OR REPLACE TABLE DEV_DB.DBT_INSTRUCTOR.DIM_CUSTOMERS AS (SELECT ...)


-- =============================================================================

-- 3. INCREMENTAL
-- - Creates a table, but only inserts/merges new data
-- - First run = full table, subsequent runs = only new rows
-- - Good for: large fact tables, event data, append-heavy workloads

/*
-- models/marts/fct_orders.sql
{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge'  -- or 'append', 'delete+insert'
    )
}}

SELECT
    order_id,
    customer_id,
    amount,
    created_at
FROM {{ ref('stg_orders') }}

{% if is_incremental() %}
    WHERE created_at > (SELECT MAX(created_at) FROM {{ this }})
{% endif %}
*/

-- First run: CREATE TABLE ... AS SELECT (all data)
-- Subsequent: MERGE INTO ... (only new data)


-- =============================================================================

-- 4. EPHEMERAL
-- - No table or view created
-- - SQL is inlined as a CTE in downstream models
-- - Good for: pure logic reuse, avoiding intermediate objects

/*
-- models/staging/ephemeral_date_calc.sql
{{
    config(
        materialized='ephemeral'
    )
}}

SELECT
    order_id,
    DATEDIFF('day', created_at, CURRENT_DATE()) AS days_since_order
FROM {{ ref('stg_orders') }}
*/

-- When another model refs this:
/*
SELECT * FROM {{ ref('ephemeral_date_calc') }}
*/

-- dbt compiles it as a CTE:
-- WITH ephemeral_date_calc AS (
--     SELECT order_id, DATEDIFF('day', created_at, CURRENT_DATE()) AS days_since_order
--     FROM stg_orders
-- )
-- SELECT * FROM ephemeral_date_calc


-- =============================================================================
-- DECISION MATRIX
-- =============================================================================

-- | Materialization | Storage | Compute on Query | Rebuild Time | Best For |
-- |-----------------|---------|------------------|--------------|----------|
-- | view            | None    | Every query      | Instant      | Staging, simple transforms |
-- | table           | Full    | None             | Full rebuild | Marts, aggregations |
-- | incremental     | Full    | None             | New rows only| Large facts, events |
-- | ephemeral       | None    | Every query      | N/A          | Logic reuse only |


-- =============================================================================
-- INCREMENTAL STRATEGIES
-- =============================================================================

-- Snowflake supports three incremental strategies:

-- 1. MERGE (default)
-- - Uses MERGE INTO with unique_key
-- - Updates existing rows, inserts new rows
-- - Best for: Slowly changing data, upserts
/*
{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge'
    )
}}
*/

-- 2. DELETE+INSERT
-- - Deletes matching rows, then inserts all new rows
-- - Faster for large batches with known partitions
-- - Best for: Date-partitioned data
/*
{{
    config(
        materialized='incremental',
        unique_key='order_date',
        incremental_strategy='delete+insert'
    )
}}
*/

-- 3. APPEND
-- - Just inserts new rows (no deduplication)
-- - Fastest, but may have duplicates if rerun
-- - Best for: Event logs, immutable data
/*
{{
    config(
        materialized='incremental',
        incremental_strategy='append'
    )
}}
*/


-- =============================================================================
-- SETTING DEFAULTS IN dbt_project.yml
-- =============================================================================

/*
# dbt_project.yml

models:
  snowflake_training:
    # All staging models default to view
    staging:
      +materialized: view
    
    # All mart models default to table
    marts:
      +materialized: table
      
    # Facts within marts are incremental
    marts:
      facts:
        +materialized: incremental
        +incremental_strategy: merge
*/


-- =============================================================================
-- INSTRUCTOR DEMO: SHOW THE DIFFERENCE
-- =============================================================================

-- Run and check Snowflake:

-- 1. View materialization
-- dbt run --select stg_events
-- SHOW VIEWS IN SCHEMA DEV_DB.DBT_INSTRUCTOR;
-- -> stg_events appears as VIEW

-- 2. Table materialization  
-- dbt run --select fct_event_counts
-- SHOW TABLES IN SCHEMA DEV_DB.DBT_INSTRUCTOR;
-- -> fct_event_counts appears as TABLE

-- 3. Incremental first run
-- dbt run --select fct_daily_events
-- SELECT COUNT(*) FROM fct_daily_events;  -- Full count

-- 4. Incremental subsequent run (add new data first)
-- INSERT INTO DEV_DB.BRONZE.RAW_EVENTS VALUES (...);
-- dbt run --select fct_daily_events
-- -- Only new rows processed

-- 5. Full refresh incremental
-- dbt run --select fct_daily_events --full-refresh


-- =============================================================================
-- INSTRUCTOR TALKING POINTS
-- =============================================================================

-- 1. "VIEW = cheap to create but slow to query. Good for staging where
--     you're just passing data through with minor transforms."

-- 2. "TABLE = fast to query but slow to rebuild. Good for marts that
--     are queried frequently by dashboards."

-- 3. "INCREMENTAL = best of both for large data. Only processes new
--     records. Like Spark's merge into Delta Lake."

-- 4. "EPHEMERAL = no physical object created. The SQL gets inlined.
--     Use when you need logic reuse but not an actual table."

-- 5. "Set defaults in dbt_project.yml so you don't repeat config()
--     in every file. Override at the model level if needed."


-- =============================================================================
-- SUMMARY
-- =============================================================================

-- Choose your materialization based on:
-- 1. How often is this queried? (frequently = table)
-- 2. How big is the data? (big = incremental)
-- 3. How often does it change? (rarely = table, frequently = incremental)
-- 4. Is this just logic reuse? (yes = ephemeral)

-- "Right materialization = right balance of build time vs query time."
