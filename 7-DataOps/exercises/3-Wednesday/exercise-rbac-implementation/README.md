# Exercise: RBAC Implementation for a Marketing Warehouse

## Overview
**Day:** 3-Wednesday
**Duration:** 2-3 hours
**Mode:** Individual (Implementation)
**Prerequisites:** RBAC demo completed; Snowflake access with SECURITYADMIN

---

## Required Reading

Before starting this exercise, review the following content:

| Topic | File | Focus Areas |
|-------|------|-------------|
| RBAC in Data Warehouses | [rbac-data-warehouses.md](../../content/3-Wednesday/rbac-data-warehouses.md) | Role hierarchies, grants, best practices |

---

## Learning Objectives
By the end of this exercise, you will be able to:
1. Design a role hierarchy from business requirements
2. Implement roles, grants, and user assignments in Snowflake
3. Use FUTURE TABLES to secure new objects automatically
4. Test access controls by switching roles
5. Audit role configurations using SHOW GRANTS

---

## The Scenario

**MarketPulse** is a marketing analytics company. They have 4 user types with different data needs:

| User Type | Needs Access To | Can Write To |
|-----------|----------------|--------------|
| **Marketing Admin** | All data (campaigns, customers, revenue) | All schemas |
| **Campaign Manager** | Campaigns + customer demographics | Campaign reports schema |
| **Data Analyst** | Aggregated campaign metrics, customer segments | Nothing (read-only) |
| **External Partner** | Campaign summary views only (no PII) | Nothing |

The warehouse has these schemas:
- `MARKETING_DB.CAMPAIGNS` — campaign details, ad spend, performance
- `MARKETING_DB.CUSTOMERS` — customer demographics, segments, PII
- `MARKETING_DB.REVENUE` — revenue attribution, conversion data
- `MARKETING_DB.REPORTS` — pre-built aggregate views for reporting

---

## Core Tasks

### Task 1: Design the Role Hierarchy (20 mins)

Before writing any SQL, design your role hierarchy on paper:

1. Identify the functional roles (match the 4 user types)
2. Identify domain roles (based on schema access patterns)
3. Draw the hierarchy showing which roles inherit from others
4. Verify the principle of least privilege is respected

**Checkpoint:** Role hierarchy diagram drawn with all relationships.

---

### Task 2: Implement RBAC in Snowflake (60 mins)

1. Open `starter_code/rbac_scaffold.sql`
2. Complete the implementation:
   - Create all functional and domain roles
   - Build the hierarchy with GRANT ROLE statements
   - Create appropriate warehouses
   - Create the database and schemas
   - Grant USAGE, SELECT, and (where needed) INSERT/UPDATE on schemas
   - Include FUTURE TABLES grants

**Critical:** Follow the hierarchy you designed in Task 1.

**Checkpoint:** All roles, grants, and warehouses created without errors.

---

### Task 3: Test Access Controls (30 mins)

For each role, run test queries and document results:

```sql
USE ROLE [role_name];
SELECT * FROM MARKETING_DB.CAMPAIGNS.CAMPAIGN_DETAILS LIMIT 3;
SELECT * FROM MARKETING_DB.CUSTOMERS.CUSTOMER_PROFILES LIMIT 3;
SELECT * FROM MARKETING_DB.REVENUE.REVENUE_ATTRIBUTION LIMIT 3;
```

Fill in the results matrix:

| Role | Campaigns | Customers | Revenue | Reports | Write to Reports |
|------|-----------|-----------|---------|---------|-----------------|
| Marketing Admin | | | | | |
| Campaign Manager | | | | | |
| Data Analyst | | | | | |
| External Partner | | | | | |

**Checkpoint:** Results match the requirements table.

---

### Task 4: Audit and Document (30 mins)

1. Run `SHOW GRANTS TO ROLE [each_role]` and capture the output
2. Create a summary showing the complete grant chain for each role
3. Verify no role has more access than intended
4. Document any issues found and how you resolved them

**Checkpoint:** Complete audit trail documented.

---

## Deliverables

Submit the following:

1. **Role hierarchy diagram** (hand-drawn or Mermaid)
2. **Completed SQL** (`rbac_scaffold.sql` with all grants)
3. **Test results matrix** (4 roles × 5 resources)
4. **Audit documentation** (SHOW GRANTS output summary)

---

## Definition of Done

- [ ] Role hierarchy designed before coding
- [ ] 4+ functional roles created
- [ ] Domain roles created for schema isolation
- [ ] Hierarchy built with GRANT ROLE
- [ ] FUTURE TABLES grants included
- [ ] All 4 roles tested with documented results
- [ ] No role has excess privileges
- [ ] SHOW GRANTS audit completed

---

## Stretch Goals (Optional)

1. Create a user for each role type and test with those users
2. Add row-level security so Partners only see their own campaigns
3. Create a stored procedure that generates an access report
4. Implement a "break glass" procedure for emergency admin access

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Object does not exist" | Missing USAGE grant on database or schema |
| New table not accessible | Forgot GRANT ON FUTURE TABLES |
| Role can see too much | Check domain role inheritance chain |
| Can't switch to role | Role not granted to your user account |
