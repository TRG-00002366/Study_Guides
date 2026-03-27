# Demo: Airflow DAG Validation & CI Pipeline

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 1-Monday |
| **Topic** | Testing and CI for Airflow DAGs |
| **Type** | Hybrid (Concept + Code) |
| **Time** | ~25 minutes |
| **Prerequisites** | Familiar with Airflow from Week 4; Git/GitHub basics |

**Weekly Epic:** *Operationalizing Data Excellence — DataOps, Quality, and Governance*

---

## Phase 1: The Concept (Diagram)

**Time:** 5 mins

1. Open `diagrams/dag-testing-strategy.mermaid`
2. Walk through the testing pyramid:
   - **Unit Tests (green, bottom):** "Test your Python functions directly — no Airflow needed. Fast, many of these."
   - **Integration Tests (orange, middle):** "Does your DAG load? Does DagBag find errors? Are dependencies valid?"
   - **E2E Tests (red, top):** "Run the full pipeline with test data. Slow but comprehensive."
3. *"Most teams stop at integration tests for CI. E2E tests run in staging on a schedule."*

> **Key Point:** *"A broken DAG file takes down the ENTIRE scheduler — not just that one pipeline. Import tests are critical."*

---

## Phase 2: The Code (Live Walkthrough)

**Time:** 20 mins

### Step 1: DAG Validation Tests (8 mins)
1. Open `code/test_dag_validation.py`
2. Walk through each test function:
   - `test_no_import_errors` — *"This is the most important test. If ANY file has an import error, the scheduler chokes."*
   - `test_no_cycles` — *"Circular dependencies cause infinite loops."*
   - `test_dags_have_tags` — *"Tags are how you organize DAGs in the Airflow UI."*
   - `test_dags_have_owners` — *"Default owner 'airflow' means nobody is responsible."*
3. Show the `@pytest.mark.parametrize` pattern:
   - *"You list expected DAG IDs. If someone deletes a DAG accidentally, this test catches it."*

### Step 2: Unit Testing Task Functions (5 mins)
1. Open `code/test_task_unit.py`
2. Explain the approach:
   - *"The function `process_customer_data` is the callable inside a PythonOperator."*
   - *"We test it WITHOUT Airflow — just call the function directly."*
3. Walk through key tests:
   - Valid input → processed records
   - Invalid email → filtered out
   - Empty input → empty output
4. *"You test the logic, not the orchestration. Airflow is just the scheduler."*

### Step 3: The CI Workflow (4 mins)
1. Open `code/airflow_ci.yml`
2. Point out Airflow-specific setup:
   - Must set `AIRFLOW_HOME`
   - Must run `airflow db init` (SQLite is fine for CI)
3. The pipeline: validation tests → unit tests → `airflow dags list` → import error check
4. *"Four layers of defense. A bad DAG has to sneak past all four."*

### Step 4: Discussion — What CI Can't Catch (3 mins)
1. *"CI tests syntax and structure. But what about:"*
   - Connection credentials that work in CI but not in prod
   - External APIs that behave differently
   - Data volume differences
2. *"That's why you also need staging environments and monitoring."*

---

## Key Talking Points

- "A broken DAG file crashes the ENTIRE scheduler — test imports first"
- "Test the function, not the operator — unit tests don't need Airflow"
- "DagBag is your best friend for structural validation"
- "CI needs `airflow db init` — it creates a minimal SQLite database"
- Bridge to Week 4: "Remember the DAGs you built? Now imagine pushing them without tests."

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| `ModuleNotFoundError` in CI | Add all dependencies to `requirements.txt` |
| DagBag loads example DAGs | Set `include_examples=False` |
| Airflow DB errors in CI | Ensure `airflow db init` runs before tests |
| Tests pass but DAG fails in prod | External dependency not available in CI — use mocking |

---

## Required Reading Reference

Before this demo, trainees should have read:
- `cicd-for-airflow.md` — DAG validation, testing strategies, deployment approaches
- `automated-testing-data-workflows.md` — Testing pyramid, frameworks, culture
