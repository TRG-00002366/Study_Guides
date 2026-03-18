# Instructor Guide: Tuesday Demos

## Overview
**Day:** 2-Tuesday - Data Modeling and DAX Fundamentals
**Total Demo Time:** ~60 minutes
**Prerequisites:** Monday demos completed, Snowflake data imported into Power BI

---

## Demo 1: Building the Star Schema in Power BI

**Time:** ~15 minutes

### Phase 1: Review Current State (3 mins)

> 📌 **INSTRUCTOR: Open Power BI Desktop**

1. Open the Power BI file from Monday
2. Switch to **Model View**
3. Point out auto-detected relationships
4. "Power BI made guesses - let's verify they match our Week 5 design"

### Phase 2: Verify Relationships (7 mins)

**Reference: Week 5 Star Schema**
```
DIM_DATE (date_key)      ----1:*---- FCT_ORDER_LINES (date_key)
DIM_CUSTOMER (customer_key) --1:*---- FCT_ORDER_LINES (customer_key)
DIM_PRODUCT (product_key)   --1:*---- FCT_ORDER_LINES (product_key)
```


1. **Delete incorrect relationships** (if any)
   - Right-click relationship line > Delete

2. **Create correct relationships:**
   - Drag `DIM_DATE.date_key` to `FCT_ORDER_LINES.date_key`
   - Drag `DIM_CUSTOMER.customer_key` to `FCT_ORDER_LINES.customer_key`
   - Drag `DIM_PRODUCT.product_key` to `FCT_ORDER_LINES.product_key`

3. **Verify settings for each:**
   - Double-click the relationship line
   - Cardinality: **One to many (1:*)**
   - Cross-filter direction: **Single**
   - Check "Make this relationship active"

### Phase 3: Validate the Model (5 mins)

1. Point out the star shape in Model View
   - "See how fact table is at the center?"
   - "Dimensions surround it like points of a star"

2. Explain filter direction arrows
   - "Filters flow FROM dimensions TO fact"
   - "This is intentional - it's how DAX calculations work"

3. Create a quick test visual
   - Drag `DIM_CUSTOMER[market_segment]` to axis
   - Drag `FCT_ORDER_LINES[net_amount]` to values
   - "If relationships are wrong, this would show blanks or errors"

### Key Talking Points
- "This is the SAME star schema from Week 5 - now in Power BI's engine"
- "Relationships are critical - wrong relationships = wrong numbers"
- "Single direction filtering is the default for a reason"

---

## Demo 2: DAX Studio Introduction (The Scratchpad)

**Time:** ~10 minutes

> 📌 **INSTRUCTOR: Keep Power BI Desktop open, then open DAX Studio alongside it**

### Phase 1: What is DAX Studio? (2 mins)
1. Open DAX Studio (should be pre-installed)
2. "Power BI Desktop is for *building reports*"
3. "DAX Studio is for *seeing the data* and *testing logic*"
4. "Think of it as our SQL Workbench but for DAX"

### Phase 2: Connect to Power BI (3 mins)
1. Click **Connect** in DAX Studio
2. Select the running Power BI Desktop instance
3. "DAX Studio reads the model directly from Power BI's memory"

### Phase 3: Peeking at the Data (5 mins)

**View a Dimension:**
1. In the Object Explorer (left), find `DIM_CUSTOMER`
2. Right-click > "Generate Query" (or just type `EVALUATE DIM_CUSTOMER`)
3. Run (F5)
4. "This shows us the RAW table exactly as Power BI sees it"

**View an Aggregated Result (The "Scratchpad" Concept):**
"Before we create complex measures, we can test what data we are grabbing."

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
1. Run the query
2. "We can quickly see our top 10 customers by revenue without building a visual"

> ⚠️ **Note for Instructors:** Avoid running `EVALUATE <FactTable>` directly on large tables. DAX Studio has a 1M row limit. Always aggregate or filter first.

**Why this matters:**
- "In Power BI, you often work 'blind' inside a measure formula"
- "In DAX Studio, you can see the tables first"

### Key Talking Points
- "Use DAX Studio to 'fact check' what you think the data looks like"
- "We will use this to verify our complex logic later"

---

## Demo 3: DAX Basics - First Measures

**Time:** ~15 minutes

> 📌 **INSTRUCTOR: Switch back to Power BI Desktop**

### Phase 1: Calculated Column vs Measure (5 mins)

**Calculated Column Example:**

1. Select FCT_ORDER_LINES table in Power BI
2. **Table tools** > **New column**
3. Enter:
   ```dax
   Line Total = FCT_ORDER_LINES[quantity] * FCT_ORDER_LINES[extended_price]
   ```
4. "This runs for each row - stored in memory"

**Why this is often wrong:**

5. Create a quick **Table visual** and add `FCT_ORDER_LINES[Line Total]` and `FCT_ORDER_LINES[net_amount]`
6. Show that the values are *different* per row
7. "But wait - we already have `net_amount` from Snowflake!"
8. "Prefer source calculations over calculated columns"

