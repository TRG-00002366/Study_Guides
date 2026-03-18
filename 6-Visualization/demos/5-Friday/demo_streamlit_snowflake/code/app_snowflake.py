"""
Streamlit Demo 3: Snowflake Gold Zone Dashboard
Day: Friday
Description: Connect Streamlit to Snowflake GOLD layer with caching and filters
Run: streamlit run code/app_snowflake.py
Prerequisites: 
  - pip install streamlit pandas snowflake-connector-python
  - Create .streamlit/secrets.toml with Snowflake credentials
"""
import streamlit as st
import pandas as pd
from snowflake.connector import connect

st.set_page_config(
    page_title="Snowflake Gold Zone Dashboard",
    page_icon=":snowflake:",
    layout="wide"
)

st.title("❄️ Snowflake Gold Zone Dashboard")
st.write("Connected to the same GOLD layer as Power BI — now in Python!")

# ---------------------------------------------------------------------------
# CONNECTION & CACHING
# ---------------------------------------------------------------------------

@st.cache_resource
def get_connection():
    """
    Cache the Snowflake connection object.
    @st.cache_resource ensures the connection is created once and reused.
    """
    return connect(
        account=st.secrets["snowflake"]["account"],
        user=st.secrets["snowflake"]["user"],
        password=st.secrets["snowflake"]["password"],
        warehouse=st.secrets["snowflake"]["warehouse"],
        database=st.secrets["snowflake"]["database"],
        schema=st.secrets["snowflake"]["schema"]
    )


@st.cache_data(ttl=600)  # Cache for 10 minutes
def run_query(query):
    """
    Cache query results as a DataFrame.
    TTL=600 means results refresh every 10 minutes.
    """
    conn = get_connection()
    return pd.read_sql(query, conn)


# ---------------------------------------------------------------------------
# QUERY THE GOLD ZONE
# ---------------------------------------------------------------------------

query = """
SELECT 
    d.year,
    c.market_segment,
    SUM(f.net_amount) as total_revenue,
    COUNT(DISTINCT f.order_key) as order_count,
    COUNT(DISTINCT f.customer_key) as customer_count
FROM FCT_ORDER_LINES f
JOIN DIM_DATE d ON f.date_key = d.date_key
JOIN DIM_CUSTOMER c ON f.customer_key = c.customer_key
GROUP BY d.year, c.market_segment
ORDER BY d.year, total_revenue DESC
"""

try:
    df = run_query(query)
    st.success("Connected to Snowflake successfully!")
except Exception as e:
    st.error(f"Connection failed: {e}")
    st.info("Make sure .streamlit/secrets.toml is configured correctly.")
    st.stop()

# ---------------------------------------------------------------------------
# SIDEBAR FILTERS
# ---------------------------------------------------------------------------

st.sidebar.header("Filters")

years = sorted(df['YEAR'].unique().tolist())
selected_year = st.sidebar.selectbox("Year", years)

segments = sorted(df['MARKET_SEGMENT'].unique().tolist())
selected_segments = st.sidebar.multiselect(
    "Market Segment",
    segments,
    default=segments
)

# ---------------------------------------------------------------------------
# FILTER DATA
# ---------------------------------------------------------------------------

filtered_df = df[
    (df['YEAR'] == selected_year) &
    (df['MARKET_SEGMENT'].isin(selected_segments))
]

# ---------------------------------------------------------------------------
# KPI METRICS
# ---------------------------------------------------------------------------

st.subheader(f"Key Metrics — {selected_year}")

total_rev = filtered_df['TOTAL_REVENUE'].sum()
total_orders = filtered_df['ORDER_COUNT'].sum()
total_customers = filtered_df['CUSTOMER_COUNT'].sum()

col1, col2, col3 = st.columns(3)
with col1:
    st.metric("Total Revenue", f"${total_rev:,.2f}")
with col2:
    st.metric("Total Orders", f"{total_orders:,}")
with col3:
    st.metric("Unique Customers", f"{total_customers:,}")

st.divider()

# ---------------------------------------------------------------------------
# CHARTS
# ---------------------------------------------------------------------------

col_chart, col_table = st.columns([2, 1])

with col_chart:
    st.subheader("Revenue by Market Segment")
    chart_data = filtered_df.set_index('MARKET_SEGMENT')['TOTAL_REVENUE']
    st.bar_chart(chart_data)

with col_table:
    st.subheader("Data Table")
    st.dataframe(
        filtered_df[['MARKET_SEGMENT', 'TOTAL_REVENUE', 'ORDER_COUNT']],
        use_container_width=True,
        hide_index=True
    )

# ---------------------------------------------------------------------------
# YEAR-OVER-YEAR COMPARISON
# ---------------------------------------------------------------------------

st.subheader("Revenue Trend — All Years")
yearly_data = df.groupby('YEAR')['TOTAL_REVENUE'].sum().reset_index()
yearly_data = yearly_data.set_index('YEAR')
st.line_chart(yearly_data)

# Footer
st.divider()
st.caption("Week 6 Visualization — Streamlit Demo 3 | Data from Snowflake GOLD Layer")
