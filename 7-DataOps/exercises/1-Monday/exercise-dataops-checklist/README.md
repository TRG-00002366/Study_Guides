# Exercise: DataOps Readiness Checklist

## Overview
**Day:** 1-Monday
**Duration:** 1-2 hours
**Mode:** Individual (Conceptual / Design)
**Prerequisites:** DataOps lifecycle reading completed

---

## Required Reading

Before starting this exercise, review the following content:

| Topic | File | Focus Areas |
|-------|------|-------------|
| DataOps Lifecycle | [dataops-lifecycle.md](../../content/1-Monday/dataops-lifecycle.md) | 8 lifecycle phases, culture, practices |
| Automated Testing | [automated-testing-data-workflows.md](../../content/1-Monday/automated-testing-data-workflows.md) | Testing frameworks, monitoring |

---

## Learning Objectives
By the end of this exercise, you will be able to:
1. Evaluate a data pipeline against each DataOps lifecycle phase
2. Identify gaps in a team's DataOps maturity
3. Propose concrete improvements for each gap
4. Prioritize improvements by impact and effort

---

## The Scenario

You've just joined **BrightData Analytics** as a senior data engineer. The company has 3 data pipelines running in production:

1. **Customer Pipeline:** Extracts customer data from Salesforce CRM, loads into Snowflake, transforms with dbt. Runs daily at 6 AM. No tests. One engineer manually checks the dashboard each morning.

2. **Revenue Pipeline:** Extracts financial data from Stripe, processes with Airflow DAGs, loads into Snowflake. Runs every 4 hours. Has some dbt tests but no CI. Deployments happen from engineer laptops via `dbt run`.

3. **Marketing Pipeline:** Extracts event data from Google Analytics, processes with Python scripts, loads into Snowflake. Runs hourly. No version control — scripts live on a shared EC2 instance. No monitoring.

Your CTO wants a DataOps readiness assessment. She wants to know: *"How mature are we? Where should we invest first?"*

---

## Core Tasks

### Task 1: Audit Each Pipeline (45 mins)

Open `templates/dataops_checklist.md` and evaluate each pipeline against the 8 DataOps lifecycle phases:

For each phase, answer:
- **Current state:** What does the team do now? (Be specific)
- **Gap:** What's missing?
- **Risk:** What could go wrong because of this gap?

| Phase | Customer Pipeline | Revenue Pipeline | Marketing Pipeline |
|-------|-------------------|------------------|--------------------|
| Plan | | | |
| Develop | | | |
| Test | | | |
| Release | | | |
| Deploy | | | |
| Operate | | | |
| Monitor | | | |
| Feedback | | | |

**Checkpoint:** All 24 cells filled (8 phases × 3 pipelines).

---

### Task 2: Calculate Maturity Scores (15 mins)

For each pipeline, rate each phase from 1 (Ad-hoc) to 5 (Optimized):

| Level | Description |
|-------|-------------|
| 1 - Ad-hoc | No process, depends on individual knowledge |
| 2 - Repeatable | Some process exists but inconsistent |
| 3 - Defined | Documented process followed by team |
| 4 - Managed | Measured and automated |
| 5 - Optimized | Continuously improved with metrics |

Calculate the average score per pipeline. Which is most mature? Which is highest risk?

**Checkpoint:** Each pipeline has a numerical maturity score.

---

### Task 3: Propose Improvements (30 mins)

For each pipeline, propose the **top 3 improvements** ordered by priority:

For each improvement, document:
1. **What:** Specific action to take
2. **Phase:** Which lifecycle phase it addresses
3. **Impact:** High/Medium/Low — what risk does it mitigate?
4. **Effort:** High/Medium/Low — how long to implement?
5. **Prerequisites:** What needs to be in place first?

Example:
> **Improvement:** Add dbt tests for all critical models
> **Phase:** Test
> **Impact:** High — prevents data corruption reaching dashboards
> **Effort:** Medium — 2-3 days to write tests for existing models
> **Prerequisites:** dbt project must be in version control

**Checkpoint:** 9 improvements documented (3 per pipeline).

---

### Task 4: Create Executive Summary (15 mins)

Write a 1-page executive summary for the CTO that includes:
1. Overall assessment (1 paragraph)
2. Highest risk finding
3. Recommended first action
4. 90-day improvement roadmap (3 phases)

**Checkpoint:** Summary fits on one page and is non-technical enough for the CTO.

---

## Deliverables

Submit the following:

1. **Completed checklist** (`dataops_checklist.md` with all phases evaluated)
2. **Maturity scores** (table with scores per pipeline per phase)
3. **Improvement proposals** (9 prioritized improvements)
4. **Executive summary** (1-page CTO brief)

---

## Definition of Done

- [ ] All 8 lifecycle phases evaluated for all 3 pipelines
- [ ] Maturity scores calculated (1-5 scale)
- [ ] Top 3 improvements proposed per pipeline (9 total)
- [ ] Each improvement has impact and effort ratings
- [ ] Executive summary written
- [ ] Summary includes a 90-day roadmap

---

## Stretch Goals (Optional)

1. Create a Mermaid diagram showing the current vs target state for one pipeline
2. Estimate cost savings from reducing manual intervention
3. Draft a DataOps team charter defining roles and responsibilities
4. Compare two monitoring tools and recommend one for the team

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Not sure what "mature" looks like | Reference the 5-level maturity model in the theory |
| Stuck on improvements | Think about what would prevent the most recent outage |
| Executive summary too technical | Remove tool names; focus on risk and business impact |
| Can't prioritize | Use Impact × Effort matrix (high impact + low effort = do first) |