> ⚠️ **Note:** Data View is unavailable in DirectQuery mode. Use a Table visual to inspect row-level values instead.

> 📋 **INSTRUCTOR NOTES: The Data Lineage Lesson**
>
> **What you just created vs. what already exists:**
> | Field | Source | Meaning |
> |-------|--------|---------|
> | `Line Total` (your column) | Calculated in Power BI | `quantity × extended_price` (gross amount) |
> | `net_amount` (from Snowflake) | Calculated upstream in dbt/SQL | Final amount *after* discounts, taxes, adjustments |
>
> **Key teaching points to hit:**
> 1. **They are NOT the same value.** `extended_price` is often the list price; `net_amount` is the true revenue after business logic (discounts, promos, returns).
> 2. **Trust your upstream source.** In Week 5, trainees learned that dbt applies business logic in the warehouse. That's where `net_amount` was computed. Re-deriving it in Power BI risks:
>    - Getting a *different* answer (no discount logic here)
>    - Duplicating maintenance (two places to fix if logic changes)
>    - Wasting memory (calculated columns are stored per-row)
> 3. **When ARE calculated columns appropriate?** Use them for:
>    - Row-level flags (e.g., `Is High Value = IF([net_amount] > 1000, "Yes", "No")`)
>    - Categorizations needed for slicing (e.g., binning dates into fiscal quarters)
>    - Fields that don't exist upstream and can't be added there
>
> **Suggested dialogue:**
> - *"Notice I created `Line Total` by multiplying quantity times extended price. But look — we already have `net_amount`. Are they the same? Let me show you..."*
> - *"See how `Line Total` is higher? That's because `net_amount` includes discounts that were applied in Snowflake. Which one should we trust for revenue reporting?"*
> - *"As data engineers, we want to push calculations as far upstream as possible. If dbt already computed net revenue, don't redo it here."*

### Phase 2: Create Essential Measures (7 mins)

> 📋 **INSTRUCTOR NOTES: Connecting to Phase 1**
>
> **Transition dialogue:**
> - *"We just saw that calculated columns can duplicate upstream work and give us the wrong answer. Now let's do it the right way."*
> - *"Notice we're using `net_amount` — the field Snowflake already calculated — not trying to re-derive it ourselves."*
>
> **Why measures are the correct pattern here:**
> | Calculated Column (Phase 1) | Measure (Phase 2) |
> |-----------------------------|-------------------|
> | Uses `extended_price` (gross) | Uses `net_amount` (net, from Snowflake) |
> | Stored per-row in memory | Calculated on-demand, no storage |
> | Fixed — ignores slicers | Dynamic — reacts to filter context |
> | Duplicates/conflicts with upstream | Trusts upstream business logic |
>
> **Key point to emphasize:**
> - *"As data engineers, we built `net_amount` in dbt during Week 5. Now as report developers, we just aggregate it. That's the proper separation of concerns."*

**Create a Measures table first:**
1. **Home** > **Enter Data** > Create empty table named "_Measures"
2. "Organizing measures in a dedicated table is best practice"

**Total Revenue:**
```dax
Total Revenue = SUM(FCT_ORDER_LINES[net_amount])
```

**Order Count:**
```dax
Order Count = DISTINCTCOUNT(FCT_ORDER_LINES[order_key])
```

**Average Order Value:**
```dax
Avg Order Value = DIVIDE([Total Revenue], [Order Count], 0)
```

**Customer Count:**
```dax
Customer Count = DISTINCTCOUNT(FCT_ORDER_LINES[customer_key])
```

### Phase 3: See Measures in Action (3 mins)

1. Create a card visual with `[Total Revenue]`
2. Add a slicer for `DIM_DATE[year]`
3. Select different years
4. "Watch the measure recalculate!"
5. "This is filter context in action"

> 📋 **INSTRUCTOR NOTES: Understanding Filter Context**
>
> **What is filter context?**
> Filter context is the set of filters active when a measure evaluates. It comes from:
> - **Slicers** (like the year slicer you just added)
> - **Visual axes** (rows/columns in a matrix)
> - **Page/report-level filters**
> - **Cross-filtering** from other visuals
>
> **What trainees should observe:**
> ```
> No slicer selection:    Total Revenue = $X (all years)
> Select 2023:            Total Revenue = $Y (only 2023 data)
> Select 2022:            Total Revenue = $Z (only 2022 data)
> ```
>
> **Why this matters (tie to Phase 1):**
> - The calculated column `Line Total` from Phase 1 would show the SAME per-row values regardless of slicer.
> - The measure `Total Revenue` *recalculates* based on what's filtered.
> - *"This is why we use measures for reporting — they respond to user interaction."*
>
> **Suggested dialogue:**
> - *"When I select 2023, Power BI says 'only give me rows where year = 2023' and then runs SUM(net_amount) on just those rows."*
> - *"The measure doesn't store a value — it computes one fresh every time the filter changes."*
> - *"This is the magic of DAX: one formula, infinite answers depending on context."*
>
> **Common trainee question:**
> - *"What if I want total revenue ignoring the slicer?"* → That's CALCULATE with ALL(), covered in Demo 4.

