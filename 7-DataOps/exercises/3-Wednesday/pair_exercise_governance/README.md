# Pair Programming Exercise: Complete Data Governance Solution

## Overview
**Day:** 3-Wednesday
**Duration:** 3-4 hours
**Mode:** Collaborative (Pair Programming)
**Prerequisites:** RBAC and PII masking demos completed; Snowflake access

---

## Required Reading

Before starting this exercise, review the following content:

| Topic | File | Focus Areas |
|-------|------|-------------|
| RBAC in Data Warehouses | [rbac-data-warehouses.md](../../content/3-Wednesday/rbac-data-warehouses.md) | Role hierarchies, grants |
| PII Handling & Masking | [pii-handling-masking.md](../../content/3-Wednesday/pii-handling-masking.md) | Masking policies, dynamic masking |
| Data Governance Pillars | [data-governance-pillars.md](../../content/3-Wednesday/data-governance-pillars.md) | Ownership, security, cataloging |

---

## Learning Objectives
By the end of this exercise, you will be able to:
1. Design and implement a complete RBAC model in Snowflake
2. Create and apply dynamic data masking policies
3. Document a data governance framework
4. Practice pair programming with clear role rotation
5. Validate access controls through systematic testing

---

## Pair Programming Protocol

### Role Definitions

**Driver:**
- Controls the keyboard (Snowsight or SQL editor)
- Writes and executes SQL statements
- Explains decisions out loud
- Asks navigator for input before executing destructive operations

**Navigator:**
- Reviews every SQL statement before execution
- References documentation and requirements
- Documents the governance framework in real time
- Validates access by checking expected vs actual behavior

### Rotation Schedule

| Phase | Duration | Driver Focus | Navigator Focus |
|-------|----------|--------------|-----------------|
| 1 | 45 mins | RBAC role setup | Document role hierarchy |
| 2 | 45 mins | Grant configuration | Document access matrix |
| 3 | 45 mins | Masking policies | Document PII handling |
| 4 | 30 mins | Access testing | Validate and sign off |
| 5 | 15 mins | Joint review | Joint review |

**CRITICAL: Switch roles after each phase!**

---

## The Scenario

**HealthData Inc.** is a healthcare analytics company. They must comply with HIPAA regulations while enabling their data team to work efficiently. You and your partner will build the governance infrastructure for their Snowflake warehouse.

**Business Requirements:**
1. Four user types: Data Admin, Data Engineer, Data Analyst, Business User
2. Patient health data (PHI) must be masked for non-admin users
3. Finance data is restricted to admin and finance team only
4. All access must be auditable
5. New tables must be automatically accessible to the right roles

---

## Phase 1: RBAC Role Setup (45 mins)

**Driver Task:** Create the role hierarchy

1. Open `starter_code/rbac_template.sql`
2. Complete the role creation and hierarchy:
   - Create 4 functional roles: `DATA_ADMIN`, `DATA_ENGINEER`, `DATA_ANALYST`, `BUSINESS_USER`
   - Create 3 domain roles: `PATIENT_READ`, `CLINICAL_READ`, `FINANCE_READ`
   - Build the hierarchy so:
     - DATA_ADMIN inherits ALL domain roles
     - DATA_ENGINEER inherits PATIENT_READ + CLINICAL_READ (not finance)
     - DATA_ANALYST inherits CLINICAL_READ only
     - BUSINESS_USER gets no domain roles (uses masked views only)
3. Grant all functional roles to SYSADMIN

**Navigator Task:**
- Draw the role hierarchy on paper/whiteboard
- Verify each GRANT ROLE statement matches the diagram
- Begin documenting in `templates/governance_framework.md`

**Checkpoint:** Role hierarchy created and documented.

**SWITCH ROLES!**

---

## Phase 2: Grant Configuration (45 mins)

**Driver Task:** Set up database, schema, and table grants

1. Create warehouses for each workload:
   - `ADMIN_WH` (SMALL) for DATA_ADMIN
   - `ENGINEER_WH` (SMALL) for DATA_ENGINEER
   - `ANALYST_WH` (XSMALL) for DATA_ANALYST and BUSINESS_USER
2. Create the database and schemas:
   - `HEALTH_DB.PATIENT` — patient demographics and PHI
   - `HEALTH_DB.CLINICAL` — clinical records and treatments
   - `HEALTH_DB.FINANCE` — billing and insurance
