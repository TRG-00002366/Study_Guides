# Demo: Row-Level Security (RLS) — Data Access Control

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 4-Thursday |
| **Topic** | Row-Level Security in Power BI |
| **Type** | Hybrid (Concept + Code) |
| **Time** | ~15 minutes |
| **Prerequisites** | Report published to Power BI Service |

**Weekly Epic:** *Data Storytelling — From Warehouse to Insight with Power BI and Streamlit*

---

## Phase 1: The Concept (Diagram)

**Time:** 3 mins

1. Open `diagrams/rls-architecture.mermaid`
2. Explain the scenario:
   - *"Imagine sales managers should only see data for their region. Without RLS, everyone sees everything. With RLS, each user sees only their data — from the same report."*
3. Walk through the flow:
   - Define roles in Desktop → Publish → Assign users in Service → Filter enforced at query time

> **Key Point:** *"Users can't bypass RLS — it's enforced server-side by Power BI."*

---

## Phase 2: The Code (Live Implementation)

**Time:** 12 mins

### Step 1: Create RLS Role in Desktop (5 mins)
1. Open Power BI Desktop with the report
2. Go to **Modeling** > **Manage roles**
3. Click **Create**
4. Name the role: "Market Segment Filter"
5. Select `DIM_CUSTOMER` table
6. Enter DAX filter expression (reference `code/dax_rls_patterns.txt`):
   ```dax
   [market_segment] = "AUTOMOBILE"
   ```
7. Click **Save**

### Step 2: Test the Role (3 mins)
1. **Modeling** > **View as**
2. Check "Market Segment Filter" role
3. Click **OK**
4. Navigate the report — all data now filtered to AUTOMOBILE segment
5. *"Every chart, every measure, every visual — all filtered automatically"*
6. Click **Stop viewing**

### Step 3: Publish and Assign (4 mins)
1. **Publish** the updated report
2. In Power BI Service:
   - Go to Dataset > **...** > **Security**
   - Select the role
   - Add members (email addresses)
   - *"Members see only data allowed by their role filter"*

**Advanced Pattern** (explain verbally):
```dax
// Dynamic RLS based on login
[market_segment] = LOOKUPVALUE(
    UserTable[market_segment],
    UserTable[email],
    USERPRINCIPALNAME()
)
```
*"Dynamic RLS uses USERPRINCIPALNAME() to auto-filter based on who's logged in — no manual role assignment per user needed."*

---

## Key Talking Points

- "RLS is essential for multi-tenant reports"
- "Filter is applied automatically at query time — zero performance overhead"
- "Combine with Snowflake RLS for defense in depth"
- "Static RLS = hardcoded values; Dynamic RLS = user-based lookup"

---

## Required Reading Reference

Before this demo, trainees should have read:
- `power-bi-service.md` — Service features, sharing, RLS
