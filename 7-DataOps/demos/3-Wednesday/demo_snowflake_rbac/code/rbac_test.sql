-- rbac_test.sql
-- ============================================
-- Test that RBAC is configured correctly
-- by switching roles and verifying access
-- ============================================

-- ============================================
-- TEST 1: Analyst can access customer data
-- ============================================
USE ROLE DATA_ANALYST;
USE WAREHOUSE ANALYST_WH;

-- This should SUCCEED (analyst has CUSTOMER_READ)
SELECT * FROM ANALYTICS_DB.CUSTOMERS.DIM_CUSTOMERS LIMIT 5;

-- This should SUCCEED (analyst has PRODUCT_READ)
SELECT * FROM ANALYTICS_DB.PRODUCTS.DIM_PRODUCTS LIMIT 5;

-- This should FAIL (analyst does NOT have FINANCE_READ)
-- Expected error: Object does not exist or not authorized
SELECT * FROM ANALYTICS_DB.FINANCE.FCT_REVENUE LIMIT 5;


-- ============================================
-- TEST 2: Engineer can access ALL domains
-- ============================================
USE ROLE DATA_ENGINEER;
USE WAREHOUSE ENGINEER_WH;

-- These should all SUCCEED
SELECT * FROM ANALYTICS_DB.CUSTOMERS.DIM_CUSTOMERS LIMIT 5;
SELECT * FROM ANALYTICS_DB.PRODUCTS.DIM_PRODUCTS LIMIT 5;
SELECT * FROM ANALYTICS_DB.FINANCE.FCT_REVENUE LIMIT 5;  -- Engineer has finance!


-- ============================================
-- TEST 3: Engineer can write to STAGING
-- ============================================
USE ROLE DATA_ENGINEER;

CREATE TABLE ANALYTICS_DB.STAGING.TEST_TABLE (id INT, value STRING);
INSERT INTO ANALYTICS_DB.STAGING.TEST_TABLE VALUES (1, 'test');
SELECT * FROM ANALYTICS_DB.STAGING.TEST_TABLE;
DROP TABLE ANALYTICS_DB.STAGING.TEST_TABLE;


-- ============================================
-- TEST 4: Analyst CANNOT write to STAGING
-- ============================================
USE ROLE DATA_ANALYST;

-- This should FAIL
CREATE TABLE ANALYTICS_DB.STAGING.ANALYST_TABLE (id INT);
-- Expected error: Insufficient privileges


-- ============================================
-- AUDIT: View current role configuration
-- ============================================

-- What can DATA_ANALYST do?
SHOW GRANTS TO ROLE DATA_ANALYST;

-- Who has DATA_ANALYST?
SHOW GRANTS OF ROLE DATA_ANALYST;

-- What can access the customers table?
SHOW GRANTS ON SCHEMA ANALYTICS_DB.CUSTOMERS;

-- Show role hierarchy for DATA_ENGINEER
SHOW GRANTS TO ROLE DATA_ENGINEER;

-- All roles for a specific user
SHOW GRANTS TO USER trainee_alice;
