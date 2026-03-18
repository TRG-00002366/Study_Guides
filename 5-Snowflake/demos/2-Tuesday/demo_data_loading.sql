-- =============================================================================
-- DEMO: Data Loading with COPY INTO
-- Day: 2-Tuesday
-- Duration: ~30 minutes
-- Prerequisites: Monday demos completed, DEV_DB with BRONZE/SILVER schemas exists
-- =============================================================================
--
-- INSTRUCTOR NOTES:
-- This demo uses INTERNAL stages only. Do NOT attempt external S3/Azure.
-- External stage setup involves IAM roles and will derail the lesson.
--
-- KEY BRIDGE: "COPY INTO is like spark.read.csv().write.saveAsTable() but
-- Snowflake handles the parallelization for you."
--
-- MEDALLION CONNECTION: We load data into BRONZE.RAW_ORDERS (created Monday)
-- then transform it into SILVER.ORDERS to complete the Bronze → Silver flow.
-- =============================================================================

-- =============================================================================
-- SETUP: Context & Sample Data File
-- =============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEV_DB;
USE SCHEMA BRONZE;

-- Credit protection
ALTER WAREHOUSE COMPUTE_WH SET AUTO_SUSPEND = 60;

-- =============================================================================
-- PHASE 1: Create a File Format (5 mins)
-- =============================================================================

-- "A file format defines how to parse your files.
-- Think of it like the options you pass to spark.read.csv()"

CREATE OR REPLACE FILE FORMAT CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '', 'N/A')
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    COMMENT = 'Standard CSV format with header';

-- "This is like setting:
-- spark.read.option('header', True).option('nullValue', 'NULL').csv(...)"

-- Create a JSON format for semi-structured data
CREATE OR REPLACE FILE FORMAT JSON_FORMAT
    TYPE = 'JSON'
    STRIP_OUTER_ARRAY = TRUE
    COMMENT = 'JSON format for event data';

-- Show our formats
SHOW FILE FORMATS;

-- =============================================================================
-- PHASE 2: Create an Internal Stage (5 mins)
-- =============================================================================

-- "A stage is where files live before loading.
-- Internal stages are managed by Snowflake - no S3 credentials needed."

CREATE OR REPLACE STAGE INTERNAL_LOAD_STAGE
    FILE_FORMAT = CSV_FORMAT
    COMMENT = 'Internal stage for loading CSV files';

-- "Think of this as an S3 bucket that Snowflake manages for you.
-- In production, you'd probably use an EXTERNAL stage pointing to S3,
-- but for learning, internal stages are simpler - no IAM roles to configure."

-- Check the stage
SHOW STAGES;
DESCRIBE STAGE INTERNAL_LOAD_STAGE;

-- =============================================================================
-- PHASE 3: Upload a File (5 mins)
-- =============================================================================

-- OPTION A: Using SnowSQL CLI (if available)
-- PUT file://C:\data\sample_orders.csv @INTERNAL_LOAD_STAGE;
-- PUT file:///home/user/data/sample_orders.csv @INTERNAL_LOAD_STAGE;

-- OPTION B: Using Snowsight UI (RECOMMENDED for demo)
-- 1. Go to Data > Databases > DEV_DB > BRONZE
-- 2. Click on the stage INTERNAL_LOAD_STAGE
-- 3. Click "Upload Files" button
-- 4. Drag and drop your CSV file

-- INSTRUCTOR: Create this sample file beforehand (sample_orders.csv):
-- order_id,customer_id,order_date,amount,status
-- O001,C100,2024-01-15,150.00,completed
-- O002,C101,2024-01-16,275.50,pending
-- O003,C100,2024-01-17,89.99,completed
-- O004,C102,2024-01-18,432.00,shipped
-- O005,C101,2024-01-19,67.25,completed

-- After upload, list files in stage
LIST @INTERNAL_LOAD_STAGE;

-- =============================================================================
-- PHASE 4: Verify Target Table from Monday (2 mins)
-- =============================================================================

-- "Remember the RAW_ORDERS table we created Monday? Let's use it."
-- "Bronze tables store raw data in VARIANT - preserving the original payload."

DESCRIBE TABLE BRONZE.RAW_ORDERS;

-- =============================================================================
-- PHASE 5: COPY INTO - The Main Event (5 mins)
-- =============================================================================

-- "Now we load the data. COPY INTO is the workhorse.
-- We'll load each CSV row as a JSON object into the VARIANT column."

-- First, create a temporary table to stage the CSV data
CREATE OR REPLACE TEMPORARY TABLE STAGING_ORDERS (
    order_id STRING,
    customer_id STRING,
    order_date STRING,
    amount STRING,
    status STRING
);

COPY INTO STAGING_ORDERS
FROM @INTERNAL_LOAD_STAGE
FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT)
ON_ERROR = 'CONTINUE'  -- Like Spark's corrupt record handling
PURGE = FALSE;         -- Keep files after loading (for debugging)

