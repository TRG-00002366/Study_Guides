# Demo: Power Query Basics — Transform Your Data

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 1-Monday |
| **Topic** | Power Query Editor and Data Transformations |
| **Type** | Hybrid (Concept + Implementation) |
| **Time** | ~15 minutes |
| **Prerequisites** | Snowflake data imported into Power BI (Demo 2 complete) |

**Weekly Epic:** *Data Storytelling — From Warehouse to Insight with Power BI and Streamlit*

---

## Phase 1: The Concept (Whiteboard/Diagram)

**Time:** 3 mins

1. Open `diagrams/power-query-workflow.mermaid`
2. Explain the Power Query pipeline:
   - Each transformation is a **step** recorded in the Applied Steps pane
   - Steps execute sequentially during data refresh
   - Changes happen at refresh time, NOT at query time
3. **Analogy:** *"Power Query is ETL inside Power BI — like mini Spark transformations. The Applied Steps pane is your transformation audit log."*

---

## Phase 2: The Code (Live Implementation)

**Time:** 12 mins

### Step 1: Open Power Query Editor (2 mins)
1. Click **Transform Data** from the Home ribbon
2. Point out the **Applied Steps** pane on the right
3. *"See how it already recorded 'Source' and 'Navigation'? Every action adds a step."*

### Step 2: Common Transformations (8 mins)

**Example 1: Rename Columns**
1. Select `DIM_CUSTOMER` query
2. Right-click `CUSTOMER_NAME` > Rename
3. Change to "Customer Name" (human-friendly)
4. Show the new step added in Applied Steps

**Example 2: Change Data Types**
1. Select a numeric column
2. Click the type icon (ABC/123)
3. Change to appropriate type
4. *"This is critical — wrong types break DAX calculations"*

**Example 3: Filter Rows**
1. Select `FCT_ORDER_LINES` query
2. Click dropdown on `ORDER_STATUS` column
3. Uncheck "Cancelled" orders
4. *"Filtering at source reduces data volume"*

**Example 4: Add Calculated Column**
1. Click **Add Column** > **Custom Column**
2. Create a simple calculation:
   ```
   = [EXTENDED_PRICE] * (1 - [DISCOUNT_PCT])
   ```
3. Name it "Net Amount"
4. *"This runs once during refresh, not every query"*

### Step 3: M Language Preview (2 mins)
1. Click **Advanced Editor**
2. Show the generated M code
3. Walk through the reference code in `code/m_language_example.txt`
4. *"You don't need to write M, but understanding it helps debugging"*
5. **Close & Apply**

---

## Key Talking Points

- "Power Query changes happen during refresh, not at query time"
- "Always check Applied Steps — it's your transformation audit log"
- "Prefer upstream calculations (Snowflake/dbt) over Power Query when possible"
- "M is functional — each step is a variable that references the previous step"

---

## Common Issues

| Issue | Solution |
|-------|----------|
| Power Query changes not applied | Click "Close & Apply" |
| Wrong data type after transform | Explicitly set type in Power Query |
| Step produces error | Check Applied Steps, delete/reorder problematic step |
| Performance slow on large tables | Filter early, select fewer columns |

---

## Required Reading Reference

Before this demo, trainees should have read:
- `data-manipulation-and-transformation.md` — Power Query Editor and M language
- `data-cleaning-techniques.md` — Handling nulls, duplicates, errors
