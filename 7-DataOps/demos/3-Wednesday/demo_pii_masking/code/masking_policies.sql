-- masking_policies.sql
-- ============================================
-- Snowflake Dynamic Data Masking demo
-- Creates masking policies and applies them
-- to sensitive columns
-- ============================================

-- ============================================
-- SETUP: Create demo table with PII
-- ============================================
USE ROLE DATA_ENGINEER;
USE WAREHOUSE ENGINEER_WH;
USE DATABASE ANALYTICS_DB;
USE SCHEMA CUSTOMERS;

CREATE OR REPLACE TABLE customers_pii (
    customer_id   INT,
    full_name     STRING,
    email         STRING,
    phone         STRING,
    ssn           STRING,
    date_of_birth DATE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Insert sample data
INSERT INTO customers_pii VALUES
    (1, 'Alice Johnson',  'alice.johnson@company.com', '555-123-4567', '123-45-6789', '1990-03-15', CURRENT_TIMESTAMP()),
    (2, 'Bob Smith',      'bob.smith@email.org',      '555-987-6543', '987-65-4321', '1985-07-22', CURRENT_TIMESTAMP()),
    (3, 'Carol Williams', 'carol.w@example.net',      '555-456-7890', '456-78-9012', '1978-11-30', CURRENT_TIMESTAMP());


-- ============================================
-- POLICY 1: Email masking
-- Admin sees full email; others see domain only
-- ============================================
USE ROLE ACCOUNTADMIN;  -- Masking policies require elevated privileges

CREATE OR REPLACE MASKING POLICY email_mask AS (val STRING)
RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('DATA_ADMIN', 'DATA_ENGINEER') THEN val
    WHEN CURRENT_ROLE() IN ('DATA_ANALYST') THEN CONCAT('****@', SPLIT_PART(val, '@', 2))
    ELSE '[REDACTED]'
  END;


-- ============================================
-- POLICY 2: SSN masking
-- Admin sees full SSN; others see last 4 only
-- ============================================
CREATE OR REPLACE MASKING POLICY ssn_mask AS (val STRING)
RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('DATA_ADMIN') THEN val
    ELSE CONCAT('XXX-XX-', RIGHT(REPLACE(val, '-', ''), 4))
  END;


-- ============================================
-- POLICY 3: Phone masking
-- Admin sees full phone; analyst sees partial
-- ============================================
CREATE OR REPLACE MASKING POLICY phone_mask AS (val STRING)
RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('DATA_ADMIN', 'DATA_ENGINEER') THEN val
    WHEN CURRENT_ROLE() IN ('DATA_ANALYST') THEN CONCAT('***-***-', RIGHT(REPLACE(val, '-', ''), 4))
    ELSE '[REDACTED]'
  END;


-- ============================================
-- POLICY 4: Full name masking
-- Admin sees name; others see initials
-- ============================================
CREATE OR REPLACE MASKING POLICY name_mask AS (val STRING)
RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('DATA_ADMIN', 'DATA_ENGINEER') THEN val
    ELSE CONCAT(LEFT(SPLIT_PART(val, ' ', 1), 1), '. ', LEFT(SPLIT_PART(val, ' ', 2), 1), '.')
  END;


-- ============================================
-- APPLY POLICIES to columns
-- ============================================
ALTER TABLE customers_pii MODIFY COLUMN email     SET MASKING POLICY email_mask;
ALTER TABLE customers_pii MODIFY COLUMN ssn       SET MASKING POLICY ssn_mask;
ALTER TABLE customers_pii MODIFY COLUMN phone     SET MASKING POLICY phone_mask;
ALTER TABLE customers_pii MODIFY COLUMN full_name SET MASKING POLICY name_mask;


-- ============================================
-- TEST: View data as different roles
-- ============================================

-- As DATA_ENGINEER (full access)
USE ROLE DATA_ENGINEER;
SELECT customer_id, full_name, email, phone, ssn FROM customers_pii;
-- Expected: All values visible

-- As DATA_ANALYST (partial access)
USE ROLE DATA_ANALYST;
SELECT customer_id, full_name, email, phone, ssn FROM customers_pii;
-- Expected: 
--   full_name = "A. J."
--   email     = "****@company.com"
--   phone     = "***-***-4567"
--   ssn       = "XXX-XX-6789"

-- As BUSINESS_USER (minimal access)
USE ROLE BUSINESS_USER;
SELECT customer_id, full_name, email, phone, ssn FROM customers_pii;
-- Expected:
--   full_name = "A. J."
--   email     = "[REDACTED]"
--   phone     = "[REDACTED]"
--   ssn       = "XXX-XX-6789"


-- ============================================
-- CLEANUP (optional — remove policies)
-- ============================================
-- ALTER TABLE customers_pii MODIFY COLUMN email     UNSET MASKING POLICY;
-- ALTER TABLE customers_pii MODIFY COLUMN ssn       UNSET MASKING POLICY;
-- ALTER TABLE customers_pii MODIFY COLUMN phone     UNSET MASKING POLICY;
-- ALTER TABLE customers_pii MODIFY COLUMN full_name UNSET MASKING POLICY;
-- DROP MASKING POLICY IF EXISTS email_mask;
-- DROP MASKING POLICY IF EXISTS ssn_mask;
-- DROP MASKING POLICY IF EXISTS phone_mask;
-- DROP MASKING POLICY IF EXISTS name_mask;
