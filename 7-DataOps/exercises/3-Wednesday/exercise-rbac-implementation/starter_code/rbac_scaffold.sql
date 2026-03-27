-- rbac_scaffold.sql
-- ============================================
-- EXERCISE: Implement RBAC for MarketPulse
-- Complete the TODO sections based on your
-- role hierarchy design from Task 1.
-- ============================================

-- ============================================
-- STEP 1: Create roles
-- ============================================
USE ROLE SECURITYADMIN;

-- Functional roles
CREATE ROLE IF NOT EXISTS MARKETING_ADMIN;
CREATE ROLE IF NOT EXISTS CAMPAIGN_MANAGER;
-- TODO: Create remaining functional roles


-- Domain roles
-- TODO: Create domain roles based on your hierarchy design
-- Hint: Think about which schemas need separate access control


-- ============================================
-- STEP 2: Build role hierarchy
-- TODO: Use GRANT ROLE to build the hierarchy
-- Remember: Higher roles inherit from lower roles
-- ============================================

-- TODO: Grant domain roles to functional roles

-- TODO: Grant functional roles to SYSADMIN


-- ============================================
-- STEP 3: Create warehouses
-- TODO: Create appropriately sized warehouses
-- ============================================
USE ROLE SYSADMIN;

-- TODO: Create warehouses and grant USAGE


-- ============================================
-- STEP 4: Create database and schemas
-- ============================================

CREATE DATABASE IF NOT EXISTS MARKETING_DB;
CREATE SCHEMA IF NOT EXISTS MARKETING_DB.CAMPAIGNS;
CREATE SCHEMA IF NOT EXISTS MARKETING_DB.CUSTOMERS;
CREATE SCHEMA IF NOT EXISTS MARKETING_DB.REVENUE;
CREATE SCHEMA IF NOT EXISTS MARKETING_DB.REPORTS;


-- ============================================
-- STEP 5: Grant access
-- TODO: Grant USAGE on database and schemas
-- TODO: Grant SELECT on ALL TABLES and FUTURE TABLES
-- TODO: Grant write access where appropriate
-- ============================================

-- TODO: Database-level grants

-- TODO: Schema-level grants

-- TODO: Table-level grants (current + future)

-- TODO: Write grants for Campaign Manager on REPORTS schema


-- ============================================
-- STEP 6: Test access (run after completing grants)
-- ============================================

-- USE ROLE MARKETING_ADMIN;
-- SELECT * FROM MARKETING_DB.CAMPAIGNS... LIMIT 3;

-- USE ROLE CAMPAIGN_MANAGER;
-- SELECT * FROM MARKETING_DB.CAMPAIGNS... LIMIT 3;
-- SELECT * FROM MARKETING_DB.REVENUE... LIMIT 3;  -- Should this work?

-- USE ROLE DATA_ANALYST;
-- ...

-- USE ROLE EXTERNAL_PARTNER;
-- ...