3. Grant USAGE on database to all domain roles
4. Grant USAGE on schemas to matching domain roles
5. Grant SELECT on ALL TABLES and FUTURE TABLES

**Navigator Task:**
- Create an access matrix table:

| Role | PATIENT Schema | CLINICAL Schema | FINANCE Schema |
|------|---------------|-----------------|----------------|
| DATA_ADMIN | R/W | R/W | R/W |
| DATA_ENGINEER | R | R | ❌ |
| DATA_ANALYST | ❌ | R | ❌ |
| BUSINESS_USER | ❌ | ❌ | ❌ |

- Verify each GRANT matches the matrix

**Checkpoint:** Access matrix documented and grants applied.

**SWITCH ROLES!**

---

## Phase 3: Masking Policies (45 mins)

**Driver Task:** Create and apply masking policies

1. Open `starter_code/masking_template.sql`
2. Create sample tables with PHI:
   - `HEALTH_DB.PATIENT.PATIENTS` (patient_id, full_name, ssn, date_of_birth, email, diagnosis_code)
3. Create masking policies:
   - `name_mask` — Admin sees full name; others see initials
   - `ssn_mask` — Admin sees full SSN; others see last 4
   - `email_mask` — Admin/Engineer see full; Analyst sees domain only; Business sees [REDACTED]
4. Apply policies to columns
5. Insert 3-5 sample patient records

**Navigator Task:**
- Document each masking policy:

| Column | Policy | DATA_ADMIN | DATA_ENGINEER | DATA_ANALYST | BUSINESS_USER |
|--------|--------|------------|---------------|--------------|---------------|
| full_name | | Full name | | | |
| ssn | | | | | |
| email | | | | | |

- Verify masking logic matches HIPAA requirements

**Checkpoint:** Masking policies applied and documented.

**SWITCH ROLES!**

---

## Phase 4: Access Testing (30 mins)

**Driver Task:** Systematically test all access controls

1. Open `starter_code/rbac_template.sql` — use the test section
2. For each role, execute:
   ```sql
   USE ROLE [role_name];
   SELECT * FROM HEALTH_DB.PATIENT.PATIENTS LIMIT 3;
   ```
3. Record actual results vs expected results:

| Test | Role | Expected | Actual | Pass/Fail |
|------|------|----------|--------|-----------|
| Read patients | DATA_ADMIN | Full data | | |
| Read patients | DATA_ENGINEER | Masked PHI | | |
| Read patients | DATA_ANALYST | Access denied | | |
| Read finance | DATA_ADMIN | Full data | | |
| Read finance | DATA_ENGINEER | Access denied | | |

**Navigator Task:**
- Verify each test result against the access matrix
- Flag any unexpected results
- Document any issues found and how they were resolved

**Checkpoint:** All access tests documented with pass/fail.

---

## Phase 5: Joint Review and Documentation (15 mins)

**Both Partners Together:**

1. Review the complete governance framework document
2. Ensure all sections are filled:
   - Role hierarchy diagram
   - Access matrix
   - Masking policy documentation
   - Test results
3. Write a 3-sentence HIPAA compliance statement
4. Complete the pair reflection

---

## Deliverables

As a pair, submit:

1. **SQL Files:** Completed `rbac_template.sql` and `masking_template.sql`
2. **Governance Framework:** Completed `governance_framework.md`
3. **Test Results:** Access testing matrix with pass/fail
4. **Pair Reflection:** What worked well, what was challenging

---

## Definition of Done

- [ ] 4 functional roles + 3 domain roles created
- [ ] Role hierarchy matches design
- [ ] Warehouses created and assigned
- [ ] Database/schema/table grants applied
- [ ] FUTURE TABLES grants included
- [ ] At least 3 masking policies created and applied
- [ ] Sample data inserted for testing
- [ ] All access tests documented with pass/fail
- [ ] Governance framework document completed
- [ ] Both partners drove at least twice
- [ ] Pair reflection submitted

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Insufficient privileges" | Check USAGE on database AND schema |
| Masking policy type mismatch | Return type must match column type |
| Can't create masking policy | Requires ACCOUNTADMIN or CREATE MASKING POLICY privilege |
| Both partners disagree | Navigator's role is advisory — discuss, then decide together |
| Time running out | Prioritize RBAC + 1 masking policy over complete documentation |
