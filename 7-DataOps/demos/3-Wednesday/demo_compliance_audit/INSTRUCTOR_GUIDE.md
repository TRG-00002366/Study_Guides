# Demo: Compliance Audit Walkthrough

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 3-Wednesday |
| **Topic** | GDPR, HIPAA, SOC 2 compliance — audit scenario walkthrough |
| **Type** | Concept (Whiteboard + SQL walkthrough) |
| **Time** | ~15 minutes |
| **Prerequisites** | RBAC and PII masking demos completed |

**Weekly Epic:** *Operationalizing Data Excellence — DataOps, Quality, and Governance*

---

## Phase 1: The Standards (Diagram)

**Time:** 4 mins

1. Open `diagrams/compliance-comparison.mermaid`
2. Walk through each standard in one sentence:
   - **GDPR:** *"EU privacy law. If you store data about EU residents, you MUST let them see, export, or delete it."*
   - **HIPAA:** *"US healthcare law. If you touch patient health data, you need strict access controls and audit trails."*
   - **SOC 2:** *"Not a law but a trust framework. Service companies need it to win enterprise customers."*
3. Highlight the penalties:
   - *"GDPR: 4% of GLOBAL revenue. For a company like Amazon, that's billions."*
   - *"HIPAA: $1.5M per category per year."*
   - *"SOC 2: No fine, but you lose customers."*

> **Key Point:** *"Compliance is not optional. And as a data engineer, these are YOUR pipelines that must support it."*

---

## Phase 2: The Audit Workflow (Diagram)

**Time:** 4 mins

1. Open `diagrams/audit-workflow.mermaid`
2. Walk through the flow:
   - Audit request → Data inventory → PII locations → Access review → Audit logs → Retention check → Report
3. *"An auditor will ask: Where is personal data? Who can access it? How long do you keep it? Can you delete it?"*
4. **Whiteboard:** Write the four audit questions:
   ```
   1. INVENTORY:   What PII do you have and where?
   2. ACCESS:      Who can see it? Who DID see it?
   3. RETENTION:   How long do you keep it?
   4. DELETION:    Can you delete it on request?
   ```
5. *"If you can answer all four with working SQL queries, you're 80% of the way to compliance."*

---

## Phase 3: Compliance Queries (SQL Walkthrough)

**Time:** 7 mins

1. Open `code/compliance_queries.sql`
2. Walk through each scenario:

### DSAR — Data Subject Access Request (2 mins)
- *"Alice emails: 'Show me all data you have about me.' You have 30 days to respond."*
- Show the UNION ALL query that searches customers + orders + support tickets
- *"This query proves you KNOW where Alice's data lives. Without lineage, this takes days."*

### Right to Erasure (1 min)
- *"Alice now says: 'Delete everything.' You must delete from ALL tables."*
- Show the DELETE statements (commented out for safety)
- *"Delete in reverse dependency order — support_tickets first, then orders, then customers."*

### Retention Enforcement (1 min)
- *"GDPR says you can't keep data longer than necessary. Your policy says 2 years for events."*
- Show the retention query identifying records past their retention date

### Access Audit (2 mins)
- *"HIPAA auditor asks: 'Who accessed patient records in the last 30 days?'"*
- Show the query_history query
- *"Snowflake logs EVERY query automatically. This is your audit trail."*
- Show the failed login query
- *"Multiple failed logins from the same IP? That's a security incident."*

### Data Inventory (1 min)
- *"Step zero of any compliance program: know what data you have."*
- Show the column name pattern matching query
- *"This is a quick scan for PII-like column names. A proper catalog does this more rigorously."*

---

## Key Talking Points

- "Compliance is a data engineering problem — your pipelines handle the data"
- "DSAR response: if you can't find a user's data across all tables, you fail"
- "Snowflake's query_history and login_history are free audit trails — use them"
- "Retention is about deletion, not just storage — you must prove you DELETE old data"
- "Lineage + RBAC + Masking + Audit = a defensible compliance posture"
- Bridge to full week: "Monday: CI/CD ensures quality. Tuesday: Tests catch issues. Wednesday: Governance protects data."

---

## Required Reading Reference

Before this demo, trainees should have read:
- `compliance-standards.md` — GDPR, HIPAA, SOC 2 requirements and data engineer responsibilities
- `data-stewardship.md` — Data ownership and accountability models
