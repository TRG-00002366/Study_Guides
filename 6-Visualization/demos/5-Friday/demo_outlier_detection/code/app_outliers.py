"""
Streamlit Demo 4: Interactive Outlier Detection Tool
Day: Friday
Description: Z-Score and IQR outlier detection with Plotly visualization
Run: streamlit run code/app_outliers.py
Prerequisites: pip install streamlit pandas numpy plotly
"""
import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px

st.set_page_config(
    page_title="Outlier Detection Tool",
    page_icon=":mag:",
    layout="wide"
)

st.title("🔍 Outlier Detection Tool")
st.write("Detect anomalies using statistical methods with interactive threshold tuning.")

# ---------------------------------------------------------------------------
# GENERATE SAMPLE DATA (or connect to Snowflake)
# ---------------------------------------------------------------------------

st.sidebar.header("Data Configuration")

data_source = st.sidebar.radio(
    "Data Source",
    ["Sample Data (Normal Distribution)", "Custom Upload"]
)

if data_source == "Sample Data (Normal Distribution)":
    np.random.seed(42)
    n_points = st.sidebar.slider("Data Points", 100, 500, 200)
    data = np.random.normal(100, 15, n_points)
    # Inject deliberate outliers
    outlier_count = st.sidebar.slider("Injected Outliers", 2, 10, 4)
    outliers = np.random.choice([200, 210, 5, 10, 220, 0, 230, -5], outlier_count)
    data = np.append(data, outliers)
    df = pd.DataFrame({"Value": data})
else:
    uploaded_file = st.sidebar.file_uploader("Upload CSV", type="csv")
    if uploaded_file:
        df = pd.read_csv(uploaded_file)
        numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
        selected_col = st.sidebar.selectbox("Select Column", numeric_cols)
        df = pd.DataFrame({"Value": df[selected_col]})
    else:
        st.info("Please upload a CSV file with numeric data.")
        st.stop()

st.write(f"**Dataset:** {len(df)} records")

# ---------------------------------------------------------------------------
# DETECTION METHOD SELECTION
# ---------------------------------------------------------------------------

st.divider()

col_method, col_config = st.columns(2)

with col_method:
    method = st.selectbox(
        "Detection Method",
        ["Z-Score", "IQR (Interquartile Range)"]
    )

with col_config:
    if method == "Z-Score":
        threshold = st.slider(
            "Z-Score Threshold",
            1.0, 4.0, 2.0, 0.1,
            help="Values with |z-score| above this threshold are flagged as outliers"
        )
    else:
        threshold = st.slider(
            "IQR Multiplier",
            0.5, 3.0, 1.5, 0.1,
            help="Points outside Q1 - k*IQR or Q3 + k*IQR are flagged"
        )

# ---------------------------------------------------------------------------
# OUTLIER DETECTION LOGIC
# ---------------------------------------------------------------------------

if method == "Z-Score":
    mean_val = df["Value"].mean()
    std_val = df["Value"].std()
    df["z_score"] = (df["Value"] - mean_val) / std_val
    df["is_outlier"] = abs(df["z_score"]) > threshold
    metric_label = f"|Z-Score| > {threshold}"
else:
    Q1 = df["Value"].quantile(0.25)
    Q3 = df["Value"].quantile(0.75)
    IQR = Q3 - Q1
    lower = Q1 - threshold * IQR
    upper = Q3 + threshold * IQR
    df["is_outlier"] = (df["Value"] < lower) | (df["Value"] > upper)
    metric_label = f"Outside [{lower:.1f}, {upper:.1f}]"

outlier_count = df["is_outlier"].sum()
normal_count = len(df) - outlier_count

# ---------------------------------------------------------------------------
# RESULTS DISPLAY
# ---------------------------------------------------------------------------

st.divider()

# KPI Metrics
col1, col2, col3, col4 = st.columns(4)
with col1:
    st.metric("Total Records", len(df))
with col2:
    st.metric("Outliers Found", int(outlier_count))
with col3:
    st.metric("Normal Points", int(normal_count))
with col4:
    st.metric("Outlier %", f"{outlier_count / len(df) * 100:.1f}%")

# Scatter Plot with Plotly
df_plot = df.reset_index()
df_plot["Label"] = df_plot["is_outlier"].map({True: "Outlier", False: "Normal"})

fig = px.scatter(
    df_plot,
    x="index",
    y="Value",
    color="Label",
    color_discrete_map={"Outlier": "#e53935", "Normal": "#1e88e5"},
    title=f"Outlier Detection: {method} ({metric_label})",
    labels={"index": "Record Index", "Value": "Value"},
    hover_data=["Value"]
)

# Add threshold lines for IQR method
if method == "IQR (Interquartile Range)":
    fig.add_hline(y=upper, line_dash="dash", line_color="red",
                  annotation_text=f"Upper Bound ({upper:.1f})")
    fig.add_hline(y=lower, line_dash="dash", line_color="red",
                  annotation_text=f"Lower Bound ({lower:.1f})")

fig.update_layout(height=500)
st.plotly_chart(fig, use_container_width=True)

# Outlier details
if st.checkbox("Show outlier details"):
    outlier_df = df[df["is_outlier"]].copy()
    outlier_df = outlier_df.sort_values("Value", ascending=False)
    st.dataframe(outlier_df, use_container_width=True, hide_index=True)

# ---------------------------------------------------------------------------
# STATISTICS PANEL
# ---------------------------------------------------------------------------

with st.expander("View Distribution Statistics"):
    col1, col2 = st.columns(2)
    with col1:
        st.write("**Descriptive Statistics:**")
        st.dataframe(df["Value"].describe().round(2))
    with col2:
        st.write("**Distribution:**")
        fig_hist = px.histogram(
            df, x="Value", nbins=30,
            color="is_outlier",
            color_discrete_map={True: "#e53935", False: "#1e88e5"},
            title="Value Distribution"
        )
        st.plotly_chart(fig_hist, use_container_width=True)

# Footer
st.divider()
st.caption("Week 6 Visualization — Streamlit Demo 4 | Outlier Detection")
