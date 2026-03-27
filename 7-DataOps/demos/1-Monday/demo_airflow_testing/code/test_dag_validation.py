"""
DAG validation tests for CI pipeline.
Ensures all DAGs can be loaded without errors and meet quality standards.

Usage:
    pytest test_dag_validation.py -v
"""

import os
import sys
from pathlib import Path

import pytest
from airflow.models import DagBag


# ---------- Configuration ----------
DAGS_FOLDER = Path(__file__).parent.parent / "dags"


# ---------- Fixtures ----------
@pytest.fixture(scope="module")
def dag_bag():
    """Load all DAGs into a DagBag for testing."""
    return DagBag(
        dag_folder=str(DAGS_FOLDER),
        include_examples=False
    )


# ---------- Import Tests ----------
def test_no_import_errors(dag_bag):
    """Verify that all DAGs can be imported without errors.

    This is the MOST CRITICAL test. If a DAG has an import error,
    the Airflow scheduler cannot load ANY DAGs from that file.
    """
    assert len(dag_bag.import_errors) == 0, (
        f"DAG import errors found: {dag_bag.import_errors}"
    )


def test_dags_loaded(dag_bag):
    """Verify that at least one DAG was loaded."""
    assert len(dag_bag.dags) > 0, "No DAGs found in DAGs folder"


# ---------- Structure Tests ----------
@pytest.mark.parametrize("dag_id", [
    "customer_pipeline",
    "product_sync",
    "daily_analytics",
])
def test_expected_dags_exist(dag_bag, dag_id):
    """Verify that expected DAGs are present."""
    assert dag_id in dag_bag.dags, f"Expected DAG '{dag_id}' not found"


def test_no_cycles(dag_bag):
    """Verify that no DAG has circular dependencies.

    Circular dependencies cause infinite loops in the scheduler.
    """
    for dag_id, dag in dag_bag.dags.items():
        dag.topological_sort()  # Raises if a cycle exists


# ---------- Quality Gate Tests ----------
def test_dags_have_tags(dag_bag):
    """Verify that all DAGs have at least one tag for organization."""
    for dag_id, dag in dag_bag.dags.items():
        assert dag.tags, f"DAG '{dag_id}' has no tags"


def test_dags_have_owners(dag_bag):
    """Verify that all DAGs have a specific owner (not default 'airflow')."""
    for dag_id, dag in dag_bag.dags.items():
        assert dag.owner != "airflow", (
            f"DAG '{dag_id}' should have a specific owner, not 'airflow'"
        )


def test_dags_have_descriptions(dag_bag):
    """Verify that all DAGs have a description."""
    for dag_id, dag in dag_bag.dags.items():
        assert dag.description, (
            f"DAG '{dag_id}' is missing a description"
        )


def test_task_count_reasonable(dag_bag):
    """Verify DAGs do not have an unreasonable number of tasks."""
    max_tasks = 100
    for dag_id, dag in dag_bag.dags.items():
        task_count = len(dag.tasks)
        assert task_count <= max_tasks, (
            f"DAG '{dag_id}' has {task_count} tasks, exceeding max of {max_tasks}"
        )
