"""
sample_dag.py
A sample Airflow DAG for testing exercises.
DO NOT MODIFY THIS FILE — write tests for it instead.
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.empty import EmptyOperator


# ---------- Task Functions ----------

def transform_data(records: list) -> list:
    """Transform raw sales records into clean format.
    
    Rules:
    - Only include records where 'amount' > 0
    - Convert 'product_name' to uppercase
    - Add a 'processed_at' timestamp
    - Skip records missing 'amount' or 'product_name'
    """
    processed = []
    for record in records:
        amount = record.get("amount")
        product = record.get("product_name")

        if amount is None or product is None:
            continue
        if amount <= 0:
            continue

        processed.append({
            "product_name": product.upper(),
            "amount": round(amount, 2),
            "original_amount": amount,
            "processed_at": datetime.utcnow().isoformat(),
        })
    return processed


def validate_data(**kwargs):
    """Validate that data meets quality thresholds."""
    ti = kwargs["ti"]
    data = ti.xcom_pull(task_ids="transform_task")
    if not data or len(data) == 0:
        raise ValueError("No data to validate — pipeline may be broken")
    return len(data)


def load_data(**kwargs):
    """Load processed data to destination."""
    ti = kwargs["ti"]
    record_count = ti.xcom_pull(task_ids="validate_task")
    print(f"Loading {record_count} records to warehouse...")
    return f"Loaded {record_count} records successfully"


# ---------- DAG Definition ----------

default_args = {
    "owner": "data-engineering",
    "depends_on_past": False,
    "email_on_failure": True,
    "email": ["data-team@company.com"],
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="sample_etl_pipeline",
    default_args=default_args,
    description="Sample ETL pipeline for testing exercises",
    schedule="0 6 * * *",  # Daily at 6 AM
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=["etl", "training", "week7"],
) as dag:

    start = EmptyOperator(task_id="start")

    transform_task = PythonOperator(
        task_id="transform_task",
        python_callable=transform_data,
        op_args=[
            [
                {"product_name": "Widget A", "amount": 29.99},
                {"product_name": "Widget B", "amount": 49.99},
            ]
        ],
    )

    validate_task = PythonOperator(
        task_id="validate_task",
        python_callable=validate_data,
    )

    load_task = PythonOperator(
        task_id="load_task",
        python_callable=load_data,
    )

    end = EmptyOperator(task_id="end")

    start >> transform_task >> validate_task >> load_task >> end
