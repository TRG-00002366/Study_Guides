-- rbac_template.sql
-- ============================================
-- PAIR EXERCISE: Complete the RBAC setup
-- Driver: Execute SQL. Navigator: Verify grants.
-- ============================================

-- ============================================
-- STEP 1: Create functional roles
-- TODO: Create 4 roles
-- ============================================
USE ROLE SECURITYADMIN;

-- TODO: Create DATA_ADMIN role

-- TODO: Create DATA_ENGINEER role

-- TODO: Create DATA_ANALYST role

-- TODO: Create BUSINESS_USER role


-- ============================================
-- STEP 2: Create domain roles
-- TODO: Create 3 domain-specific roles
-- ============================================

-- TODO: Create PATIENT_READ role

-- TODO: Create CLINICAL_READ role

-- TODO: Create FINANCE_READ role


-- ============================================
-- STEP 3: Build role hierarchy
-- TODO: Grant domain roles to functional roles
-- Refer to the requirements:
--   DATA_ADMIN    → ALL domain roles
--   DATA_ENGINEER → PATIENT_READ + CLINICAL_READ
--   DATA_ANALYST  → CLINICAL_READ only
--   BUSINESS_USER → No domain roles
-- ============================================

-- TODO: Grant domain roles to DATA_ADMIN

-- TODO: Grant domain roles to DATA_ENGINEER

-- TODO: Grant domain role to DATA_ANALYST

-- TODO: Grant all functional roles to SYSADMIN


-- ============================================
-- STEP 4: Create warehouses
-- TODO: Create 3 warehouses with appropriate sizes
-- ============================================
USE ROLE SYSADMIN;

-- TODO: Create ADMIN_WH (SMALL, auto-suspend 300)

-- TODO: Create ENGINEER_WH (SMALL, auto-suspend 300)

-- TODO: Create ANALYST_WH (XSMALL, auto-suspend 60)

-- TODO: Grant warehouse usage to appropriate roles


-- ============================================
-- STEP 5: Create database and schemas
-- ============================================

-- TODO: Create HEALTH_DB database

-- TODO: Create PATIENT schema

-- TODO: Create CLINICAL schema

-- TODO: Create FINANCE schema


-- ============================================
-- STEP 6: Grant database and schema access
-- TODO: Grant USAGE + SELECT on tables and FUTURE tables
-- ============================================

-- TODO: Grant USAGE on HEALTH_DB to all domain roles

-- TODO: Grant USAGE on schemas to matching domain roles

-- TODO: Grant SELECT on ALL TABLES in each schema

-- TODO: Grant SELECT on FUTURE TABLES in each schema


-- ============================================
-- TESTING: Verify access controls
-- ============================================

-- Test as DATA_ADMIN
USE ROLE DATA_ADMIN;
-- SELECT * FROM HEALTH_DB.PATIENT.PATIENTS LIMIT 3;
-- SELECT * FROM HEALTH_DB.CLINICAL.TREATMENTS LIMIT 3;
-- SELECT * FROM HEALTH_DB.FINANCE.BILLING LIMIT 3;

-- Test as DATA_ENGINEER
USE ROLE DATA_ENGINEER;
-- SELECT * FROM HEALTH_DB.PATIENT.PATIENTS LIMIT 3;  -- Should work (masked)
-- SELECT * FROM HEALTH_DB.FINANCE.BILLING LIMIT 3;   -- Should FAIL

-- Test as DATA_ANALYST
USE ROLE DATA_ANALYST;
-- SELECT * FROM HEALTH_DB.PATIENT.PATIENTS LIMIT 3;  -- Should FAIL
-- SELECT * FROM HEALTH_DB.CLINICAL.TREATMENTS LIMIT 3; -- Should work

-- Test as BUSINESS_USER
USE ROLE BUSINESS_USER;
-- SELECT * FROM HEALTH_DB.PATIENT.PATIENTS LIMIT 3;  -- Should FAIL
