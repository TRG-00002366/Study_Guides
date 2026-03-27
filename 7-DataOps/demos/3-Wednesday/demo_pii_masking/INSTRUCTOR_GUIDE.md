# Demo: PII Detection & Dynamic Data Masking

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 3-Wednesday |
| **Topic** | PII identification, Snowflake dynamic masking policies |
| **Type** | Hybrid (Concept + Code) |
| **Time** | ~20 minutes |
| **Prerequisites** | RBAC demo completed; ACCOUNTADMIN access for masking policies |

**Weekly Epic:** *Operationalizing Data Excellence — DataOps, Quality, and Governance*

---

## Phase 1: The Concept (Diagram)

**Time:** 5 mins

1. Open `diagrams/masking-architecture.mermaid`
2. Walk through the sequence:
   - *"A user runs SELECT email FROM customers. Before Snowflake returns the result, it checks: what role is this user?"*
   - DATA_ADMIN → full email (alice@company.com)
   - DATA_ANALYST → masked (****@company.com)
   - BUSINESS_USER → fully redacted ([REDACTED])
3. Emphasize the critical point:
   - *"The original data is NEVER modified. The table still contains the real email. Masking happens at QUERY TIME."*

> **Key Point:** *"One table, one query, three different results — based entirely on who's asking."*

### Whiteboard: Types of PII
Draw a quick table:
```
DIRECT IDENTIFIERS          INDIRECT IDENTIFIERS
─────────────────          ────────────────────
Full Name                  Date of Birth
Email Address              ZIP Code
SSN / Government ID        Gender
Phone Number               Job Title
Credit Card Number         IP Address
```
*"Direct identifiers alone can identify someone. Indirect identifiers are dangerous in combination."*

---

## Phase 2: The Code (Live in Snowsight)

**Time:** 15 mins

### Step 1: Create Sample PII Table (2 mins)
1. Open `code/masking_policies.sql`
2. Run the SETUP section to create `customers_pii` with sample data
3. *"This table has name, email, phone, and SSN — all PII that needs protection."*

### Step 2: Create Masking Policies (5 mins)
1. Run each policy creation:
   - `email_mask` — admin sees full, analyst sees domain, others get [REDACTED]
   - `ssn_mask` — admin sees full, everyone else sees last 4
   - `phone_mask` — admin/engineer see full, analyst sees last 4
   - `name_mask` — admin/engineer see full, others see initials
2. Walk through the CASE logic:
   ```sql
   CASE
     WHEN CURRENT_ROLE() IN ('DATA_ADMIN') THEN val     -- Full access
     ELSE CONCAT('****@', SPLIT_PART(val, '@', 2))       -- Masked
   END
   ```
3. *"The policy is just a function that takes a value and returns either the original or a masked version."*

### Step 3: Apply Policies to Columns (2 mins)
1. Run the ALTER TABLE statements
2. *"Once applied, the masking is automatic. No one needs to remember to call a masking function."*

### Step 4: Test with Role Switching (6 mins)
1. Switch to DATA_ENGINEER → run SELECT → full data visible
2. Switch to DATA_ANALYST → run SELECT → masked data
   - *"Look at the email column — same query, different result. Alice's email is now ****@company.com."*
3. Switch to BUSINESS_USER → run SELECT → heavily masked
4. **Dramatic moment:** Compare results side by side
   - *"Same table. Same SQL. Three different views. That's the power of dynamic masking."*

---

## Key Talking Points

- "Dynamic masking protects PII WITHOUT changing the underlying data"
- "Masking policies are applied per-column — you choose exactly what to protect"
- "CURRENT_ROLE() is the key — the policy checks what role you're using right now"
- "This combines with RBAC: roles determine access, masking determines visibility"
- Bridge to RBAC demo: "We just built the roles. Now masking adds a fine-grained layer on top."

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Can't create masking policy | Requires ACCOUNTADMIN or specific CREATE MASKING POLICY privilege |
| Policy type mismatch | Policy return type must match column data type |
| Masking not applied after ALTER TABLE | Verify column name matches exactly |
| All roles see masked data | Check CURRENT_ROLE() IN list includes the correct role names |

---

## Required Reading Reference

Before this demo, trainees should have read:
- `pii-handling-masking.md` — PII types, masking techniques, tokenization
- `data-governance-pillars.md` — Security pillar, data classification
