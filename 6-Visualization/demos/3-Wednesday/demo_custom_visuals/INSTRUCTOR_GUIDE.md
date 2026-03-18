# Demo: Custom Visuals from AppSource

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 3-Wednesday |
| **Topic** | Custom Visual Marketplace and Configuration |
| **Type** | Concept + Walkthrough |
| **Time** | ~10 minutes |
| **Prerequisites** | Basic report page created (Demo 1) |

**Weekly Epic:** *Data Storytelling — From Warehouse to Insight with Power BI and Streamlit*

---

## Phase 1: The Concept (Diagram)

**Time:** 3 mins

1. Open `diagrams/custom-visual-options.mermaid`
2. Explain custom visual categories:
   - **Slicers** — Enhanced filtering (Chiclet, Hierarchy)
   - **Charts** — Advanced visualizations (Sankey, Heatmap)
   - **KPIs** — Status indicators (Card with States, Bullet Chart)
   - **Maps** — Geographic visuals (ArcGIS, Icon Map)

> **Key Point:** *"AppSource is Microsoft's marketplace — like an app store for Power BI visuals."*

---

## Phase 2: The Code (Live Implementation)

**Time:** 7 mins

### Step 1: Access AppSource (2 mins)
1. In Visualizations pane, click **...** (three dots)
2. Select **Get more visuals**
3. Browse categories — point out "Certified" badge
4. *"Certified visuals have been reviewed by Microsoft for security"*

### Step 2: Install Chiclet Slicer (2 mins)
1. Search for "Chiclet Slicer"
2. Click **Add**
3. Accept terms
4. *"Chiclet Slicer shows image tiles for selection — more engaging than dropdowns"*

### Step 3: Configure Custom Visual (3 mins)
1. Add Chiclet Slicer to report canvas
2. Category: `DIM_CUSTOMER[market_segment]`
3. Format options:
   - Layout: Horizontal
   - Selection: Single/Multi select
   - Colors: Match report theme
4. Show it cross-filtering other visuals

**Other Recommended Visuals to Mention:**
| Visual | Use Case |
|--------|----------|
| **Hierarchy Slicer** | Drilling through dimensions (Date > Quarter > Month) |
| **Card with States** | KPIs with thresholds (red/yellow/green) |
| **Sankey Diagram** | Flow visualization (customer journey) |
| **Infographic Designer** | Pictorial charts with icons |

---

## Key Talking Points

- "Custom visuals extend Power BI beyond its built-in charts"
- "Some are free, some require a license — check pricing"
- "Test performance — custom visuals can be slower than built-in ones"
- "Certified visuals are safer for enterprise use"

---

## Required Reading Reference

Before this demo, trainees should have read:
- `custom-visuals.md` — AppSource marketplace and SDK overview
