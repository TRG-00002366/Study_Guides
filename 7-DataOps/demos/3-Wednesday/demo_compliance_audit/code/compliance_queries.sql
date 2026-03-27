-- compliance_queries.sql
-- ============================================
-- SQL queries supporting a compliance audit
-- Covers DSAR, retention enforcement, and
-- access auditing in Snowflake
-- ============================================


-- ============================================
-- 1. DATA SUBJECT ACCESS REQUEST (DSAR)
--    "Show me ALL data you have about this person"
--    Required by: GDPR Article 15
-- ============================================

-- Find all data for a specific user across all tables
SELECT
    'customers' AS source_table,
    customer_id,
    full_name,
    email,
    phone,
    created_at
FROM customers_pii
WHERE email = 'alice.johnson@company.com'

UNION ALL

SELECT
    'orders' AS source_table,
    customer_id,
    NULL AS full_name,
    NULL AS email,
    NULL AS phone,
    order_date AS created_at
FROM fct_orders
WHERE customer_key = (
    SELECT customer_key FROM dim_customers
    WHERE email = 'alice.johnson@company.com'
)

UNION ALL

SELECT
    'support_tickets' AS source_table,
    customer_id,
    NULL AS full_name,
    NULL AS email,
    NULL AS phone,
    created_at
FROM support_tickets
WHERE customer_id = (
    SELECT customer_id FROM customers_pii
    WHERE email = 'alice.johnson@company.com'
);


-- ============================================
-- 2. RIGHT TO ERASURE ("Right to be Forgotten")
--    Delete all data for a specific user
--    Required by: GDPR Article 17
-- ============================================

-- Step 1: Identify all tables containing user data
-- (Run DSAR query above first to know what to delete)

-- Step 2: Delete in reverse dependency order
-- DELETE FROM support_tickets
-- WHERE customer_id = (SELECT customer_id FROM customers_pii WHERE email = 'alice.johnson@company.com');

-- DELETE FROM fct_orders
-- WHERE customer_key = (SELECT customer_key FROM dim_customers WHERE email = 'alice.johnson@company.com');

-- DELETE FROM customers_pii
-- WHERE email = 'alice.johnson@company.com';

-- Step 3: Log the deletion for audit trail
-- INSERT INTO deletion_log (email, deleted_at, reason, regulation)
-- VALUES ('alice.johnson@company.com', CURRENT_TIMESTAMP(), 'User request', 'GDPR Art 17');


-- ============================================
-- 3. DATA RETENTION ENFORCEMENT
--    Auto-delete data past retention period
--    Required by: GDPR Article 5(1)(e), SOC 2
-- ============================================

-- Identify data past retention
SELECT
    'user_events' AS table_name,
    COUNT(*) AS records_to_delete,
    MIN(event_date) AS oldest_record,
    '2 years' AS retention_policy,
    'GDPR' AS regulation
FROM user_events
WHERE event_date < DATEADD(year, -2, CURRENT_DATE)

UNION ALL

SELECT
    'audit_logs',
    COUNT(*),
    MIN(log_date),
    '7 years',
    'SOC 2'
FROM audit_logs
WHERE log_date < DATEADD(year, -7, CURRENT_DATE);

-- Execute retention (with safety check)
-- DELETE FROM user_events
-- WHERE event_date < DATEADD(year, -2, CURRENT_DATE);


-- ============================================
-- 4. ACCESS AUDIT
--    Who accessed sensitive data and when?
--    Required by: HIPAA Security Rule, SOC 2
-- ============================================

-- Recent queries touching PII tables
SELECT
    user_name,
    role_name,
    query_text,
    start_time,
    execution_status
FROM snowflake.account_usage.query_history
WHERE query_text ILIKE '%customers_pii%'
  AND start_time > DATEADD(day, -30, CURRENT_DATE)
ORDER BY start_time DESC
LIMIT 50;

-- Login audit: who logged in and from where?
SELECT
    user_name,
    client_ip,
    reported_client_type,
    first_authentication_factor,
    event_timestamp,
    is_success
FROM snowflake.account_usage.login_history
WHERE event_timestamp > DATEADD(day, -30, CURRENT_DATE)
ORDER BY event_timestamp DESC
LIMIT 50;

-- Failed login attempts (security concern)
SELECT
    user_name,
    client_ip,
    error_message,
    event_timestamp
FROM snowflake.account_usage.login_history
WHERE is_success = 'NO'
  AND event_timestamp > DATEADD(day, -7, CURRENT_DATE)
ORDER BY event_timestamp DESC;


-- ============================================
-- 5. DATA INVENTORY
--    What data do we have and where?
--    Required for: All compliance standards
-- ============================================

-- List all tables with PII-like column names
SELECT
    table_catalog AS database_name,
    table_schema AS schema_name,
    table_name,
    column_name,
    data_type,
    CASE
        WHEN column_name ILIKE '%email%' THEN 'PII: Email'
        WHEN column_name ILIKE '%phone%' THEN 'PII: Phone'
        WHEN column_name ILIKE '%ssn%' THEN 'PII: SSN'
        WHEN column_name ILIKE '%name%' AND column_name NOT ILIKE '%table_name%' THEN 'PII: Name'
        WHEN column_name ILIKE '%address%' THEN 'PII: Address'
        WHEN column_name ILIKE '%birth%' THEN 'PII: DOB'
        ELSE 'Non-PII'
    END AS pii_classification
FROM information_schema.columns
WHERE pii_classification != 'Non-PII'
ORDER BY database_name, schema_name, table_name;
