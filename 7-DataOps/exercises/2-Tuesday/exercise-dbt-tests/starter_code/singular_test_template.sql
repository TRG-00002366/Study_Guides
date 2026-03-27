-- tests/assert_order_totals_match.sql
-- ============================================
-- SINGULAR TEST: Verify order totals equal
-- the sum of their line items.
--
-- If this query returns rows, those orders
-- have a discrepancy. Empty result = PASS.
-- ============================================

-- TODO: Complete this singular test
-- 
-- Requirements:
-- 1. Join fct_orders to fct_line_items on order_key
-- 2. Calculate line item sum as: SUM(quantity * unit_price)
-- 3. Compare to fct_orders.order_total
-- 4. Return rows where they DON'T match
-- 5. Also return rows where an order has NO line items (NULL sum)
--
-- Columns to return: order_key, order_total, line_item_sum, discrepancy
--
-- Hint: Use a LEFT JOIN with a subquery that groups line items by order_key

SELECT
    -- Your query here
    1 AS placeholder  -- Remove this line when you write the real query
