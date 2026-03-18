-- =============================================================================
-- DEMO: Snowpipe Setup (Conceptual)
-- Day: 3-Wednesday
-- Duration: ~15 minutes
-- Prerequisites: DEV_DB with BRONZE schema exists
-- =============================================================================
--
-- INSTRUCTOR NOTES:
-- Full Snowpipe setup requires S3 event notifications with IAM roles.
-- DO NOT attempt real external integration - it will take 30+ minutes.
-- This demo shows the concept and syntax with manual triggering.
--
-- KEY BRIDGE: "Snowpipe is like a Kafka consumer that watches for new files."
-- =============================================================================

-- =============================================================================
-- SETUP
-- =============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEV_DB;
USE SCHEMA BRONZE;

ALTER WAREHOUSE COMPUTE_WH SET AUTO_SUSPEND = 60;

-- =============================================================================
-- PHASE 1: The Concept (5 mins verbal explanation)
-- =============================================================================

-- INSTRUCTOR: Explain verbally before writing SQL:
--
-- "Snowpipe is Snowflake's continuous loading service.
--
-- How it works:
-- 1. Files land in a cloud storage bucket (S3, Azure, GCS)
-- 2. Cloud sends an event notification to Snowflake
-- 3. Snowpipe automatically runs COPY INTO
-- 4. Data appears in your table within ~1-2 minutes
--
-- BRIDGE: 
-- - It's like a Kafka consumer that never stops running
-- - Or like Spark Structured Streaming with file source
-- - But serverless - Snowflake manages the compute
--
-- Why use it:
-- - Near real-time data freshness
-- - No scheduling needed - event-driven
-- - Pay per file, not for always-on compute"

-- =============================================================================
-- PHASE 2: Create the Pipe Components (5 mins)
-- =============================================================================

-- "Let's set up a Snowpipe. We'll use internal stage and manual trigger
-- to keep things simple. In production, you'd use external S3 with events."

-- Create a stage for incoming files
CREATE OR REPLACE STAGE SNOWPIPE_STAGE
    FILE_FORMAT = (TYPE = 'JSON');

-- Create target table
CREATE OR REPLACE TABLE STREAMING_EVENTS (
    event_id STRING,
    event_type STRING,
    event_data VARIANT,
    loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Create the Pipe
-- AUTO_INGEST = FALSE for demo (would be TRUE with S3 events)
CREATE OR REPLACE PIPE EVENTS_PIPE
    AUTO_INGEST = FALSE
    COMMENT = 'Demo pipe for continuous event loading'
AS
COPY INTO STREAMING_EVENTS (event_id, event_type, event_data)
FROM (
    SELECT 
        $1:event_id::STRING,
        $1:event_type::STRING,
        $1
    FROM @SNOWPIPE_STAGE
)
FILE_FORMAT = (TYPE = 'JSON');

-- "Notice the COPY INTO is defined as part of the pipe.
-- When files arrive, Snowpipe executes this exact COPY command."

-- =============================================================================
-- PHASE 3: Check Pipe Status (3 mins)
-- =============================================================================

-- View pipe definition
SHOW PIPES;
DESCRIBE PIPE EVENTS_PIPE;

-- Check pipe status
SELECT SYSTEM$PIPE_STATUS('EVENTS_PIPE');

-- "The status shows:
-- - executionState: Is the pipe running?
-- - pendingFileCount: How many files waiting to load?
-- - lastIngestedTimestamp: When was the last successful load?"

-- =============================================================================
-- PHASE 4: Simulated Workflow (2 mins)
-- =============================================================================

-- "In production, the workflow would be:
--
-- 1. Configure S3 bucket with event notifications
-- 2. Set AUTO_INGEST = TRUE on the pipe
-- 3. Files land in S3 -> S3 sends SQS message -> Snowflake loads data
--
-- For this demo, we'd manually trigger with:"

-- Manual refresh (simulates file arrival)
-- Uncomment if you've uploaded files to the stage:
-- ALTER PIPE EVENTS_PIPE REFRESH;

-- View load history
-- SELECT * FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
--     TABLE_NAME => 'STREAMING_EVENTS',
--     START_TIME => DATEADD('hour', -1, CURRENT_TIMESTAMP())
-- ));

-- =============================================================================
-- PHASE 5: Production Architecture Diagram (Verbal)
-- =============================================================================

-- INSTRUCTOR: Draw on whiteboard:
--
--  +-----------+     +-------------+     +----------+
--  |   Files   | --> |   S3/GCS/   | --> | Snowpipe |
--  | (App/Logs)|     |   Azure     |     |  (Queue) |
--  +-----------+     +-------------+     +----------+
--                          |                   |
--                          v                   v
--                    Event Notification    COPY INTO
--                    (SQS/Event Grid/      (Automatic)
--                     Pub/Sub)                 |
--                                              v
--                                      +---------------+
--                                      | Target Table  |
--                                      | (BRONZE Layer)|
--                                      +---------------+
--
-- "BRIDGE: Remember Kafka Connect? It watches for files and streams them.
-- Snowpipe is the same idea, but serverless and built into Snowflake."

-- =============================================================================
-- PHASE 6: Comparison with Batch Loading
-- =============================================================================

-- "When to use Snowpipe vs COPY INTO directly?"

-- | Aspect         | COPY INTO (Batch)  | Snowpipe (Streaming)    |
-- |----------------|--------------------| ------------------------|
-- | Trigger        | Manual/Scheduled   | Automatic on file arrival|
-- | Latency        | Minutes to hours   | 1-2 minutes             |
-- | Compute        | Your warehouse     | Serverless (per-file)   |
-- | Cost Model     | Warehouse credits  | Per-file charges        |
-- | Best For       | Large batch loads  | Continuous small files  |

-- =============================================================================
-- SUMMARY
-- =============================================================================

-- Key Takeaways:
--
-- 1. Snowpipe = continuous, event-driven loading
-- 2. Like a Kafka consumer for files, but serverless
-- 3. AUTO_INGEST = TRUE requires cloud event notification setup
-- 4. Pay per file loaded, not for always-on compute
-- 5. Typically 1-2 minute latency from file arrival to queryable
-- 6. Use for: IoT data, clickstreams, logs, CDC files
-- 7. Batch COPY INTO is still better for large, scheduled loads

-- "In a real project, you'd spend time setting up the S3 -> SQS -> Snowpipe
-- integration. For now, understand the concept. The syntax is straightforward
-- once the cloud infrastructure is in place."
