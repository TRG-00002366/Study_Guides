# Demo: Multi-Page Dashboard with Metrics and Filters

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 5-Friday |
| **Topic** | Multi-Page Dashboard Layout and Interactivity |
| **Type** | Code-Focused |
| **Time** | ~15 minutes |
| **Prerequisites** | Streamlit basics demo complete, environment active |

**Weekly Epic:** *Data Storytelling — From Warehouse to Insight with Power BI and Streamlit*

---

## Phase 1: The Concept (Diagram)

**Time:** 2 mins

1. Open `diagrams/streamlit-layout-options.mermaid`
2. Explain Streamlit's layout components:
   - `st.sidebar` — Persistent navigation and filters
   - `st.columns()` — Horizontal grid layout
   - `st.tabs()` — Tabbed views
   - `st.expander()` — Collapsible sections

---

## Phase 2: The Code (Live Implementation)

**Time:** 13 mins

### Step 1: Page Configuration and Navigation (3 mins)

Open `code/app_dashboard.py` and walk through:

```python
import streamlit as st
import pandas as pd
import numpy as np

st.set_page_config(
    page_title="Analytics Dashboard",
    page_icon=":bar_chart:",
    layout="wide"
)

st.sidebar.title("Navigation")
page = st.sidebar.radio("Go to", ["Overview", "Details", "Trends"])
```

*"set_page_config must be the FIRST Streamlit command — it configures the browser tab."*

### Step 2: KPI Metrics Row (5 mins)

```python
if page == "Overview":
    st.title("Sales Overview")
    
    col1, col2, col3, col4 = st.columns(4)
    with col1:
        st.metric("Total Revenue", "$1.2M", "+12%")
    with col2:
        st.metric("Orders", "8,542", "+5%")
    with col3:
        st.metric("Customers", "2,103", "+8%")
    with col4:
        st.metric("Avg Order", "$140", "-2%")
```

*"st.metric shows value + delta with automatic color coding (green up, red down)."*

### Step 3: Interactive Filters (5 mins)

```python
    st.subheader("Filters")
    col1, col2 = st.columns(2)
    with col1:
        year = st.selectbox("Year", [2023, 2024, 2025])
    with col2:
        region = st.multiselect("Region", 
            ["North", "South", "East", "West"])
    
    st.subheader("Sales by Region")
    chart_data = pd.DataFrame(
        np.random.randn(12, len(region) if region else 4),
        columns=region if region else ["North", "South", "East", "West"]
    )
    st.line_chart(chart_data)
```

**Run:** `streamlit run code/app_dashboard.py`

---

## Key Talking Points

- "Columns create responsive grid layouts — just like Power BI card rows"
- "st.metric shows KPIs with delta indicators — instant status"
- "Sidebar keeps filters accessible but not cluttered"
- "Every widget interaction triggers a full script re-run"

---

## Required Reading Reference

Before this demo, trainees should have read:
- `streamlit-core-components.md` — UI components and layout
- `streamlit-charts.md` — Built-in chart options
