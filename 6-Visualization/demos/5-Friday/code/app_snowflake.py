"""
Streamlit Demo 3: Snowflake Connection
Day: Friday
Description: Connect to Snowflake GOLD zone and display data

Prerequisites:
1. Create .streamlit/secrets.toml with Snowflake credentials
2. pip install snowflake-connector-python

secrets.toml format:
[snowflake]
account = "xy12345.us-east-1"
user = "your_username"
password = "your_password"
warehouse = "COMPUTE_WH"
database = "DEV_DB"
schema = "GOLD"
"""
import streamlit as st
import pandas as pd

# Try to import snowflake connector
try:
    from snowflake.connector import connect
    SNOWFLAKE_AVAILABLE = True
except ImportError:
    SNOWFLAKE_AVAILABLE = False

st.set_page_config(page_title="Snowflake Dashboard", layout="wide")

st.title("Snowflake Gold Zone Dashboard")
st.write("Connecting to the same data warehouse used in Power BI demos!")

# ============================================================================
# SNOWFLAKE CONNECTION
# ============================================================================
if not SNOWFLAKE_AVAILABLE:
    st.warning("Snowflake connector not installed. Run: pip install snowflake-connector-python")
    st.stop()

@st.cache_resource
def get_connection():
    """Cache the Snowflake connection."""
    try:
        return connect(
            account=st.secrets["snowflake"]["account"],
            user=st.secrets["snowflake"]["user"],
            password=st.secrets["snowflake"]["password"],
            warehouse=st.secrets["snowflake"]["warehouse"],
            database=st.secrets["snowflake"]["database"],
            schema=st.secrets["snowflake"]["schema"]
        )
    except Exception as e:
        st.error(f"Connection failed: {e}")
        return None

@st.cache_data(ttl=600)  # Cache for 10 minutes
def run_query(query: str) -> pd.DataFrame:
    """Run a query and return results as DataFrame."""
    conn = get_connection()
    if conn is None:
        return pd.DataFrame()
    return pd.read_sql(query, conn)

# ============================================================================
# MAIN DASHBOARD
# ============================================================================

# Check for secrets
if "snowflake" not in st.secrets:
    st.error("Snowflake credentials not found. Create .streamlit/secrets.toml")
    st.code("""
[snowflake]
account = "xy12345.us-east-1"
user = "your_username"
password = "your_password"
warehouse = "COMPUTE_WH"
database = "DEV_DB"
schema = "GOLD"
    """)
    st.stop()

# Sidebar filters
st.sidebar.header("Filters")

# Query for filter options
year_query = "SELECT DISTINCT year FROM DIM_DATE ORDER BY year"
years_df = run_query(year_query)

if not years_df.empty:
    years = years_df["YEAR"].tolist()
    selected_year = st.sidebar.selectbox("Year", years, index=len(years)-1)
else:
    st.error("Could not load years from DIM_DATE")
    st.stop()

segment_query = "SELECT DISTINCT market_segment FROM DIM_CUSTOMER ORDER BY market_segment"
segments_df = run_query(segment_query)

if not segments_df.empty:
    segments = segments_df["MARKET_SEGMENT"].tolist()
    selected_segments = st.sidebar.multiselect("Market Segment", segments, default=segments)
else:
    selected_segments = []

# ============================================================================
# MAIN QUERIES
# ============================================================================

# Build the main query with filters
segment_filter = "'" + "','".join(selected_segments) + "'" if selected_segments else "''"

main_query = f"""
SELECT 
    d.year,
    d.quarter,
    c.market_segment,
    SUM(f.net_amount) as total_revenue,
    SUM(f.quantity) as total_quantity,
    COUNT(DISTINCT f.order_key) as order_count,
    COUNT(DISTINCT f.customer_key) as customer_count
FROM FCT_ORDER_LINES f
JOIN DIM_DATE d ON f.date_key = d.date_key
JOIN DIM_CUSTOMER c ON f.customer_key = c.customer_key
WHERE d.year = {selected_year}
  AND c.market_segment IN ({segment_filter})
GROUP BY d.year, d.quarter, c.market_segment
ORDER BY d.quarter, c.market_segment
"""

df = run_query(main_query)

# ============================================================================
# DISPLAY RESULTS
# ============================================================================

if df.empty:
    st.warning("No data returned. Check your filters and connection.")
else:
    # KPI metrics
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.metric("Total Revenue", f"${df['TOTAL_REVENUE'].sum():,.2f}")
    with col2:
        st.metric("Total Orders", f"{df['ORDER_COUNT'].sum():,}")
    with col3:
        st.metric("Unique Customers", f"{df['CUSTOMER_COUNT'].sum():,}")
    with col4:
        avg_order = df['TOTAL_REVENUE'].sum() / df['ORDER_COUNT'].sum()
        st.metric("Avg Order Value", f"${avg_order:,.2f}")
    
    st.divider()
    
    # Charts
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Revenue by Quarter")
        quarterly = df.groupby("QUARTER")["TOTAL_REVENUE"].sum()
        st.bar_chart(quarterly)
    
    with col2:
        st.subheader("Revenue by Segment")
        by_segment = df.groupby("MARKET_SEGMENT")["TOTAL_REVENUE"].sum()
        st.bar_chart(by_segment)
    
    # Data table
    st.subheader("Detailed Data")
    st.dataframe(df, use_container_width=True)
    
    # Download
    csv = df.to_csv(index=False)
    st.download_button("Download CSV", csv, "snowflake_data.csv", "text/csv")

# Footer
st.sidebar.divider()
st.sidebar.caption("Week 6 - Same GOLD zone as Power BI!")
