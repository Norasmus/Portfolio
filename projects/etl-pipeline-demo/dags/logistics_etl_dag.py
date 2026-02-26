"""
Logistics ETL Pipeline DAG.

This DAG orchestrates the daily extraction, transformation, and loading
of logistics data from PostgreSQL (OLTP) to Snowflake (Data Warehouse).

Pipeline flow:
    1. Extract data from source tables (shipments, carriers, warehouses, customers)
    2. Validate extraction completeness
    3. Transform data (clean, enrich, calculate metrics)
    4. Validate transformation quality
    5. Load to staging schema
    6. Promote to production tables
    7. Send completion notification
"""

from datetime import datetime, timedelta
from pathlib import Path

from airflow import DAG
from airflow.operators.python import PythonOperator

# Add project root to path for ETL imports
PROJECT_ROOT = Path(__file__).resolve().parent.parent
import sys
sys.path.insert(0, str(PROJECT_ROOT))


def extract_data(**context):
    """Extract data from source tables."""
    import yaml
    from etl.extract import DataExtractor

    with open(PROJECT_ROOT / "config" / "pipeline_config.yaml") as f:
        config = yaml.safe_load(f)

    extractor = DataExtractor(config)
    extracted = {}
    for table_name, df in extractor.extract_all():
        # Serialize for XCom (DataFrames aren't JSON-serializable by default)
        extracted[table_name] = df.to_dict(orient="records")

    context["ti"].xcom_push(key="extracted_data", value=extracted)
    return len(extracted)


def validate_extract(**context):
    """Validate extraction completeness."""
    extracted = context["ti"].xcom_pull(key="extracted_data", task_ids="extract_data")
    expected_tables = ["shipments", "carriers", "warehouses", "customers"]
    missing = [t for t in expected_tables if t not in (extracted or {})]
    if missing:
        raise ValueError(f"Missing extracted tables: {missing}")
    return True


def transform_data(**context):
    """Transform extracted data."""
    import yaml
    import pandas as pd
    from etl.transform import DataTransformer

    extracted = context["ti"].xcom_pull(key="extracted_data", task_ids="extract_data")
    with open(PROJECT_ROOT / "config" / "pipeline_config.yaml") as f:
        config = yaml.safe_load(f)

    transformer = DataTransformer(config)
    transformed = {}
    for table_name, records in extracted.items():
        df = pd.DataFrame(records)
        df = transformer.run_transforms(df, table_name)
        transformed[table_name] = df.to_dict(orient="records")

    context["ti"].xcom_push(key="transformed_data", value=transformed)
    return len(transformed)


def validate_transform(**context):
    """Validate transformation quality."""
    transformed = context["ti"].xcom_pull(
        key="transformed_data", task_ids="transform_data"
    )
    if not transformed:
        raise ValueError("No transformed data found")
    for table, records in transformed.items():
        if len(records) == 0 and table != "customers":
            raise ValueError(f"Table {table} has zero rows after transform")
    return True


def load_staging(**context):
    """Load transformed data to staging."""
    import yaml
    import pandas as pd
    from etl.load import DataLoader

    transformed = context["ti"].xcom_pull(
        key="transformed_data", task_ids="transform_data"
    )
    with open(PROJECT_ROOT / "config" / "pipeline_config.yaml") as f:
        config = yaml.safe_load(f)

    loader = DataLoader(config)
    for table_name, records in transformed.items():
        df = pd.DataFrame(records)
        stg_name = f"stg_{table_name}"
        loader.load_staging(df, stg_name)
    return True


def load_production(**context):
    """Promote staging data to production."""
    import yaml
    from etl.load import DataLoader

    with open(PROJECT_ROOT / "config" / "pipeline_config.yaml") as f:
        config = yaml.safe_load(f)

    loader = DataLoader(config)
    loader.load_production("stg_shipments", "fact_shipments")
    loader.load_production("stg_carriers", "dim_carriers")
    return True


def notify_completion(**context):
    """Send completion notification."""
    dag_run = context.get("dag_run")
    run_id = dag_run.run_id if dag_run else "manual"
    print(f"Logistics ETL pipeline completed successfully. Run ID: {run_id}")
    return True


def on_failure_callback(context):
    """Handle DAG/task failure."""
    task_instance = context.get("task_instance")
    task_id = task_instance.task_id if task_instance else "unknown"
    exception = context.get("exception", "Unknown error")
    print(f"Pipeline failed at task '{task_id}': {exception}")


default_args = {
    "owner": "data-engineering",
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "on_failure_callback": on_failure_callback,
}

with DAG(
    dag_id="logistics_etl_pipeline",
    default_args=default_args,
    description="Daily ETL pipeline for logistics data (PostgreSQL -> Snowflake)",
    schedule="0 6 * * *",  # Daily at 6:00 AM
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=["etl", "logistics", "daily"],
) as dag:
    extract_data_task = PythonOperator(
        task_id="extract_data",
        python_callable=extract_data,
    )

    validate_extract_task = PythonOperator(
        task_id="validate_extract",
        python_callable=validate_extract,
    )

    transform_data_task = PythonOperator(
        task_id="transform_data",
        python_callable=transform_data,
    )

    validate_transform_task = PythonOperator(
        task_id="validate_transform",
        python_callable=validate_transform,
    )

    load_staging_task = PythonOperator(
        task_id="load_staging",
        python_callable=load_staging,
    )

    load_production_task = PythonOperator(
        task_id="load_production",
        python_callable=load_production,
    )

    notify_completion_task = PythonOperator(
        task_id="notify_completion",
        python_callable=notify_completion,
    )

    (
        extract_data_task
        >> validate_extract_task
        >> transform_data_task
        >> validate_transform_task
        >> load_staging_task
        >> load_production_task
        >> notify_completion_task
    )
