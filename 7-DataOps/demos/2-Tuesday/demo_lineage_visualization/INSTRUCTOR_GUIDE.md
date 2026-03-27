# Demo: Data Lineage Visualization — From Source to Dashboard

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 2-Tuesday |
| **Topic** | Data lineage — technical lineage, dbt docs, Snowflake tracing |
| **Type** | Concept (Diagram-focused) |
| **Time** | ~15 minutes |
| **Prerequisites** | dbt fundamentals from Week 5; Snowflake from Week 5 |

**Weekly Epic:** *Operationalizing Data Excellence — DataOps, Quality, and Governance*

---

## Phase 1: End-to-End Lineage (Diagram)

**Time:** 5 mins

1. Open `diagrams/data-lineage-flow.mermaid`
2. Start the story:
   - *"The CFO just called: 'Revenue on the executive dashboard looks wrong.' You have 15 minutes. Where do you start?"*
3. Trace RIGHT to LEFT (reverse lineage):
   - Dashboard reads from `customer_metrics`
   - `customer_metrics` joins `fct_orders` + `dim_customers`
   - `fct_orders` comes from `stg_orders` comes from `raw.oms_orders`
   - `raw.oms_orders` is extracted from the Order Management System
4. *"Without lineage, you'd be digging through code for an hour. With lineage, you trace the problem in 5 minutes."*

> **Key Point:** *"Lineage is your debugger for data. It's the stack trace when data goes wrong."*

### Discussion Prompt
*"If I want to change the `customer_id` column in `stg_customers`, what downstream objects are affected?"* (Answer: `dim_customers`, `fct_orders`, `customer_metrics`, Dashboard, Report, ML Model)

---

## Phase 2: dbt DAG Lineage (Diagram + Live)

**Time:** 5 mins

1. Open `diagrams/dbt-dag-lineage.mermaid`
2. Explain how dbt creates lineage automatically:
   - *"Every `ref()` call creates a dependency. dbt compiles this into a DAG."*
   - Show how `fct_orders` references `stg_orders` and `dim_customers`
3. Show the dbt docs command (terminal):
   ```bash
   dbt docs generate
   dbt docs serve
   ```
4. *"dbt docs gives you an interactive lineage graph for free — click any model to see upstream and downstream."*
5. If live Snowflake is available, briefly show:
   - Navigate to dbt docs in browser
   - Click on `fct_orders`
   - Show the upstream inputs and downstream consumers

---

## Phase 3: Snowflake Runtime Lineage (SQL)

**Time:** 5 mins

1. Open `code/lineage_queries.sql`
2. Walk through key queries:
   - **Query 1 — Who depends on this table?**
     - Uses `ACCESS_HISTORY` to find real consumers
     - *"This shows you who is ACTUALLY using this table — not who you THINK is using it."*
   - **Query 2 — Who is querying this table?**
     - Shows users + roles + frequency
     - *"Before you change a table, check who's querying it."*
   - **Query 5 — Root cause trace:**
     - Manual lineage reconstruction
     - *"When dbt docs isn't available, you trace manually."*
3. Impact analysis scenario:
   - *"I want to rename `customer_id` to `cust_id` in `dim_customers`. Query 4 tells me every downstream object that will break."*

---

## Key Talking Points

- "Lineage answers: Where did this come from? What breaks if I change it?"
- "dbt generates lineage FOR FREE from `ref()` — this is one of dbt's killer features"
- "Snowflake ACCESS_HISTORY shows ACTUAL usage, not just declared dependencies"
- "Technical lineage (tables/columns) + Business lineage (definitions/owners) = complete picture"
- "Lineage is required for GDPR compliance — you must trace where personal data flows"
- Bridge to Wednesday: "Governance builds on lineage — you can't govern what you can't trace"

---

## Required Reading Reference

Before this demo, trainees should have read:
- `data-lineage.md` — Technical vs business lineage, tools, impact analysis, dbt lineage
