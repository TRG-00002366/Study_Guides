# Demo: Connecting Streamlit to Snowflake

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 5-Friday |
| **Topic** | Snowflake Integration and Query Caching |
| **Type** | Hybrid (Concept + Code) |
| **Time** | ~20 minutes |
| **Prerequisites** | Streamlit installed, Snowflake credentials from Week 5 |

**Weekly Epic:** *Data Storytelling — From Warehouse to Insight with Power BI and Streamlit*

---

## Phase 1: The Concept (Diagram)

**Time:** 3 mins

1. Open `diagrams/streamlit-snowflake-connection.mermaid`
2. Explain the connection architecture:
   - Secrets management via `.streamlit/secrets.toml`
   - Connection caching with `@st.cache_resource`
   - Query caching with `@st.cache_data` and TTL
3. *"Same GOLD zone from Week 5 and Power BI — now in Python."*

> **Key Point:** *"NEVER commit secrets.toml to git! Add it to .gitignore."*

---

## Phase 2: The Code (Live Implementation)

**Time:** 17 mins

### Step 1: Configure Secrets (3 mins)

Create `.streamlit/secrets.toml` (use template in `code/secrets_template.toml`):

```toml
[snowflake]
account = "xy12345.us-east-1"
user = "your_username"
password = "your_password"
warehouse = "COMPUTE_WH"
database = "DEV_DB"
schema = "GOLD"
```

*"Streamlit secrets are stored locally — accessed via st.secrets dictionary."*

### Step 2: Build the Snowflake App (10 mins)

Open `code/app_snowflake.py` and walk through:

**Connection with caching:**
```python
@st.cache_resource
def get_connection():
    return connect(
        account=st.secrets["snowflake"]["account"],
        user=st.secrets["snowflake"]["user"],
        password=st.secrets["snowflake"]["password"],
        ...
    )
```

*"@st.cache_resource caches the connection object — creates once, reuses on every re-run."*

**Cached query:**
```python
@st.cache_data(ttl=600)  # Cache for 10 minutes
def run_query(query):
    conn = get_connection()
    return pd.read_sql(query, conn)
```

*"@st.cache_data caches the DataFrame result — avoids re-querying Snowflake on every click."*

**SQL query against Gold zone:**
```python
query = """
SELECT d.year, c.market_segment,
       SUM(f.net_amount) as total_revenue,
       COUNT(DISTINCT f.order_key) as order_count
FROM FCT_ORDER_LINES f
JOIN DIM_DATE d ON f.date_key = d.date_key
JOIN DIM_CUSTOMER c ON f.customer_key = c.customer_key
GROUP BY d.year, c.market_segment
ORDER BY d.year, total_revenue DESC
"""
```

### Step 3: Add Interactivity (4 mins)

```python
# Sidebar filters
st.sidebar.header("Filters")
selected_year = st.sidebar.selectbox("Year", years)
selected_segments = st.sidebar.multiselect("Segment", segments, default=segments)

# Filter and display
filtered_df = df[
    (df['YEAR'] == selected_year) & 
    (df['MARKET_SEGMENT'].isin(selected_segments))
]
```

**Run:** `streamlit run code/app_snowflake.py`

---

## Key Talking Points

- "@st.cache_data prevents re-running queries on each interaction"
- "Same GOLD zone tables — Power BI and Streamlit side by side"
- "Secrets management keeps credentials secure — never hardcode passwords"
- "TTL controls cache staleness — 600s = queries refresh every 10 minutes"

---

## Required Reading Reference

Before this demo, trainees should have read:
- `streamlit-snowflake-connection.md` — Connector setup, caching, secrets
