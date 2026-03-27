-- data_quality_checks.sql
-- ============================================
-- SQL queries measuring each of the 6 data quality dimensions
-- Run these against your Snowflake warehouse
-- ============================================

-- ============================================
-- 1. COMPLETENESS: Measure null rates for key columns
-- ============================================
SELECT
    COUNT(*) AS total_records,
    COUNT(customer_id) AS customer_id_populated,
    COUNT(email) AS email_populated,
    COUNT(phone) AS phone_populated,
    COUNT(created_at) AS created_at_populated,
    ROUND(100.0 * COUNT(email) / NULLIF(COUNT(*), 0), 2) AS email_completeness_pct,
    ROUND(100.0 * COUNT(phone) / NULLIF(COUNT(*), 0), 2) AS phone_completeness_pct
FROM dim_customers;

-- ============================================
-- 2. UNIQUENESS: Find duplicate primary keys
-- ============================================
SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Overall uniqueness score
SELECT
    COUNT(DISTINCT customer_id) AS unique_count,
    COUNT(*) AS total_count,
    ROUND(100.0 * COUNT(DISTINCT customer_id) / NULLIF(COUNT(*), 0), 2) AS uniqueness_pct
FROM dim_customers;

-- ============================================
-- 3. VALIDITY: Check email format
-- ============================================
SELECT
    COUNT(*) AS total_emails,
    COUNT(CASE WHEN email LIKE '%@%.%' THEN 1 END) AS valid_format_count,
    COUNT(CASE WHEN email NOT LIKE '%@%.%' THEN 1 END) AS invalid_format_count,
    ROUND(100.0 * COUNT(CASE WHEN email LIKE '%@%.%' THEN 1 END)
        / NULLIF(COUNT(*), 0), 2) AS validity_pct
FROM dim_customers
WHERE email IS NOT NULL;

-- Validity: Check status values
SELECT DISTINCT
    customer_status,
    COUNT(*) AS record_count
FROM dim_customers
GROUP BY customer_status
ORDER BY record_count DESC;

-- ============================================
-- 4. CONSISTENCY: Check referential integrity
-- ============================================
-- Orders referencing non-existent customers
SELECT
    o.order_key,
    o.customer_key,
    'Orphan order — no matching customer' AS issue
FROM fct_orders o
LEFT JOIN dim_customers c ON o.customer_key = c.customer_key
WHERE c.customer_key IS NULL;

-- Consistency: Do order totals match across tables?
SELECT
    o.order_key,
    o.order_total AS orders_table_total,
    li.calculated_total AS line_items_total,
    ABS(o.order_total - li.calculated_total) AS discrepancy
FROM fct_orders o
JOIN (
    SELECT order_key, SUM(quantity * unit_price) AS calculated_total
    FROM fct_line_items
    GROUP BY order_key
) li ON o.order_key = li.order_key
WHERE ABS(o.order_total - li.calculated_total) > 0.01;

-- ============================================
-- 5. TIMELINESS: Check data freshness
-- ============================================
SELECT
    MAX(updated_at) AS most_recent_update,
    DATEDIFF(hour, MAX(updated_at), CURRENT_TIMESTAMP()) AS hours_since_update,
    CASE
        WHEN DATEDIFF(hour, MAX(updated_at), CURRENT_TIMESTAMP()) <= 4 THEN 'FRESH'
        WHEN DATEDIFF(hour, MAX(updated_at), CURRENT_TIMESTAMP()) <= 12 THEN 'STALE'
        ELSE 'CRITICAL'
    END AS freshness_status
FROM dim_customers;

-- ============================================
-- 6. ACCURACY: Cross-reference sample (when available)
-- ============================================
-- Compare warehouse values against a verified source
SELECT
    c.customer_id,
    c.email AS warehouse_email,
    v.email AS verified_email,
    CASE WHEN c.email = v.email THEN 'Match' ELSE 'MISMATCH' END AS accuracy_status
FROM dim_customers c
INNER JOIN verified_customer_data v ON c.customer_id = v.customer_id
WHERE c.email != v.email;

-- ============================================
-- SUMMARY REPORT: All dimensions in one view
-- ============================================
SELECT
    'Completeness' AS dimension,
    ROUND(100.0 * COUNT(email) / NULLIF(COUNT(*), 0), 2) AS score_pct,
    'Email column' AS measured_on
FROM dim_customers
UNION ALL
SELECT
    'Uniqueness',
    ROUND(100.0 * COUNT(DISTINCT customer_id) / NULLIF(COUNT(*), 0), 2),
    'customer_id column'
FROM dim_customers
UNION ALL
SELECT
    'Validity',
    ROUND(100.0 * COUNT(CASE WHEN email LIKE '%@%.%' THEN 1 END)
        / NULLIF(COUNT(email), 0), 2),
    'Email format'
FROM dim_customers
WHERE email IS NOT NULL;
