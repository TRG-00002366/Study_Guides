-- =============================================================================
-- DEMO: Star Schema Design
-- Day: 3-Wednesday
-- Duration: ~20 minutes
-- Prerequisites: DEV_DB with GOLD schema, SNOWFLAKE_SAMPLE_DATA access
-- =============================================================================
--
-- INSTRUCTOR NOTES:
-- Build a simple star schema from TPC-H sample data.
-- Focus on: one fact, two dimensions, then show the analytical query payoff.
--
-- KEY BRIDGE: "This is like Spark DataFrame joins, but intentionally
-- denormalized for dashboard performance."
-- =============================================================================

-- =============================================================================
-- SETUP
-- =============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEV_DB;
USE SCHEMA GOLD;

ALTER WAREHOUSE COMPUTE_WH SET AUTO_SUSPEND = 60;

-- =============================================================================
-- PHASE 1: Star Schema Concept (5 mins verbal)
-- =============================================================================

-- INSTRUCTOR: Draw on whiteboard before SQL:
--
--                    +---------------+
--                    |   DIM_DATE    |
--                    | (date_key PK) |
--                    +---------------+
--                           |
--                           |
-- +---------------+   +---------------+   +---------------+
-- | DIM_CUSTOMER  |---|  FCT_ORDERS  |---| DIM_PRODUCT   |
-- | (customer_key)|   | (order_key)   |   | (product_key) |
-- +---------------+   +---------------+   +---------------+
--
-- "The fact table (center) contains:
--   - Foreign keys to dimensions
--   - Measures (things you SUM, COUNT, AVG)
--
-- Dimension tables (points of the star) contain:
--   - Descriptive attributes
--   - Things you GROUP BY, filter on"

-- =============================================================================
-- PHASE 2: Build Date Dimension (5 mins)
-- =============================================================================

-- "Every star schema needs a date dimension. It enables time-based analysis."

CREATE OR REPLACE TABLE DIM_DATE AS
SELECT
    -- Surrogate key (YYYYMMDD format as integer)
    TO_NUMBER(TO_CHAR(date_day, 'YYYYMMDD')) AS date_key,
    
    -- Date attributes
    date_day AS full_date,
    DAY(date_day) AS day_of_month,
    DAYOFWEEK(date_day) AS day_of_week,
    DAYNAME(date_day) AS day_name,
    
    -- Week attributes
    WEEKOFYEAR(date_day) AS week_of_year,
    
    -- Month attributes
    MONTH(date_day) AS month_num,
    MONTHNAME(date_day) AS month_name,
    
    -- Quarter and Year
    QUARTER(date_day) AS quarter,
    YEAR(date_day) AS year,
    
    -- Fiscal dimensions (assuming calendar = fiscal for demo)
    QUARTER(date_day) AS fiscal_quarter,
    YEAR(date_day) AS fiscal_year,
    
    -- Useful flags
    CASE WHEN DAYOFWEEK(date_day) IN (0, 6) THEN TRUE ELSE FALSE END AS is_weekend,
    FALSE AS is_holiday  -- Would be populated from a holiday calendar
FROM (
    -- Start from 1992 to cover TPC-H data range (1992-1998) plus future dates
    SELECT DATEADD('day', SEQ4(), '1992-01-01')::DATE AS date_day
    FROM TABLE(GENERATOR(ROWCOUNT => 15000))  -- ~41 years (1992-2033)
);

-- Verify (check TPC-H date range)
SELECT * FROM DIM_DATE WHERE year = 1995 AND month_num = 1 LIMIT 10;
SELECT COUNT(*) AS total_dates FROM DIM_DATE;
SELECT MIN(full_date) AS min_date, MAX(full_date) AS max_date FROM DIM_DATE;

-- "This table lets you query by year, quarter, month, day name, etc.
-- without putting date functions in every query. BI tools love this."

-- =============================================================================
-- PHASE 3: Build Customer Dimension (3 mins)
-- =============================================================================

-- "Customer dimension comes from the TPC-H sample data."

CREATE OR REPLACE TABLE DIM_CUSTOMER AS
SELECT 
    C_CUSTKEY AS customer_key,
    C_CUSTKEY AS customer_id,  -- Natural key preserved
    C_NAME AS customer_name,
    C_MKTSEGMENT AS market_segment,
    C_NATIONKEY AS nation_key,
    'Active' AS customer_status  -- Example derived attribute
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

-- Verify
SELECT * FROM DIM_CUSTOMER LIMIT 10;
SELECT market_segment, COUNT(*) FROM DIM_CUSTOMER GROUP BY market_segment;

