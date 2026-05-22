from __future__ import annotations

import pendulum

from airflow import DAG
from airflow.operators.empty import EmptyOperator


with DAG(
    dag_id="edp_healthcheck",
    description="Minimal EDP Airflow DAG used to confirm local DAG discovery.",
    start_date=pendulum.datetime(2026, 1, 1, tz="UTC"),
    schedule=None,
    catchup=False,
    tags=["edp", "local"],
) as dag:
    EmptyOperator(task_id="airflow_ready")
