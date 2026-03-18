-- =============================================================================
-- DEMO: Data Modeling with TPC-H Sample Data
-- Day: 3-Wednesday
-- Duration: ~20 minutes
-- Prerequisites: Access to SNOWFLAKE_SAMPLE_DATA
-- =============================================================================
--
-- INSTRUCTOR NOTES:
-- This demo explores the TPC-H sample dataset to teach data modeling concepts.
-- TPC-H is a standard decision support benchmark - perfect for teaching!
--
-- KEY OBJECTIVES:
-- 1. Understand the TPC-H schema structure
-- 2. Identify normalized vs denormalized patterns
-- 3. Recognize snowflake schema (the modeling pattern, not the product!)
-- 4. Practice reverse-engineering a data model from existing tables
--
-- BRIDGE: "TPC-H is like a real-world OLTP schema that we'll transform
-- into our Gold layer star schema."
-- =============================================================================


-- =============================================================================
-- SETUP
-- =============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

ALTER WAREHOUSE COMPUTE_WH SET AUTO_SUSPEND = 60;


-- =============================================================================
-- PHASE 1: Introducing TPC-H (5 mins)
-- =============================================================================

-- "TPC-H is a decision support benchmark created by the Transaction
-- Processing Performance Council. Every major database vendor uses it."

-- Show available sample databases
SHOW DATABASES LIKE 'SNOWFLAKE_SAMPLE_DATA';

-- Explore schemas in the sample database
SHOW SCHEMAS IN DATABASE SNOWFLAKE_SAMPLE_DATA;

-- "SF1 means Scale Factor 1 - about 1GB of data.
-- SF10 = 10GB, SF100 = 100GB, SF1000 = 1TB.
-- We'll use SF1 for demos."

-- Show tables in TPC-H
SHOW TABLES IN SCHEMA SNOWFLAKE_SAMPLE_DATA.TPCH_SF1;

-- "Notice 8 tables:
--   CUSTOMER, NATION, REGION (dimensions)
--   SUPPLIER, PART, PARTSUPP (supplier/product dimensions)  
--   ORDERS, LINEITEM (facts/transactions)"


-- =============================================================================
-- PHASE 2: Understanding the TPC-H Schema (5 mins - WHITEBOARD)
-- =============================================================================

-- INSTRUCTOR: Draw this on the whiteboard:
--
--                        +----------+
--                        |  REGION  |
--                        +----+-----+
--                             |
--                        +----v-----+
--                        |  NATION  |
--                        +----+-----+
--                             |
--          +------------------+------------------+
--          |                                     |
--     +----v-----+                         +-----v----+
--     | CUSTOMER |                         | SUPPLIER |
--     +----+-----+                         +-----+----+
--          |                                     |
--          |                               +-----v----+
--          |                               | PARTSUPP |<----+----+
--          |                               +-----+----+     |    |
--     +----v-----+                               |     +----+----+
--     |  ORDERS  |                               |     |   PART  |
--     +----+-----+                               |     +---------+
--          |                                     |
--     +----v------+                              |
--     | LINEITEM  |<-----------------------------+
--     +-----------+
--
-- "This is a SNOWFLAKE SCHEMA (the modeling pattern):
--   - REGION connects to NATION (hierarchy)
--   - NATION connects to CUSTOMER and SUPPLIER (normalization)
--   - LINEITEM is the grain (one row per item per order)"


-- =============================================================================
-- PHASE 3: Exploring Dimension Tables (5 mins)
-- =============================================================================

-- "Let's explore the geographic hierarchy: REGION -> NATION"

-- REGION table (top of hierarchy)
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION;

-- "Only 5 rows! Regions are: AFRICA, AMERICA, ASIA, EUROPE, MIDDLE EAST"

-- NATION table (references REGION)
SELECT 
    n.N_NATIONKEY,
    n.N_NAME,
    r.R_NAME AS region_name
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r ON n.N_REGIONKEY = r.R_REGIONKEY
ORDER BY r.R_NAME, n.N_NAME;

-- "25 nations across 5 regions. Notice the foreign key N_REGIONKEY."

-- CUSTOMER table (references NATION)
SELECT 
    C_CUSTKEY,
    C_NAME,
    C_MKTSEGMENT,
    C_NATIONKEY
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
LIMIT 10;

-- Check customer distribution by market segment
SELECT 
    C_MKTSEGMENT,
    COUNT(*) AS customer_count
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
GROUP BY C_MKTSEGMENT
ORDER BY customer_count DESC;

-- "5 market segments: AUTOMOBILE, BUILDING, FURNITURE, HOUSEHOLD, MACHINERY"


-- =============================================================================
-- PHASE 4: Exploring Fact Tables (5 mins)
-- =============================================================================

-- "ORDERS is the header, LINEITEM is the detail (like invoice vs line items)"

-- ORDERS table structure
SELECT 
    O_ORDERKEY,
    O_CUSTKEY,
    O_ORDERSTATUS,
    O_TOTALPRICE,
    O_ORDERDATE,
    O_ORDERPRIORITY
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
LIMIT 10;

-- Order status distribution
SELECT 
    O_ORDERSTATUS,
    COUNT(*) AS order_count,
    ROUND(AVG(O_TOTALPRICE), 2) AS avg_order_value
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
GROUP BY O_ORDERSTATUS;

-- "F = Fulfilled, O = Open, P = Pending"

