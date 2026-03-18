-- =============================================================================
-- DEMO: dbt Transformations (Advanced)
-- Day: 5-Friday
-- Duration: ~20 minutes
-- Purpose: Incremental models, Jinja templating, custom macros
-- =============================================================================
--
-- INSTRUCTOR NOTES:
-- This covers advanced dbt patterns. Trainees should be comfortable with
-- source(), ref(), and basic models from Thursday.
--
-- KEY BRIDGES:
-- - "Incremental models are like Spark's merge into Delta Lake"
-- - "Jinja is like f-strings in Python but for SQL"
-- =============================================================================


-- =============================================================================
-- PART 1: INCREMENTAL MODELS
-- =============================================================================

-- FILE: models/marts/fct_daily_events.sql
-- An incremental model that only processes new data

/*
{{
    config(
        materialized='incremental',
        unique_key='surrogate_key',
        incremental_strategy='merge'
    )
}}

-- Generate a unique key for merge
WITH new_events AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['event_date', 'event_type']) }} AS surrogate_key,
        DATE_TRUNC('day', event_timestamp)::DATE AS event_date,
        event_type,
        COUNT(*) AS event_count,
        COUNT(DISTINCT user_id) AS unique_users,
        CURRENT_TIMESTAMP() AS last_updated
    FROM {{ ref('stg_events') }}
    
    -- This is the incremental filter
    -- Only runs on subsequent runs (not first run)
    {% if is_incremental() %}
        WHERE event_timestamp > (
            SELECT COALESCE(MAX(last_updated), '1900-01-01')
            FROM {{ this }}
        )
    {% endif %}
    
    GROUP BY 2, 3
)

SELECT * FROM new_events
*/


-- =============================================================================
-- HOW INCREMENTAL WORKS (Explain verbally)
-- =============================================================================

-- FIRST RUN (is_incremental() = FALSE):
-- - Processes ALL data from stg_events
-- - Creates the table from scratch
-- - The {% if is_incremental() %} block is SKIPPED

-- SUBSEQUENT RUNS (is_incremental() = TRUE):
-- - The WHERE clause filters to only NEW data
-- - {{ this }} refers to the current table (fct_daily_events)
-- - MERGE inserts new rows or updates existing ones (by unique_key)

-- FULL REFRESH (override incremental behavior):
-- dbt run --select fct_daily_events --full-refresh


-- =============================================================================
-- PART 2: JINJA TEMPLATING
-- =============================================================================

-- Jinja gives you programming constructs in SQL

-- VARIABLES
/*
{% set event_types = ['CLICK', 'VIEW', 'PURCHASE'] %}

SELECT
    event_date,
    {% for event_type in event_types %}
    SUM(CASE WHEN event_type = '{{ event_type }}' THEN 1 ELSE 0 END) AS {{ event_type | lower }}_count
    {% if not loop.last %},{% endif %}
    {% endfor %}
FROM {{ ref('stg_events') }}
GROUP BY event_date
*/

-- This compiles to:
-- SELECT
--     event_date,
--     SUM(CASE WHEN event_type = 'CLICK' THEN 1 ELSE 0 END) AS click_count,
--     SUM(CASE WHEN event_type = 'VIEW' THEN 1 ELSE 0 END) AS view_count,
--     SUM(CASE WHEN event_type = 'PURCHASE' THEN 1 ELSE 0 END) AS purchase_count
-- FROM DEV_DB.DBT_INSTRUCTOR.STG_EVENTS
-- GROUP BY event_date


-- CONDITIONALS
/*
SELECT
    *,
    {% if target.name == 'prod' %}
    -- In production, mask PII
    MASK_EMAIL(user_email) AS user_email_display
    {% else %}
    -- In dev, show real email for debugging
    user_email AS user_email_display
    {% endif %}
FROM {{ ref('stg_users') }}
*/


-- =============================================================================
-- PART 3: CUSTOM MACROS
-- =============================================================================

-- Macros are reusable SQL/Jinja functions
-- Create in: macros/cents_to_dollars.sql

/*
{% macro cents_to_dollars(column_name) %}
    ROUND({{ column_name }} / 100.0, 2)
{% endmacro %}
*/

-- Usage in a model:
/*
SELECT
    order_id,
    amount_cents,
    {{ cents_to_dollars('amount_cents') }} AS amount_dollars
FROM {{ ref('stg_orders') }}
*/

-- Compiles to:
-- SELECT
--     order_id,
--     amount_cents,
--     ROUND(amount_cents / 100.0, 2) AS amount_dollars
-- FROM DEV_DB.DBT_INSTRUCTOR.STG_ORDERS


-- Another example: standard timestamp formatting
-- macros/format_timestamp.sql
/*
{% macro format_timestamp(column_name, format='YYYY-MM-DD HH24:MI:SS') %}
    TO_CHAR({{ column_name }}, '{{ format }}')
{% endmacro %}
*/


-- =============================================================================
-- PART 4: dbt_utils PACKAGE (Common Macros)
-- =============================================================================

-- Install dbt_utils by adding to packages.yml:
/*
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
*/

-- Then run: dbt deps

-- Common dbt_utils macros:

-- 1. generate_surrogate_key - Create unique keys
/*
SELECT
    {{ dbt_utils.generate_surrogate_key(['customer_id', 'order_date']) }} AS sk,
    *
FROM {{ ref('stg_orders') }}
*/

-- 2. pivot - Pivot rows to columns
/*
{{ dbt_utils.pivot(
    'event_type',
    dbt_utils.get_column_values(ref('stg_events'), 'event_type')
) }}
*/

-- 3. date_spine - Generate date range
/*
{{ dbt_utils.date_spine(
    datepart="day",
    start_date="cast('2020-01-01' as date)",
    end_date="cast('2025-12-31' as date)"
) }}
*/


-- =============================================================================
-- RUNNING AND DEBUGGING
-- =============================================================================

-- Compile SQL without running (great for debugging Jinja)
-- dbt compile --select fct_daily_events

-- View compiled SQL
-- cat target/compiled/.../fct_daily_events.sql

-- Run with full refresh
-- dbt run --select fct_daily_events --full-refresh

-- Run incremental (normal)
-- dbt run --select fct_daily_events


-- =============================================================================
-- INSTRUCTOR TALKING POINTS
-- =============================================================================

-- 1. "Incremental models are like Spark's merge into Delta Lake.
--     First run = full load, subsequent runs = only new data."

-- 2. "is_incremental() returns FALSE on first run and TRUE after.
--     Use this to add filters that skip already-processed data."

-- 3. "Jinja is like Python f-strings but for SQL. You can loop,
--     use variables, and conditionally include SQL."

-- 4. "Macros are reusable functions. Write once, use everywhere.
--     Great for company-standard calculations."

-- 5. "dbt compile lets you see the actual SQL that will run.
--     Essential for debugging complex Jinja."

-- 6. "dbt_utils is a community package with common patterns.
--     Don't reinvent the wheel - check if dbt_utils has it."


-- =============================================================================
-- SUMMARY
-- =============================================================================

-- | Concept | Purpose | Bridge |
-- |---------|---------|--------|
-- | Incremental | Process only new data | Spark Delta merge |
-- | is_incremental() | Check if subsequent run | -- |
-- | {{ this }} | Reference current table | -- |
-- | Jinja {% %} | Loops, conditionals | Python f-strings |
-- | Macros | Reusable SQL functions | Python functions |
-- | dbt compile | Preview SQL | -- |
