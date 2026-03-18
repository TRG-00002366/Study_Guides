-- =============================================================================
-- DEMO: dbt Models (Staging and Marts)
-- Day: 4-Thursday
-- Duration: ~15 minutes
-- Purpose: Show how to build dbt models using source() and ref()
-- =============================================================================
--
-- INSTRUCTOR NOTES:
-- This file contains examples of two model types:
-- 1. Staging model - transforms from source()
-- 2. Mart/fact model - transforms from ref() to staging
--
-- Create these as separate .sql files in the dbt project:
-- - models/staging/stg_events.sql
-- - models/marts/fct_event_counts.sql
--
-- KEY BRIDGE: 
-- - "source() points to external data, like an Airflow external sensor"
-- - "ref() creates dependencies, like Airflow's >> operator"
-- =============================================================================


-- =============================================================================
-- FILE 1: models/staging/stg_events.sql
-- =============================================================================

-- Paste this content into: models/staging/stg_events.sql

/*
{{
    config(
        materialized='view'  -- Staging models are typically views
    )
}}

WITH source AS (
    -- source() references our defined source in sources.yml
    -- Format: source('<source_name>', '<table_name>')
    SELECT * FROM {{ source('bronze', 'raw_events') }}
),

renamed AS (
    SELECT
        -- Keep the ID as-is
        event_id,
        
        -- Normalize event type to uppercase for consistency
        UPPER(event_type) AS event_type,
        
        -- Extract fields from VARIANT/JSON payload
        payload:user::STRING AS user_id,
        payload:page::STRING AS page_url,
        payload:product::STRING AS product_id,
        payload:amount::DECIMAL(10,2) AS amount,
        
        -- Keep original timestamp
        created_at AS event_timestamp,
        
        -- Add processing metadata
        CURRENT_TIMESTAMP() AS _loaded_at
    FROM source
    WHERE event_id IS NOT NULL  -- Basic data quality filter
)

SELECT * FROM renamed
*/


-- =============================================================================
-- FILE 2: models/marts/fct_event_counts.sql
-- =============================================================================

-- Paste this content into: models/marts/fct_event_counts.sql

/*
{{
    config(
        materialized='table'  -- Mart models are typically tables for performance
    )
}}

WITH events AS (
    -- ref() creates a dependency on stg_events
    -- dbt will run stg_events BEFORE this model
    SELECT * FROM {{ ref('stg_events') }}
),

aggregated AS (
    SELECT
        DATE_TRUNC('day', event_timestamp)::DATE AS event_date,
        event_type,
        COUNT(*) AS event_count,
        COUNT(DISTINCT user_id) AS unique_users,
        SUM(COALESCE(amount, 0)) AS total_amount
    FROM events
    GROUP BY 1, 2
)

SELECT
    event_date,
    event_type,
    event_count,
    unique_users,
    total_amount,
    CURRENT_TIMESTAMP() AS _refreshed_at
FROM aggregated
*/


-- =============================================================================
-- RUNNING THE MODELS
-- =============================================================================

-- After creating the files, run these commands in your terminal:

-- Run just the staging model
-- dbt run --select stg_events

-- Run just the mart model (will also run stg_events because of ref())
-- dbt run --select fct_event_counts

-- Run everything
-- dbt run

-- Run a model and all its upstream dependencies
-- dbt run --select +fct_event_counts

-- Run a model and all its downstream dependents
-- dbt run --select stg_events+


-- =============================================================================
-- VERIFYING RESULTS IN SNOWFLAKE
-- =============================================================================

-- After running dbt, check your schema in Snowflake:

-- Show all objects in your dbt schema
-- SHOW OBJECTS IN SCHEMA DEV_DB.DBT_INSTRUCTOR;

-- Query the staging model (it's a view)
-- SELECT * FROM DEV_DB.DBT_INSTRUCTOR.STG_EVENTS LIMIT 10;

-- Query the mart model (it's a table)
-- SELECT * FROM DEV_DB.DBT_INSTRUCTOR.FCT_EVENT_COUNTS;


-- =============================================================================
-- INSTRUCTOR TALKING POINTS
-- =============================================================================

-- 1. "source('bronze', 'raw_events') tells dbt: 'This data exists outside
--     dbt - I just want to read from it.' Like an Airflow external sensor."

-- 2. "ref('stg_events') tells dbt: 'This model depends on stg_events.
--     Run that one first.' Like Airflow's task1 >> task2."

-- 3. "The config() block sets materialization. Views are cheap but compute
--     at query time. Tables are faster but cost storage."

-- 4. "Notice we didn't write CREATE TABLE or CREATE VIEW. dbt handles that.
--     We just write SELECT statements."

-- 5. "The DAG is built automatically from your source() and ref() calls.
--     Run 'dbt docs generate' and 'dbt docs serve' to see it visually."


-- =============================================================================
-- DAG VISUALIZATION
-- =============================================================================

-- The models create this dependency graph:
--
-- BRONZE.RAW_EVENTS (source)
--         |
--         | source('bronze', 'raw_events')
--         v
--    STG_EVENTS (staging model, view)
--         |
--         | ref('stg_events')
--         v
--  FCT_EVENT_COUNTS (mart model, table)
--
-- "This is your Bronze -> Silver -> Gold flow, now managed by dbt."
