-- =============================================================================
-- DEMO: Streams and Tasks
-- Day: 3-Wednesday
-- Duration: ~25 minutes
-- Prerequisites: DEV_DB with BRONZE and SILVER schemas
-- =============================================================================
--
-- INSTRUCTOR NOTES:
-- This is a KEY lesson - connects to their Kafka and Airflow knowledge.
-- Stream = Kafka offset tracking for tables
-- Task = Airflow Task defined in SQL
--
-- KEY BRIDGES:
-- - "A Stream is like a Kafka offset tracking what rows you've processed"
-- - "A Task is like an Airflow task, but defined entirely in SQL"
-- =============================================================================

-- =============================================================================
-- SETUP
-- =============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEV_DB;

ALTER WAREHOUSE COMPUTE_WH SET AUTO_SUSPEND = 60;

-- =============================================================================
-- PHASE 1: Create Source Table (Bronze Layer) - 3 mins
-- =============================================================================

USE SCHEMA BRONZE;

-- "This is our Bronze landing table. In production, Snowpipe would populate this."
CREATE OR REPLACE TABLE RAW_EVENTS (
    event_id STRING,
    event_type STRING,
    payload VARIANT,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Insert some initial data
INSERT INTO RAW_EVENTS (event_id, event_type, payload)
SELECT 'E001', 'click', PARSE_JSON('{"page": "/home", "user": "U100"}')
UNION ALL SELECT 'E002', 'view', PARSE_JSON('{"page": "/products", "user": "U101"}')
UNION ALL SELECT 'E003', 'purchase', PARSE_JSON('{"product": "P001", "amount": 99.99, "user": "U100"}');

SELECT * FROM RAW_EVENTS;

-- =============================================================================
-- PHASE 2: Create a Stream (CDC Tracking) - 5 mins
-- =============================================================================

-- "A Stream captures changes to a table. Like a Kafka offset, it knows
-- which rows you've already processed and which are new."

CREATE OR REPLACE STREAM RAW_EVENTS_STREAM ON TABLE RAW_EVENTS
    APPEND_ONLY = FALSE  -- Track inserts, updates, and deletes
    COMMENT = 'Tracks changes to RAW_EVENTS for incremental processing';

-- The stream is empty right now because we created it AFTER inserting data.
-- Let's insert new rows to see the stream in action.

INSERT INTO RAW_EVENTS (event_id, event_type, payload)
SELECT 'E004', 'click', PARSE_JSON('{"page": "/checkout", "user": "U102"}')
UNION ALL SELECT 'E005', 'purchase', PARSE_JSON('{"product": "P002", "amount": 149.99, "user": "U101"}');

-- Now query the stream - shows only NEW changes
SELECT * FROM RAW_EVENTS_STREAM;

-- "Notice the metadata columns:
-- METADATA$ACTION = INSERT, DELETE, or UPDATE
-- METADATA$ISUPDATE = TRUE if this is part of an update operation
-- METADATA$ROW_ID = unique identifier for the row
--
-- BRIDGE: This is exactly like Kafka consumer offsets. The stream remembers
-- which rows you've 'consumed' and only shows you new ones."

-- =============================================================================
-- PHASE 3: Create Target Table (Silver Layer) - 2 mins
-- =============================================================================

USE SCHEMA SILVER;

-- "This is where processed events will land."
CREATE OR REPLACE TABLE PROCESSED_EVENTS (
    event_id STRING,
    event_type STRING,
    user_id STRING,
    processed_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- =============================================================================
-- PHASE 4: Create a Task (Scheduled Processing) - 8 mins
-- =============================================================================

-- "A Task is like an Airflow task, but defined in SQL.
-- It can run on a schedule OR when there's data in a stream."

CREATE OR REPLACE TASK PROCESS_EVENTS_TASK
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = '1 MINUTE'  -- Check every minute
    WHEN SYSTEM$STREAM_HAS_DATA('BRONZE.RAW_EVENTS_STREAM')  -- Only run if stream has data
AS
INSERT INTO SILVER.PROCESSED_EVENTS (event_id, event_type, user_id, processed_at)
SELECT 
    event_id,
    UPPER(event_type) AS event_type,  -- Simple transformation
    payload:user::STRING AS user_id,   -- Extract from JSON
    CURRENT_TIMESTAMP()
FROM BRONZE.RAW_EVENTS_STREAM
WHERE METADATA$ACTION = 'INSERT';  -- Only process insertions

-- "CRITICAL: Tasks are created in SUSPENDED state by default!
-- You must explicitly resume them."

-- View task definition
SHOW TASKS;
DESCRIBE TASK PROCESS_EVENTS_TASK;

-- "BRIDGE: 
-- - The SCHEDULE is like an Airflow schedule_interval
-- - The WHEN clause is like an Airflow sensor
-- - When stream has data AND schedule fires, the task runs
-- - It's like combining a sensor + operator into one definition"

-- =============================================================================
-- PHASE 5: Execute the Task Manually - 5 mins
-- =============================================================================

-- "For demo purposes, let's run the task manually instead of waiting."

-- First, let's see what's in the stream
SELECT 'Stream before processing:' AS status;
SELECT * FROM BRONZE.RAW_EVENTS_STREAM;

-- Execute the task manually
EXECUTE TASK PROCESS_EVENTS_TASK;

-- Check Silver table - should have the processed events
SELECT 'Silver table after processing:' AS status;
SELECT * FROM SILVER.PROCESSED_EVENTS;

-- Check stream - should be empty now (consumed)
SELECT 'Stream after processing (should be empty):' AS status;
SELECT * FROM BRONZE.RAW_EVENTS_STREAM;

-- "See how the stream is empty now? That's because we 'consumed' the changes
-- by using them in a DML operation (INSERT). Just like committing a Kafka offset."

-- =============================================================================
-- PHASE 6: Add More Data and Process Again - 3 mins
-- =============================================================================

-- Insert more data to Bronze
INSERT INTO BRONZE.RAW_EVENTS (event_id, event_type, payload)
SELECT 'E006', 'click', PARSE_JSON('{"page": "/about", "user": "U103"}')
UNION ALL SELECT 'E007', 'logout', PARSE_JSON('{"user": "U100"}');

-- Stream now has new data
SELECT 'New data in stream:' AS status;
SELECT * FROM BRONZE.RAW_EVENTS_STREAM;

-- Execute task again
EXECUTE TASK PROCESS_EVENTS_TASK;

-- Verify Silver table has new records
SELECT 'Updated Silver table:' AS status;
SELECT * FROM SILVER.PROCESSED_EVENTS ORDER BY processed_at;

-- =============================================================================
-- PHASE 7: Task Chaining (DAGs) - 3 mins
-- =============================================================================

-- "You can chain tasks together, just like Airflow DAG dependencies."

-- First, create the Gold table (must exist before the task references it)
CREATE SCHEMA IF NOT EXISTS GOLD;
CREATE TABLE IF NOT EXISTS GOLD.EVENT_SUMMARY (
    event_type STRING,
    event_count INTEGER
);

-- Create a second task that runs AFTER the first one
CREATE OR REPLACE TASK AGGREGATE_EVENTS_TASK
    WAREHOUSE = COMPUTE_WH
    AFTER PROCESS_EVENTS_TASK  -- Runs after parent task completes
AS
MERGE INTO GOLD.EVENT_SUMMARY tgt
USING (
    SELECT event_type, COUNT(*) AS event_count
    FROM SILVER.PROCESSED_EVENTS
    GROUP BY event_type
) src
ON tgt.event_type = src.event_type
WHEN MATCHED THEN UPDATE SET event_count = src.event_count
WHEN NOT MATCHED THEN INSERT (event_type, event_count) VALUES (src.event_type, src.event_count);

-- "Now we have a mini-DAG:
-- 
-- BRONZE.RAW_EVENTS
--        |
--        v
-- PROCESS_EVENTS_TASK (Bronze -> Silver)
--        |
--        v
-- AGGREGATE_EVENTS_TASK (Silver -> Gold)
--
-- BRIDGE: This is exactly like defining task1 >> task2 in Airflow."

-- Execute the aggregation task manually to populate Gold layer
EXECUTE TASK AGGREGATE_EVENTS_TASK;

-- Verify Gold layer has data
SELECT 'Gold layer after aggregation:' AS status;
SELECT * FROM GOLD.EVENT_SUMMARY ORDER BY event_count DESC;

-- Show the DAG structure
SELECT 
    NAME,
    STATE,
    SCHEDULE,
    PREDECESSORS,
    CONDITION
FROM TABLE(INFORMATION_SCHEMA.TASK_DEPENDENTS(
    TASK_NAME => 'PROCESS_EVENTS_TASK',
    RECURSIVE => TRUE
));

-- =============================================================================
-- PHASE 8: Enable Automatic Execution (2 mins)
-- =============================================================================

-- "To make tasks run automatically (like Airflow), you must RESUME them.
-- CRITICAL: Resume CHILD tasks FIRST, then the PARENT task!"

-- Step 1: Resume the child task first
ALTER TASK AGGREGATE_EVENTS_TASK RESUME;

-- Step 2: Resume the parent task (this starts the schedule)
ALTER TASK PROCESS_EVENTS_TASK RESUME;

-- "Now the tasks will run automatically!
-- - PROCESS_EVENTS_TASK checks every 1 minute
-- - If RAW_EVENTS_STREAM has data, it processes Bronze -> Silver
-- - After it completes, AGGREGATE_EVENTS_TASK automatically runs Silver -> Gold
--
-- This is exactly like an Airflow DAG with schedule_interval='1 minute'"

-- Verify tasks are running
SHOW TASKS LIKE '%EVENTS_TASK%';

-- Insert new data to trigger the pipeline
INSERT INTO BRONZE.RAW_EVENTS (event_id, event_type, payload)
SELECT 'E008', 'purchase', PARSE_JSON('{"product": "P003", "amount": 299.99, "user": "U104"}');

-- "Wait ~1 minute, then check the tables to see automatic processing!"
-- SELECT * FROM SILVER.PROCESSED_EVENTS ORDER BY processed_at DESC;
-- SELECT * FROM GOLD.EVENT_SUMMARY ORDER BY event_count DESC;

-- =============================================================================
-- PHASE 9: Suspend Tasks (Cleanup)
-- =============================================================================

-- "When done, SUSPEND tasks to stop automatic execution.
-- IMPORTANT: Suspend PARENT task FIRST, then child tasks!"

-- Uncomment these when you want to stop the tasks:
-- ALTER TASK PROCESS_EVENTS_TASK SUSPEND;
-- ALTER TASK AGGREGATE_EVENTS_TASK SUSPEND;

-- View task history
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    TASK_NAME => 'PROCESS_EVENTS_TASK',
    SCHEDULED_TIME_RANGE_START => DATEADD('hour', -1, CURRENT_TIMESTAMP())
));

-- =============================================================================
-- SUMMARY
-- =============================================================================

-- | Concept | Analogy | Purpose |
-- |---------|---------|---------|
-- | Stream | Kafka offset | Track which rows are new/changed |
-- | Task | Airflow Task | Run SQL on a schedule |
-- | WHEN clause | Airflow Sensor | Only run when condition is met |
-- | AFTER clause | Task dependency | Chain tasks into a DAG |

-- Key Takeaways:
--
-- 1. Streams track changes (INSERT, UPDATE, DELETE) like Kafka offsets
-- 2. Tasks execute SQL on a schedule (like Airflow)
-- 3. WHEN SYSTEM$STREAM_HAS_DATA() = sensor that checks for new data
-- 4. Tasks are SUSPENDED by default - must ALTER TASK ... RESUME
-- 5. Chain tasks with AFTER clause to create DAGs
-- 6. EXECUTE TASK lets you test without waiting for schedule
-- 7. Stream is "consumed" when used in DML (SELECT alone doesn't consume)

-- "This is how you build incremental pipelines natively in Snowflake.
-- Bronze -> Silver -> Gold, all automated with Streams and Tasks."
