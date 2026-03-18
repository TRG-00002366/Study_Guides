# Demo: Scheduled Refresh Configuration

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 4-Thursday |
| **Topic** | Dataset Refresh and Monitoring |
| **Type** | Hybrid (Concept + Implementation) |
| **Time** | ~15 minutes |
| **Prerequisites** | Report published to Power BI Service (Demo 1 complete) |

**Weekly Epic:** *Data Storytelling — From Warehouse to Insight with Power BI and Streamlit*

---

## Phase 1: The Concept (Diagram)

**Time:** 4 mins

1. Open `diagrams/refresh-architecture.mermaid`
2. Explain refresh flow:
   - Cloud sources (Snowflake) → direct refresh, no gateway needed
   - On-premises sources → require Data Gateway
3. Open `diagrams/WHITEBOARD_PLAN.md` — draw the ETL→Refresh→Dashboard timeline
4. *"This connects to your Airflow pipelines — schedule refresh AFTER ETL completes"*

---

## Phase 2: The Code (Live Implementation)

**Time:** 11 mins

### Step 1: Dataset Settings (4 mins)

**In Power BI Service:**

1. Navigate to **Workspaces** > Training Workspace
2. Click the **Dataset** (not the report)
3. Click **...** > **Settings**
4. Expand **Data source credentials:**
   - Click **Edit credentials** for Snowflake
   - Enter Snowflake username/password
   - *"Credentials must be stored for scheduled refresh"*

### Step 2: Configure Schedule (4 mins)
1. Expand **Scheduled refresh**
2. Toggle **Keep your data up to date** to ON
3. Configure:
   - Refresh frequency: Daily
   - Time zone: Select appropriate zone
   - Time: Add refresh time (e.g., 6:00 AM)
4. Add notification email for failures
5. Click **Apply**

**Explain refresh limits:**
| License | Max Refreshes/Day |
|---------|------------------|
| Pro | 8 |
| Premium Per User | 48 |
| Premium Capacity | 48 |

### Step 3: On-Demand Refresh and History (3 mins)
1. Click **Refresh now** to trigger manual refresh
2. Wait for completion (or show in-progress status)
3. Click **Refresh history**
4. Show: Duration, Status (success/failure)
5. *"Always monitor for failures — stale data is worse than no data"*

---

## Key Talking Points

- "Refresh keeps Import mode data current — DirectQuery doesn't need it"
- "Gateway required for on-premises sources, NOT for cloud (Snowflake)"
- "Coordinate refresh schedule with upstream ETL pipelines (Airflow)"
- "Monitor refresh history — failures mean dashboards show stale data"

---

## Required Reading Reference

Before this demo, trainees should have read:
- `dataset-refresh.md` — Refresh strategies, gateways, monitoring
