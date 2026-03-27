# Exercise: Writing Tests for Airflow DAGs

## Overview
**Day:** 1-Monday
**Duration:** 2-3 hours
**Mode:** Individual (Implementation)
**Prerequisites:** Airflow basics from Week 4; pytest fundamentals

---

## Required Reading

Before starting this exercise, review the following content:

| Topic | File | Focus Areas |
|-------|------|-------------|
| CI/CD for Airflow | [cicd-for-airflow.md](../../content/1-Monday/cicd-for-airflow.md) | DAG validation, testing strategies |
| Automated Testing | [automated-testing-data-workflows.md](../../content/1-Monday/automated-testing-data-workflows.md) | Testing pyramid, pytest |

---

## Learning Objectives
By the end of this exercise, you will be able to:
1. Write DAG validation tests using DagBag
2. Write unit tests for PythonOperator callables
3. Verify DAG structure (no cycles, correct tags, proper owners)
4. Understand which tests belong at each level of the testing pyramid

---

## The Scenario

Your data team has grown from 2 to 8 engineers. DAGs are being checked in faster than they can be reviewed. Last sprint, someone accidentally introduced a circular dependency that crashed the scheduler for 4 hours — taking down ALL pipelines, not just the broken one. You need to build a test suite that prevents this from ever happening again.

---

## Core Tasks

### Task 1: Understand the Sample DAG (15 mins)

1. Open `starter_code/sample_dag.py`
2. Read through the DAG and answer:
   - What is the DAG ID?
   - How many tasks does it have?
   - What schedule does it run on?
   - What does the `transform_data` function do?

**Checkpoint:** You can explain the DAG's purpose and structure.

---

### Task 2: Write DAG Validation Tests (45 mins)

1. Open `starter_code/test_template.py`
2. Complete the following test functions:

**Test 1: No import errors**
- Load all DAGs using `DagBag`
- Assert `dag_bag.import_errors` is empty

**Test 2: Expected DAG exists**
- Verify that `sample_etl_pipeline` is in the loaded DAGs

**Test 3: No circular dependencies**
- Call `dag.topological_sort()` — it raises an exception if cycles exist

**Test 4: DAG has required tags**
- Verify the DAG has at least one tag
- Verify the tags include `"etl"`

**Test 5: DAG has a proper owner**
- Verify the owner is NOT the default `"airflow"`

**Checkpoint:** All 5 validation tests pass when run with `pytest`.

---

### Task 3: Write Unit Tests for Task Functions (45 mins)

The sample DAG has a `transform_data` function used in a PythonOperator. Write unit tests for it:

1. **Test with valid data** — pass a list of records and verify the output
2. **Test with empty data** — pass an empty list, expect an empty result
3. **Test with invalid records** — pass records missing required fields
4. **Test with edge cases** — negative values, None values, very large numbers

**Hint:** You're testing the FUNCTION, not the operator. Just call `transform_data()` directly.

**Checkpoint:** At least 4 unit tests pass.

---

### Task 4: Run and Interpret Test Results (20 mins)

1. Run all tests:
   ```bash
   pytest starter_code/test_template.py -v
   ```
2. Capture the output showing pass/fail for each test
3. If any tests fail, debug and fix them
4. Run with coverage:
   ```bash
   pytest starter_code/test_template.py -v --tb=short
   ```

**Checkpoint:** All tests pass with verbose output.

---

### Task 5: Categorize Your Tests (15 mins)

Create a table categorizing each test by pyramid level:

| Test Name | Pyramid Level | What It Catches | Time to Run |
|-----------|---------------|-----------------|-------------|
| test_no_import_errors | | | |
| test_expected_dag_exists | | | |
| test_no_cycles | | | |
| test_valid_data | | | |
| ... | | | |

Pyramid levels: Unit, Integration, End-to-End

**Checkpoint:** All tests categorized with justification.

---

## Deliverables

Submit the following:

1. **Completed test file** (`test_template.py` with all tests implemented)
2. **Test output** (screenshot or copy of pytest verbose output)
3. **Test categorization table** (which pyramid level each test belongs to)

---

## Definition of Done

- [ ] DagBag import error test implemented
- [ ] Expected DAG existence test implemented
- [ ] Cycle detection test implemented
- [ ] Tag and owner validation tests implemented
- [ ] At least 4 unit tests for `transform_data`
- [ ] All tests pass (`pytest` runs green)
- [ ] Tests categorized by testing pyramid level

---

## Stretch Goals (Optional)

1. Add a test that verifies the DAG has no more than 20 tasks
2. Add a test that checks all tasks have `retries` set to at least 1
3. Write a test using `unittest.mock` to mock an external API call
4. Create a `conftest.py` with a shared `dag_bag` fixture

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `ModuleNotFoundError: airflow` | Install with `pip install apache-airflow` |
| DagBag loads example DAGs | Use `DagBag(include_examples=False)` |
| Import errors on DagBag | Check PYTHONPATH includes the dags directory |
| Tests pass but DAG still broken | Unit tests can't catch runtime connection issues |
| `transform_data` not importable | Import the function directly from the DAG file |
