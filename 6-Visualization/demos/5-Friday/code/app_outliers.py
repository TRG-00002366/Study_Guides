"""
Streamlit Demo 4: Outlier Detection Tool
Day: Friday
Description: Interactive outlier detection with multiple statistical methods
"""
import streamlit as st
import pandas as pd
import numpy as np

# Try to import plotly for better visualizations
try:
    import plotly.express as px
    import plotly.graph_objects as go
    PLOTLY_AVAILABLE = True
except ImportError:
    PLOTLY_AVAILABLE = False

st.set_page_config(page_title="Outlier Detection", layout="wide")

st.title("Interactive Outlier Detection Tool")
st.write("Analyze data for anomalies using statistical methods.")

# ============================================================================
# DATA GENERATION / UPLOAD
# ============================================================================

st.sidebar.header("Data Source")
data_source = st.sidebar.radio("Choose data source", ["Sample Data", "Upload CSV"])

if data_source == "Sample Data":
    # Generate sample data with outliers
    np.random.seed(42)
    n_normal = 200
    n_outliers = 10
    
    # Normal distribution
    normal_data = np.random.normal(100, 15, n_normal)
    
    # Add outliers
    outlier_data = np.concatenate([
        np.random.uniform(180, 220, n_outliers // 2),  # High outliers
        np.random.uniform(20, 40, n_outliers // 2)     # Low outliers
    ])
    
    all_data = np.concatenate([normal_data, outlier_data])
    
    df = pd.DataFrame({
        "Index": range(len(all_data)),
        "Value": all_data,
        "Category": np.random.choice(["A", "B", "C"], len(all_data))
    })
    
    st.sidebar.success(f"Loaded {len(df)} sample records with embedded outliers")

else:
    uploaded_file = st.sidebar.file_uploader("Upload CSV", type="csv")
    if uploaded_file is not None:
        df = pd.read_csv(uploaded_file)
        numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
        if not numeric_cols:
            st.error("No numeric columns found in uploaded file")
            st.stop()
        value_col = st.sidebar.selectbox("Select numeric column", numeric_cols)
        df = df.rename(columns={value_col: "Value"})
        df["Index"] = range(len(df))
    else:
        st.info("Please upload a CSV file or use sample data")
        st.stop()

# ============================================================================
# OUTLIER DETECTION CONFIGURATION
# ============================================================================

st.sidebar.header("Detection Settings")

method = st.sidebar.selectbox(
    "Detection Method",
    ["Z-Score", "IQR (Interquartile Range)", "Modified Z-Score"]
)

if method == "Z-Score":
    threshold = st.sidebar.slider("Z-Score Threshold", 1.0, 4.0, 2.5, 0.1)
    st.sidebar.caption("Values with |z| > threshold are outliers")
    
elif method == "IQR (Interquartile Range)":
    threshold = st.sidebar.slider("IQR Multiplier", 1.0, 3.0, 1.5, 0.1)
    st.sidebar.caption("Values outside Q1 - k*IQR or Q3 + k*IQR are outliers")
    
else:  # Modified Z-Score
    threshold = st.sidebar.slider("Modified Z-Score Threshold", 2.0, 5.0, 3.5, 0.1)
    st.sidebar.caption("Uses median absolute deviation (MAD) - more robust")

# ============================================================================
# OUTLIER DETECTION LOGIC
# ============================================================================

def detect_outliers_zscore(data, threshold):
    """Z-Score method: outliers have |z| > threshold"""
    mean = data.mean()
    std = data.std()
    z_scores = (data - mean) / std
    return abs(z_scores) > threshold, z_scores

def detect_outliers_iqr(data, multiplier):
    """IQR method: outliers are outside Q1 - k*IQR and Q3 + k*IQR"""
    Q1 = data.quantile(0.25)
    Q3 = data.quantile(0.75)
    IQR = Q3 - Q1
    lower_bound = Q1 - multiplier * IQR
    upper_bound = Q3 + multiplier * IQR
    return (data < lower_bound) | (data > upper_bound), (lower_bound, upper_bound)

def detect_outliers_modified_zscore(data, threshold):
    """Modified Z-Score using MAD (Median Absolute Deviation)"""
    median = data.median()
    mad = np.median(np.abs(data - median))
    if mad == 0:
        mad = 1e-6  # Avoid division by zero
    modified_z = 0.6745 * (data - median) / mad
    return abs(modified_z) > threshold, modified_z

# Apply selected method
if method == "Z-Score":
    df["is_outlier"], df["score"] = detect_outliers_zscore(df["Value"], threshold)
    score_label = "Z-Score"
elif method == "IQR (Interquartile Range)":
    df["is_outlier"], bounds = detect_outliers_iqr(df["Value"], threshold)
    df["score"] = 0  # IQR doesn't produce a score
    score_label = "IQR"
else:
    df["is_outlier"], df["score"] = detect_outliers_modified_zscore(df["Value"], threshold)
    score_label = "Modified Z-Score"

# ============================================================================
# RESULTS DISPLAY
# ============================================================================

# Summary metrics
col1, col2, col3, col4 = st.columns(4)

with col1:
    st.metric("Total Records", len(df))
with col2:
    outlier_count = df["is_outlier"].sum()
    st.metric("Outliers Found", outlier_count)
with col3:
    pct = (outlier_count / len(df)) * 100
    st.metric("Outlier %", f"{pct:.1f}%")
with col4:
    st.metric("Method", method)

st.divider()

# Visualization
if PLOTLY_AVAILABLE:
    st.subheader("Outlier Visualization")
    
    fig = px.scatter(
        df,
        x="Index",
        y="Value",
        color="is_outlier",
        color_discrete_map={True: "red", False: "blue"},
        title=f"Data Points with Outliers Highlighted ({method})",
        labels={"is_outlier": "Is Outlier"}
    )
    
    # Add threshold lines for IQR method
    if method == "IQR (Interquartile Range)":
        fig.add_hline(y=bounds[0], line_dash="dash", line_color="orange", 
                      annotation_text=f"Lower: {bounds[0]:.2f}")
        fig.add_hline(y=bounds[1], line_dash="dash", line_color="orange",
                      annotation_text=f"Upper: {bounds[1]:.2f}")
    
    st.plotly_chart(fig, use_container_width=True)
    
    # Distribution plot
    col1, col2 = st.columns(2)
    
    with col1:
        fig_hist = px.histogram(df, x="Value", color="is_outlier", 
                                title="Value Distribution",
                                color_discrete_map={True: "red", False: "blue"})
        st.plotly_chart(fig_hist, use_container_width=True)
    
    with col2:
        fig_box = px.box(df, y="Value", title="Box Plot")
        st.plotly_chart(fig_box, use_container_width=True)
else:
    # Fallback to basic Streamlit charts
    st.subheader("Outlier Visualization")
    st.scatter_chart(df, x="Index", y="Value", color="is_outlier")

# Outlier details
st.subheader("Outlier Details")
if st.checkbox("Show outlier records"):
    outliers_df = df[df["is_outlier"]][["Index", "Value", "score" if method != "IQR (Interquartile Range)" else "Value"]]
    st.dataframe(outliers_df, use_container_width=True)

# Statistics
st.subheader("Data Statistics")
col1, col2 = st.columns(2)

with col1:
    st.write("**All Data**")
    st.write(df["Value"].describe())

with col2:
    st.write("**Excluding Outliers**")
    st.write(df[~df["is_outlier"]]["Value"].describe())

# Footer
st.divider()
st.caption("Week 6 Visualization - Statistical Outlier Detection Demo")
