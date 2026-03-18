"""
Streamlit Demo 2: Multi-Page Dashboard
Day: Friday
Description: Dashboard with sidebar navigation, metrics, and charts
"""
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

# Generate sample data
np.random.seed(42)
dates = pd.date_range("2024-01-01", periods=365, freq="D")
sales_data = pd.DataFrame({
    "Date": dates,
    "Revenue": np.random.uniform(8000, 15000, 365),
    "Orders": np.random.randint(50, 150, 365),
    "Region": np.random.choice(["North", "South", "East", "West"], 365)
})

# ============================================================================
# OVERVIEW PAGE
# ============================================================================
if page == "Overview":
    st.title("Sales Overview Dashboard")
    st.write("High-level metrics and trends for the business.")
    
    # KPI row using columns
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        total_rev = sales_data["Revenue"].sum()
        st.metric("Total Revenue", f"${total_rev:,.0f}", "+12%")
    with col2:
        total_orders = sales_data["Orders"].sum()
        st.metric("Orders", f"{total_orders:,}", "+5%")
    with col3:
        customers = 2103  # Simulated
        st.metric("Customers", f"{customers:,}", "+8%")
    with col4:
        avg_order = total_rev / total_orders
        st.metric("Avg Order", f"${avg_order:.2f}", "-2%")
    
    st.divider()
    
    # Charts row
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Revenue Trend")
        monthly = sales_data.groupby(sales_data["Date"].dt.month)["Revenue"].sum()
        st.line_chart(monthly)
    
    with col2:
        st.subheader("Revenue by Region")
        by_region = sales_data.groupby("Region")["Revenue"].sum()
        st.bar_chart(by_region)

# ============================================================================
# DETAILS PAGE
# ============================================================================
elif page == "Details":
    st.title("Detailed Data View")
    
    # Filters
    st.subheader("Filters")
    col1, col2 = st.columns(2)
    
    with col1:
        regions = st.multiselect(
            "Select Regions", 
            sales_data["Region"].unique(),
            default=sales_data["Region"].unique()
        )
    with col2:
        date_range = st.date_input(
            "Date Range",
            value=(sales_data["Date"].min(), sales_data["Date"].max())
        )
    
    # Filter data
    filtered = sales_data[
        (sales_data["Region"].isin(regions)) &
        (sales_data["Date"] >= pd.Timestamp(date_range[0])) &
        (sales_data["Date"] <= pd.Timestamp(date_range[1]))
    ]
    
    st.subheader(f"Filtered Data ({len(filtered)} records)")
    st.dataframe(filtered, use_container_width=True)
    
    # Download button
    csv = filtered.to_csv(index=False)
    st.download_button(
        "Download CSV",
        csv,
        "filtered_data.csv",
        "text/csv"
    )

# ============================================================================
# TRENDS PAGE
# ============================================================================
elif page == "Trends":
    st.title("Trend Analysis")
    
    # Metric selection
    metric = st.selectbox("Select Metric", ["Revenue", "Orders"])
    
    # Rolling average
    window = st.slider("Rolling Average Window (days)", 7, 30, 14)
    
    # Calculate rolling average
    sales_data["Rolling"] = sales_data[metric].rolling(window=window).mean()
    
    # Chart
    st.subheader(f"{metric} with {window}-Day Rolling Average")
    chart_data = sales_data[["Date", metric, "Rolling"]].set_index("Date")
    st.line_chart(chart_data)
    
    # Statistics
    st.subheader("Summary Statistics")
    col1, col2, col3 = st.columns(3)
    with col1:
        st.metric("Mean", f"{sales_data[metric].mean():,.2f}")
    with col2:
        st.metric("Median", f"{sales_data[metric].median():,.2f}")
    with col3:
        st.metric("Std Dev", f"{sales_data[metric].std():,.2f}")

# Footer
st.sidebar.divider()
st.sidebar.caption("Week 6 Visualization - Streamlit Demo 2")
