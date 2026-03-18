# Demo: Interactive Outlier Detection Tool

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 5-Friday |
| **Topic** | Statistical Outlier Detection with Visualization |
| **Type** | Hybrid (Concept + Code) |
| **Time** | ~10 minutes |
| **Prerequisites** | Streamlit basics, Plotly installed (`pip install plotly`) |

**Weekly Epic:** *Data Storytelling — From Warehouse to Insight with Power BI and Streamlit*

---

## Phase 1: The Concept (Diagram)

**Time:** 3 mins

1. Open `diagrams/outlier-methods-comparison.mermaid`
2. Explain the two detection methods:
   - **Z-Score** — How many standard deviations from the mean. Good for normally distributed data.
   - **IQR** — Based on interquartile range (Q1, Q3). More robust to skewed data.
3. *"Outlier detection is a key data quality tool — catches errors, fraud, and anomalies."*

---

## Phase 2: The Code (Live Implementation)

**Time:** 7 mins

### Step 1: Build the Detection Tool (4 mins)

Open `code/app_outliers.py` and walk through:

```python
# Method selection — user picks the algorithm
method = st.selectbox(
    "Detection Method",
    ["Z-Score", "IQR (Interquartile Range)"]
)

# Threshold — user adjusts sensitivity
threshold = st.slider("Threshold", 1.0, 4.0, 2.0, 0.1)
```

**Z-Score logic:**
```python
df["z_score"] = (df["Value"] - df["Value"].mean()) / df["Value"].std()
df["is_outlier"] = abs(df["z_score"]) > threshold
```

**IQR logic:**
```python
Q1 = df["Value"].quantile(0.25)
Q3 = df["Value"].quantile(0.75)
IQR = Q3 - Q1
lower = Q1 - threshold * IQR
upper = Q3 + threshold * IQR
df["is_outlier"] = (df["Value"] < lower) | (df["Value"] > upper)
```

### Step 2: Visualize with Plotly (3 mins)

```python
fig = px.scatter(
    df, x="index", y="Value",
    color="is_outlier",
    color_discrete_map={True: "red", False: "blue"},
    title=f"Outlier Detection: {method}"
)
st.plotly_chart(fig, use_container_width=True)
```

*"Interactive — users can adjust threshold and instantly see which points are outliers."*

**Run:** `streamlit run code/app_outliers.py`

---

## Key Talking Points

- "Interactive analysis tools in minutes, not days"
- "Users can adjust parameters and see results instantly — that's the Streamlit advantage"
- "Plotly integration gives rich, zoomable visualizations"
- "This pattern works for any anomaly detection: network traffic, sensor data, financial transactions"

---

## Required Reading Reference

Before this demo, trainees should have read:
- `detecting-outliers.md` — Statistical methods (IQR, Z-score)
