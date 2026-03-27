# Data Governance Framework — HealthData Inc.

**Prepared by:** [Partner 1 Name] & [Partner 2 Name]
**Date:** [Today's Date]

---

## 1. Role Hierarchy

*(Draw or describe the role hierarchy here)*

### System Roles
- ACCOUNTADMIN → ...
- SECURITYADMIN → ...
- SYSADMIN → ...

### Functional Roles
| Role | Purpose | Inherits From |
|------|---------|---------------|
| DATA_ADMIN | | |
| DATA_ENGINEER | | |
| DATA_ANALYST | | |
| BUSINESS_USER | | |

### Domain Roles
| Role | Schema Access | Purpose |
|------|--------------|---------|
| PATIENT_READ | | |
| CLINICAL_READ | | |
| FINANCE_READ | | |

---

## 2. Access Control Matrix

| Resource | DATA_ADMIN | DATA_ENGINEER | DATA_ANALYST | BUSINESS_USER |
|----------|------------|---------------|--------------|---------------|
| ADMIN_WH | | | | |
| ENGINEER_WH | | | | |
| ANALYST_WH | | | | |
| HEALTH_DB.PATIENT | | | | |
| HEALTH_DB.CLINICAL | | | | |
| HEALTH_DB.FINANCE | | | | |

---

## 3. Data Masking Policies

| Column | Policy Name | DATA_ADMIN Sees | DATA_ENGINEER Sees | DATA_ANALYST Sees | BUSINESS_USER Sees |
|--------|-------------|-----------------|--------------------|--------------------|---------------------|
| full_name | | | | | |
| ssn | | | | | |
| email | | | | | |

---

## 4. PII Inventory

| Table | Column | PII Type | Masking Policy | Classification |
|-------|--------|----------|----------------|----------------|
| | | | | |
| | | | | |

---

## 5. Access Test Results

| # | Test Description | Role | Expected | Actual | Status |
|---|-----------------|------|----------|--------|--------|
| 1 | | | | | ⬜ |
| 2 | | | | | ⬜ |
| 3 | | | | | ⬜ |
| 4 | | | | | ⬜ |
| 5 | | | | | ⬜ |

---

## 6. HIPAA Compliance Statement

*(Write 3 sentences documenting how this governance framework supports HIPAA compliance)*

---

## 7. Pair Reflection

**What went well in pair programming?**

**What was challenging?**

**How did you resolve disagreements?**

**What would you do differently?**
