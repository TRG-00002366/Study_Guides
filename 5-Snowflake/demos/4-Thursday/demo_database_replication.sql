-- =============================================================================
-- DEMO: Database Replication in Snowflake
-- Day: 4-Thursday
-- Duration: ~15 minutes
-- Purpose: Demonstrate database replication for disaster recovery and data sharing
-- =============================================================================
--
-- INSTRUCTOR NOTES:
-- This demo covers Snowflake's database replication capabilities:
-- 1. Understanding replication concepts and use cases
-- 2. Creating and managing replicated databases
-- 3. Failover and failback scenarios
--
-- PREREQUISITES:
-- - Account with ORGADMIN privileges (or ACCOUNTADMIN with replication enabled)
-- - At least two Snowflake accounts OR Business Critical edition for failover
--
-- KEY BRIDGE:
-- - "Replication is like Airflow's backup DAG strategy - ensuring continuity"
-- - "Think of it as Git for your entire database - sync to another region"
-- =============================================================================


-- =============================================================================
-- PHASE 1: Understanding Replication Fundamentals
-- =============================================================================

-- Replication enables copying databases across Snowflake accounts/regions.
-- Use cases:
--   1. Disaster Recovery (DR) - failover to secondary region
--   2. Data Sharing - share data with other business units
--   3. Read Replicas - offload queries from primary
--   4. Geographic Distribution - lower latency for global teams

-- Check if replication is enabled for your organization
SHOW REPLICATION ACCOUNTS;
-- NOTE FOR INSTRUCTOR: This will likely return EMPTY results in training accounts.
-- This is expected! Explain to trainees:
--   "Empty results mean either (1) we don't have ORGADMIN role, or 
--    (2) no accounts are linked for replication in this organization.
--    In production, you'd see linked accounts here."

-- View available regions (this WILL return results)
SHOW REGIONS;


-- =============================================================================
-- PHASE 2: Setting Up Replication Group (Requires ORGADMIN)
-- =============================================================================

-- NOTE: The following commands require cross-account setup.
-- For training purposes, we'll demonstrate the syntax and explain the flow.

-- STEP 1: On the SOURCE account, create a replication group
-- A replication group bundles objects (databases, shares) for replication

/*
CREATE REPLICATION GROUP training_replication_group
    OBJECT_TYPES = DATABASES
    ALLOWED_DATABASES = DEV_DB
    ALLOWED_ACCOUNTS = <target_account_locator>
    REPLICATION_SCHEDULE = '10 MINUTE';

-- Explanation:
-- OBJECT_TYPES: What to replicate (DATABASES, SHARES, etc.)
-- ALLOWED_DATABASES: Which databases to include
-- ALLOWED_ACCOUNTS: Target account(s) that can replicate
-- REPLICATION_SCHEDULE: How often to sync (CRON or interval)
*/


-- =============================================================================
-- PHASE 3: Creating a Secondary Database (On Target Account)
-- =============================================================================

-- On the TARGET account, create a replica of the source database

/*
-- Option A: Using Replication Groups (Recommended for production)
CREATE REPLICATION GROUP training_replication_group
    AS REPLICA OF <source_account>.training_replication_group;

-- Option B: Direct Database Replication (Simpler for demos)
CREATE DATABASE dev_db_replica
    AS REPLICA OF <source_account>.DEV_DB;
*/

-- Check replication status
-- SHOW REPLICATION DATABASES;


-- =============================================================================
-- PHASE 4: Monitoring Replication (Demo in Current Account)
-- =============================================================================

-- Since cross-account setup is complex, let's demonstrate monitoring commands
-- that work in any account:

-- View replication history for the organization
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.REPLICATION_GROUP_REFRESH_HISTORY
ORDER BY PHASE_START_TIME DESC
LIMIT 10;

-- Check database replication lag
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASE_REPLICATION_USAGE_HISTORY
WHERE START_TIME > DATEADD('day', -7, CURRENT_TIMESTAMP())
ORDER BY START_TIME DESC;


-- =============================================================================
-- PHASE 5: Simulating Replication with CLONE (In-Account Demo)
-- =============================================================================

-- For training without multi-account setup, we can use CLONE
-- to demonstrate similar concepts:

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

-- Create a "source" database with sample data
CREATE OR REPLACE DATABASE replication_demo_source;
CREATE SCHEMA replication_demo_source.sales_data;

