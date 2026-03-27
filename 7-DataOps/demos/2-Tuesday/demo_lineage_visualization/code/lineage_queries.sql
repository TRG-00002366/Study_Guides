-- lineage_queries.sql
-- ============================================
-- Queries for exploring data lineage using
-- Snowflake system views and dbt metadata
-- ============================================

-- ============================================
-- 1. SNOWFLAKE: What objects depend on this table?
--    Uses ACCESS_HISTORY (Enterprise Edition+)
-- ============================================
SELECT
    referencing_object_name,
    referencing_object_domain,
    COUNT(*) AS reference_count,
    MAX(query_start_time) AS last_accessed
FROM snowflake.account_usage.access_history,
LATERAL FLATTEN(base_objects_accessed) AS f
WHERE f.value:objectName::STRING = 'ANALYTICS_DB.MARTS.FCT_ORDERS'
GROUP BY referencing_object_name, referencing_object_domain
ORDER BY reference_count DESC;

-- ============================================
-- 2. SNOWFLAKE: Who is querying this table?
--    Useful for understanding data consumers
-- ============================================
SELECT
    user_name,
    role_name,
    COUNT(*) AS query_count,
    MAX(start_time) AS most_recent_query
FROM snowflake.account_usage.query_history
WHERE query_text ILIKE '%fct_orders%'
  AND start_time > DATEADD(day, -30, CURRENT_DATE)
GROUP BY user_name, role_name
ORDER BY query_count DESC
LIMIT 20;

-- ============================================
-- 3. SNOWFLAKE: View dependencies for views
--    Shows what base tables a view references
-- ============================================
SELECT
    referencing_database,
    referencing_schema,
    referencing_object_name,
    referenced_database,
    referenced_schema,
    referenced_object_name
FROM snowflake.account_usage.object_dependencies
WHERE referenced_object_name = 'FCT_ORDERS'
ORDER BY referencing_object_name;

-- ============================================
-- 4. IMPACT ANALYSIS: What breaks if I change this table?
--    Find all downstream dependencies
-- ============================================
-- Downstream views
SELECT
    referencing_object_name AS downstream_object,
    referencing_object_domain AS object_type,
    'Direct dependency' AS relationship
FROM snowflake.account_usage.object_dependencies
WHERE referenced_object_name = 'DIM_CUSTOMERS'
ORDER BY downstream_object;

-- ============================================
-- 5. ROOT CAUSE: Trace a metric back to its source
--    "Where does revenue come from?"
-- ============================================
-- Level 1: customer_metrics reads from fct_orders
SELECT 'customer_metrics' AS model, 'fct_orders' AS depends_on, 1 AS depth
UNION ALL
-- Level 2: fct_orders reads from stg_orders + dim_customers
SELECT 'fct_orders', 'stg_orders', 2
UNION ALL
SELECT 'fct_orders', 'dim_customers', 2
UNION ALL
-- Level 3: staging reads from raw sources
SELECT 'stg_orders', 'raw.oms_orders', 3
UNION ALL
SELECT 'stg_customers', 'raw.crm_customers', 3
ORDER BY depth, model;

-- ============================================
-- 6. dbt DOCS: Generate and serve lineage
--    (Run in terminal, not Snowflake)
-- ============================================
-- dbt docs generate
-- dbt docs serve
-- Then navigate to the DAG view in the browser
