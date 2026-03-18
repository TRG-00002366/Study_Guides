# Demo: The CALCULATE Function — Power of Filter Modification

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 2-Tuesday |
| **Topic** | CALCULATE Function and Time Intelligence |
| **Type** | Hybrid (Concept + Code) |
| **Time** | ~20 minutes |
| **Prerequisites** | DAX Basics demo complete, core measures created |

**Weekly Epic:** *Data Storytelling — From Warehouse to Insight with Power BI and Streamlit*

---

## Phase 1: The Concept (Diagram)

**Time:** 5 mins

1. Open `diagrams/dax-context-flow.mermaid`
2. Explain how CALCULATE works:
   - **First argument:** What to calculate (a measure)
   - **Second+ arguments:** How to modify filter context
   - CALCULATE either **adds**, **removes**, or **replaces** filters
3. *"CALCULATE is THE most important DAX function. Master this, master DAX."*

> **Discussion:** *"When I select 2023 in a slicer, Power BI creates a filter context. CALCULATE lets us override, augment, or remove that context."*

---

## Phase 2: The Code (Live Implementation)

**Time:** 15 mins

### Step 1: The Problem — Why CALCULATE? (3 mins)

1. Create a **Matrix** visual:
   - Rows: `DIM_DATE[year]`
   - Values: `[Total Revenue]`
2. *"Each row shows revenue for that year — filtered by the row context."*
3. **The Challenge:** *"How do I show Total Revenue across ALL years for comparison?"*

### Step 2: CALCULATE Patterns (10 mins)

Create each measure in the `_Measures` table (reference `code/dax_calculate_patterns.txt`):

**Remove all filters (ALL):**
```dax
Total Revenue All Years = CALCULATE([Total Revenue], ALL(DIM_DATE))
```
- Add to the matrix — this column stays constant across all rows
- *"CALCULATE with ALL removes filter context for that table"*

**Fixed filter value:**
```dax
Revenue 2023 = CALCULATE([Total Revenue], DIM_DATE[year] = 2023)
```

**Time Intelligence — Prior Year:**

> ⚠️ **Before creating:** Mark `DIM_DATE` as a date table.
> 1. Go to **Model View** > Select `DIM_DATE`
> 2. **Table tools** > **Mark as date table**
> 3. Select `full_date` as the date column

```dax
Revenue PY = CALCULATE([Total Revenue], SAMEPERIODLASTYEAR(DIM_DATE[full_date]))
```

**Year-to-Date:**
```dax
Revenue YTD = TOTALYTD([Total Revenue], DIM_DATE[full_date])
```

**Filtered by dimension:**
```dax
Manufacturer1 Revenue = CALCULATE([Total Revenue], DIM_PRODUCT[manufacturer] = "Manufacturer#1")
```

### Step 3: Context Transition (2 mins)

1. Create a **Table** visual:
   - Rows: `DIM_CUSTOMER[customer_name]`
   - Values: `[Total Revenue]`
2. *"For each customer row, the engine creates a filter context — the measure evaluates in THAT context."*
3. *"This is why measures are so powerful for dynamic reporting."*

---

## Key Talking Points

- "CALCULATE = what to calculate + how to modify context"
- "ALL() removes filters; specific values add filters"
- "Time intelligence functions (TOTALYTD, SAMEPERIODLASTYEAR) use CALCULATE internally"
- **Common trainee question:** *"What if I want total revenue ignoring the slicer?"* → `CALCULATE([Total Revenue], ALL(DIM_DATE))`

---

## Required Reading Reference

Before this demo, trainees should have read:
- `dax-calculate-function.md` — CALCULATE deep dive, context transition
