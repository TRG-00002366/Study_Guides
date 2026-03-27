-- quality_check_template.sql
-- ============================================
-- Complete a query for EACH data quality dimension.
-- Each query should return a single score/percentage.
-- ============================================


-- ============================================
-- 1. COMPLETENESS
-- Question: What percentage of customer emails are populated?
-- Expected output: A single percentage (e.g., 78.50%)
-- ============================================

-- TODO: Write a query that calculates:
-- (count of non-null emails / total customer count) * 100



-- ============================================
-- 2. UNIQUENESS
-- Question: Are there duplicate customer_id values?
-- Expected output: Uniqueness percentage and/or duplicate count
-- ============================================

-- TODO: Write a query that:
-- 1. Counts total customer_ids
-- 2. Counts DISTINCT customer_ids
-- 3. Calculates uniqueness percentage
-- 4. BONUS: List any duplicates with their count



-- ============================================
-- 3. VALIDITY
-- Question: Do all emails contain a valid format?
-- Expected output: Percentage of valid emails
-- ============================================

-- TODO: Write a query that checks email format
-- Hint: At minimum, check for '@' and '.' in the email
-- Hint: Use LIKE '%@%.%' as a basic format check



-- ============================================
-- 4. CONSISTENCY
-- Question: Do order totals match the sum of line items?
-- Expected output: Percentage of orders with matching totals
-- ============================================

-- TODO: Write a query that:
-- 1. Joins fct_orders to aggregated fct_line_items
-- 2. Compares order_total to SUM(quantity * unit_price)
-- 3. Returns the percentage of orders that match
-- Hint: Allow a small tolerance (e.g., 0.01) for rounding



-- ============================================
-- 5. TIMELINESS
-- Question: How fresh is the data?
-- Expected output: Hours since last update + freshness status
-- ============================================

-- TODO: Write a query that:
-- 1. Finds the MAX(updated_at) or MAX(created_at) from a table
-- 2. Calculates hours since that timestamp
-- 3. Returns a status: FRESH (<4 hrs), STALE (4-12 hrs), CRITICAL (>12 hrs)



-- ============================================
-- 6. ACCURACY
-- This is the hardest dimension to measure because
-- it requires a "source of truth" to compare against.
-- ============================================

-- TODO: Document your approach in a SQL comment block.
-- How would you measure accuracy if you had access to
-- a verified source? What would you compare?
-- Write a SAMPLE query assuming a 'verified_customers' table exists.
