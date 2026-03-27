-- masking_template.sql
-- ============================================
-- PAIR EXERCISE: Create and apply masking policies
-- Driver: Write policies. Navigator: Document behavior.
-- ============================================

-- ============================================
-- STEP 1: Create sample table with PHI
-- ============================================
USE ROLE DATA_ADMIN;
USE WAREHOUSE ADMIN_WH;
USE SCHEMA HEALTH_DB.PATIENT;

CREATE OR REPLACE TABLE PATIENTS (
    patient_id    INT,
    full_name     STRING,
    ssn           STRING,
    date_of_birth DATE,
    email         STRING,
    diagnosis_code STRING,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Insert sample data
INSERT INTO PATIENTS VALUES
    (1, 'Sarah Connor',    '123-45-6789', '1965-02-28', 'sarah.c@hospital.org', 'J06.9', CURRENT_TIMESTAMP()),
    (2, 'John Smith',      '987-65-4321', '1980-11-15', 'john.smith@clinic.net', 'M54.5', CURRENT_TIMESTAMP()),
    (3, 'Maria Garcia',    '456-78-9012', '1992-07-04', 'mgarcia@health.com',   'E11.9', CURRENT_TIMESTAMP()),
    (4, 'James Wilson',    '321-54-9876', '1973-03-20', 'jwilson@hospital.org',  'I10',   CURRENT_TIMESTAMP()),
    (5, 'Emily Chen',      '654-32-1098', '1988-09-12', 'echen@clinic.net',      'J45.9', CURRENT_TIMESTAMP());


-- ============================================
-- STEP 2: Create masking policies
-- TODO: Complete each policy's CASE logic
-- ============================================
USE ROLE ACCOUNTADMIN;

-- POLICY 1: Name masking
-- DATA_ADMIN → full name
-- DATA_ENGINEER → first initial + last initial (e.g., "S. C.")
-- Everyone else → "[REDACTED]"
CREATE OR REPLACE MASKING POLICY name_mask AS (val STRING)
RETURNS STRING ->
  CASE
    -- TODO: Complete the CASE logic
    ELSE val
  END;


-- POLICY 2: SSN masking
-- DATA_ADMIN → full SSN
-- Everyone else → "XXX-XX-" + last 4 digits
CREATE OR REPLACE MASKING POLICY ssn_mask AS (val STRING)
RETURNS STRING ->
  CASE
    -- TODO: Complete the CASE logic
    ELSE val
  END;


-- POLICY 3: Email masking
-- DATA_ADMIN, DATA_ENGINEER → full email
-- DATA_ANALYST → "****@" + domain
-- Everyone else → "[REDACTED]"
CREATE OR REPLACE MASKING POLICY email_mask AS (val STRING)
RETURNS STRING ->
  CASE
    -- TODO: Complete the CASE logic
    ELSE val
  END;


-- ============================================
-- STEP 3: Apply policies to columns
-- TODO: Apply each policy to the correct column
-- ============================================

-- TODO: Apply name_mask to PATIENTS.full_name

-- TODO: Apply ssn_mask to PATIENTS.ssn

-- TODO: Apply email_mask to PATIENTS.email


-- ============================================
-- STEP 4: Test masking behavior
-- ============================================

-- As DATA_ADMIN (should see all unmasked)
USE ROLE DATA_ADMIN;
SELECT patient_id, full_name, ssn, email FROM HEALTH_DB.PATIENT.PATIENTS;

-- As DATA_ENGINEER (should see masked name/ssn, full email)
USE ROLE DATA_ENGINEER;
SELECT patient_id, full_name, ssn, email FROM HEALTH_DB.PATIENT.PATIENTS;

-- As DATA_ANALYST (should see heavy masking)
USE ROLE DATA_ANALYST;
SELECT patient_id, full_name, ssn, email FROM HEALTH_DB.PATIENT.PATIENTS;
