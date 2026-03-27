"""
Unit tests for Airflow task functions.
Tests the Python callables used in PythonOperator tasks — in isolation,
without needing a running Airflow instance.

Usage:
    pytest test_task_unit.py -v
"""

import pytest
from datetime import datetime
from unittest.mock import MagicMock, patch


# ---------- Sample function under test ----------
# In a real project, this would be imported from your DAG file:
#   from dags.customer_pipeline import process_customer_data

def process_customer_data(records: list) -> list:
    """Example task function that processes customer records.
    
    - Validates email format
    - Marks each record as processed
    - Filters out records with invalid emails
    """
    import re
    email_pattern = re.compile(r'^[\w\.-]+@[\w\.-]+\.\w+$')
    
    processed = []
    for record in records:
        email = record.get("email", "")
        if email_pattern.match(email):
            record["processed"] = True
            record["processed_at"] = datetime.utcnow().isoformat()
            processed.append(record)
    return processed


# ---------- Tests ----------
class TestProcessCustomerData:
    """Tests for the process_customer_data function."""

    def test_valid_customer_data(self):
        """Test processing valid customer data."""
        input_data = [
            {"id": 1, "name": "Alice", "email": "alice@example.com"},
            {"id": 2, "name": "Bob", "email": "bob@example.com"},
        ]
        result = process_customer_data(input_data)

        assert len(result) == 2
        assert result[0]["processed"] is True
        assert "processed_at" in result[0]

    def test_empty_input(self):
        """Test that empty input returns empty output."""
        result = process_customer_data([])
        assert result == []

    def test_invalid_email_filtered(self):
        """Test that records with invalid emails are filtered out."""
        input_data = [
            {"id": 1, "name": "Alice", "email": "alice@example.com"},
            {"id": 2, "name": "Bob", "email": "invalid-email"},
        ]
        result = process_customer_data(input_data)

        assert len(result) == 1
        assert result[0]["id"] == 1

    def test_missing_email_filtered(self):
        """Test that records without email key are filtered."""
        input_data = [
            {"id": 1, "name": "Alice"},  # No email key
        ]
        result = process_customer_data(input_data)

        assert len(result) == 0

    def test_all_invalid_returns_empty(self):
        """Test that all-invalid input returns empty list."""
        input_data = [
            {"id": 1, "name": "Bob", "email": "bad"},
            {"id": 2, "name": "Carol", "email": "@missing"},
        ]
        result = process_customer_data(input_data)

        assert result == []