-- Now insert into RAW_ORDERS as VARIANT (JSON objects)
INSERT INTO BRONZE.RAW_ORDERS (source_file, raw_data)
SELECT 
    'sample_orders.csv' AS source_file,
    OBJECT_CONSTRUCT(
        'order_id', order_id,
        'customer_id', customer_id,
        'order_date', order_date,
        'amount', amount,
        'status', status
    ) AS raw_data
FROM STAGING_ORDERS;

-- Check the results in Bronze
SELECT * FROM BRONZE.RAW_ORDERS LIMIT 10;

-- "Notice ingestion_ts was auto-populated. The raw_data is a JSON object.
-- This is schema-on-read - we didn't define column types in Bronze."

-- View the load history
SELECT 
    TABLE_NAME,
    FILE_NAME,
    STATUS,
    ROWS_PARSED,
    ROWS_LOADED,
    ERRORS_SEEN,
    FIRST_ERROR
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
    TABLE_NAME => 'STAGING_ORDERS',
    START_TIME => DATEADD('hour', -1, CURRENT_TIMESTAMP())
));

-- =============================================================================
-- PHASE 5B: Bronze to Silver Transformation (5 mins)
-- =============================================================================

-- "Now let's complete the medallion flow - Bronze to Silver.
-- We extract, type-cast, and validate the data."

INSERT INTO SILVER.ORDERS (order_id, customer_id, order_date, order_status, amount)
SELECT 
    raw_data:order_id::STRING AS order_id,
    raw_data:customer_id::STRING AS customer_id,
    TRY_TO_DATE(raw_data:order_date::STRING) AS order_date,
    raw_data:status::STRING AS order_status,
    TRY_TO_DECIMAL(raw_data:amount::STRING, 12, 2) AS amount
FROM BRONZE.RAW_ORDERS
WHERE raw_data:order_id IS NOT NULL;  -- Filter out bad records

-- Verify the Silver data
SELECT * FROM SILVER.ORDERS LIMIT 10;

-- "See the difference? Silver has typed columns, NOT NULL constraints.
-- We used TRY_TO_DATE and TRY_TO_DECIMAL for safe casting - bad values become NULL.
-- This is the cleansing step in Medallion architecture."

-- =============================================================================
-- PHASE 6: Loading Semi-Structured Data (5 mins)
-- =============================================================================

-- "Now let's load JSON. This is where Snowflake really shines compared to Spark."

-- Create a stage for JSON
CREATE OR REPLACE STAGE JSON_STAGE
    FILE_FORMAT = JSON_FORMAT;

-- Sample JSON to upload (events.json):
-- [
--   {"event_id": "E001", "type": "click", "timestamp": "2024-01-15T10:30:00Z", "user_id": "U100"},
--   {"event_id": "E002", "type": "purchase", "timestamp": "2024-01-15T10:35:00Z", "user_id": "U101", "amount": 99.99},
--   {"event_id": "E003", "type": "view", "timestamp": "2024-01-15T10:40:00Z", "user_id": "U100", "page": "/products"}
-- ]

-- Create target table with VARIANT
CREATE OR REPLACE TABLE RAW_EVENTS (
    loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    raw_data VARIANT
);

-- After uploading events.json via UI or PUT:
-- COPY INTO RAW_EVENTS (raw_data)
-- FROM @JSON_STAGE
-- FILE_FORMAT = (FORMAT_NAME = JSON_FORMAT);

-- Query the JSON data
-- SELECT 
--     raw_data:event_id::STRING AS event_id,
--     raw_data:type::STRING AS event_type,
--     raw_data:timestamp::TIMESTAMP AS event_time,
--     raw_data:user_id::STRING AS user_id,
--     raw_data
-- FROM RAW_EVENTS;

-- "Notice we didn't have to define a schema for the JSON.
-- We store it in VARIANT and extract fields at query time.
-- This is schema-on-read - like Spark's inferSchema but more flexible."

-- =============================================================================
-- SUMMARY
-- =============================================================================

-- Key Takeaways:
--
-- 1. FILE FORMAT = spark.read options (delimiter, header, null handling)
-- 2. STAGE = managed S3 bucket (internal) or pointer to S3 (external)
-- 3. COPY INTO = spark.read().write() but parallelized automatically
-- 4. ON_ERROR = CONTINUE is like Spark's corrupt record handling
-- 5. VARIANT type handles semi-structured data without predefined schema
-- 6. Use INFORMATION_SCHEMA.COPY_HISTORY to check load status
-- 7. Bronze → Silver flow: raw VARIANT → typed columns with validation

-- "In production, you'd use external stages pointing to S3, and Snowpipe
-- for continuous loading. We'll see Snowpipe on Wednesday."
