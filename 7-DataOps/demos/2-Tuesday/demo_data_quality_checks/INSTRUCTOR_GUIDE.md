# Demo: Data Quality Validation — Measuring the Six Dimensions

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 2-Tuesday |
| **Topic** | Data quality dimensions, SQL measurement, Great Expectations |
| **Type** | Hybrid (Concept + Code) |
| **Time** | ~20 minutes |
| **Prerequisites** | SQL proficiency; dbt testing concepts from previous demo |

**Weekly Epic:** *Operationalizing Data Excellence — DataOps, Quality, and Governance*

---

## Phase 1: The Concept (Diagram)

**Time:** 5 mins

1. Open `diagrams/quality-dimensions.mermaid`
2. Walk through each dimension:
   - **Accuracy:** *"Does the data match reality? If the DB says Alice lives in New York but she moved to LA, that's an accuracy issue."*
   - **Completeness:** *"Is anything missing? 20% of customers have no email — is that a bug or normal?"*
   - **Timeliness:** *"Is the data fresh enough? For real-time fraud detection, 'yesterday's data' is useless."*
   - **Consistency:** *"Do the numbers agree? If the orders table says $100 but line items sum to $95, something's wrong."*
   - **Validity:** *"Is the format right? An email without @ is invalid even if it's 'accurate'."*
   - **Uniqueness:** *"Is each customer recorded once? Duplicates corrupt every downstream metric."*
3. *"These six dimensions give you a VOCABULARY for talking about data quality. Instead of 'the data is bad,' you can say 'we have a completeness issue in the email column at 78%.'"*

> **Key Point:** *"Quality is measured, not assumed. If you're not measuring it, you don't know it."*

---

## Phase 2: The Code (SQL Quality Checks)

**Time:** 12 mins

1. Open `code/data_quality_checks.sql`
2. Walk through each section, running queries live in Snowsight:

### Completeness (2 mins)
- Run the null rate query
- *"78% email completeness — is that acceptable? Depends on the use case. For marketing campaigns, no. For aggregate analytics, maybe."*

### Uniqueness (2 mins)
- Run the duplicate detection query
- *"If this returns rows, you have duplicate customers. Every join downstream will produce incorrect results."*

### Validity (2 mins)
- Run the email format check
- *"Valid format ≠ accurate. 'nobody@example.com' passes the format test but isn't a real email."*

### Consistency (2 mins)
- Run the referential integrity and order total check
- *"This is the most dangerous dimension. Your pipeline ran perfectly — but the data contradicts itself."*

### Timeliness (2 mins)
- Run the freshness query
- *"2 hours since last update — FRESH. If this shows 48 hours, your pipeline is silently broken."*

### Summary Report (2 mins)
- Run the summary query (all dimensions in one view)
- *"This is what you'd put on a data quality dashboard."*

---

## Phase 3: Great Expectations (Intro)

**Time:** 3 mins

1. Open `code/great_expectations_suite.py` (walkthrough only)
2. *"Great Expectations is a Python framework that does what we just did in SQL — but programmatically."*
3. Show how each expectation maps to a dimension:
   - `expect_column_values_to_not_be_null` → Completeness
   - `expect_column_values_to_be_unique` → Uniqueness
   - `expect_column_values_to_match_regex` → Validity
4. *"You'd integrate this into your Airflow DAGs or CI pipeline for automated quality gates."*

---

## Key Talking Points

- "Quality is a spectrum, not a binary — measure percentages, not pass/fail"
- "The six dimensions give you a shared language with business stakeholders"
- "Valid ≠ accurate — format checks catch syntax, not truth"
- "Consistency issues are the hardest to find and the most damaging"
- Bridge to dbt tests demo: "dbt tests implement many of these checks automatically"

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| All quality scores show 100% | Test data is too clean — use realistic data |
| Freshness check returns NULL | Table has no timestamp column — add one |
| Completeness threshold debates | Define thresholds PER COLUMN with business input |

---

## Required Reading Reference

Before this demo, trainees should have read:
- `data-quality-dimensions.md` — Six dimensions, measurement approaches, relationships
- `writing-test-cases.md` — Test case design, edge cases, regression testing
