-- tests/assert_order_totals_match.sql
-- ============================================
-- SINGULAR TEST: Order total must equal sum of line items
-- If this query returns rows, those orders have a discrepancy.
-- An empty result = PASS.
-- ============================================

SELECT
    o.order_key,
    o.order_total,
    l.line_item_sum,
    o.order_total - l.line_item_sum AS discrepancy
FROM {{ ref('fct_orders') }} o
LEFT JOIN (
    SELECT
        order_key,
        SUM(quantity * unit_price) AS line_item_sum
    FROM {{ ref('fct_line_items') }}
    GROUP BY order_key
) l ON o.order_key = l.order_key
WHERE o.order_total != l.line_item_sum
   OR l.line_item_sum IS NULL
