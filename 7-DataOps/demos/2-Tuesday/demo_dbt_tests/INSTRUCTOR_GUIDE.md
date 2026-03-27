# Demo: Building a Comprehensive dbt Test Suite

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 2-Tuesday |
| **Topic** | dbt testing — schema tests, singular tests, custom generic tests |
| **Type** | Code (Implementation) |
| **Time** | ~25 minutes |
| **Prerequisites** | dbt model fundamentals from Week 5 |

**Weekly Epic:** *Operationalizing Data Excellence — DataOps, Quality, and Governance*

---

## Phase 1: Schema Tests (Built-In)

**Time:** 10 mins

1. Open `code/schema.yml`
2. Start with `dim_customers`:
   - *"Every dimension table needs two tests on its primary key: `unique` and `not_null`. No exceptions."*
   - Show `customer_key` with both tests
   - Show `customer_status` with `accepted_values`:
     - *"If someone inserts a status that's not active/inactive/churned, this test catches it."*
3. Move to `fct_orders`:
   - Show `customer_key` with the `relationships` test:
     - *"This validates referential integrity — every order must have a valid customer."*
     ```yaml
     relationships:
       to: ref('dim_customers')
       field: customer_key
     ```
   - *"Without this test, orphan orders silently corrupt your analytics."*
4. Show `fct_line_items`:
   - Two relationship tests: to `fct_orders` AND `dim_products`
   - *"Line items are the glue — they must reference valid orders AND valid products."*

### Run the Tests (Show Output)
```bash
dbt test --select dim_customers fct_orders fct_line_items
```
- Walk through the output: model name, test name, PASS/FAIL, rows returned
- *"Zero rows returned = PASS. Any rows returned = FAIL."*

---

## Phase 2: Singular Tests (Custom SQL)

**Time:** 8 mins

1. Open `code/assert_order_totals_match.sql`
2. Explain the pattern:
   - *"A singular test is just a SQL query. If it returns rows, those rows FAILED."*
   - Walk through the logic: join orders to line items, compare totals
   - *"This catches rounding errors, missing line items, or bad joins in your model."*

3. Open `code/assert_no_future_orders.sql`
4. *"Simple but critical — orders dated in the future mean your ingestion pipeline has a bug."*

5. Explain when to use singular vs schema tests:
   - Schema tests: column-level properties (unique, not_null)
   - Singular tests: cross-table business rules, complex logic

### Run a Singular Test
```bash
dbt test --select assert_order_totals_match
```

---

## Phase 3: Custom Generic Tests (Reusable)

**Time:** 7 mins

1. Open `code/test_positive_value.sql`
2. Explain the Jinja macro:
   - *"This is a template. `model` and `column_name` are injected by dbt when you use it in schema.yml."*
   ```sql
   {% test positive_value(model, column_name) %}
   SELECT {{ column_name }}
   FROM {{ model }}
   WHERE {{ column_name }} < 0
   {% endtest %}
   ```
3. Show where it's used in `schema.yml`:
   - `fct_orders.order_total` → `positive_value`
   - `fct_line_items.quantity` → `positive_value`
4. *"Write once, use everywhere. Now every money and quantity column gets the same check."*

### Discussion Prompt
*"What other generic tests would be useful? Think about date ranges, string lengths, percentage values..."*

---

## Key Talking Points

- "Every model must have: primary key (unique + not_null), foreign keys (relationships), enums (accepted_values)"
- "Singular tests > manual spot-checks — they run every time, they never forget"
- "Generic tests are DRY — write the SQL once, apply it across 50 columns"
- "`dbt test` checks DATA, not CODE — this is fundamentally different from pytest"
- Bridge to Monday: "These tests run in your CI pipeline automatically on every PR"

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Test fails with 0 rows returned | Test passed — 0 failing rows means success |
| `relationships` test fails | Orphan records exist — check your joins |
| Generic test not found | Ensure file is in `macros/` directory |
| Too many test failures | Use `severity: warn` for non-critical tests |

---

## Required Reading Reference

Before this demo, trainees should have read:
- `dbt-testing.md` — Built-in tests, singular tests, generic tests, testing strategies
