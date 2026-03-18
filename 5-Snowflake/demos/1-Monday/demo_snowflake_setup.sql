-- =============================================================================
-- DEMO: Snowflake Setup & First Steps
-- Day: 1-Monday
-- Duration: ~25 minutes
-- Prerequisites: Snowflake Free Trial account
-- =============================================================================
-- 
-- INSTRUCTOR NOTES:
-- This is the trainees' first hands-on Snowflake experience. They're coming
-- from Spark/Kafka/Airflow and will be surprised how "easy" this feels.
-- Emphasize the "no infrastructure" aspect throughout.
--
-- KEY BRIDGE: "Think of a Virtual Warehouse as an EMR cluster that starts
-- in 2 seconds instead of 5 minutes."
-- =============================================================================

-- =============================================================================
-- PHASE 1: Context & Cost Control (5 mins)
-- =============================================================================

-- First, explain the session context pattern
-- "In Spark, you'd configure your SparkSession. In Snowflake, you set context."

-- Check what we're connected to (like checking your Spark master)
SELECT 
    CURRENT_USER() AS user,
    CURRENT_ROLE() AS role,
    CURRENT_WAREHOUSE() AS warehouse,
    CURRENT_DATABASE() AS database,
    CURRENT_SCHEMA() AS schema;

-- CRITICAL: Set cost-saving auto-suspend IMMEDIATELY
-- "Your trial has $400 in credits. Let's not burn them by accident."
-- This is like setting spark.executor.instances conservatively on EMR.
ALTER WAREHOUSE COMPUTE_WH SET 
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;

-- Verify the setting
SHOW WAREHOUSES LIKE 'COMPUTE_WH';

-- =============================================================================
-- PHASE 2: Exploring Sample Data (5 mins)
-- =============================================================================

-- "Snowflake includes sample datasets. Think of it as pre-loaded data 
-- that someone else managed - like a company's shared data lake."

-- Set context to use sample data
USE DATABASE SNOWFLAKE_SAMPLE_DATA;
USE SCHEMA TPCH_SF1;

-- Show available tables (like listing tables in a Spark catalog)
SHOW TABLES;

-- Quick query to demonstrate speed
-- "Watch this - 1.5 million rows..."
SELECT COUNT(*) AS total_orders FROM ORDERS;
-- "Under a second. On Spark, you'd still be waiting for executors to spin up."

-- Basic exploration (this is identical to Spark SQL)
SELECT 
    O_ORDERSTATUS AS status,
    COUNT(*) AS order_count,
    SUM(O_TOTALPRICE) AS total_revenue
FROM ORDERS
GROUP BY O_ORDERSTATUS
ORDER BY total_revenue DESC;

-- =============================================================================
-- PHASE 3: Creating Your Own Playground (10 mins)
-- =============================================================================

-- "Now let's create your own database. Like creating a new Spark database."

-- Use admin role for creating resources
-- "Think of roles like IAM policies in AWS."
USE ROLE ACCOUNTADMIN;

-- Create a development database
-- "This is your sandbox for the week."
CREATE DATABASE IF NOT EXISTS DEV_DB
    COMMENT = 'Development database for Week 5 training';

-- Create a sandbox schema
CREATE SCHEMA IF NOT EXISTS DEV_DB.SANDBOX
    COMMENT = 'Personal sandbox for experiments';

-- Switch to the new context
USE DATABASE DEV_DB;
USE SCHEMA SANDBOX;

-- Verify your location
SELECT CURRENT_DATABASE(), CURRENT_SCHEMA();

-- Create a simple table to confirm everything works
CREATE OR REPLACE TABLE HELLO_SNOWFLAKE (
    message STRING,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO HELLO_SNOWFLAKE (message) VALUES ('Snowflake is working!');
SELECT * FROM HELLO_SNOWFLAKE;

-- =============================================================================
-- PHASE 4: Understanding the UI (5 mins)
-- =============================================================================

-- INSTRUCTOR: Switch to Snowsight UI and show:
-- 
-- 1. ACTIVITY > Query History
--    - "See all your queries, execution times, bytes scanned"
--    - "Like Spark UI's SQL tab, but for all your history"
--
-- 2. DATA > Databases
--    - "Visual browser for your objects"
--    - "Notice DEV_DB now appears here"
--
-- 3. ADMIN > Warehouses  
--    - "This is like your EMR cluster management"
--    - "Notice AUTO_SUSPEND is set - warehouse will stop when idle"
--
-- 4. Click on COMPUTE_WH
--    - "See it's X-Small sized. This is like configuring executor memory."
--    - "You can resize instantly - no cluster restart needed"

-- =============================================================================
-- SUMMARY: What We Learned
-- =============================================================================

-- Key Takeaways (SAY THESE OUT LOUD):
--
-- 1. No installation required. Cloud-native from day one.
-- 2. Set AUTO_SUSPEND to avoid burning credits (like shutting down EMR).
-- 3. Context (USE statements) is like configuring your SparkSession.
-- 4. Query speed is instantaneous - no cluster warm-up time.
-- 5. The UI shows everything happening - like a combined Spark UI + console.

-- =============================================================================
-- CLEANUP (Optional)
-- =============================================================================

-- Don't run this during the demo, but useful if resetting:
-- DROP TABLE HELLO_SNOWFLAKE;
