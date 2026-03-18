# Whiteboard Plan: Report Layout Grid

## Drawing Script

### Step 1: Draw the Grid (2 mins)

Draw the following layout grid on the whiteboard:

```
+--------------------------------------------------+
|  TITLE BAR                              | FILTER |
+--------------------------------------------------+
|  [ Revenue ]  [ Orders ]  [ Customers ] |  AREA  |
|  (Cards)      (Cards)     (Cards)       |        |
+------------------------------------------+        |
|                             |            |  Year  |
|   MAIN VISUAL               | SECONDARY |  Slicer|
|   (Bar Chart or             | (Pie or   |        |
|    Line Chart)              |  Gauge)   | Market |
|                             |            |  Slicer|
+------------------------------------------+--------+
|  DETAIL TABLE / MATRIX                            |
|  (Exact numbers for power users)                  |
+--------------------------------------------------+
```

### Step 2: Annotate Design Principles

Write next to the grid:

1. **F-Pattern Reading:** Users scan left-to-right, top-to-bottom
   - Most important content → top-left
   - KPIs → first thing users see
   - Detail tables → bottom (for users who want specifics)

2. **Visual Hierarchy:**
   - Cards = instant answer ("What's the number?")
   - Charts = pattern/trend ("What's happening?")
   - Tables = proof ("Show me the details")

3. **The 5-Second Rule:**
   - A dashboard should answer its main question within 5 seconds
   - If users need to scroll or squint → redesign

### Step 3: Chart Type Decision Guide

Draw a quick decision matrix:

| Question Type | Best Chart | Example |
|--------------|-----------|---------|
| "How much?" | Card / KPI | Total Revenue |
| "Compare groups" | Bar chart | Revenue by segment |
| "Trend over time" | Line chart | Monthly revenue |
| "Part of whole" | Pie / Donut | Market share |
| "Show detail" | Table / Matrix | Product-level data |
| "Performance vs target" | Gauge / Bullet | Quota attainment |
