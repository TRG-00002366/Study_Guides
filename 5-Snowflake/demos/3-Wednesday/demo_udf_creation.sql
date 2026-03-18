-- =============================================================================
-- DEMO: User-Defined Functions (UDFs)
-- Day: 3-Wednesday
-- Duration: ~20 minutes
-- Prerequisites: DEV_DB with SILVER schema exists
-- =============================================================================
--
-- INSTRUCTOR NOTES:
-- Trainees know Spark UDFs. Snowflake UDFs are similar but with key differences:
-- - SQL UDFs are fastest (compile to native operations)
-- - JavaScript UDFs for string/complex logic
-- - Python UDFs for ML/data science libraries
--
-- KEY BRIDGE: "Same concept as Spark UDFs, but no serialization overhead."
-- =============================================================================

-- =============================================================================
-- SETUP
-- =============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEV_DB;
USE SCHEMA SILVER;

ALTER WAREHOUSE COMPUTE_WH SET AUTO_SUSPEND = 60;

-- =============================================================================
-- PHASE 1: SQL UDFs - Simplest and Fastest (5 mins)
-- =============================================================================

-- "SQL UDFs are the simplest. They compile down to native Snowflake operations."

-- Simple mathematical UDF
CREATE OR REPLACE FUNCTION CENTS_TO_DOLLARS(cents NUMBER)
RETURNS DECIMAL(12,2)
LANGUAGE SQL
AS
$$
    cents / 100.0
$$;

-- Test it
SELECT CENTS_TO_DOLLARS(15099);  -- Returns 150.99
SELECT CENTS_TO_DOLLARS(9999);   -- Returns 99.99

-- UDF with multiple parameters
CREATE OR REPLACE FUNCTION CALCULATE_TAX(amount DECIMAL(12,2), tax_rate DECIMAL(5,4))
RETURNS DECIMAL(12,2)
LANGUAGE SQL
AS
$$
    ROUND(amount * tax_rate, 2)
$$;

-- Test with sample data
SELECT 
    100.00 AS subtotal,
    CALCULATE_TAX(100.00, 0.0825) AS tax,
    100.00 + CALCULATE_TAX(100.00, 0.0825) AS total;

-- UDF with CASE logic
CREATE OR REPLACE FUNCTION CATEGORIZE_AMOUNT(amount DECIMAL(12,2))
RETURNS STRING
LANGUAGE SQL
AS
$$
    CASE 
        WHEN amount >= 10000 THEN 'Enterprise'
        WHEN amount >= 1000 THEN 'Mid-Market'
        WHEN amount >= 100 THEN 'SMB'
        ELSE 'Micro'
    END
$$;

-- Use on sample data
SELECT 
    O_ORDERKEY,
    O_TOTALPRICE,
    CATEGORIZE_AMOUNT(O_TOTALPRICE) AS customer_tier
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
LIMIT 10;

-- "BRIDGE: SQL UDFs are like Spark's built-in functions - fast because
-- they're native. Use these whenever the logic can be expressed in SQL."

-- =============================================================================
-- PHASE 2: JavaScript UDFs - Complex Logic (7 mins)
-- =============================================================================

-- "JavaScript UDFs are for complex string manipulation, loops, or logic
-- that's awkward in SQL. Like Python UDFs in Spark, but JavaScript."

