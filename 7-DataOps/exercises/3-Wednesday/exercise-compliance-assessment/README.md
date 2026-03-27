# Exercise: Mock Compliance Assessment

## Overview
**Day:** 3-Wednesday
**Duration:** 1-2 hours
**Mode:** Individual (Conceptual / Design)
**Prerequisites:** Compliance standards reading completed

---

## Required Reading

Before starting this exercise, review the following content:

| Topic | File | Focus Areas |
|-------|------|-------------|
| Compliance Standards | [compliance-standards.md](../../content/3-Wednesday/compliance-standards.md) | GDPR, HIPAA, SOC 2 |
| Data Stewardship | [data-stewardship.md](../../content/3-Wednesday/data-stewardship.md) | Ownership, accountability |

---

## Learning Objectives
By the end of this exercise, you will be able to:
1. Map compliance requirements to data warehouse controls
2. Identify compliance gaps in a given scenario
3. Draft a Data Subject Access Request (DSAR) response
4. Create an audit-ready compliance checklist

---

## The Scenario

**TravelEasy** is an online travel booking platform serving customers in both the US and EU. They store the following data in their Snowflake warehouse:

**Tables:**
- `customers` — name, email, phone, passport_number, nationality, date_of_birth
- `bookings` — customer_id, destination, travel_dates, total_cost, payment_method
- `payments` — customer_id, card_last_four, billing_address, transaction_amount
- `support_tickets` — customer_id, issue_description, resolution, agent_notes

**Current State:**
- No masking policies on any table
- All data engineers have SELECT access to all tables
- No data retention policy — data is kept forever
- No audit logging enabled beyond Snowflake defaults
- No documented process for handling user data requests

A GDPR auditor is arriving next week. Your job is to assess readiness.

---

## Core Tasks

### Task 1: Complete the GDPR Compliance Checklist (30 mins)

Open `templates/compliance_checklist.md` and evaluate TravelEasy against each GDPR article:

For each requirement:
- **Current Status:** Compliant / Partially Compliant / Non-Compliant
- **Evidence:** What proves compliance (or what's missing)
- **Gap:** What needs to be fixed
- **Priority:** Critical / High / Medium / Low

**Checkpoint:** All 8 checklist items evaluated with status and gap.

---

### Task 2: Draft a DSAR Response (30 mins)

A customer named **Anna Mueller** (email: anna.mueller@example.de) has submitted a Data Subject Access Request:

> "Under GDPR Article 15, I request a copy of all personal data you hold about me, including the purposes of processing and any third parties you have shared my data with."

Open `templates/dsar_template.md` and complete the response:

1. List all tables containing Anna's data
2. For each table, list which columns contain personal data
3. Describe the purpose of processing for each data category
4. Identify any third parties who received the data
5. State the retention period for each data category

**Checkpoint:** Complete DSAR response covering all 4 tables.

---

### Task 3: Gap Analysis and Remediation Plan (20 mins)

Based on your findings, create a prioritized remediation plan:

| # | Gap | GDPR Article | Remediation | Effort | Deadline |
|---|-----|--------------|-------------|--------|----------|
| 1 | | | | | |
| 2 | | | | | |
| 3 | | | | | |
| 4 | | | | | |
| 5 | | | | | |

Order by priority: fix Critical items before the auditor arrives.

**Checkpoint:** At least 5 gaps identified with remediation plans.

---

### Task 4: Write Auditor Briefing (10 mins)

Write a 1-page briefing for the CTO to prepare for the auditor:

1. Overall GDPR readiness assessment (Red/Yellow/Green)
2. Top 3 risks the auditor will find
3. What has already been fixed (from your plan)
4. What will be fixed by the audit date
5. What requires more time (with timeline)

**Checkpoint:** Briefing is honest, concise, and actionable.

---

## Deliverables

Submit the following:

1. **Compliance checklist** (`compliance_checklist.md`)
2. **DSAR response** (`dsar_template.md`)
3. **Remediation plan** (prioritized gap table)
4. **Auditor briefing** (1-page CTO summary)

---

## Definition of Done

- [ ] All 8 GDPR checklist items evaluated
- [ ] Each item has status, evidence, gap, and priority
- [ ] DSAR response covers all 4 tables
- [ ] DSAR lists personal data columns and processing purposes
- [ ] At least 5 remediation items identified
- [ ] Remediation items have effort estimates and deadlines
- [ ] Auditor briefing includes honest risk assessment

---

## Stretch Goals (Optional)

1. Add a HIPAA assessment for the same scenario (assume some customers have health insurance data)
2. Write SQL queries that would support the DSAR (finding all of Anna's data)
3. Draft a data retention policy document with specific retention periods per table
4. Create a data classification matrix (Public / Internal / Confidential / Restricted)

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Not sure about GDPR articles | Focus on Articles 5, 15, 17, 25, 32, 33 |
| Can't determine compliance | Assume non-compliant if no evidence exists |
| DSAR response too long | Focus on data categories, not individual records |
| Remediation plan too ambitious | Prioritize: masking → access control → retention → audit |
