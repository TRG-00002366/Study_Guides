# Demo: Power BI Desktop Setup and Interface Tour

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 1-Monday |
| **Topic** | Power BI Foundations and Data Connectivity |
| **Type** | Conceptual + Walkthrough (Hybrid) |
| **Time** | ~15 minutes |
| **Prerequisites** | Power BI Desktop installed, Snowflake accounts from Week 5 |

**Weekly Epic:** *Data Storytelling — From Warehouse to Insight with Power BI and Streamlit*

---

## Phase 1: The Concept (Whiteboard/Diagram)

**Time:** 5 mins

1. Open `diagrams/powerbi-interface-overview.mermaid`
2. Walk through the three main views:
   - **Report View** — Canvas for building visualizations
   - **Data View** — Spreadsheet-like table inspection ("Like viewing a DataFrame in Python")
   - **Model View** — Relationship diagrams ("Where your Week 5 star schema knowledge comes in")
3. Open `diagrams/powerbi-editions.mermaid`
4. Explain the three Power BI editions:
   - **Desktop** — Free development environment (what we'll use)
   - **Service** — Cloud publishing and sharing (Thursday topic)
   - **Premium** — Enterprise scale and features

> **Discussion Prompt:** *"Think of Power BI Desktop as VS Code for dashboards. The Service is like GitHub — where you publish and share."*

---

## Phase 2: Installation Verification (Live Walkthrough)

**Time:** 3 mins

1. Confirm Power BI Desktop is installed (should be pre-done)
2. Launch the application
3. **Talking Point:** "This is free to use — no license needed for building reports"

---

## Phase 3: Interface Tour (Live Walkthrough)

**Time:** 7 mins

### Report View (Default)
1. Point out the canvas area in the center
2. Identify the **Visualizations pane** on the right — chart type selection
3. Identify the **Fields pane** — shows all loaded data tables and columns
4. Identify the **Filters pane** — slicer and filter configuration

### Data View (Table Icon in Left Sidebar)
1. Click the table icon in the left sidebar
2. "This is your data inspection view — like looking at a DataFrame"
3. Show how you can sort, search, and review column values

### Model View (Diagram Icon in Left Sidebar)
1. Click the diagram icon in the left sidebar
2. "This is where your Week 5 star schema knowledge comes in"
3. Note: Empty until we connect data (Demo 2)

### Quick Sample Connection
1. Click **Get Data** > **More...**
2. Show the extensive list of data connectors
3. Select **Sample Datasets** > **Sales and Marketing Sample**
4. Point out auto-detected relationships in Model View

---

## Key Talking Points

- "Three views match three phases: **Model** your data, **Verify** it, **Build** reports"
- "Power BI Desktop is the development tool; Service is the delivery platform"
- "The ribbon and panes follow Microsoft's familiar interface patterns — Excel users will feel at home"

---

## Required Reading Reference

Before this demo, trainees should have read:
- `power-bi-introduction.md` — Platform overview, editions, role in modern data stack
