-- tests/assert_no_future_orders.sql
-- ============================================
-- SINGULAR TEST: No order should have a future date
-- Orders dated in the future indicate data ingestion errors.
-- An empty result = PASS.
-- ============================================

SELECT
    order_key,
    order_date,
    CURRENT_DATE AS today
FROM {{ ref('fct_orders') }}
WHERE order_date > CURRENT_DATE
