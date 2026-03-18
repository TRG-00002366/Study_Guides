# Instructor Guide: Friday Demos

## Overview
**Day:** 5-Friday - Streamlit for Python Data Applications
**Total Demo Time:** ~60 minutes
**Prerequisites:** Python environment, Snowflake credentials, basic Python knowledge

---

## Demo 1: Streamlit Basics - Your First App

**Time:** ~15 minutes

### Phase 1: Environment Setup (3 mins)

**Terminal commands:**
```bash
# Create virtual environment (if not exists)
python -m venv streamlit_env

# Activate (Windows)
streamlit_env\Scripts\activate

# Activate (macOS/Linux)
source streamlit_env/bin/activate

# Install streamlit
pip install streamlit pandas
```

### Phase 2: Hello World App (5 mins)

Create `app_basic.py`:
```python
import streamlit as st

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

"Browser opens automatically - THIS is Streamlit's magic"

### Phase 3: Add Data Display (7 mins)

Expand the app:
```python
import streamlit as st
import pandas as pd

st.title("Sales Dashboard - Basic")

# Sample data
data = {
    "Product": ["Widget A", "Widget B", "Widget C"],
    "Sales": [1000, 1500, 800],
    "Region": ["North", "South", "East"]
}
df = pd.DataFrame(data)

# Display data
st.dataframe(df)

# Metrics
total_sales = df["Sales"].sum()
st.metric("Total Sales", f"${total_sales:,}")

# Simple chart
st.bar_chart(df.set_index("Product")["Sales"])
```

### Key Talking Points
- "No HTML, CSS, or JavaScript needed"
- "Python script runs top-to-bottom on each interaction"
- "Hot reload - save file, see changes instantly"

---

## Demo 2: Multi-Page Dashboard with Metrics

**Time:** ~15 minutes

### Phase 1: App Structure (5 mins)

Create `app_dashboard.py`:
```python
import streamlit as st
import pandas as pd
import numpy as np

# Page configuration
st.set_page_config(
    page_title="Analytics Dashboard",
    page_icon=":bar_chart:",
    layout="wide"
)

# Sidebar navigation
st.sidebar.title("Navigation")
page = st.sidebar.radio("Go to", ["Overview", "Details", "Trends"])
```

### Phase 2: Dashboard Metrics (5 mins)

Add metrics section:
```python
if page == "Overview":
    st.title("Sales Overview")
    
    # KPI row using columns
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

### Phase 3: Interactive Filters (5 mins)

Add filtering:
```python
    # Filter section
    st.subheader("Filters")
    col1, col2 = st.columns(2)
    
    with col1:
        year = st.selectbox("Year", [2023, 2024, 2025])
    with col2:
        region = st.multiselect("Region", ["North", "South", "East", "West"])
    
    # Filtered data display
    st.subheader("Sales by Region")
    
    # Generate sample data
    chart_data = pd.DataFrame(
        np.random.randn(12, len(region) if region else 4),
        columns=region if region else ["North", "South", "East", "West"]
    )
    st.line_chart(chart_data)
```

### Key Talking Points
- "Columns create responsive grid layouts"
- "st.metric shows KPIs with delta indicators"
- "Sidebar keeps filters accessible but not cluttered"

---

## Demo 3: Connecting Streamlit to Snowflake

**Time:** ~20 minutes

### Phase 1: Secrets Configuration (5 mins)

Create `.streamlit/secrets.toml`:
```toml
[snowflake]
account = "xy12345.us-east-1"
user = "your_username"
password = "your_password"
warehouse = "COMPUTE_WH"
database = "DEV_DB"
schema = "GOLD"
```

"NEVER commit secrets.toml to git!"

### Phase 2: Snowflake Connection (10 mins)

Create `app_snowflake.py`:
```python
import streamlit as st
import pandas as pd
from snowflake.connector import connect

st.title("Snowflake Gold Zone Dashboard")
st.write("Connected to the same data as Power BI!")

# Cache the connection
@st.cache_resource
def get_connection():
    return connect(
        account=st.secrets["snowflake"]["account"],
        user=st.secrets["snowflake"]["user"],
        password=st.secrets["snowflake"]["password"],
        warehouse=st.secrets["snowflake"]["warehouse"],
        database=st.secrets["snowflake"]["database"],
        schema=st.secrets["snowflake"]["schema"]
    )

# Cache query results
@st.cache_data(ttl=600)  # Cache for 10 minutes
def run_query(query):
    conn = get_connection()
    return pd.read_sql(query, conn)

# Query the gold zone
query = """
SELECT 
    d.year,
    c.market_segment,
    SUM(f.net_amount) as total_revenue,
    COUNT(DISTINCT f.order_key) as order_count
FROM FCT_ORDER_LINES f
JOIN DIM_DATE d ON f.date_key = d.date_key
JOIN DIM_CUSTOMER c ON f.customer_key = c.customer_key
GROUP BY d.year, c.market_segment
ORDER BY d.year, total_revenue DESC
"""

df = run_query(query)

# Display
st.dataframe(df)

# Chart
st.bar_chart(df.pivot(index='YEAR', columns='MARKET_SEGMENT', values='TOTAL_REVENUE'))
```

