# Simple Drill-Through Demo: Customer Revenue Analysis

## Overview
| Field | Detail |
|-------|--------|
| **Goal** | Build a 2-page report with drill-through navigation |
| **Data** | Star schema with `DIM_CUSTOMER` and fact table |
| **Time** | ~10 minutes |
| **Power BI Version** | 2.151.x (February 2026) |

---

## Page 1: Customer Summary (Main Page)

### Step 1: Rename the Page
- Double-click the page tab at the bottom → rename to **Customer Summary**

### Step 2: Add a Customer Revenue Table
1. From **Visualizations** pane, click the **Table** icon
2. From **Data** pane, drag these fields into the table's **Columns** well:
   - `DIM_CUSTOMER[customer_key]`
   - `DIM_CUSTOMER[market_segment]`
   - `[Total Revenue]` (DAX measure)
   - `[Order Count]` (DAX measure)
3. Resize the table to fill the **top half** of the page

### Step 3: Add a Bar Chart Below
1. Click empty space on the canvas (deselect the table)
2. Select **Clustered Bar Chart** from Visualizations pane
3. Configure:
   - **Y-Axis:** `DIM_CUSTOMER[market_segment]`
   - **X-Axis:** `[Total Revenue]`
4. Resize to fill the **bottom half** of the page

> ✅ **Checkpoint:** You should now have a table showing customer data and a bar chart showing revenue by segment — all on one page.

---

## Page 2: Customer Details (Drill-Through Target)

### Step 4: Create a New Page
1. Click the **+** button next to the page tabs at the bottom
2. Double-click the new page tab → rename to **Customer Details**

### Step 5: Add a Card Visual
1. Select **Card** from the Visualizations pane
2. Drag `[Total Revenue]` into the **Fields** well
3. Position at the **top-left** of the page

### Step 6: Add a Revenue-by-Year Chart
1. Click empty canvas space
2. Select **Line Chart** from Visualizations pane
3. Configure:
   - **X-Axis:** `DIM_DATE[year]`
   - **Values:** `[Total Revenue]`
4. Position in the **middle area** of the page

### Step 7: Add an Orders Table
1. Click empty canvas space
2. Select **Table** from Visualizations pane
3. Drag into **Columns**:
   - `DIM_DATE[year]`
   - `[Total Revenue]`
   - `[Order Count]`
4. Position at the **bottom** of the page

> ✅ **Checkpoint:** Your "Customer Details" page should have 3 visuals: a revenue card, a line chart, and a table. These currently show ALL data — that's fine, the drill-through filter will scope them to one customer.

---

## Configure Drill-Through

### Step 8: Set Up the Drill-Through Field

> ⚠️ **Important:** You must be on the **Customer Details** page (the target page, NOT the main page).

1. Make sure you're on the **Customer Details** page
2. Click **empty canvas space** (don't select any visual)
3. In the **Visualizations** pane, look below the visual formatting options
4. Find the **Drill through** well/section (it appears below the standard field wells)
5. From the **Data** pane, drag `DIM_CUSTOMER[customer_key]` into the **Drill through** well
6. A **back arrow** button will automatically appear on the canvas — this is normal and expected

```
What you should see in the Visualizations pane:

┌─────────────────────────┐
│  Drill through          │
│  ┌───────────────────┐  │
│  │ customer_key      │  │
│  └───────────────────┘  │
│                         │
│  ☑ Keep all filters     │
└─────────────────────────┘
```

> ✅ **Checkpoint:** You should see `customer_key` in the drill-through well and a back arrow on your canvas.

---

## Test the Drill-Through

### Step 9: Navigate Using Drill-Through
1. Click the **Customer Summary** page tab at the bottom (go back to Page 1)
2. In your **customer table**, find any row
3. **Right-click** on a row (e.g., on a customer_key value)
4. In the context menu, select **Drill through → Customer Details**

```
Right-click menu you should see:

┌──────────────────────────────┐
│  Copy                        │
│  Show as a table             │
│  ──────────────────────────  │
│  Drill through ►             │
│    └── Customer Details      │  ← Click this
│  ──────────────────────────  │
│  Filter                      │
│  ...                         │
└──────────────────────────────┘
```

5. Power BI navigates to **Customer Details** — all visuals are now **filtered to that one customer**
6. The card shows that customer's total revenue
7. The line chart shows that customer's revenue by year
8. The table shows that customer's yearly breakdown

### Step 10: Return to Main Page
1. Click the **back arrow** (top-left of the Customer Details page)
2. You're back on the **Customer Summary** page with no filters applied

> ✅ **Done!** You've built a working drill-through report.

---

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| "Drill through" not in right-click menu | The visual doesn't contain `customer_key` | Make sure your table on Page 1 includes `DIM_CUSTOMER[customer_key]` |
| Drill-through shows all data (not filtered) | Field placed in wrong well | Check that `customer_key` is in the **Drill through** well, not Filters or Columns |
| No back arrow on Customer Details page | Drill-through not configured | Re-drag `customer_key` into the Drill through well on the Customer Details page |
| Right-click shows "Drill through" but it's greyed out | Clicked a blank area or header | Right-click directly on a **data value** in a row, not on the header or empty space |
