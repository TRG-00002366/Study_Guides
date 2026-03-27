# Demo: Snowflake RBAC — Role-Based Access Control

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 3-Wednesday |
| **Topic** | Implementing RBAC in Snowflake |
| **Type** | Code (Implementation) |
| **Time** | ~25 minutes |
| **Prerequisites** | Snowflake basics from Week 5; ACCOUNTADMIN access |

**Weekly Epic:** *Operationalizing Data Excellence — DataOps, Quality, and Governance*

---

## Phase 1: The Concept (Diagram)

**Time:** 5 mins

1. Open `diagrams/rbac-hierarchy.mermaid`
2. Start from the top:
   - *"ACCOUNTADMIN is God mode. You should NEVER use it for daily work."*
   - *"SECURITYADMIN manages users and roles. SYSADMIN manages databases and warehouses."*
3. Walk through the functional roles:
   - DATA_ENGINEER → all domain access (builds pipelines everywhere)
   - DATA_ANALYST → customer + product (no finance)
   - DATA_SCIENTIST → inherits from analyst (plus ML resources)
   - BUSINESS_USER → limited, curated views only
4. Walk through domain roles:
   - FINANCE_READ, CUSTOMER_READ, PRODUCT_READ
   - *"These are the building blocks. Functional roles are assembled FROM domain roles."*

> **Key Point:** *"Never grant to users directly. Always use roles. If Alice leaves, you just revoke the role — not 50 individual grants."*

---

## Phase 2: The Code (Live in Snowsight)

**Time:** 20 mins

### Step 1: Create Roles (3 mins)
1. Open `code/rbac_setup.sql`
2. Run Steps 1-2 (create roles + hierarchy):
   ```sql
   USE ROLE SECURITYADMIN;
   CREATE ROLE IF NOT EXISTS DATA_ENGINEER;
   ```
3. *"We create with SECURITYADMIN — the role responsible for access management."*

### Step 2: Build the Hierarchy (4 mins)
1. Run the GRANT ROLE statements
2. *"When we grant FINANCE_READ to DATA_ENGINEER, the engineer inherits all finance permissions."*
3. Draw the hierarchy on whiteboard to match the diagram

### Step 3: Set Up Warehouses (3 mins)
1. Run Step 3 (create warehouses)
2. *"Different sizes for different workloads. Analysts get XSMALL; engineers get SMALL."*
3. *"AUTO_SUSPEND saves money — the warehouse sleeps after 60 seconds of inactivity."*

### Step 4: Grant Schema & Table Access (5 mins)
1. Run Steps 4-6
2. Highlight FUTURE TABLES:
   ```sql
   GRANT SELECT ON FUTURE TABLES IN SCHEMA ... TO ROLE ...;
   ```
   - *"Without this, new tables created tomorrow won't be accessible. FUTURE TABLES is critical."*
3. Highlight engineer write access to STAGING only

### Step 5: Test Access (5 mins)
1. Open `code/rbac_test.sql`
2. Switch to DATA_ANALYST:
   - Run customer query → ✅ SUCCESS
   - Run finance query → ❌ FAIL
   - *"Alice can see customers but NOT finance. That's the principle of least privilege in action."*
3. Switch to DATA_ENGINEER:
   - Run finance query → ✅ SUCCESS
   - *"Bob can see everything because engineers need full access to build pipelines."*
4. Run the SHOW GRANTS queries:
   - *"This is how you audit access. In a real organization, you'd review these quarterly."*

---

## Key Talking Points

- "Never use ACCOUNTADMIN for routine work — it's the nuclear option"
- "GRANT ON FUTURE TABLES is the most commonly forgotten step"
- "Roles are composable: ANALYST = CUSTOMER_READ + PRODUCT_READ"
- "Principle of least privilege: start with nothing, add what's needed"
- Bridge to Tuesday: "Lineage tells you WHERE data flows. RBAC controls WHO can access it."
- Bridge to Week 5: "Remember your Snowflake setup? Now you understand the roles behind it."

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| "Object does not exist" error | Missing USAGE grant on database or schema |
| User can't see new tables | Forgot GRANT ON FUTURE TABLES |
| Can't create roles | Must use SECURITYADMIN or ACCOUNTADMIN |
| Role hierarchy not inherited | Verify GRANT ROLE child TO ROLE parent |

---

## Required Reading Reference

Before this demo, trainees should have read:
- `rbac-data-warehouses.md` — RBAC concepts, Snowflake access model, role hierarchies, best practices
