# Instructor Guide: Wednesday Demos

## Overview
**Day:** 3-Wednesday - Report Design and Visualization Best Practices
**Total Demo Time:** ~55 minutes
**Prerequisites:** Tuesday demos completed, star schema model built, DAX measures created

---

## Demo 1: Building a Complete Report Page

**Time:** ~15 minutes

### Phase 1: Report Layout Principles (3 mins)

**Key Design Rules:**
1. "Start with the business question, not the chart type"
2. "Guide the eye: top-left is most important"
3. "Consistency: same colors, fonts, spacing throughout"

**Draw on whiteboard:**
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

### Phase 2: Create KPI Cards (4 mins)
1. Add **Card** visual from Visualizations pane
2. Drag `[Total Revenue]` to Fields
3. Format: increase font size, add data label
4. Duplicate for `[Order Count]`, `[Customer Count]`
5. Align cards at top of page

### Phase 3: Add Main Chart (4 mins)
1. Add **Clustered Bar Chart**
2. Axis: `DIM_DATE[year]`
3. Values: `[Total Revenue]`
4. "Bar charts excel at comparisons"

**Alternative: Line Chart for Trends**
1. Add **Line Chart**
2. Axis: `DIM_DATE[month_name]`
3. Values: `[Total Revenue]`
4. Legend: `DIM_DATE[year]`
5. "Line charts show trends over time"

### Phase 4: Add Supporting Visuals (4 mins)
1. **Pie Chart** for market segment breakdown
   - Legend: `DIM_CUSTOMER[market_segment]`
   - Values: `[Total Revenue]`
   - "Pie charts: only for parts of whole, limit to 5-7 slices"

2. **Matrix** for detailed data
   - Rows: `DIM_PRODUCT[manufacturer]`
   - Values: `[Total Revenue]`, `[Order Count]`
   - "Tables when users need exact numbers"

### Key Talking Points
- "Every visual answers a specific question"
- "Less is more - don't overcrowd the page"
- "Consistent alignment makes reports look professional"

---

## Demo 2: Custom Visuals from AppSource

**Time:** ~10 minutes

### Phase 1: Access AppSource (3 mins)
1. In Visualizations pane, click **...** (more options)
2. Select **Get more visuals**
3. "AppSource is Microsoft's marketplace - like app stores"

### Phase 2: Install Chiclet Slicer (3 mins)
1. Search for "Chiclet Slicer"
2. Click **Add**
3. Accept terms
4. "Chiclet Slicer shows image tiles for selection"

### Phase 3: Configure Custom Visual (4 mins)
1. Add Chiclet Slicer to report
2. Category: `DIM_CUSTOMER[market_segment]`
3. Format options:
   - Layout: Horizontal
   - Selection: Single/Multi
4. "More visually engaging than standard dropdowns"

**Other Recommended Visuals:**
- **Hierarchy Slicer** - For drilling through dimensions
- **Card with States** - KPIs with thresholds
- **Sankey Diagram** - Flow visualization

### Key Talking Points
- "Custom visuals extend Power BI capabilities"
- "Some are free, some require license"
- "Test performance - custom visuals can be slower"

---

## Demo 3: Interactivity and Filtering

**Time:** ~15 minutes

### Phase 1: Add Standard Slicers (5 mins)
1. Add **Slicer** visual
2. Field: `DIM_DATE[year]`
3. Format as **Tile** style (horizontal buttons)
4. Position in header area

**Filter to TPC-H date range:**
5. With year slicer selected, open **Filters pane**
6. Under **Filters on this visual**, find `DIM_DATE[year]`
7. Set **Advanced filtering**:
   - `is greater than or equal to` → **1992**
   - **And**
   - `is less than or equal to` → **1998**
8. Click **Apply filter**
9. "TPC-H data only spans 1992-1998 - filter out empty years"

**Add second slicer:**
10. Field: `DIM_CUSTOMER[market_segment]`
11. Format as **Dropdown**
12. "Dropdowns save space when many options"

### Phase 2: Configure Cross-Filtering (5 mins)
1. Select the bar chart
2. Go to **Format** > **Edit interactions** (in ribbon)
3. Click different visuals to set interaction type:
   - **Filter**: Chart filters the visual
   - **Highlight**: Chart highlights values
   - **None**: No interaction

4. Set the matrix to **None** from the bar chart
5. "Sometimes you DON'T want cross-filtering"

### Phase 3: Create Drill-Through Page (6 mins)
1. **Add new page** named "Customer Details"
2. Add visuals for customer analysis
3. Add a **Drill-through** field:
   - In Filters pane > Drill through
   - Drag `DIM_CUSTOMER[customer_key]`

4. Return to main page
5. Right-click a customer data point > **Drill through** > Customer Details
6. "Drill-through enables detail exploration without clutter"

### Key Talking Points
- "Interactivity is what makes Power BI powerful"
- "Configure interactions intentionally - defaults may not be right"
- "Drill-through keeps main pages clean"

---

## Demo 4: Conditional Formatting

**Time:** ~15 minutes

### Phase 1: Data Bars (3 mins)
1. Create a **Table** visual with:
   - `DIM_PRODUCT[manufacturer]`
   - `[Total Revenue]`
2. Select Total Revenue column
3. **Format** > **Cell elements** > **Data bars** ON
4. "Data bars show relative magnitude at a glance"

### Phase 2: Color Scales (4 mins)
1. In same table, add `[Avg Order Value]`
2. **Format** > **Cell elements** > **Background color**
3. Select **Color scale**
4. Configure:
   - Minimum: Light green
   - Maximum: Dark green
5. "Color scales highlight high and low performers"

### Phase 3: Rule-Based Formatting (4 mins)
1. Add `[YoY Growth]` measure to table (if created)
2. **Format** > **Cell elements** > **Icons**
3. **Rules** tab:
   - If value > 0.1: Up arrow (green)
   - If value >= 0: Right arrow (yellow)
   - If value < 0: Down arrow (red)
4. "Icons communicate status instantly"

### Phase 4: DAX-Driven Formatting (4 mins)

**Create a formatting measure:**
```dax
Revenue Color = 
IF([Total Revenue] > 10000000, "#2E7D32",  // Dark green
IF([Total Revenue] > 5000000, "#66BB6A",   // Light green
"#FFEB3B"))                                 // Yellow
```

1. Apply to background color
2. **Field value** > select `[Revenue Color]`
3. "DAX measures give ultimate formatting control"

### Key Talking Points
- "Conditional formatting guides user attention"
- "Don't overdo it - too many colors confuse"
- "Rules should match business thresholds"

---

## Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Custom visual won't load | Check organization settings allow custom visuals |
| Cross-filtering causes slow refresh | Reduce number of interactions, use None where appropriate |
| Drill-through missing | Ensure drill-through field is configured on target page |
| Data bars don't appear | Column must be numeric, check data type |
| Color scale wrong direction | Swap minimum/maximum values |

---

## Transition to Thursday

"Today we built a complete, interactive report. Tomorrow we'll:
1. Publish to Power BI Service
2. Create dashboards from pinned visuals
3. Configure scheduled refresh
4. Implement row-level security"

---

## Required Reading Reference

Before this demo, trainees should have read:
- `report-generation.md` - Report structure and design
- `creating-reports.md` - Visual types and configuration
- `custom-visuals.md` - AppSource and SDK
- `slicing-and-filtering.md` - Filter concepts
- `conditional-formatting.md` - Formatting techniques
- `analyze-feature.md` - AI-powered insights
