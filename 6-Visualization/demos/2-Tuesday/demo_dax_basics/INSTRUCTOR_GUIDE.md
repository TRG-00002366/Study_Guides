# Demo: DAX Basics — First Measures and Filter Context

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 2-Tuesday |
| **Topic** | DAX Fundamentals — Calculated Columns vs Measures |
| **Type** | Hybrid (Concept + Code) |
| **Time** | ~15 minutes |
| **Prerequisites** | Star schema model built in Power BI (Demo 1 complete) |

**Weekly Epic:** *Data Storytelling — From Warehouse to Insight with Power BI and Streamlit*

---

## Phase 1: The Concept (Diagram)

**Time:** 3 mins

1. Open `diagrams/calculated-column-vs-measure.mermaid`
2. Explain the fundamental difference:
   - **Calculated Column:** Runs per-row at refresh time, stored in memory, fixed values
   - **Measure:** Runs on-demand at query time, NOT stored, responds to filter context

> **Key Insight:** *"As data engineers, we built `net_amount` in dbt during Week 5. Now as report developers, we just aggregate it. That's the proper separation of concerns."*

---

## Phase 2: The Code (Live Implementation)

**Time:** 12 mins

### Step 1: Calculated Column — The Anti-Pattern (5 mins)

1. Select `FCT_ORDER_LINES` table in Power BI
2. **Table tools** > **New column**
3. Enter:
   ```dax
   Line Total = FCT_ORDER_LINES[quantity] * FCT_ORDER_LINES[extended_price]
   ```
4. *"This runs for each row — stored in memory"*

**Why this is often wrong:**
5. Create a quick **Table visual** with `[Line Total]` and `[net_amount]`
6. Show the values are *different* per row
7. *"Line Total is quantity × extended_price (gross). But net_amount from Snowflake already includes discounts."*
8. *"Trust your upstream source — don't re-derive in Power BI."*

> ⚠️ **Note:** Data View is unavailable in DirectQuery mode. Use a Table visual to inspect row-level values.

**When ARE calculated columns appropriate?**
- Row-level flags: `Is High Value = IF([net_amount] > 1000, "Yes", "No")`
- Categorizations for slicing (binning dates into fiscal quarters)
- Fields that don't exist upstream and can't be added there

### Step 2: Create Essential Measures (5 mins)

**Create a Measures table first:**
1. **Home** > **Enter Data** > Create empty table named `_Measures`
2. *"Organizing measures in a dedicated table is best practice"*

**Create four core measures** (reference `code/dax_basic_measures.txt`):

```dax
Total Revenue = SUM(FCT_ORDER_LINES[net_amount])
```

```dax
Order Count = DISTINCTCOUNT(FCT_ORDER_LINES[order_key])
```

```dax
Avg Order Value = DIVIDE([Total Revenue], [Order Count], 0)
```

```dax
Customer Count = DISTINCTCOUNT(FCT_ORDER_LINES[customer_key])
```

### Step 3: See Measures in Filter Context (2 mins)

1. Create a **Card** visual with `[Total Revenue]`
2. Add a **Slicer** for `DIM_DATE[year]`
3. Select different years — watch the measure recalculate
4. *"This is filter context in action — one formula, infinite answers depending on context"*

---

## Key Talking Points

| Concept | Why It Matters |
|---------|---------------|
| `SUM` vs `SUMX` | `SUM(column)` = simple aggregation. `SUMX(table, expr)` = row-by-row iteration. Start with SUM. |
| `DISTINCTCOUNT` | Counts unique values. Essential when fact table has multiple rows per customer/order. |
| `DIVIDE` | `DIVIDE(a, b, 0)` returns 0 on zero division. Using `a / b` would error. Always use DIVIDE. |
| Measure composition | `Avg Order Value` references `[Total Revenue]` and `[Order Count]` — changes cascade automatically. |

---

## Required Reading Reference

Before this demo, trainees should have read:
- `dax-introduction.md` — DAX syntax, row vs filter context
- `dax-aggregation-statistics.md` — Aggregation functions deep dive
