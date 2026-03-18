# Demo: Building a Complete Report Page

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 3-Wednesday |
| **Topic** | Report Design and Visual Layout |
| **Type** | Hybrid (Concept + Implementation) |
| **Time** | ~15 minutes |
| **Prerequisites** | Star schema model built, DAX measures created (Tuesday) |

**Weekly Epic:** *Data Storytelling — From Warehouse to Insight with Power BI and Streamlit*

---

## Phase 1: The Concept (Whiteboard/Diagram)

**Time:** 4 mins

1. Open `diagrams/report-structure.mermaid`
2. Discuss report layout principles:
   - Start with the business question, not the chart type
   - Guide the eye: **top-left is most important**
   - Consistency: same colors, fonts, spacing throughout

3. Open `diagrams/WHITEBOARD_PLAN.md` — draw the layout grid on the whiteboard:

```
+------------------------------------------+
|  Title / KPI Cards        | Filters     |
+------------------------------------------+
|                           |             |
|   Main Visual             | Secondary   |
|   (largest area)          | Visuals     |
|                           |             |
+------------------------------------------+
|  Supporting Details / Table              |
+------------------------------------------+
```

> **Discussion:** *"Every visual answers a specific question. Before adding a chart, ask: what question does this answer?"*

---

## Phase 2: The Code (Live Implementation)

**Time:** 11 mins

### Step 1: Create KPI Cards (3 mins)
1. Add **Card** visual from Visualizations pane
2. Drag `[Total Revenue]` to Fields
3. Format: increase font size, add data label
4. Duplicate for `[Order Count]`, `[Customer Count]`
5. Align cards at top of page — use **Format** > **Align** tools

### Step 2: Add Main Chart (4 mins)

**Clustered Bar Chart:**
1. Add **Clustered Bar Chart**
2. Axis: `DIM_DATE[year]`
3. Values: `[Total Revenue]`
4. *"Bar charts excel at comparisons"*

**Line Chart for Trends:**
1. Add **Line Chart** (below or beside)
2. Axis: `DIM_DATE[month_name]`
3. Values: `[Total Revenue]`
4. Legend: `DIM_DATE[year]`
5. *"Line charts show trends over time"*

### Step 3: Add Supporting Visuals (4 mins)

**Pie Chart — Market Segment Breakdown:**
1. Legend: `DIM_CUSTOMER[market_segment]`
2. Values: `[Total Revenue]`
3. *"Pie charts: only for parts-of-whole, limit to 5-7 slices"*

**Matrix — Detailed Data:**
1. Rows: `DIM_PRODUCT[manufacturer]`
2. Values: `[Total Revenue]`, `[Order Count]`
3. *"Tables when users need exact numbers"*

---

## Key Talking Points

- "Less is more — don't overcrowd the page"
- "Consistent alignment makes reports look professional"
- "Choose chart type based on the question: comparison → bar, trend → line, proportion → pie"

---

## Required Reading Reference

Before this demo, trainees should have read:
- `report-generation.md` — Report structure and design
- `creating-reports.md` — Visual types and configuration
