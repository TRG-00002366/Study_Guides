-- =============================================================================
-- DEMO: SnowSQL Operations
-- Day: 2-Tuesday
-- Duration: ~15 minutes
-- Prerequisites: Monday demos completed, DEV_DB exists
-- =============================================================================
--
-- INSTRUCTOR NOTES:
-- SnowSQL is Snowflake's CLI. Similar to spark-shell or pyspark REPL.
-- Have Snowsight UI as backup if SnowSQL installation issues occur.
--
-- KEY BRIDGE: "SnowSQL is like spark-shell, but for Snowflake."
-- =============================================================================

-- =============================================================================
-- PHASE 1: Connection & Context Verification (5 mins)
-- =============================================================================

-- Run these commands in SnowSQL CLI or Snowsight worksheet

-- "First, let's verify we're connected properly."
-- "Think of this like checking your SparkSession configuration."

SELECT 
    CURRENT_USER() AS connected_user,
    CURRENT_ROLE() AS current_role,
    CURRENT_WAREHOUSE() AS warehouse,
    CURRENT_DATABASE() AS database,
    CURRENT_SCHEMA() AS schema;

-- Set our working context
USE WAREHOUSE COMPUTE_WH;
USE DATABASE SNOWFLAKE_SAMPLE_DATA;
USE SCHEMA TPCH_SF1;

-- Credit protection reminder
ALTER WAREHOUSE COMPUTE_WH SET AUTO_SUSPEND = 60;

-- =============================================================================
-- PHASE 2: Basic Queries (5 mins)
-- =============================================================================

-- "Now let's run some queries. This should feel very familiar from Spark SQL."

-- Simple SELECT with LIMIT (identical to Spark)
SELECT * FROM CUSTOMER LIMIT 10;

-- Aggregation query
-- "This is EXACTLY like Spark SQL. Same syntax, same patterns."
SELECT 
    C_MKTSEGMENT AS market_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(C_ACCTBAL), 2) AS avg_balance,
    ROUND(SUM(C_ACCTBAL), 2) AS total_balance
FROM CUSTOMER
GROUP BY C_MKTSEGMENT
ORDER BY customer_count DESC;

-- Filtering with WHERE
SELECT 
    C_NAME,
    C_NATIONKEY,
    C_ACCTBAL
FROM CUSTOMER
WHERE C_ACCTBAL > 5000
    AND C_MKTSEGMENT = 'MACHINERY'
ORDER BY C_ACCTBAL DESC
LIMIT 20;

-- =============================================================================
-- PHASE 3: Joins Across Tables (5 mins)
-- =============================================================================

-- "Let's do a join - again, identical to Spark SQL."

-- Join CUSTOMER with NATION
SELECT 
    c.C_NAME AS customer_name,
    n.N_NAME AS nation,
    c.C_ACCTBAL AS balance
FROM CUSTOMER c
JOIN NATION n ON c.C_NATIONKEY = n.N_NATIONKEY
WHERE n.N_NAME = 'UNITED STATES'
ORDER BY c.C_ACCTBAL DESC
LIMIT 10;

-- Multi-table join
SELECT 
    n.N_NAME AS nation,
    r.R_NAME AS region,
    COUNT(*) AS customer_count,
    ROUND(AVG(c.C_ACCTBAL), 2) AS avg_balance
FROM CUSTOMER c
JOIN NATION n ON c.C_NATIONKEY = n.N_NATIONKEY
JOIN REGION r ON n.N_REGIONKEY = r.R_REGIONKEY
GROUP BY n.N_NAME, r.R_NAME
ORDER BY customer_count DESC
LIMIT 10;

-- =============================================================================
-- PHASE 4: SnowSQL-Specific Features (CLI Demo)
-- =============================================================================

-- If using SnowSQL CLI, demonstrate these meta-commands:
-- (These won't run in Snowsight worksheet)

-- !help                    -- Show available commands
-- !set output_format=csv   -- Change output format
-- !set output_format=psql  -- Back to table format (default)
-- !source my_script.sql    -- Run a SQL file
-- !exit                    -- Exit SnowSQL

-- Show query history
SELECT 
    QUERY_TEXT,
    EXECUTION_STATUS,
    TOTAL_ELAPSED_TIME/1000 AS seconds,
    BYTES_SCANNED/1000000 AS mb_scanned
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE QUERY_TYPE = 'SELECT'
ORDER BY START_TIME DESC
LIMIT 5;

-- =============================================================================
-- SUMMARY
-- =============================================================================

-- Key Takeaways:
--
-- 1. SnowSQL syntax is standard SQL - if you know Spark SQL, you know this
-- 2. USE statements set your context (database, schema, warehouse)
-- 3. Joins work exactly as expected
-- 4. Meta-commands (!) are like IPython magic commands
-- 5. Query history is available via INFORMATION_SCHEMA

-- "Everything you learned in Spark SQL applies here. The syntax is the same."
