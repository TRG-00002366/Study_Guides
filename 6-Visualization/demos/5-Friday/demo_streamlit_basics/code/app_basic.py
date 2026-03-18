"""
Streamlit Demo 1: Basic App
Day: Friday
Description: Hello World app demonstrating basic Streamlit components
Run: streamlit run code/app_basic.py
"""
import streamlit as st
import pandas as pd

# Page title
st.title("Hello, Streamlit!")
st.write("This is my first Streamlit app — built in just a few lines of Python.")

# Divider
st.divider()

# Text input for interactivity
st.subheader("Interactive Greeting")
name = st.text_input("Enter your name")
if name:
    st.write(f"Welcome, {name}! You are now a Streamlit developer.")

# Divider
st.divider()

# Sample data display
st.subheader("Sample Data Display")

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
st.subheader("Sales by Product")
st.bar_chart(df.set_index("Product")["Sales"])

# Footer
st.divider()
st.caption("Week 6 Visualization — Streamlit Demo 1")
