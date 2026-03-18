# Demo: Streamlit Basics — Your First Python App

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 5-Friday |
| **Topic** | Streamlit Fundamentals and First App |
| **Type** | Hybrid (Concept + Code) |
| **Time** | ~15 minutes |
| **Prerequisites** | Python environment, basic Python knowledge |

**Weekly Epic:** *Data Storytelling — From Warehouse to Insight with Power BI and Streamlit*

---

## Phase 1: The Concept (Diagram)

**Time:** 3 mins

1. Open `diagrams/streamlit-architecture.mermaid`
2. Explain Streamlit's unique architecture:
   - Python script runs top-to-bottom on each user interaction
   - Streamlit server converts Python to HTML/JS automatically
   - Hot reload — save the file, see changes instantly
3. *"No HTML, CSS, or JavaScript needed — pure Python."*

> **Comparison:** *"Power BI is enterprise BI with a GUI. Streamlit is developer BI with code. Both connect to the same data."*

---

## Phase 2: The Code (Live Implementation)

**Time:** 12 mins

### Step 1: Environment Setup (3 mins)

```bash
# Create virtual environment
python -m venv streamlit_env

# Activate (Windows)
streamlit_env\Scripts\activate

# Activate (macOS/Linux)
source streamlit_env/bin/activate

# Install packages
pip install streamlit pandas
```

### Step 2: Hello World App (4 mins)

Open `code/app_basic.py` and walk through line by line:

```python
import streamlit as st
import pandas as pd

st.title("Hello, Streamlit!")
st.write("This is my first Streamlit app.")

# Simple interactivity
name = st.text_input("Enter your name")
if name:
    st.write(f"Welcome, {name}!")
```

**Run the app:**
```bash
streamlit run code/app_basic.py
```

*"Browser opens automatically — THIS is Streamlit's magic."*

### Step 3: Add Data Display (5 mins)

Continue building the app (already in `code/app_basic.py`):

```python
# Sample data
data = {
    "Product": ["Widget A", "Widget B", "Widget C", "Widget D"],
    "Sales": [1000, 1500, 800, 1200],
    "Region": ["North", "South", "East", "West"]
}
df = pd.DataFrame(data)

# Display as interactive table
st.dataframe(df)

# Metrics row
col1, col2, col3 = st.columns(3)
with col1:
    st.metric("Total Sales", f"${df['Sales'].sum():,}")
with col2:
    st.metric("Products", len(df))
with col3:
    st.metric("Avg Sale", f"${df['Sales'].mean():,.0f}")

# Simple bar chart
st.bar_chart(df.set_index("Product")["Sales"])
```

---

## Key Talking Points

- "No HTML, CSS, or JavaScript needed — just Python"
- "Hot reload — save file, see changes instantly"
- "Script runs top-to-bottom on each interaction — simple mental model"
- "Perfect for internal tools, prototypes, and data apps"

---

## Required Reading Reference

Before this demo, trainees should have read:
- `streamlit-introduction.md` — What Streamlit is and how it works
- `streamlit-setup.md` — Environment setup and dev workflow