-- =============================================================================
-- PHASE 4: Build Product Dimension (3 mins)
-- =============================================================================

-- "Product dimension comes from TPC-H PART table."

CREATE OR REPLACE TABLE DIM_PRODUCT AS
SELECT
    P_PARTKEY AS product_key,
    P_PARTKEY AS product_id,  -- Natural key preserved
    P_NAME AS product_name,
    P_MFGR AS manufacturer,
    P_BRAND AS brand,
    P_TYPE AS product_type,
    P_SIZE AS product_size,
    P_CONTAINER AS container_type,
    P_RETAILPRICE AS retail_price
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART;

-- Verify
SELECT * FROM DIM_PRODUCT LIMIT 10;
SELECT manufacturer, COUNT(*) AS product_count 
FROM DIM_PRODUCT 
GROUP BY manufacturer 
ORDER BY product_count DESC;

-- =============================================================================
-- PHASE 5: Build Fact Table (5 mins)
-- =============================================================================

-- "The fact table contains measures and foreign keys to ALL dimensions."
-- "We use LINEITEM level for product detail - this is the true grain."

CREATE OR REPLACE TABLE FCT_ORDER_LINES AS
SELECT
    -- Composite grain: order + line number
    l.L_ORDERKEY AS order_key,
    l.L_LINENUMBER AS line_number,
    
    -- Foreign keys to ALL dimensions
    TO_NUMBER(TO_CHAR(o.O_ORDERDATE, 'YYYYMMDD')) AS date_key,
    o.O_CUSTKEY AS customer_key,
    l.L_PARTKEY AS product_key,
    
    -- Measures (things you aggregate)
    l.L_QUANTITY AS quantity,
    l.L_EXTENDEDPRICE AS extended_price,
    l.L_DISCOUNT AS discount_pct,
    l.L_EXTENDEDPRICE * (1 - l.L_DISCOUNT) AS net_amount,
    l.L_EXTENDEDPRICE * (1 - l.L_DISCOUNT) * (1 + l.L_TAX) AS total_amount,
    1 AS line_count,  -- Useful for COUNT aggregations
    
    -- Semi-additive/descriptive (from order header)
    o.O_ORDERSTATUS AS order_status,
    o.O_ORDERPRIORITY AS order_priority
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM l
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS o ON l.L_ORDERKEY = o.O_ORDERKEY;

-- Verify
SELECT * FROM FCT_ORDER_LINES LIMIT 10;
SELECT COUNT(*) AS total_line_items FROM FCT_ORDER_LINES;

-- "Notice:
-- - Grain is order + line_number (one row per line item)
-- - date_key, customer_key, AND product_key are FK to dimensions
-- - net_amount is the calculated measure we'll SUM
-- - ~6M rows because LINEITEM is the detail level"

-- =============================================================================
-- PHASE 6: The Payoff - Analytical Query (5 mins)
-- =============================================================================

-- "Now let's see why this structure is powerful for analytics."

-- Query 1: Revenue by Year and Quarter
SELECT
    d.year,
    d.quarter,
    SUM(f.net_amount) AS total_revenue,
    SUM(f.quantity) AS total_units,
    COUNT(DISTINCT f.order_key) AS total_orders,
    ROUND(SUM(f.net_amount) / COUNT(DISTINCT f.order_key), 2) AS avg_order_value
FROM FCT_ORDER_LINES f
JOIN DIM_DATE d ON f.date_key = d.date_key
GROUP BY d.year, d.quarter
ORDER BY d.year, d.quarter;

-- Query 2: Revenue by Customer Segment
SELECT
    c.market_segment,
    d.year,
    SUM(f.net_amount) AS total_revenue,
    COUNT(DISTINCT f.customer_key) AS unique_customers,
    ROUND(SUM(f.net_amount) / COUNT(DISTINCT f.customer_key), 2) AS revenue_per_customer
FROM FCT_ORDER_LINES f
JOIN DIM_DATE d ON f.date_key = d.date_key
JOIN DIM_CUSTOMER c ON f.customer_key = c.customer_key
GROUP BY c.market_segment, d.year
ORDER BY d.year, c.market_segment;

-- Query 3: Top Customers by Revenue (using dimensions for context)
SELECT
    c.customer_name,
    c.market_segment,
    SUM(f.net_amount) AS total_revenue,
    SUM(f.quantity) AS total_units,
    COUNT(DISTINCT f.order_key) AS order_count
