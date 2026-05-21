# Orchestration

EDP needs orchestration for connector jobs, scheduled ingestion, transformation runs, data quality checks, publication workflows, dashboard refresh dependencies, and recovery after failures.

The recommended starting point is Apache Airflow paired with dbt.

## Primary Recommendation

Use Apache Airflow as the default orchestration tool for early EDP implementations.

Airflow is a strong fit for scheduled, batch-oriented workflows with clear dependencies. It works well for recurring API pulls, raw data landing, ODS refreshes, Data Vault loads, Data Mart builds, quality checks, and operational alerting.

Pair Airflow with dbt for transformation logic, model testing, lineage, and documentation. In this pattern, Airflow coordinates when work happens, while dbt owns how analytical models are built and validated.

## Suggested Tool Mapping

| Use Case | Recommended Tool |
| --- | --- |
| Primary EDP pipeline orchestration | Apache Airflow |
| Data transformations, tests, and lineage | dbt |
| Data asset modeling and lineage-heavy orchestration | Dagster |
| Lightweight Python-first workflows | Prefect |
| Long-running durable business workflows | Temporal |
| Kubernetes-native scheduled jobs | Kubernetes CronJob or Argo Workflows |

## Airflow Responsibilities

Use Airflow for:

- Connector job scheduling
- Source API extraction workflows
- Raw data landing
- ODS refreshes
- Data Vault loads
- Data Mart builds
- dbt command orchestration
- Data quality checks
- Dashboard refresh dependencies
- Failure alerting and retry handling
- Operational audit records for pipeline runs

## dbt Responsibilities

Use dbt for:

- SQL transformations
- ODS, Data Vault, and Data Mart model definitions
- Model tests and data quality assertions
- Documentation for models and columns
- Lineage between source data and published data products
- Repeatable builds across development, test, and production environments

## When to Consider Dagster

Consider Dagster when the platform becomes strongly asset-centric. Dagster is compelling when the main mental model is maintaining reliable data assets such as tables, marts, reports, machine learning features, or published datasets.

Dagster may be a better fit when lineage, freshness, asset checks, and data product ownership become more important than traditional scheduled job chains.

## When to Consider Prefect

Consider Prefect for smaller Python-first workflows that need less scheduler ceremony or more dynamic runtime behavior than a traditional DAG. It can be useful for lightweight automation and developer-friendly operational scripts.

## When to Consider Temporal

Temporal is best reserved for durable business workflows rather than normal data pipelines.

Use Temporal when workflows are long-running, stateful, event-driven, and need strong recovery guarantees. Examples might include multi-step approval processes, remediation workflows, provisioning lifecycles, or operational applications where the workflow itself is part of the business process.

## Kubernetes-Native Options

Kubernetes CronJobs can handle simple scheduled container tasks. Argo Workflows can be useful for Kubernetes-native workflow execution.

These tools are helpful for infrastructure-level jobs, but they should not replace the main EDP orchestration layer unless the platform deliberately chooses a Kubernetes-native workflow model.

## Starting Architecture

Start with:

- Airflow for orchestration
- dbt for transformations and model tests
- PostgreSQL for Airflow metadata and EDP persistence
- Containerized workers for connector and transformation workloads

As the platform matures, consider Kubernetes-based execution for scalable workers and better workload isolation.

## Selection Guidance

Start with Airflow plus dbt when the main need is reliable scheduled data movement and transformation.

Choose Dagster when the platform is organized primarily around data assets, freshness, and lineage.

Choose Prefect when workflows are mostly Python functions and developer speed matters more than formal DAG governance.

Choose Temporal when the workflow is a durable operational process, not just a data pipeline.
