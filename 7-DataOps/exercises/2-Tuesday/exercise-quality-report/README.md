# Exercise: Data Quality Scorecard Report

## Overview
**Day:** 2-Tuesday
**Duration:** 2-3 hours
**Mode:** Individual (Hybrid — Design + Implementation)
**Prerequisites:** SQL proficiency; data quality dimensions reading completed

---

## Required Reading

Before starting this exercise, review the following content:

| Topic | File | Focus Areas |
|-------|------|-------------|
| Data Quality Dimensions | [data-quality-dimensions.md](../../content/2-Tuesday/data-quality-dimensions.md) | 6 dimensions, measurement approaches |
| Writing Test Cases | [writing-test-cases.md](../../content/2-Tuesday/writing-test-cases.md) | Test case design, edge cases |

---

## Learning Objectives
By the end of this exercise, you will be able to:
1. Measure all 6 data quality dimensions using SQL
2. Calculate quality scores as percentages
3. Present quality findings in a stakeholder-ready scorecard
4. Recommend actions for dimensions below threshold

---

## The Scenario

The head of analytics has asked you to produce a **Data Quality Scorecard** for the customer analytics warehouse. She needs it for the quarterly data governance review next Friday. She wants to know: *"Can we trust this data for executive decision-making?"*

The warehouse has three key tables:
- `dim_customers` — Customer dimension (customer_key, customer_id, name, email, phone, customer_status, created_at)
- `fct_orders` — Order facts (order_key, customer_key, order_date, order_total, order_status)
- `fct_line_items` — Line items (line_item_key, order_key, product_key, quantity, unit_price)

---

## Core Tasks

### Task 1: Write Quality Measurement Queries (60 mins)

Open `starter_code/quality_check_template.sql` and complete a query for each dimension:

1. **Completeness** — What percentage of customer emails are populated?
2. **Uniqueness** — Are there any duplicate `customer_id` values?
3. **Validity** — Do all emails contain an `@` symbol?
4. **Consistency** — Do order totals in `fct_orders` match the sum of line items?
5. **Timeliness** — How many hours since the last data update?
6. **Accuracy** — This is hardest to measure. Propose an approach and document it.

Each query should return a **single percentage** or **score** for the dimension.

**Checkpoint:** 5 working SQL queries (accuracy may be documented conceptually).

---

### Task 2: Build the Scorecard (30 mins)

Open `templates/quality_scorecard.md` and fill in the scorecard using your query results:

For each dimension:
- **Score** (percentage or metric)
- **Status** (🟢 Green: ≥95%, 🟡 Yellow: 80-94%, 🔴 Red: <80%)
- **Details** (what the score means in plain English)
- **Action** (what to do if below target)

**Checkpoint:** All 6 dimensions scored with status indicators.

---

### Task 3: Deep Dive on Failures (30 mins)

For any dimension scored Yellow or Red:

1. Write a follow-up query to identify the **specific records** causing the issue
2. Categorize by root cause (data entry error, missing source field, pipeline bug, etc.)
3. Propose a fix with estimated effort

Example:
> **Dimension:** Completeness (email = 78%)
> **Root Cause:** 22% of customers from Salesforce import are missing email
> **Fix:** Add NOT NULL constraint on source, or backfill from CRM (2 days effort)

**Checkpoint:** Each failing dimension has a root cause and proposed fix.

---

### Task 4: Write Executive Summary (20 mins)

Write a 1-paragraph summary for the head of analytics:
- Overall quality assessment (trustworthy or not?)
- Biggest risk to decision-making
- Recommended immediate action
- Timeline for improvement

**Checkpoint:** Summary is non-technical and actionable.

---

## Deliverables

Submit the following:

1. **Completed SQL queries** (`quality_check_template.sql`)
2. **Quality scorecard** (`quality_scorecard.md`)
3. **Root cause analysis** for any failing dimensions
4. **Executive summary** (1 paragraph)

---

## Definition of Done

- [ ] Completeness query returns percentage
- [ ] Uniqueness query identifies duplicates
- [ ] Validity query checks email format
- [ ] Consistency query compares order totals to line items
- [ ] Timeliness query returns freshness metric
- [ ] Accuracy approach documented
- [ ] Scorecard has status indicators for all 6 dimensions
- [ ] Failing dimensions have root cause analysis

---

## Stretch Goals (Optional)

1. Create a summary query that returns all 6 scores in a single result set
2. Add a trend comparison (compare this week's scores to a hypothetical baseline)
3. Write a Great Expectations suite that automates the scorecard
4. Propose SLA thresholds (minimum acceptable score per dimension)

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Completeness always 100% | Test data may be too clean — use realistic data |
| Can't measure accuracy | Document approach and mock the comparison data |
| Timeliness shows very old data | Check if table has a timestamp column |
| Consistency query is complex | Break into CTEs — first aggregate line items, then join |