FROM FCT_ORDER_LINES f
JOIN DIM_CUSTOMER c ON f.customer_key = c.customer_key
GROUP BY c.customer_name, c.market_segment
ORDER BY total_revenue DESC
LIMIT 10;

-- Query 4: Revenue by Product Brand (NEW - using product dimension!)
SELECT
    p.manufacturer,
    p.brand,
    d.year,
    SUM(f.net_amount) AS total_revenue,
    SUM(f.quantity) AS units_sold,
    COUNT(DISTINCT p.product_key) AS unique_products
FROM FCT_ORDER_LINES f
JOIN DIM_DATE d ON f.date_key = d.date_key
JOIN DIM_PRODUCT p ON f.product_key = p.product_key
GROUP BY p.manufacturer, p.brand, d.year
ORDER BY d.year, total_revenue DESC
LIMIT 20;

-- "Notice how clean these queries are:
-- - Simple JOINs on key columns (date_key, customer_key, product_key)
-- - GROUP BY dimension attributes
-- - SUM/COUNT fact measures
--
-- BRIDGE: This is exactly like Spark DataFrame joins, but the schema
-- is designed specifically for analytical queries. BI tools generate
-- SQL that looks just like this."


-- =============================================================================
-- PHASE 6B: Comparison - Normalized vs. Star Schema Queries
-- =============================================================================

-- "Let's compare the same question answered two ways:
-- 1. Using the raw TPC-H normalized schema (5+ JOINs)
-- 2. Using our star schema (2-3 JOINs)"

-- -----------------------------------------------------------------------------
-- QUESTION: Revenue by Region, Year, and Product Type
-- -----------------------------------------------------------------------------

-- APPROACH A: Normalized TPC-H Schema (5 JOINs!)
-- This is what you'd have to write without a star schema

SELECT
    r.R_NAME AS region,
    YEAR(o.O_ORDERDATE) AS order_year,
    p.P_TYPE AS product_type,
    SUM(l.L_EXTENDEDPRICE * (1 - l.L_DISCOUNT)) AS revenue
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM l
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS o ON l.L_ORDERKEY = o.O_ORDERKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER c ON o.O_CUSTKEY = c.C_CUSTKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n ON c.C_NATIONKEY = n.N_NATIONKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r ON n.N_REGIONKEY = r.R_REGIONKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART p ON l.L_PARTKEY = p.P_PARTKEY
WHERE YEAR(o.O_ORDERDATE) = 1995
GROUP BY r.R_NAME, YEAR(o.O_ORDERDATE), p.P_TYPE
ORDER BY region, product_type
LIMIT 20;

-- "Problems with this approach:
-- 1. SIX tables joined (LINEITEM -> ORDERS -> CUSTOMER -> NATION -> REGION, plus PART)
-- 2. Have to remember the whole data model
-- 3. Easy to make mistakes in JOIN conditions
-- 4. YEAR() function in GROUP BY prevents some optimizations
-- 5. Harder for BI tools to auto-generate"


-- APPROACH B: Star Schema (3 JOINs - much simpler!)
-- Note: We'd need to add region to DIM_CUSTOMER for this to work fully
-- For now, let's show the simplified version

SELECT
    d.year AS order_year,
    p.product_type,
    c.market_segment,
    SUM(f.net_amount) AS revenue
FROM FCT_ORDER_LINES f
JOIN DIM_DATE d ON f.date_key = d.date_key
JOIN DIM_CUSTOMER c ON f.customer_key = c.customer_key
JOIN DIM_PRODUCT p ON f.product_key = p.product_key
WHERE d.year = 1995
GROUP BY d.year, p.product_type, c.market_segment
ORDER BY c.market_segment, p.product_type
LIMIT 20;

-- "Notice the difference:
-- 1. Only 4 tables (fact + 3 dimensions)
-- 2. Simple key-based JOINs (no multi-hop navigation)
-- 3. Year is a column, not a function call
-- 4. BI tools can easily generate this pattern
-- 5. Query optimizer loves this structure"


-- -----------------------------------------------------------------------------
-- SIDE-BY-SIDE: Customer Revenue Analysis
-- -----------------------------------------------------------------------------

-- NORMALIZED (4 JOINs + function calls):
SELECT
    r.R_NAME AS region,
    n.N_NAME AS nation,
    c.C_MKTSEGMENT AS segment,
    COUNT(DISTINCT o.O_ORDERKEY) AS orders,
    ROUND(SUM(o.O_TOTALPRICE), 2) AS revenue
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS o
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER c ON o.O_CUSTKEY = c.C_CUSTKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n ON c.C_NATIONKEY = n.N_NATIONKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r ON n.N_REGIONKEY = r.R_REGIONKEY
WHERE YEAR(o.O_ORDERDATE) BETWEEN 1994 AND 1996
GROUP BY r.R_NAME, n.N_NAME, c.C_MKTSEGMENT
ORDER BY revenue DESC
LIMIT 10;

