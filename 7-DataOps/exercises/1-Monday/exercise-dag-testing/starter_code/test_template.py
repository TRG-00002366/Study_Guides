"""
test_template.py
Complete the test functions below to validate the sample DAG.

Usage:
    pytest test_template.py -v
"""

import pytest
from pathlib import Path

# Import the function to unit test
from sample_dag import transform_data


# ============================================
# FIXTURES
# ============================================

@pytest.fixture(scope="module")
def dag_bag():
    """Load all DAGs for testing.
    
    TODO: Import DagBag from airflow.models
    and return a DagBag instance that loads DAGs
    from the current directory with include_examples=False.
    """
    pass  # TODO: Replace with DagBag setup


# ============================================
# DAG VALIDATION TESTS
# ============================================

def test_no_import_errors(dag_bag):
    """Verify that all DAGs can be imported without errors.
    
    TODO: Assert that dag_bag.import_errors is empty.
    Hint: len(dag_bag.import_errors) should be 0
    """
    pass  # TODO: Implement


def test_expected_dag_exists(dag_bag):
    """Verify that 'sample_etl_pipeline' DAG is loaded.
    
    TODO: Assert that 'sample_etl_pipeline' is in dag_bag.dags
    """
    pass  # TODO: Implement


def test_no_cycles(dag_bag):
    """Verify that no DAG has circular dependencies.
    
    TODO: For each DAG in dag_bag.dags, call dag.topological_sort()
    This will raise an exception if a cycle exists.
    """
    pass  # TODO: Implement


def test_dag_has_tags(dag_bag):
    """Verify the sample DAG has required tags.
    
    TODO: 
    1. Get the 'sample_etl_pipeline' DAG from dag_bag
    2. Assert it has at least one tag
    3. Assert 'etl' is in the tags
    """
    pass  # TODO: Implement


def test_dag_has_proper_owner(dag_bag):
    """Verify the DAG has a specific owner (not default 'airflow').
    
    TODO: Assert that the DAG's owner is not 'airflow'
    """
    pass  # TODO: Implement


# ============================================
# UNIT TESTS FOR transform_data()
# ============================================

def test_transform_valid_data():
    """Test transform_data with valid records.
    
    TODO: 
    1. Create a list of valid records with 'amount' and 'product_name'
    2. Call transform_data(records)
    3. Assert the output has the same number of records
    4. Assert product_name is uppercase
    5. Assert 'processed_at' key exists
    """
    pass  # TODO: Implement


def test_transform_empty_data():
    """Test transform_data with empty input.
    
    TODO: Pass an empty list and assert the result is also empty.
    """
    pass  # TODO: Implement


def test_transform_filters_negative_amounts():
    """Test that records with amount <= 0 are filtered out.
    
    TODO:
    1. Include a record with negative amount
    2. Include a record with zero amount
    3. Include a record with positive amount
    4. Assert only the positive-amount record is in the output
    """
    pass  # TODO: Implement


def test_transform_skips_missing_fields():
    """Test that records missing required fields are skipped.
    
    TODO:
    1. Include a record without 'amount'
    2. Include a record without 'product_name'
    3. Include a valid record
    4. Assert only the valid record is in the output
    """
    pass  # TODO: Implement
