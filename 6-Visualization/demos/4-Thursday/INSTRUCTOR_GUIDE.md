# Instructor Guide: Thursday Demos

## Overview
**Day:** 4-Thursday - Dashboards, Refresh, and Production Operations (Pair Programming Day)
**Total Demo Time:** ~45 minutes
**Prerequisites:** Wednesday demos completed, complete Power BI report built

---

## Demo 1: Publishing to Power BI Service

**Time:** ~15 minutes

### Phase 1: Prepare for Publishing (3 mins)
1. Review the completed report
2. Verify all measures work correctly
3. Save the .pbix file
4. "Always save before publishing - published version comes from saved file"

### Phase 2: Publish the Report (5 mins)
1. Click **Home** > **Publish**
2. Sign in with Power BI account (if prompted)
3. Select a workspace (or create "Training Workspace")
4. Click **Select**
5. Wait for publish completion
6. Click the link to open in Power BI Service

### Phase 3: Create a Dashboard (7 mins)

**In Power BI Service (browser):**

1. Open the published report
2. Pin visuals to dashboard:
   - Hover over Total Revenue card > **Pin** icon
   - Select **New dashboard** > Name it "Sales Dashboard"
   - Repeat for other key visuals

3. Open the dashboard
   - Demonstrate tile rearrangement (drag and drop)
   - "Dashboards are single-page, high-level views"

4. Configure a Data Alert:
   - Click the Revenue card tile
   - Click **...** > **Manage alerts**
   - **Add alert rule**:
     - Condition: Above
     - Threshold: 5000000
   - "Alerts notify when business thresholds are crossed"

### Key Talking Points
- "Reports have pages and interactivity; dashboards are single-page summaries"
- "Pin the most important visuals to dashboards"
- "Executives often view only dashboards, not full reports"

---

## Demo 2: Scheduled Refresh Configuration

**Time:** ~15 minutes

### Phase 1: Dataset Settings (5 mins)

**In Power BI Service:**

1. Navigate to **Workspaces** > Training Workspace
2. Click the **Dataset** (not the report)
3. Click **...** > **Settings**

4. Expand **Data source credentials**:
   - Click **Edit credentials** for Snowflake
   - Enter Snowflake username/password
   - "Credentials must be stored for scheduled refresh"

### Phase 2: Configure Schedule (5 mins)
1. Expand **Scheduled refresh**
2. Toggle **Keep your data up to date** to ON
3. Configure:
   - Refresh frequency: Daily
   - Time zone: Select appropriate zone
   - Time: Add refresh time (e.g., 6:00 AM)
4. Add notification email for failures
5. Click **Apply**

**Explain refresh limits:**
- Pro license: 8 refreshes per day
- Premium: 48 refreshes per day

### Phase 3: On-Demand Refresh and History (5 mins)
1. Click **Refresh now** to trigger manual refresh
2. Wait for completion (or show in-progress status)
3. Click **Refresh history**
4. Show:
   - Duration
   - Status (success/failure)
   - "Always monitor for failures"

### Key Talking Points
- "Refresh keeps Import mode data current"
- "DirectQuery doesn't need refresh - queries are real-time"
- "Gateway required for on-premises data sources"
- "This connects to your Airflow pipelines - refresh after ETL completes"

---

## Demo 3: Row-Level Security (RLS)

**Time:** ~15 minutes

### Phase 1: Why RLS Matters (3 mins)

**Scenario:**
"Imagine sales managers should only see data for their region. Without RLS, everyone sees everything. With RLS, each user sees only their data - from the same report."

### Phase 2: Create RLS Role in Desktop (7 mins)

1. Open Power BI Desktop with the report
2. Go to **Modeling** > **Manage roles**
3. Click **Create**
4. Name the role: "Market Segment Filter"

5. Select `DIM_CUSTOMER` table
6. Enter DAX filter expression:
   ```dax
   [market_segment] = "AUTOMOBILE"
   ```
7. Click **Save**

**Test the role:**
8. **Modeling** > **View as**
9. Check "Market Segment Filter" role
10. Click **OK**
11. Navigate report - all data now filtered to AUTOMOBILE
12. Click **Stop viewing**

### Phase 3: Publish and Assign (5 mins)

1. **Publish** the updated report
2. In Power BI Service:
   - Go to Dataset > **...** > **Security**
   - Select the role
   - Add members (email addresses)
   - "Members see only data allowed by their role filter"

**Advanced Pattern (explain verbally):**
```dax
// Dynamic RLS based on login
[market_segment] = LOOKUPVALUE(
    UserTable[market_segment],
    UserTable[email],
    USERPRINCIPALNAME()
)
```

### Key Talking Points
- "RLS is essential for multi-tenant reports"
- "Filter is applied automatically at query time"
- "Users can't bypass RLS - it's enforced server-side"
- "Combine with Snowflake RLS for defense in depth"

---

## Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Publish fails | Check Power BI account, workspace permissions |
| Refresh fails with credential error | Re-enter data source credentials |
| Dashboard tile shows stale data | Trigger manual refresh, check schedule |
| RLS not filtering | Verify role is assigned to user in Service |
| "Gateway required" error | Cloud sources like Snowflake don't need gateway |

---

## Pair Programming Introduction

After the demos, trainees work in pairs on the `pair_exercise_dashboard`:

**Driver/Navigator Roles:**
- **Driver**: Writes the code/configuration
- **Navigator**: Reviews, suggests improvements, references docs

**Rotation Points:**
1. First rotation: After data modeling complete
2. Second rotation: After measures created

**Instructor Role During Pair Work:**
- Circulate and observe
- Answer questions
- Note common issues for recap

---

## Transition to Friday

"Today we covered the production side of Power BI. Tomorrow we shift to:
1. Streamlit - Python-native dashboards
2. Connecting Streamlit to the same Snowflake gold zone
3. Building interactive data apps without enterprise BI tools"

---

## Required Reading Reference

Before this demo, trainees should have read:
- `data-alerts-dashboard.md` - Dashboard creation
- `dataset-refresh.md` - Refresh strategies
- `power-bi-service.md` - Service features and RLS