-- STAR SCHEMA (2 JOINs + simple WHERE):
SELECT
    c.market_segment AS segment,
    d.year,
    COUNT(DISTINCT f.order_key) AS orders,
    ROUND(SUM(f.net_amount), 2) AS revenue
FROM FCT_ORDER_LINES f
JOIN DIM_DATE d ON f.date_key = d.date_key
JOIN DIM_CUSTOMER c ON f.customer_key = c.customer_key
WHERE d.year BETWEEN 1994 AND 1996
GROUP BY c.market_segment, d.year
ORDER BY revenue DESC
LIMIT 10;

-- "The star schema query is:
-- - Fewer JOINs (2 vs 4)
-- - More readable (fact at center, dimensions around it)
-- - Uses pre-computed date attributes (no YEAR() function)
-- - Pattern is consistent across all queries"


-- -----------------------------------------------------------------------------
-- KEY INSIGHT: Why Star Schema Wins
-- -----------------------------------------------------------------------------

-- | Aspect              | Normalized (TPC-H)        | Star Schema            |
-- |---------------------|---------------------------|------------------------|
-- | JOINs for region    | 4 hops (O->C->N->R)       | 1 hop (F->DIM)         |
-- | Date handling       | YEAR(), QUARTER() funcs  | Pre-computed columns   |
-- | BI tool friendly    | Requires custom modeling | Auto-discovers schema  |
-- | Query complexity    | Expert SQL knowledge     | Simple patterns        |
-- | Maintenance         | Update source tables     | Rebuild dimensions     |

-- "This is why data warehouses use star schemas:
-- Analysts shouldn't need to navigate 6 tables to answer a question."

-- =============================================================================
-- PHASE 7: Verify the Star Schema
-- =============================================================================

-- Check row counts
SELECT 'DIM_DATE' AS table_name, COUNT(*) AS row_count FROM DIM_DATE
UNION ALL
SELECT 'DIM_CUSTOMER', COUNT(*) FROM DIM_CUSTOMER
UNION ALL
SELECT 'DIM_PRODUCT', COUNT(*) FROM DIM_PRODUCT
UNION ALL
SELECT 'FCT_ORDER_LINES', COUNT(*) FROM FCT_ORDER_LINES;

-- Check referential integrity (FK relationships)
-- Line items should have matching dates, customers, AND products
SELECT 
    'Orphan lines (no matching date)' AS check_type,
    COUNT(*) AS count
FROM FCT_ORDER_LINES f
LEFT JOIN DIM_DATE d ON f.date_key = d.date_key
WHERE d.date_key IS NULL
UNION ALL
SELECT 
    'Orphan lines (no matching customer)',
    COUNT(*)
FROM FCT_ORDER_LINES f
LEFT JOIN DIM_CUSTOMER c ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL
UNION ALL
SELECT 
    'Orphan lines (no matching product)',
    COUNT(*)
FROM FCT_ORDER_LINES f
LEFT JOIN DIM_PRODUCT p ON f.product_key = p.product_key
WHERE p.product_key IS NULL;

-- =============================================================================
-- SUMMARY
-- =============================================================================

-- Star Schema Components:
-- 
-- FACT TABLE (FCT_ORDER_LINES):
--   - Contains measures (quantity, net_amount, total_amount)
--   - Contains foreign keys (date_key, customer_key, product_key)
--   - One row per line item (finest grain)
--
-- DIMENSION TABLES (DIM_DATE, DIM_CUSTOMER, DIM_PRODUCT):
--   - Contain descriptive attributes
--   - Enable filtering and grouping
--   - Relatively small compared to fact
--
-- Key Takeaways:
--
-- 1. Star schema = one central fact, multiple dimension tables
-- 2. Fact tables have MEASURES (SUM, COUNT) and FOREIGN KEYS
-- 3. Dimension tables have ATTRIBUTES (GROUP BY, WHERE)
-- 4. Date dimension is essential for time-based analysis
-- 5. Product dimension enables brand/category analytics
-- 6. This is the GOLD layer of Medallion architecture
-- 7. BI tools are optimized for this pattern

-- "This is what powers 90% of business dashboards. Once you learn this
-- pattern, you can model almost any analytical use case."

