-- =============================================================================
-- DEMO: Tables and Views
-- Day: 2-Tuesday
-- Duration: ~15 minutes
-- Prerequisites: DEV_DB with SILVER schema exists
-- =============================================================================
--
-- INSTRUCTOR NOTES:
-- Focus on the differences between table types and introduce Time Travel.
-- Time Travel is a key differentiator - version history is built into Snowflake.
--
-- KEY BRIDGE: "Time Travel is built-in. It's like having git for your data."
-- =============================================================================

-- =============================================================================
-- SETUP
-- =============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEV_DB;
USE SCHEMA SILVER;

ALTER WAREHOUSE COMPUTE_WH SET AUTO_SUSPEND = 60;

-- =============================================================================
-- PHASE 1: Table Types Comparison (5 mins)
-- =============================================================================

-- "Snowflake has three types of tables. Let's understand the differences."

-- PERMANENT TABLE (default)
-- - Full Time Travel (up to 90 days on Enterprise)
-- - Fail-Safe (7 days disaster recovery)
-- - Highest storage cost, highest durability
CREATE OR REPLACE TABLE ORDERS_PERMANENT (
    order_id STRING,
    customer_id STRING,
    amount DECIMAL(10,2),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Permanent table - full Time Travel and Fail-Safe';

-- TRANSIENT TABLE
-- - Time Travel (up to 1 day only)
-- - NO Fail-Safe
-- - Lower storage cost, good for staging/intermediate data
CREATE OR REPLACE TRANSIENT TABLE ORDERS_STAGING (
    order_id STRING,
    customer_id STRING,
    amount DECIMAL(10,2),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Transient table - 1-day Time Travel, no Fail-Safe';

-- TEMPORARY TABLE
-- - Session-scoped (disappears when session ends)
-- - Time Travel (up to 1 day)
-- - NO Fail-Safe
-- - Like Spark's createTempView but persists across queries
CREATE TEMPORARY TABLE ORDERS_TEMP (
    order_id STRING,
    customer_id STRING,
    amount DECIMAL(10,2),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Temporary table - session-scoped only';

-- "BRIDGE: Think of it this way:
-- - PERMANENT = Production tables (full version history for recovery)
-- - TRANSIENT = Staging tables (temp files you don't need to recover)
-- - TEMPORARY = Spark temp views that survive multiple queries in a session"

-- =============================================================================
-- PHASE 2: Time Travel Demo (5 mins)
-- =============================================================================

-- "This is where Snowflake really shines. Built-in version history."

-- Insert initial data
INSERT INTO ORDERS_PERMANENT VALUES 
    ('O001', 'C100', 100.00, CURRENT_TIMESTAMP()),
    ('O002', 'C101', 200.00, CURRENT_TIMESTAMP()),
    ('O003', 'C102', 300.00, CURRENT_TIMESTAMP());

-- Check current state
SELECT * FROM ORDERS_PERMANENT;

-- Wait a few seconds, then update
-- INSTRUCTOR: Pause here for 5-10 seconds to create time difference

UPDATE ORDERS_PERMANENT SET amount = 999.99 WHERE order_id = 'O001';
DELETE FROM ORDERS_PERMANENT WHERE order_id = 'O003';

-- Current state after changes
SELECT * FROM ORDERS_PERMANENT ORDER BY order_id;
-- O001 now shows 999.99, O003 is gone

-- TIME TRAVEL: Query data as it was 60 seconds ago
-- "Watch this - we can see the past!"
SELECT * FROM ORDERS_PERMANENT AT (OFFSET => -60) ORDER BY order_id;
-- Shows original values: O001 = 100.00, O003 still exists!

-- Alternative syntax: specific timestamp
-- SELECT * FROM ORDERS_PERMANENT AT (TIMESTAMP => '2024-01-15 10:00:00'::TIMESTAMP);

-- Alternative syntax: query ID
-- SELECT * FROM ORDERS_PERMANENT BEFORE (STATEMENT => '<query_id>');

-- "BRIDGE: In regular Spark, once you overwrite data, it's gone.
-- Here, Snowflake keeps the history automatically. No extra setup needed."

-- =============================================================================
-- PHASE 3: Undoing Mistakes with Time Travel (3 mins)
-- =============================================================================

-- "Made a mistake? Restore from history."

-- Oops, we deleted O003 by accident. Let's restore it:
INSERT INTO ORDERS_PERMANENT
SELECT * FROM ORDERS_PERMANENT AT (OFFSET => -120) WHERE order_id = 'O003';

-- Verify restoration
SELECT * FROM ORDERS_PERMANENT ORDER BY order_id;

-- You can also clone an entire table from a point in time
CREATE OR REPLACE TABLE ORDERS_RESTORED CLONE ORDERS_PERMANENT AT (OFFSET => -120);
SELECT * FROM ORDERS_RESTORED;

-- "This is like git for your data. Accidentally DROP a table? 
-- UNDROP TABLE my_table; brings it back."

-- =============================================================================
-- PHASE 4: Views (3 mins)
-- =============================================================================

-- "Views work exactly like in Spark SQL."

-- Standard view
CREATE OR REPLACE VIEW V_HIGH_VALUE_ORDERS AS
SELECT 
    O_ORDERKEY,
    O_CUSTKEY,
    O_TOTALPRICE,
    O_ORDERDATE
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
WHERE O_TOTALPRICE > 100000;

-- Query the view
SELECT * FROM V_HIGH_VALUE_ORDERS LIMIT 10;

-- Secure view (hides definition from non-owners)
CREATE OR REPLACE SECURE VIEW V_CUSTOMER_SUMMARY AS
SELECT 
    C_MKTSEGMENT,
    COUNT(*) AS customer_count,
    AVG(C_ACCTBAL) AS avg_balance
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
GROUP BY C_MKTSEGMENT;

-- "Secure views hide the SQL definition. Good for when the query logic
-- itself is sensitive, or when you want to prevent query optimization
-- from exposing underlying data patterns."

-- =============================================================================
-- PHASE 5: Quick Reference - Table Types
-- =============================================================================

-- Show table properties
SELECT 
    TABLE_NAME,
    TABLE_TYPE,
    IS_TRANSIENT,
    RETENTION_TIME,
    COMMENT
FROM DEV_DB.INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'SILVER'
    AND TABLE_NAME LIKE 'ORDERS%';

-- =============================================================================
-- SUMMARY
-- =============================================================================

-- | Table Type  | Time Travel | Fail-Safe | Use Case               |
-- |-------------|-------------|-----------|------------------------|
-- | PERMANENT   | Up to 90d   | 7 days    | Production, critical   |
-- | TRANSIENT   | Up to 1d    | None      | Staging, intermediate  |
-- | TEMPORARY   | Up to 1d    | None      | Session calculations   |

-- Key Takeaways:
--
-- 1. Three table types with different durability/cost tradeoffs
-- 2. Time Travel is BUILT-IN - automatic version history for your data
-- 3. AT (OFFSET => -N) queries data N seconds ago
-- 4. CLONE creates instant copies without duplicating storage
-- 5. UNDROP TABLE recovers dropped tables
-- 6. SECURE views hide definition from unauthorized users

-- "This is like having git history for all your data, out of the box."