-- Email masking function
CREATE OR REPLACE FUNCTION MASK_EMAIL(email STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
    // Note: Parameter names are uppercase in JavaScript UDFs
    if (EMAIL === null || EMAIL === undefined) {
        return null;
    }
    var parts = EMAIL.split('@');
    if (parts.length !== 2) {
        return EMAIL;  // Return as-is if not valid email format
    }
    // Mask: show first 2 chars, then ***, then @domain
    var local = parts[0];
    var masked = local.substring(0, Math.min(2, local.length)) + '***@' + parts[1];
    return masked;
$$;

-- Test it
SELECT MASK_EMAIL('john.doe@example.com');  -- Returns: jo***@example.com
SELECT MASK_EMAIL('a@test.org');            -- Returns: a***@test.org
SELECT MASK_EMAIL(NULL);                     -- Returns: NULL

-- Format phone number
CREATE OR REPLACE FUNCTION FORMAT_PHONE(phone STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
    if (PHONE === null) return null;
    
    // Remove all non-digits
    var digits = PHONE.replace(/\D/g, '');
    
    // Format as (XXX) XXX-XXXX if 10 digits
    if (digits.length === 10) {
        return '(' + digits.substring(0,3) + ') ' + 
               digits.substring(3,6) + '-' + 
               digits.substring(6);
    }
    
    return PHONE; // Return original if can't format
$$;

-- Test it
SELECT FORMAT_PHONE('5551234567');    -- Returns: (555) 123-4567
SELECT FORMAT_PHONE('555-123-4567');  -- Returns: (555) 123-4567
SELECT FORMAT_PHONE('123');           -- Returns: 123 (unchanged)

-- Use on sample data (creating fake phone from customer key)
SELECT 
    C_CUSTKEY,
    C_NAME,
    LPAD(C_CUSTKEY::STRING, 10, '555') AS raw_phone,
    FORMAT_PHONE(LPAD(C_CUSTKEY::STRING, 10, '555')) AS formatted_phone
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
LIMIT 5;

-- "BRIDGE: JavaScript UDFs are like Spark Python UDFs but without the
-- JVM-Python serialization overhead. Use for string manipulation, loops,
-- or any logic that would be ugly in pure SQL."

-- =============================================================================
-- PHASE 2.5: Python UDFs - Data Science & ML (5 mins)
-- =============================================================================

-- "Python UDFs are for when you need Python libraries like pandas, numpy,
-- or scikit-learn. They're slower than SQL/JS, but incredibly powerful."

-- NOTE: Python UDFs require accepting Anaconda terms.
-- The instructor should have already done this, but if not:

-- Step 1: Accept Anaconda terms (one-time, requires ORGADMIN)
USE ROLE ORGADMIN;
SELECT SYSTEM$ACCEPT_ANACONDA_TERMS();

-- Step 2: Return to ACCOUNTADMIN for the demo
USE ROLE ACCOUNTADMIN;
USE DATABASE DEV_DB;
USE SCHEMA SILVER;

-- Simple Python UDF for text processing
CREATE OR REPLACE FUNCTION CLEAN_TEXT(text_input STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
HANDLER = 'clean_text'
AS
$$
def clean_text(text_input):
    if text_input is None:
        return None
    # Remove extra whitespace, lowercase, strip
    cleaned = ' '.join(text_input.lower().split())
    return cleaned.strip()
$$;

-- Test it
SELECT CLEAN_TEXT('  Hello   WORLD   ');  -- Returns: 'hello world'
SELECT CLEAN_TEXT(NULL);                   -- Returns: NULL

-- Python UDF with simple sentiment scoring (no external libraries)
CREATE OR REPLACE FUNCTION SIMPLE_SENTIMENT(text_input STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
HANDLER = 'analyze_sentiment'
AS
$$
def analyze_sentiment(text_input):
    if text_input is None:
        return None
    
    text_lower = text_input.lower()
    
    # Simple keyword-based sentiment
    positive_words = ['good', 'great', 'excellent', 'amazing', 'love', 'happy', 'best', 'wonderful']
    negative_words = ['bad', 'terrible', 'awful', 'hate', 'worst', 'poor', 'disappointing', 'horrible']
    
    pos_count = sum(1 for word in positive_words if word in text_lower)
    neg_count = sum(1 for word in negative_words if word in text_lower)
    
    if pos_count > neg_count:
        return 'POSITIVE'
    elif neg_count > pos_count:
        return 'NEGATIVE'
    else:
        return 'NEUTRAL'
$$;

-- Test it
SELECT SIMPLE_SENTIMENT('This product is great and amazing!');  -- POSITIVE
SELECT SIMPLE_SENTIMENT('Terrible experience, very bad');       -- NEGATIVE
SELECT SIMPLE_SENTIMENT('It arrived on time');                  -- NEUTRAL

-- Python UDF for extracting domain from email
CREATE OR REPLACE FUNCTION EXTRACT_EMAIL_DOMAIN(email STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
HANDLER = 'extract_domain'
AS
$$
def extract_domain(email):
    if email is None:
        return None
    try:
        return email.split('@')[1].lower()
    except (IndexError, AttributeError):
        return None
$$;

-- Test it
SELECT EXTRACT_EMAIL_DOMAIN('user@example.com');  -- Returns: example.com
SELECT EXTRACT_EMAIL_DOMAIN('invalid-email');      -- Returns: NULL

-- Use Python UDF on sample data
SELECT 
    C_NAME,
    CLEAN_TEXT(C_NAME) AS cleaned_name,
    SIMPLE_SENTIMENT(C_COMMENT) AS comment_sentiment
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
LIMIT 10;

-- "BRIDGE: Python UDFs are like Spark Python UDFs - use them when you need
-- Python's ecosystem. But remember: they're slower due to the Python runtime."

-- =============================================================================
-- PHASE 3: Using UDFs in Transformations (5 mins)
-- =============================================================================

-- "Now let's see UDFs in action for real transformations."

-- Create a transformed view using our UDFs
CREATE OR REPLACE VIEW V_CUSTOMER_MASKED AS
SELECT 
    C_CUSTKEY AS customer_id,
    C_NAME AS customer_name,
    MASK_EMAIL(C_NAME || '@example.com') AS masked_email,
    CATEGORIZE_AMOUNT(C_ACCTBAL) AS account_tier,
    C_ACCTBAL AS account_balance,
    CENTS_TO_DOLLARS(C_ACCTBAL * 100) AS balance_rounded
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

-- Query the view
SELECT * FROM V_CUSTOMER_MASKED LIMIT 10;

-- =============================================================================
-- PHASE 4: UDF Best Practices (3 mins)
-- =============================================================================

-- View UDF definition
DESCRIBE FUNCTION CENTS_TO_DOLLARS(NUMBER);
DESCRIBE FUNCTION MASK_EMAIL(STRING);

-- List all UDFs in schema
SHOW USER FUNCTIONS IN SCHEMA SILVER;

-- "BEST PRACTICES:
-- 1. Prefer SQL UDFs when possible - they're fastest
-- 2. Avoid UDFs in WHERE clauses - they block pruning optimization
-- 3. JavaScript UDFs use ES5 syntax (var, not let/const in older behavior)
-- 4. Test UDFs with NULL inputs - they need explicit null handling
-- 5. Document with COMMENT parameter"

-- Add a comment to a UDF
CREATE OR REPLACE FUNCTION CENTS_TO_DOLLARS(cents NUMBER)
RETURNS DECIMAL(12,2)
LANGUAGE SQL
COMMENT = 'Converts cents to dollars with 2 decimal places'
AS
$$
    cents / 100.0
$$;

-- =============================================================================
-- SUMMARY
-- =============================================================================

-- | UDF Type   | Speed  | Use Case                          |
-- |------------|--------|-----------------------------------|
-- | SQL        | Fast   | Math, CASE logic, simple queries  |
-- | JavaScript | Medium | Strings, loops, complex logic     |
-- | Python     | Slower | ML libraries, pandas, numpy       |

-- Key Takeaways:
--
-- 1. Three UDF flavors: SQL (fastest), JavaScript, Python
-- 2. SQL UDFs compile to native operations - prefer when possible
-- 3. JavaScript for string manipulation and loops
-- 4. Parameters are UPPERCASE in JavaScript UDFs
-- 5. Always handle NULL inputs explicitly
-- 6. Avoid UDFs in WHERE clauses for performance

-- "Same concept as Spark UDFs, but without the serialization overhead.
-- And you can use JavaScript instead of Python for simpler deployment."
