-- =============================================================================
-- DEMO: Medallion Architecture Overview (Bronze/Silver/Gold)
-- Day: 1-Monday
-- Duration: ~20 minutes
-- Prerequisites: demo_snowflake_setup.sql completed (creates DEV_DB)
-- NOTE: Run demo_snowflake_setup.sql FIRST to create the DEV_DB database
-- =============================================================================
--
-- INSTRUCTOR NOTES:
-- Trainees read about Medallion in the written content. This demo makes it
-- tangible with actual Snowflake objects. We're creating STRUCTURE only -
-- data loading happens Tuesday.
--
-- KEY BRIDGE: "Remember in Spark you'd read from S3 raw zone, transform,
-- and write to curated zone? Same concept, just organized as layers."
-- =============================================================================

-- =============================================================================
-- SETUP: Ensure Context
-- =============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEV_DB;

-- Quick credit check reminder
ALTER WAREHOUSE COMPUTE_WH SET AUTO_SUSPEND = 60;

-- =============================================================================
-- PHASE 1: The Three-Layer Pattern (Concept Talk - 5 mins)
-- =============================================================================

-- INSTRUCTOR: Before running SQL, explain verbally:
--
-- "Medallion Architecture has THREE LAYERS:
--
-- BRONZE (Raw/Landing)
--   - Data exactly as it arrived
--   - Schema-on-read (like reading JSON in Spark without defining columns)
--   - We keep EVERYTHING for auditing
--   - Could have duplicates, nulls, garbage - we don't care yet
--
-- SILVER (Cleansed/Conformed)  
--   - Data is typed, validated, deduplicated
--   - Like when you define a StructType schema in Spark
--   - Ready for analysts to query, but not aggregated yet
--
-- GOLD (Business-Ready)
--   - Aggregates, metrics, dimensions, facts
--   - What dashboards and reports connect to
--   - Optimized for specific business questions"

-- =============================================================================
-- PHASE 2: Create the Schema Structure (5 mins)
-- =============================================================================

-- "Let's create these three zones in Snowflake. They'll be schemas."

-- Bronze Layer - Raw data landing zone
CREATE SCHEMA IF NOT EXISTS BRONZE
    COMMENT = 'Raw data layer - schema-on-read, no transformations';

-- Silver Layer - Cleansed and typed data  
CREATE SCHEMA IF NOT EXISTS SILVER
    COMMENT = 'Cleansed layer - validated, typed, deduplicated';

-- Gold Layer - Business-ready aggregates
CREATE SCHEMA IF NOT EXISTS GOLD
    COMMENT = 'Business layer - aggregates, metrics, dimensional models';

-- Verify the structure
SHOW SCHEMAS IN DATABASE DEV_DB;

-- =============================================================================
-- PHASE 3: Bronze Layer Table (5 mins)
-- =============================================================================

USE SCHEMA BRONZE;

-- "Bronze tables often use VARIANT to store raw JSON/semi-structured data.
-- This is like spark.read.json() without specifying a schema."

CREATE OR REPLACE TABLE RAW_ORDERS (
    -- Metadata columns (when and where did this data come from?)
    ingestion_ts TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_file STRING,
    
    -- The actual payload - VARIANT stores JSON, Parquet, anything
    -- "This is Snowflake's superpower - native semi-structured support"
    raw_data VARIANT
)
COMMENT = 'Raw order events - no transformations applied';

-- "In production, this table would receive data from Snowpipe or COPY INTO.
-- We'll load data tomorrow. Today we're just setting up the structure."

-- Show the table structure
DESCRIBE TABLE RAW_ORDERS;

-- =============================================================================
-- PHASE 4: Silver Layer Table (5 mins)
-- =============================================================================

USE SCHEMA SILVER;

-- "Silver is where we apply types and constraints.
-- Like defining a Spark StructType schema before reading."