-- LINEITEM table (the true grain - most detail)
SELECT 
    L_ORDERKEY,
    L_LINENUMBER,
    L_PARTKEY,
    L_SUPPKEY,
    L_QUANTITY,
    L_EXTENDEDPRICE,
    L_DISCOUNT,
    L_TAX
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM
WHERE L_ORDERKEY = 1
ORDER BY L_LINENUMBER;

-- "One order can have multiple line items. Each line item:
--   - References a part (product)
--   - References a supplier
--   - Has quantity, price, discount, tax (measures)"

-- Count of line items per order
SELECT 
    AVG(items_per_order) AS avg_items,
    MIN(items_per_order) AS min_items,
    MAX(items_per_order) AS max_items
FROM (
    SELECT L_ORDERKEY, COUNT(*) AS items_per_order
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM
    GROUP BY L_ORDERKEY
);

-- "Average of 4 items per order, ranging from 1 to 7."


-- =============================================================================
-- PHASE 5: Understanding Cardinality (3 mins)
-- =============================================================================

-- "Understanding row counts helps identify facts vs dimensions"

SELECT 'REGION' AS table_name, COUNT(*) AS row_count FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION
UNION ALL SELECT 'NATION', COUNT(*) FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION
UNION ALL SELECT 'CUSTOMER', COUNT(*) FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
UNION ALL SELECT 'SUPPLIER', COUNT(*) FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.SUPPLIER
UNION ALL SELECT 'PART', COUNT(*) FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART
UNION ALL SELECT 'PARTSUPP', COUNT(*) FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PARTSUPP
UNION ALL SELECT 'ORDERS', COUNT(*) FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
UNION ALL SELECT 'LINEITEM', COUNT(*) FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM
ORDER BY row_count;

-- "Notice the pattern:
--   - Small: REGION (5), NATION (25) - reference data
--   - Medium: CUSTOMER (150K), SUPPLIER (10K), PART (200K) - dimensions
--   - Large: ORDERS (1.5M), LINEITEM (6M) - facts/transactions
--
-- LINEITEM is the largest because it's the lowest grain."


-- =============================================================================
-- PHASE 6: Normalized vs. Denormalized (5 mins)
-- =============================================================================

-- "TPC-H is a normalized (3NF) schema. Let's see what a denormalized
-- query looks like - this is what we'd build in our Gold layer."

-- Fully denormalized query (from LINEITEM to REGION)
SELECT
    r.R_NAME AS region,
    n.N_NAME AS nation,
    c.C_MKTSEGMENT AS segment,
    YEAR(o.O_ORDERDATE) AS order_year,
    COUNT(DISTINCT o.O_ORDERKEY) AS total_orders,
    SUM(l.L_EXTENDEDPRICE * (1 - l.L_DISCOUNT)) AS revenue
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM l
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS o ON l.L_ORDERKEY = o.O_ORDERKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER c ON o.O_CUSTKEY = c.C_CUSTKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n ON c.C_NATIONKEY = n.N_NATIONKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r ON n.N_REGIONKEY = r.R_REGIONKEY
GROUP BY r.R_NAME, n.N_NAME, c.C_MKTSEGMENT, YEAR(o.O_ORDERDATE)
ORDER BY region, nation, segment, order_year
LIMIT 20;

-- "That's 5 JOINs! In a star schema, we'd flatten customer + nation + region
-- into a single DIM_CUSTOMER table with all attributes pre-joined."


-- =============================================================================
-- PHASE 7: Snowflake Schema vs. Star Schema (2 mins)
-- =============================================================================

-- INSTRUCTOR: Explain the difference:
--
-- SNOWFLAKE SCHEMA (what TPC-H uses):
--   CUSTOMER -> NATION -> REGION (normalized, multiple hops)
--   + Less storage (no duplication)
--   + Easy to update reference data
--   - More joins = slower queries
--
-- STAR SCHEMA (what we build in GOLD layer):
--   DIM_CUSTOMER (contains region_name, nation_name inline)
--   + Fewer joins = faster queries
--   + BI tools love it
--   - More storage
--   - Updates require rebuilding dimensions
--
-- "In the Medallion architecture:
--   BRONZE = raw data
--   SILVER = cleaned, still normalized
--   GOLD = denormalized star schema for analytics"


-- =============================================================================
-- SUMMARY
-- =============================================================================

-- TPC-H Schema Key Takeaways:
--
-- 1. TPC-H is a benchmark schema - great for learning and testing
--
-- 2. It uses SNOWFLAKE SCHEMA pattern (normalized, multiple levels)
--
-- 3. Hierarchy: REGION -> NATION -> CUSTOMER/SUPPLIER
--
-- 4. ORDERS is the header fact, LINEITEM is the detail fact
--
-- 5. Cardinality increases as you go from dimensions to facts
--
-- 6. In our GOLD layer, we'll DENORMALIZE this into a STAR SCHEMA
--    for faster analytics
--
-- 7. The demo_star_schema.sql shows how to transform TPC-H into
--    a star schema

-- "This is classic data engineering: understand the source (TPC-H),
-- then transform it for the business (star schema in GOLD)."


-- =============================================================================
-- BRIDGE TO NEXT DEMO
-- =============================================================================

-- "Now that you understand TPC-H's normalized structure, let's build
-- our own star schema from it in demo_star_schema.sql."
