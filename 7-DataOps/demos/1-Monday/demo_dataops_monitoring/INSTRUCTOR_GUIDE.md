# Demo: DataOps Monitoring & Observability

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 1-Monday |
| **Topic** | Pipeline monitoring, alerting, and observability |
| **Type** | Concept-heavy (Diagram + Whiteboard + Config) |
| **Time** | ~15 minutes |
| **Prerequisites** | Understanding of DataOps lifecycle from written content |

**Weekly Epic:** *Operationalizing Data Excellence — DataOps, Quality, and Governance*

---

## Phase 1: The DataOps Lifecycle (Diagram)

**Time:** 4 mins

1. Open `diagrams/dataops-lifecycle.mermaid`
2. Walk through the eight phases:
   - Plan → Develop → Test → Release → Deploy → **Operate** → **Monitor** → Feedback → *(back to Plan)*
3. Highlight the continuous nature:
   - *"This is NOT a waterfall. It's a loop. Every pipeline goes through this cycle continuously."*
4. Circle the **Monitor** and **Operate** phases:
   - *"Today we're focused here. You've built and deployed pipelines — now how do you KNOW they're healthy?"*

> **Key Point:** *"Building the pipeline is 50% of the work. Operating it reliably is the other 50%."*

---

## Phase 2: Monitoring Architecture (Diagram)

**Time:** 5 mins

1. Open `diagrams/monitoring-architecture.mermaid`
2. Trace the flow left to right:
   - **Data Pipelines** (dbt, Airflow, Kafka) emit metrics
   - **Metrics Collector** aggregates them
   - Three outputs: Dashboard, Alerting, Logs
3. Walk through the response layer:
   - Slack for warnings, Email for failures, PagerDuty for critical incidents
4. **Whiteboard moment** — draw the three pillars of observability:
   ```
   Metrics     →  "How much? How fast? How often?"
   Logs        →  "What happened? Why did it fail?"
   Traces      →  "Where did this data come from?"
   ```
5. *"Metrics tell you SOMETHING is wrong. Logs tell you WHAT went wrong. Traces tell you WHERE it went wrong."*

---

## Phase 3: Alerting Configuration Walkthrough (Config)

**Time:** 6 mins

1. Open `code/pipeline_alert_config.yaml`
2. Walk through section by section:
   - **SLA Definition:**
     - *"Freshness: 4 hours. If the data is older than 4 hours, we have a problem."*
     - *"Completeness: 99.5%. If more than 0.5% of records are missing, alert."*
   - **Quality Checks:**
     - Row count, null checks, freshness, uniqueness, range checks
     - *"Each check has an action: 'warn' sends a Slack message; 'fail' pages the on-call engineer."*
   - **Escalation:**
     - *"Wait 15 minutes (maybe it self-heals), then alert. Repeat every 30 minutes. After 60 minutes, escalate to the manager."*
   - **Dashboard:**
     - Four panels: Pipeline Health, Data Quality, SLA Compliance, Resource Usage
3. *"This YAML is a contract with the business: 'We guarantee these data quality levels.'"*

### Discussion Prompt
*"What happens when the on-call engineer gets paged at 3 AM for a freshness alert? What information do they need?"*

---

## Key Talking Points

- "Monitoring is NOT optional — it's how you sleep at night"
- "SLAs are contracts: if you define them, you must measure and alert on them"
- "Warn vs Fail: not every issue is an emergency — escalation levels matter"
- "Three pillars of observability: Metrics, Logs, Traces"
- Bridge to Week 4: "Remember Airflow's logging? That's one piece of the observability puzzle."

---

## Required Reading Reference

Before this demo, trainees should have read:
- `dataops-lifecycle.md` — DataOps lifecycle phases, monitoring and observability practices
- `automated-testing-data-workflows.md` — Testing culture and building quality into workflows
