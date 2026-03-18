# Demo: DAX Studio — The Developer's Scratchpad

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 2-Tuesday |
| **Topic** | DAX Studio for Debugging and Data Exploration |
| **Type** | Hybrid (Concept + Code) |
| **Time** | ~10 minutes |
| **Prerequisites** | Power BI Desktop open with model loaded |

**Weekly Epic:** *Data Storytelling — From Warehouse to Insight with Power BI and Streamlit*

---

## Phase 1: The Concept (Diagram)

**Time:** 2 mins

1. Open `diagrams/dax-studio-workflow.mermaid`
2. Explain DAX Studio's role:
   - *"Power BI Desktop is for building reports"*
   - *"DAX Studio is for seeing the data and testing logic"*
   - *"Think of it as our SQL Workbench but for DAX"*

---

## Phase 2: The Code (Live Implementation)

**Time:** 8 mins

### Step 1: Connect to Power BI (3 mins)
1. Open DAX Studio (should be pre-installed)
2. Click **Connect**
3. Select the running Power BI Desktop instance
4. *"DAX Studio reads the model directly from Power BI's memory"*

### Step 2: Explore Data (5 mins)

**View a Dimension:**
1. In the Object Explorer (left), find `DIM_CUSTOMER`
2. Right-click > "Generate Query" (or type manually):
   ```dax
   EVALUATE DIM_CUSTOMER
   ```
3. Run (F5)
4. *"This shows us the RAW table exactly as Power BI sees it"*

**Aggregated Query — The "Scratchpad" Concept:**

*"Before we create complex measures, we can test what data we are grabbing."*

Reference `code/dax_studio_queries.txt` for all queries:

```dax
EVALUATE
TOPN(
    10,
    SUMMARIZECOLUMNS(
        DIM_CUSTOMER[customer_name],
        "Total Revenue", SUM(FCT_ORDER_LINES[net_amount])
    ),
    [Total Revenue], DESC
)
```

Run the query:
- *"We can quickly see our top 10 customers by revenue without building a visual"*

**Query with Filter:**
```dax
EVALUATE
CALCULATETABLE(
    SUMMARIZECOLUMNS(
        DIM_PRODUCT[manufacturer],
        "Total Revenue", SUM(FCT_ORDER_LINES[net_amount])
    ),
    DIM_DATE[year] = 1995
)
```

> ⚠️ **Warning:** Avoid running `EVALUATE <FactTable>` directly on large tables. DAX Studio has a 1M row limit. Always aggregate or filter first.

---

## Key Talking Points

- "Use DAX Studio to 'fact check' what you think the data looks like"
- "Test complex measure logic here before adding to Power BI"
- "We will use this to verify our complex logic later"
- "DAX Studio also has performance monitoring — useful for optimization"

---

## Required Reading Reference

Before this demo, trainees should have read:
- `dax-studio-introduction.md` — Installation, connection, query basics