CREATE TABLE replication_demo_source.sales_data.orders AS
SELECT 
    SEQ4() AS order_id,
    'CUST-' || UNIFORM(1, 100, RANDOM()) AS customer_id,
    DATEADD('day', -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS order_date,
    ROUND(UNIFORM(10, 1000, RANDOM())::DECIMAL(10,2), 2) AS order_amount
FROM TABLE(GENERATOR(ROWCOUNT => 1000));

-- Verify source data
SELECT COUNT(*) AS source_count FROM replication_demo_source.sales_data.orders;

-- Clone the database (zero-copy clone - instant!)
CREATE DATABASE replication_demo_replica CLONE replication_demo_source;

-- Verify clone has same data
SELECT COUNT(*) AS replica_count FROM replication_demo_replica.sales_data.orders;

-- Key Point: Clone is instant and storage-efficient (copy-on-write)


-- =============================================================================
-- PHASE 6: Demonstrating Drift and Sync
-- =============================================================================

-- Add new data to source
INSERT INTO replication_demo_source.sales_data.orders
SELECT 
    SEQ4() + 10000 AS order_id,
    'CUST-NEW' AS customer_id,
    CURRENT_DATE() AS order_date,
    999.99 AS order_amount
FROM TABLE(GENERATOR(ROWCOUNT => 50));

-- Source now has more data than replica
SELECT 'SOURCE' AS database_name, COUNT(*) AS record_count 
FROM replication_demo_source.sales_data.orders
UNION ALL
SELECT 'REPLICA' AS database_name, COUNT(*) AS record_count 
FROM replication_demo_replica.sales_data.orders;

-- In real replication, the replica would sync automatically
-- based on REPLICATION_SCHEDULE

-- For clones, you would need to recreate or use streams/tasks to sync


-- =============================================================================
-- PHASE 7: Failover and Failback Concepts
-- =============================================================================

-- With Business Critical or higher editions, you can promote a secondary
-- database to primary during an outage:

/*
-- On TARGET account during disaster:
ALTER DATABASE dev_db_replica PRIMARY;

-- This makes the replica writable and becomes the new primary.
-- When original primary recovers, you can reverse the process.

-- Failback to original primary:
-- 1. Refresh the original from the (now primary) replica
-- 2. ALTER DATABASE dev_db PRIMARY;
*/

-- Query to check which database is primary vs secondary
-- SHOW REPLICATION DATABASES;


-- =============================================================================
-- CLEANUP
-- =============================================================================

-- Remove demo databases
DROP DATABASE IF EXISTS replication_demo_source;
DROP DATABASE IF EXISTS replication_demo_replica;


-- =============================================================================
-- INSTRUCTOR TALKING POINTS
-- =============================================================================

-- 1. "Replication in Snowflake is automatic - no ETL pipelines needed.
--     The cloud services layer handles synchronization."

-- 2. "Zero-copy clones are perfect for dev/test environments.
--     They share storage until data diverges."

-- 3. "For disaster recovery, use Replication Groups. They keep
--     databases in sync across regions with configurable lag."

-- 4. "Failover requires Business Critical edition. For production
--     workloads, this is essential for SLA guarantees."

-- 5. "Compare to traditional replication:
--     - No log shipping to manage
--     - No replica lag troubleshooting
--     - Automatic consistency checks"


-- =============================================================================
-- COMPARISON: CLONE vs REPLICATION
-- =============================================================================

-- | Feature           | CLONE                  | REPLICATION              |
-- |-------------------|------------------------|--------------------------|
-- | Scope             | Same account           | Cross-account/region     |
-- | Sync              | Point-in-time snapshot | Continuous/scheduled     |
-- | Use Case          | Dev/Test environments  | DR, Data Distribution    |
-- | Failover Support  | No                     | Yes (Business Critical)  |
-- | Storage Cost      | Zero-copy (shared)     | Full copy on target      |


-- =============================================================================
-- KEY TAKEAWAYS
-- =============================================================================

-- 1. Snowflake replication is managed, not DIY
-- 2. Replication Groups bundle objects for coordinated sync
-- 3. CLONE is great for in-account copies (dev, testing)
-- 4. True cross-region DR requires Business Critical edition
-- 5. Monitor replication with ACCOUNT_USAGE views
