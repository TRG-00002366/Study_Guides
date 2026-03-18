# Demo: Publishing to Power BI Service and Creating Dashboards

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 4-Thursday |
| **Topic** | Publishing, Dashboards, and Data Alerts |
| **Type** | Hybrid (Concept + Implementation) |
| **Time** | ~15 minutes |
| **Prerequisites** | Complete Power BI report built (Wednesday) |

**Weekly Epic:** *Data Storytelling — From Warehouse to Insight with Power BI and Streamlit*

---

## Phase 1: The Concept (Diagram)

**Time:** 3 mins

1. Open `diagrams/publish-flow.mermaid`
2. Walk through the publish pipeline: Desktop → Service → Dashboard
3. Open `diagrams/dashboard-vs-report.mermaid`
4. Explain the key difference:
   - **Reports** — Multi-page, interactive, detailed analysis
   - **Dashboards** — Single-page, high-level, pinned from multiple reports

> **Analogy:** *"Reports are full newspaper articles. Dashboards are the front-page headlines."*

---

## Phase 2: The Code (Live Implementation)

**Time:** 12 mins

### Step 1: Prepare and Publish (4 mins)
1. Review the completed report — verify all measures work
2. Save the .pbix file
3. Click **Home** > **Publish**
4. Sign in with Power BI account (if prompted)
5. Select a workspace (or create "Training Workspace")
6. Click **Select** and wait for completion
7. Click the link to open in Power BI Service

### Step 2: Create a Dashboard (5 mins)

**In Power BI Service (browser):**

1. Open the published report
2. Pin visuals to dashboard:
   - Hover over Total Revenue card > **Pin** icon
   - Select **New dashboard** > Name it "Sales Dashboard"
   - Repeat for other key visuals (trend chart, segment pie)
3. Open the dashboard:
   - Demonstrate tile rearrangement (drag and drop)
   - *"Dashboards are single-page, high-level views"*

### Step 3: Configure a Data Alert (3 mins)
1. Click the Revenue card tile on the dashboard
2. Click **...** > **Manage alerts**
3. **Add alert rule:**
   - Condition: Above
   - Threshold: 5000000
   - Notification: Email
4. *"Alerts notify when business thresholds are crossed"*

---

## Key Talking Points

- "Reports have pages and interactivity; dashboards are single-page summaries"
- "Pin the most important visuals to dashboards"
- "Executives often view only dashboards — make them count"
- "Data alerts provide proactive monitoring without manual checking"

---

## Required Reading Reference

Before this demo, trainees should have read:
- `data-alerts-dashboard.md` — Dashboard creation and alerts
