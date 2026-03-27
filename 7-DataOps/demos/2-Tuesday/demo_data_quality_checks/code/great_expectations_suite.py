"""
great_expectations_suite.py
============================================
Demonstrates how to define a Great Expectations suite
for data quality validation.
============================================
"""

from great_expectations.core import ExpectationSuite


def create_customer_quality_suite() -> ExpectationSuite:
    """Create a comprehensive expectations suite for customer data.
    
    Each expectation maps to a data quality dimension:
    - Completeness  → expect_column_values_to_not_be_null
    - Uniqueness    → expect_column_values_to_be_unique
    - Validity      → expect_column_values_to_match_regex
    - Consistency   → expect_table_columns_to_match_ordered_list
    - Volume/Range  → expect_table_row_count_to_be_between
    """
    suite = ExpectationSuite(
        expectation_suite_name="customer_quality"
    )

    expectations = [
        # --- COMPLETENESS ---
        {
            "expectation_type": "expect_column_values_to_not_be_null",
            "kwargs": {"column": "customer_id"},
        },
        {
            "expectation_type": "expect_column_values_to_not_be_null",
            "kwargs": {"column": "email"},
        },

        # --- UNIQUENESS ---
        {
            "expectation_type": "expect_column_values_to_be_unique",
            "kwargs": {"column": "customer_id"},
        },

        # --- VALIDITY: email format ---
        {
            "expectation_type": "expect_column_values_to_match_regex",
            "kwargs": {
                "column": "email",
                "regex": r"^[\w\.-]+@[\w\.-]+\.\w+$",
            },
        },

        # --- VALIDITY: status values ---
        {
            "expectation_type": "expect_column_values_to_be_in_set",
            "kwargs": {
                "column": "customer_status",
                "value_set": ["active", "inactive", "churned"],
            },
        },

        # --- VALIDITY: age range ---
        {
            "expectation_type": "expect_column_values_to_be_between",
            "kwargs": {
                "column": "age",
                "min_value": 0,
                "max_value": 120,
            },
        },

        # --- SCHEMA: expected columns ---
        {
            "expectation_type": "expect_table_columns_to_match_ordered_list",
            "kwargs": {
                "column_list": [
                    "customer_id", "name", "email", 
                    "customer_status", "created_at"
                ],
            },
        },

        # --- VOLUME: reasonable row count ---
        {
            "expectation_type": "expect_table_row_count_to_be_between",
            "kwargs": {
                "min_value": 1000,
                "max_value": 10_000_000,
            },
        },
    ]

    for exp in expectations:
        suite.add_expectation(exp)

    return suite


# Example usage
if __name__ == "__main__":
    suite = create_customer_quality_suite()
    print(f"Suite: {suite.expectation_suite_name}")
    print(f"Total expectations: {len(suite.expectations)}")
    for exp in suite.expectations:
        print(f"  - {exp.expectation_type}")