### Phase 3: Add Interactivity (5 mins)

Enhance with filters:
```python
# Sidebar filters
st.sidebar.header("Filters")
years = df['YEAR'].unique().tolist()
selected_year = st.sidebar.selectbox("Year", years)

segments = df['MARKET_SEGMENT'].unique().tolist()
selected_segments = st.sidebar.multiselect("Segment", segments, default=segments)

# Filter data
filtered_df = df[
    (df['YEAR'] == selected_year) & 
    (df['MARKET_SEGMENT'].isin(selected_segments))
]

# Show metrics
total_rev = filtered_df['TOTAL_REVENUE'].sum()
st.metric("Total Revenue", f"${total_rev:,.2f}")

st.dataframe(filtered_df)
```

### Key Talking Points
- "Same GOLD zone from Week 5 and Power BI - now in Python"
- "@st.cache_data prevents re-running queries on each interaction"
- "Secrets management keeps credentials secure"

---

## Demo 4: Interactive Outlier Detection

**Time:** ~10 minutes

### Phase 1: Statistical Methods (5 mins)

Create `app_outliers.py`:
```python
import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px

st.title("Outlier Detection Tool")

# Sample data (or connect to Snowflake)
np.random.seed(42)
data = np.random.normal(100, 15, 200)
# Add some outliers
data = np.append(data, [200, 210, 5, 10])
df = pd.DataFrame({"Value": data})

st.write(f"Dataset: {len(df)} records")

# Method selection
method = st.selectbox(
    "Detection Method",
    ["Z-Score", "IQR (Interquartile Range)"]
)

threshold = st.slider("Threshold", 1.0, 4.0, 2.0, 0.1)
```

### Phase 2: Detection and Visualization (5 mins)

Add detection logic:
```python
if method == "Z-Score":
    df["z_score"] = (df["Value"] - df["Value"].mean()) / df["Value"].std()
    df["is_outlier"] = abs(df["z_score"]) > threshold
    metric_label = f"Z-Score > {threshold}"
else:
    Q1 = df["Value"].quantile(0.25)
    Q3 = df["Value"].quantile(0.75)
    IQR = Q3 - Q1
    lower = Q1 - threshold * IQR
    upper = Q3 + threshold * IQR
    df["is_outlier"] = (df["Value"] < lower) | (df["Value"] > upper)
    metric_label = f"IQR * {threshold}"

# Results
col1, col2 = st.columns(2)
with col1:
    st.metric("Total Records", len(df))
with col2:
    st.metric("Outliers Found", df["is_outlier"].sum())

# Visualization with Plotly
fig = px.scatter(
    df.reset_index(), 
    x="index", 
    y="Value",
    color="is_outlier",
    color_discrete_map={True: "red", False: "blue"},
    title=f"Outlier Detection: {method}"
)
st.plotly_chart(fig, use_container_width=True)

# Show outlier details
if st.checkbox("Show outlier details"):
    st.dataframe(df[df["is_outlier"]])
```

### Key Talking Points
- "Interactive analysis tools in minutes, not days"
- "Plotly integration for rich visualizations"
- "Users can adjust parameters and see results instantly"

---

## Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| streamlit command not found | Activate virtual environment |
| Snowflake connection error | Verify secrets.toml format and credentials |
| Page won't load | Check for Python syntax errors in terminal |
| Cache not working | Ensure function has no side effects |
| Charts not rendering | Verify data types are numeric |

---

## Week Summary

"This week we covered the full visualization stack:
- **Monday**: Power BI setup, Snowflake connection
- **Tuesday**: Data modeling, DAX fundamentals
- **Wednesday**: Report design, interactivity
- **Thursday**: Dashboards, refresh, security
- **Friday**: Streamlit for Python-native apps

You can now build dashboards in BOTH enterprise BI (Power BI) and Python (Streamlit), connecting to the Snowflake warehouse you built in Week 5."

---

## Required Reading Reference

Before this demo, trainees should have read:
- `streamlit-introduction.md` - Streamlit overview
- `streamlit-setup.md` - Environment configuration
- `streamlit-core-components.md` - UI components
- `streamlit-charts.md` - Visualization options
- `streamlit-snowflake-connection.md` - Database connectivity
- `detecting-outliers.md` - Statistical methods