### Key Talking Points

- "SUM without SUMX is for simple aggregation"
- "DISTINCTCOUNT for counting unique keys"
- "DIVIDE instead of / to handle zero division"
- "Measures reference other measures - that's powerful"

> 📋 **INSTRUCTOR NOTES: Expanding on Key Points**
>
> | Point | Why It Matters |
> |-------|----------------|
> | `SUM` vs `SUMX` | `SUM(column)` is simple aggregation. `SUMX(table, expression)` iterates row-by-row — more powerful but slower. Start with SUM. |
> | `DISTINCTCOUNT` | Counts unique values. Essential for "how many customers?" when fact table has multiple rows per customer. |
> | `DIVIDE` | `DIVIDE(a, b, 0)` returns 0 if `b` is zero. Using `a / b` would error or return infinity. Always use DIVIDE. |
> | Measure composition | `Avg Order Value` references `[Total Revenue]` and `[Order Count]`. If underlying logic changes, it cascades automatically. |

---

## Demo 4: The CALCULATE Function

**Time:** ~20 minutes

### Phase 1: Why CALCULATE Matters (5 mins)

**The Problem:**
1. Create a matrix visual:
   - Rows: `DIM_DATE[year]`
   - Values: `[Total Revenue]`
2. "Each row shows revenue for that year - filtered by row"

**The Challenge:**
- "How do I show Total Revenue across ALL years for comparison?"

**CALCULATE solves this:**

3. In the `_Measures` table, create a new measure:
   ```dax
   Total Revenue All Years = CALCULATE([Total Revenue], ALL(DIM_DATE))
   ```
4. Add `[Total Revenue All Years]` to the matrix **Values** well (next to `[Total Revenue]`)
5. "CALCULATE modified the filter context — this column stays constant across all rows!"

> 📌 **INSTRUCTOR: Switch to DAX Studio (Optional Pro Tip)**

**DAX Studio Check:**
- In DAX Studio, run `EVALUATE ALL(DIM_DATE)`
- "You'll see it returns the WHOLE table, ignoring filters. That's what CALCULATE uses."

> 📌 **INSTRUCTOR: Switch back to Power BI Desktop**

### Phase 2: Common CALCULATE Patterns (10 mins)

> 📌 **INSTRUCTOR: Stay in Power BI Desktop**

Create each of the following measures in the `_Measures` table. For each one, select the `_Measures` table, then **Modeling** > **New measure**.

**Fixed Filter Value:**
```dax
Revenue 2023 = CALCULATE([Total Revenue], DIM_DATE[year] = 2023)
```

**Prior Year Comparison:**

> ⚠️ **Before creating this measure:** You must mark `DIM_DATE` as a date table.
> 1. Go to **Model View**
> 2. Select the `DIM_DATE` table
> 3. **Table tools** > **Mark as date table**
> 4. Select `full_date` as the date column
> 5. Click **OK**

```dax
Revenue PY = CALCULATE([Total Revenue], SAMEPERIODLASTYEAR(DIM_DATE[full_date]))
```

**Year-to-Date:**
```dax
Revenue YTD = TOTALYTD([Total Revenue], DIM_DATE[full_date])
```

**Filtered by Manufacturer:**
```dax
Manufacturer1 Revenue = CALCULATE([Total Revenue], DIM_PRODUCT[manufacturer] = "Manufacturer#1")
```

### Phase 3: Context Transition (5 mins)

Create a table visual:
- Rows: `DIM_CUSTOMER[customer_name]`
- Values: `[Total Revenue]`

Explain:
- "For each customer row, CALCULATE creates a filter context"
- "The measure evaluates in THAT context"
- "This is why measures are so powerful for dynamic reporting"

### Key Talking Points
- "CALCULATE is THE most important DAX function"
- "First argument: what to calculate"
- "Second+ arguments: how to modify filter context"
- "Time intelligence functions like TOTALYTD use CALCULATE internally"

---

## Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Relationship creates circular dependency | Review cross-filter directions, use single |
| Measure returns blank | Check relationship exists and is active |
| CALCULATE filter not working | Ensure column is in related table |
| DAX Studio won't connect | Power BI must be open with a model loaded |
| Time intelligence error | Mark date table, select date column |

---

## Transition to Wednesday

"Today we built the data model and wrote our first DAX measures. Tomorrow we'll:
1. Create actual report visuals using these measures
2. Add custom visuals from AppSource
3. Configure slicers and interactivity
4. Apply conditional formatting"

---

## Required Reading Reference

Before this demo, trainees should have read:
- `designing-schemas.md` - Star schema in Power BI
- `writing-queries.md` - Power BI query patterns
- `dax-introduction.md` - DAX fundamentals
- `dax-studio-introduction.md` - DAX Studio basics
- `dax-aggregation-statistics.md` - Aggregation functions
- `dax-calculate-function.md` - CALCULATE deep dive
