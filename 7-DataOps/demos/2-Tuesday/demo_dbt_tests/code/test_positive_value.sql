-- macros/tests/test_positive_value.sql
-- ============================================
-- GENERIC TEST: Validates that a column contains
-- only positive values (> 0).
-- Reusable across any model via schema.yml.
-- ============================================

{% test positive_value(model, column_name) %}

SELECT {{ column_name }}
FROM {{ model }}
WHERE {{ column_name }} < 0

{% endtest %}
