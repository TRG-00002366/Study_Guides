# Demo: Interactivity — Slicers, Cross-Filtering, and Drill-Through

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 3-Wednesday |
| **Topic** | Report Interactivity and Navigation |
| **Type** | Hybrid (Concept + Implementation) |
| **Time** | ~15 minutes |
| **Prerequisites** | Report page with visuals created (Demo 1) |

**Weekly Epic:** *Data Storytelling — From Warehouse to Insight with Power BI and Streamlit*

---

## Phase 1: The Concept (Diagram)

**Time:** 3 mins

1. Open `diagrams/filter-hierarchy.mermaid`
2. Explain the filter hierarchy in Power BI:
   - **Report-level filters** — Apply to ALL pages
   - **Page-level filters** — Apply to current page only
   - **Visual-level filters** — Apply to one specific visual
   - **Slicers** — User-controlled interactive filters

3. Open `diagrams/drill-through-flow.mermaid`
4. Explain drill-through navigation:
   - Main page → Right-click data point → Navigate to detail page

> **Key insight:** *"Interactivity is what makes Power BI powerful — it's not just a static PDF."*

---

## Phase 2: The Code (Live Implementation)

**Time:** 12 mins

### Step 1: Add Standard Slicers (4 mins)
1. Add **Slicer** visual
2. Field: `DIM_DATE[year]`
3. Format as **Tile** style (horizontal buttons)
4. Position in header area

**Filter to TPC-H date range:**
5. With year slicer selected, open **Filters pane**
6. Under "Filters on this visual", find `DIM_DATE[year]`
7. Set Advanced filtering:
   - `is greater than or equal to` → **1992**
   - `And`
   - `is less than or equal to` → **1998**
8. Click **Apply filter**
9. *"TPC-H data spans 1992–1998 — filter out empty years"*

**Add second slicer:**
10. Field: `DIM_CUSTOMER[market_segment]`
11. Format as **Dropdown**
12. *"Dropdowns save space when there are many options"*

### Step 2: Configure Cross-Filtering (4 mins)
1. Select the bar chart
2. Go to **Format** > **Edit interactions** (in ribbon)
3. Click different visuals to set interaction type:
   - **Filter**: Chart filters the target visual
   - **Highlight**: Chart highlights values in target
   - **None**: No interaction
4. Set the matrix to **None** from the bar chart
5. *"Sometimes you DON'T want cross-filtering — configure intentionally"*

### Step 3: Create Drill-Through Page (4 mins)
1. **Add new page** named "Customer Details"
2. Add visuals for customer analysis (table, chart)
3. Add a **Drill-through** field:
   - In Filters pane > Drill through section
   - Drag `DIM_CUSTOMER[customer_key]`
4. Return to main page
5. Right-click a customer data point > **Drill through** > Customer Details
6. *"Drill-through enables detail exploration without cluttering the main page"*

---

## Key Talking Points

- "Configure interactions intentionally — defaults may not be right"
- "Drill-through keeps main pages clean while enabling deep exploration"
- "Slicer format depends on cardinality: few values = tiles, many = dropdown"

---

## Required Reading Reference

Before this demo, trainees should have read:
- `slicing-and-filtering.md` — Slicer types and filter interactions
