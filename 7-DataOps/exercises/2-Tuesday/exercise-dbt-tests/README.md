# Exercise: Building a Comprehensive dbt Test Suite

## Overview
**Day:** 2-Tuesday
**Duration:** 2-3 hours
**Mode:** Individual (Implementation)
**Prerequisites:** dbt fundamentals from Week 5; dbt testing demo completed

---

## Required Reading

Before starting this exercise, review the following content:

| Topic | File | Focus Areas |
|-------|------|-------------|
| dbt Testing | [dbt-testing.md](../../content/2-Tuesday/dbt-testing.md) | Built-in tests, singular, generic |
| Writing Test Cases | [writing-test-cases.md](../../content/2-Tuesday/writing-test-cases.md) | Edge cases, test design |

---

## Learning Objectives
By the end of this exercise, you will be able to:
1. Write schema tests in YAML for all four built-in types
2. Create singular tests for cross-table business rules
3. Build a custom generic test macro
4. Interpret dbt test results and debug failures

---

## The Scenario

The analytics team keeps finding errors in the weekly sales report. Last month, a NULL `customer_key` in `fct_orders` caused a join to silently drop 200 orders, underreporting revenue by $45,000. You have been tasked with building a comprehensive test suite that catches these issues before they reach production.

---

## Core Tasks

### Task 1: Complete the Schema Tests (45 mins)

1. Open `starter_code/schema_template.yml`
2. The `dim_customers` model has some tests already defined. Complete the missing tests:
   - Add `unique` and `not_null` to `customer_key`
   - Add `accepted_values` for `customer_status` (values: active, inactive, churned)
   - Add `not_null` for `email`
3. Add complete test definitions for `fct_orders`:
   - `order_key`: unique + not_null
   - `customer_key`: not_null + relationships to `dim_customers`
   - `order_status`: accepted_values (pending, shipped, delivered, cancelled, returned)
   - `order_total`: not_null
4. Add tests for `fct_line_items`:
   - `line_item_key`: unique + not_null
   - `order_key`: not_null + relationships to `fct_orders`
   - `quantity`: not_null

**Checkpoint:** Schema file has tests for all three models with no TODOs remaining.

---

### Task 2: Write Singular Tests (30 mins)

1. Open `starter_code/singular_test_template.sql`
2. Complete the singular test that verifies order totals match the sum of line items
3. Create a **second** singular test of your own choosing. Ideas:
   - No future-dated orders
   - No customers with negative lifetime value
   - All orders have at least one line item
   - No line items with quantity > 1000 (suspicious)

**Checkpoint:** Two singular tests that return zero rows on valid data.

---

### Task 3: Create a Custom Generic Test (30 mins)

Create a reusable test macro that can be applied to any column via schema.yml:

1. Choose one of these test ideas:
   - `test_positive_value` — column value must be > 0
   - `test_no_future_date` — date column must be ≤ today
   - `test_valid_email` — string column must contain `@`
2. Write the Jinja macro in a new `.sql` file
3. Apply your custom test to at least 2 columns in `schema_template.yml`

**Hint:** Generic test format:
```sql
{% test your_test_name(model, column_name) %}
SELECT {{ column_name }}
FROM {{ model }}
WHERE /* your condition */
{% endtest %}
```

**Checkpoint:** Custom test macro created and applied in schema.yml.

---

### Task 4: Run and Interpret Results (30 mins)

Run the full test suite and document the results:

```bash
dbt test --select dim_customers fct_orders fct_line_items
```

1. Record the output for each test (PASS/FAIL/rows returned)
2. For any failures, document:
   - Which test failed
   - What the failure means
   - How you would fix the underlying data or model
3. Create a test coverage table:

| Model | Column | Tests Applied | Status |
|-------|--------|---------------|--------|
| dim_customers | customer_key | unique, not_null | |
| ... | ... | ... | |

**Checkpoint:** Complete test coverage table with results.

---

## Deliverables

Submit the following:

1. **Completed schema** (`schema_template.yml` with all tests)
2. **Singular tests** (2 SQL files)
3. **Custom generic test** (1 SQL macro file)
4. **Test coverage table** (documenting all tests and results)

---

## Definition of Done

- [ ] dim_customers has unique, not_null, and accepted_values tests
- [ ] fct_orders has relationships test to dim_customers
- [ ] fct_line_items has relationships test to fct_orders
- [ ] At least 2 singular tests written
- [ ] Custom generic test macro created
- [ ] Custom test applied to at least 2 columns
- [ ] All tests run successfully with documented results
- [ ] Test coverage table completed

---

## Stretch Goals (Optional)

1. Add a `severity: warn` to non-critical tests so they don't block CI
2. Write a singular test that validates a business rule across 3+ tables
3. Create a second custom generic test
4. Add `where` config to a test to limit it to recent data only

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Test says 0 rows but marked FAIL | 0 rows = PASS. Check if test logic is inverted |
| Generic test not found | File must be in `macros/` or `tests/generic/` directory |
| `relationships` test fails | Orphan records exist — check your staging model |
| `accepted_values` fails | Unexpected value in column — add to list or fix data |
| Test runs too slowly | Add `--select specific_model` to narrow scope |
