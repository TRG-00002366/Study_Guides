# Exercise: Data Lineage Documentation

## Overview
**Day:** 2-Tuesday
**Duration:** 1-2 hours
**Mode:** Individual (Conceptual / Design)
**Prerequisites:** Data lineage reading completed; familiarity with dbt and Snowflake from Week 5

---

## Required Reading

Before starting this exercise, review the following content:

| Topic | File | Focus Areas |
|-------|------|-------------|
| Data Lineage | [data-lineage.md](../../content/2-Tuesday/data-lineage.md) | Technical vs business lineage, impact analysis |

---

## Learning Objectives
By the end of this exercise, you will be able to:
1. Create a visual lineage diagram using Mermaid syntax
2. Distinguish between technical and business lineage
3. Perform an impact analysis on a proposed schema change
4. Document lineage for a multi-layer data pipeline

---

## The Scenario

Your company is planning to rename the `customer_id` column to `cust_id` across the entire data warehouse to match a new corporate naming standard. Before making this change, the data governance team needs a **complete lineage analysis** to understand everything that would break.

The pipeline looks like this:
- **Sources:** Salesforce CRM exports customer records → S3 bucket
- **Raw Layer:** Snowflake `RAW.CRM_CUSTOMERS` table (loaded by Fivetran)
- **Staging:** dbt model `stg_customers` reads from raw
- **Marts:** `dim_customers` reads from staging; `fct_orders` joins `stg_orders` + `dim_customers`; `customer_metrics` aggregates from `fct_orders` + `dim_customers`
- **Consumption:** Executive Dashboard (Power BI), Weekly Revenue Report (scheduled email), Churn Prediction ML Model (Python)

---

## Core Tasks

### Task 1: Create the Lineage Diagram (30 mins)

1. Open `templates/lineage_diagram.mermaid`
2. Complete the diagram by adding:
   - All 5 layers (Source → Raw → Staging → Mart → Consumption)
   - All models and their dependencies listed in the scenario
   - Arrows showing data flow direction
   - Labels on each node indicating the system or model name

**Requirements:**
- Use subgraphs for each layer
- Include at least 8 nodes
- Show all relationships between nodes

**Checkpoint:** Diagram renders correctly and includes all pipeline components.

---

### Task 2: Annotate with Business Lineage (15 mins)

For each mart-level model, add a business context annotation:

| Model | Business Name | Business Owner | Used For |
|-------|---------------|----------------|----------|
| dim_customers | | | |
| fct_orders | | | |
| customer_metrics | | | |

*Business lineage tells you WHO cares about this data and WHY.*

**Checkpoint:** All mart models have business context documented.

---

### Task 3: Perform Impact Analysis (30 mins)

Open `templates/impact_analysis.md` and complete the analysis:

**Proposed Change:** Rename `customer_id` to `cust_id` everywhere.

For each artifact that would be affected:
1. **Object name** (table, model, report)
2. **Layer** (raw, staging, mart, consumption)
3. **Type of impact** (column rename, join break, filter break, display change)
4. **Severity** (Critical / High / Medium / Low)
5. **Action required** to update it

**Checkpoint:** At least 8 affected objects identified with severity ratings.

---

### Task 4: Write Change Recommendation (15 mins)

Based on your analysis, write a recommendation:

1. Should the rename proceed as planned? Why or why not?
2. If yes, in what order should changes be applied?
3. What testing should be done before, during, and after?
4. What is the estimated risk and rollback plan?

**Checkpoint:** Recommendation includes a clear order of operations.

---

## Deliverables

Submit the following:

1. **Lineage diagram** (`lineage_diagram.mermaid` completed)
2. **Business lineage table** (3 models annotated)
3. **Impact analysis** (`impact_analysis.md` completed)
4. **Change recommendation** (1 paragraph with order of operations)

---

## Definition of Done

- [ ] Mermaid diagram shows all 5 layers with 8+ nodes
- [ ] All dependencies/arrows are correct
- [ ] Business lineage annotations for mart models
- [ ] Impact analysis identifies 8+ affected objects
- [ ] Each affected object has severity rating
- [ ] Change recommendation includes order of operations
- [ ] Recommendation addresses testing and rollback

---

## Stretch Goals (Optional)

1. Add column-level lineage to your diagram (which columns flow where)
2. Write Snowflake SQL to query `OBJECT_DEPENDENCIES` for the affected table
3. Create a versioned lineage showing before/after the proposed rename
4. Propose an automated lineage extraction approach using dbt artifacts

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Mermaid syntax errors | Check for matching quotes and valid node IDs |
| Missing dependencies | Trace from consumption backwards to find all paths |
| Not sure about severity | Critical = breaks production; Low = cosmetic change |
| Too many affected objects | Focus on direct dependencies first, then indirect |
