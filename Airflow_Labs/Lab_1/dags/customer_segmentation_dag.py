from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator

from src.customer_clustering import (
    extract_data,
    transform_data,
    train_kmeans_model,
    evaluate_model,
)


default_args = {
    "owner": "custom_student",
    "start_date": datetime(2025, 1, 1),
    "retries": 1,
    "retry_delay": timedelta(minutes=2),
}


# Distinct DAG id, description, and schedule compared to the reference lab
with DAG(
    dag_id="customer_segmentation_lab1",
    default_args=default_args,
    description="Custom Lab 1 DAG for customer clustering with KMeans",
    schedule_interval="0 9 * * 1",  # every Monday at 09:00
    catchup=False,
) as dag:

    extract_task = PythonOperator(
        task_id="extract_customer_data",
        python_callable=extract_data,
    )

    transform_task = PythonOperator(
        task_id="transform_for_clustering",
        python_callable=transform_data,
        op_args=[extract_task.output],
    )

    train_task = PythonOperator(
        task_id="train_kmeans_customer_model",
        python_callable=train_kmeans_model,
        op_args=[transform_task.output, "kmeans_custom.sav"],
    )

    evaluate_task = PythonOperator(
        task_id="evaluate_customer_model",
        python_callable=evaluate_model,
        op_args=["kmeans_custom.sav", train_task.output],
    )

    # Define the task execution order
    extract_task >> transform_task >> train_task >> evaluate_task


if __name__ == "__main__":
    dag.test()