CREATE OR REPLACE TABLE ORDERS (
    -- Business keys
    order_id STRING NOT NULL,
    customer_id STRING NOT NULL,
    
    -- Typed and validated fields
    order_date DATE NOT NULL,
    order_status STRING,
    
    -- Monetary amounts with precision
    amount DECIMAL(12,2),
    
    -- Processing metadata
    processed_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    
    -- Primary key constraint (enforced only for metadata, not blocking inserts)
    PRIMARY KEY (order_id)
)
COMMENT = 'Cleansed orders - typed, validated, ready for analysis';

-- "Notice NOT NULL constraints. Bad data won't make it to Silver.
-- The PRIMARY KEY is declarative - Snowflake doesn't enforce it on insert,
-- but it helps query optimization and documentation."

DESCRIBE TABLE ORDERS;

-- =============================================================================
-- PHASE 5: Gold Layer Table (5 mins)
-- =============================================================================

USE SCHEMA GOLD;

-- "Gold is business-ready. Pre-aggregated, denormalized, fast.
-- This is what your BI tools and dashboards will query."

CREATE OR REPLACE TABLE DAILY_REVENUE (
    -- Date dimension key
    report_date DATE NOT NULL,
    
    -- Pre-computed metrics
    total_orders INTEGER,
    total_revenue DECIMAL(14,2),
    avg_order_value DECIMAL(10,2),
    
    -- Refresh tracking
    refreshed_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    
    PRIMARY KEY (report_date)
)
COMMENT = 'Daily revenue metrics - ready for dashboards';

-- "In production, a scheduled job (Task or dbt) refreshes this table daily.
-- Dashboards query Gold because it's fast - no aggregation at query time."

DESCRIBE TABLE DAILY_REVENUE;

-- =============================================================================
-- PHASE 6: Visualize the Architecture
-- =============================================================================

-- List all our tables across layers
SELECT 
    TABLE_SCHEMA AS layer,
    TABLE_NAME AS table_name,
    COMMENT AS description
FROM DEV_DB.INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA IN ('BRONZE', 'SILVER', 'GOLD')
ORDER BY 
    CASE TABLE_SCHEMA 
        WHEN 'BRONZE' THEN 1 
        WHEN 'SILVER' THEN 2 
        WHEN 'GOLD' THEN 3 
    END;

-- INSTRUCTOR: Draw this flow on the whiteboard:
--
--   BRONZE.RAW_ORDERS
--         |
--         | (cleanse + type)
--         v
--   SILVER.ORDERS
--         |
--         | (aggregate)
--         v
--   GOLD.DAILY_REVENUE
--
-- "Data flows DOWN through the layers, gaining quality at each step."

-- =============================================================================
-- SUMMARY: Key Takeaways
-- =============================================================================

-- Key Points (SAY THESE OUT LOUD):
--
-- 1. Medallion is an ARCHITECTURE PATTERN, not a Snowflake feature.
--    You could do this in Spark, Databricks, BigQuery - anywhere.
--
-- 2. BRONZE = Raw, keep everything, use VARIANT for flexibility.
--
-- 3. SILVER = Apply business rules, types, constraints.
--
-- 4. GOLD = Pre-aggregated, dashboard-ready, fast queries.
--
-- 5. Tomorrow we'll load actual data into Bronze and transform it.

-- =============================================================================
-- NEXT STEPS
-- =============================================================================

-- Tomorrow (Tuesday): We'll use COPY INTO to load data into BRONZE.RAW_ORDERS,
-- then write transformations to populate SILVER.ORDERS.

-- Verify everything exists before leaving
SELECT 'Setup Complete!' AS status,
    (SELECT COUNT(*) FROM DEV_DB.INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME IN ('BRONZE','SILVER','GOLD')) AS schemas_created,
    (SELECT COUNT(*) FROM DEV_DB.INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA IN ('BRONZE','SILVER','GOLD')) AS tables_created;
