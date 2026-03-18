"""
Streamlit Demo 2: Multi-Page Dashboard
Day: Friday
Description: Dashboard with sidebar navigation, KPI metrics, and interactive filters
Run: streamlit run code/app_dashboard.py
"""
import streamlit as st
import pandas as pd
import numpy as np

# Page configuration — MUST be first Streamlit command
st.set_page_config(
    page_title="Analytics Dashboard",
    page_icon=":bar_chart:",
    layout="wide"
)

# Sidebar navigation
st.sidebar.title("Navigation")
page = st.sidebar.radio("Go to", ["Overview", "Details", "Trends"])

# --- PAGE: Overview ---
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

    st.divider()

    # Filter section
    st.subheader("Filters")
    col1, col2 = st.columns(2)
    with col1:
        year = st.selectbox("Year", [2023, 2024, 2025])
    with col2:
        region = st.multiselect(
            "Region",
            ["North", "South", "East", "West"],
            default=["North", "South", "East", "West"]
        )

    # Filtered chart
    st.subheader("Monthly Sales by Region")
    months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
              "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    if region:
        np.random.seed(year)  # Consistent data per year
        chart_data = pd.DataFrame(
            np.random.randint(50, 200, size=(12, len(region))),
            columns=region,
            index=months
        )
        st.line_chart(chart_data)
    else:
        st.warning("Please select at least one region.")

# --- PAGE: Details ---
elif page == "Details":
    st.title("Detailed Data View")

    # Generate sample data
    np.random.seed(42)
    detail_data = pd.DataFrame({
        "Customer": [f"Customer {i}" for i in range(1, 21)],
        "Region": np.random.choice(["North", "South", "East", "West"], 20),
        "Revenue": np.random.randint(1000, 50000, 20),
        "Orders": np.random.randint(1, 100, 20),
    })

    # Sortable, searchable table
    st.dataframe(detail_data, use_container_width=True)

    # Download button
    csv = detail_data.to_csv(index=False)
    st.download_button(
        "Download CSV",
        csv,
        "customer_data.csv",
        "text/csv"
    )

# --- PAGE: Trends ---
elif page == "Trends":
    st.title("Revenue Trends")

    # Year selector
    years = st.slider("Year Range", 2020, 2025, (2022, 2025))

    # Generate trend data
    np.random.seed(0)
    trend_data = pd.DataFrame({
        "Year": range(years[0], years[1] + 1),
        "Revenue": np.cumsum(np.random.randint(100, 500, years[1] - years[0] + 1)) + 5000,
        "Costs": np.cumsum(np.random.randint(50, 300, years[1] - years[0] + 1)) + 3000,
    })
    trend_data = trend_data.set_index("Year")

    st.area_chart(trend_data)

    with st.expander("View Raw Data"):
        st.dataframe(trend_data)

# Footer
st.divider()
st.caption("Week 6 Visualization — Streamlit Demo 2")
