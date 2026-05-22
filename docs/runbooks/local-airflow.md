# Local Airflow

Use the local Airflow containers for DAG development, orchestration experiments, and connector scheduling tests. This is a developer convenience, not the production deployment pattern.

## Start Airflow

```sh
cp .env.example .env
make airflow-up
```

Airflow starts at:

- `http://127.0.0.1:8080`

The default local administrator account is:

- Username: `airflow`
- Password: `airflow`

Change the `AIRFLOW_ADMIN_*` values in `.env` before running this outside disposable local development.

## Services

The local scaffold uses the official Apache Airflow image with LocalExecutor and the existing local PostgreSQL metadata database.

Compose services:

- `airflow-init`
- `airflow-apiserver`
- `airflow-scheduler`
- `airflow-dag-processor`
- `postgres`

The `airflow-init` service applies Airflow database migrations and creates the local admin user.

## Metadata Database

Airflow stores its metadata in the existing local PostgreSQL `airflow` database.

The local Compose service uses:

```sh
AIRFLOW_DATABASE_URL=postgresql+psycopg2://airflow:airflow@pgbouncer:6432/airflow
```

The local PostgreSQL init script creates the `airflow` database with the `AIRFLOW_DATABASE_USER` role as owner.

## Project Folders

Airflow mounts these local folders:

- `airflow/dags`
- `airflow/logs`
- `airflow/plugins`
- `airflow/config`

A small `edp_healthcheck` DAG is included to confirm DAG discovery.

## Common Commands

```sh
make airflow-up
make airflow-init
make airflow-logs
make airflow-cli
make airflow-down
```

Use `make postgres-down` to stop the full local Compose stack.

## DAG Guidance

Keep DAGs orchestration-focused. DAGs should schedule and observe connector work, transformations, checks, and publication steps; they should not hide large transformation logic inside Python tasks when that logic belongs in SQL, dbt, or reusable connector code.

Use the Data Mart and ODS databases as downstream targets after raw ingestion and governed transformations are in place.

## Configuration

Airflow configuration is primarily environment-driven in `compose.yaml` and `.env`.

Important local values:

- `AIRFLOW_DATABASE_USER`
- `AIRFLOW_DATABASE_PASSWORD`
- `AIRFLOW_DATABASE_URL`
- `AIRFLOW_FERNET_KEY`
- `AIRFLOW_SECRET_KEY`
- `AIRFLOW_ADMIN_USERNAME`
- `AIRFLOW_ADMIN_PASSWORD`

The values in `.env.example` are intentionally not production-safe.

Airflow image tags are declared in `compose.yaml`. Override them at the shell or CI environment level only when testing an image upgrade.

## Troubleshooting

If Airflow cannot connect to its metadata database:

- Confirm `make postgres-up` succeeds.
- Confirm the `airflow` database exists.
- Confirm `AIRFLOW_DATABASE_URL` uses the Compose hostname `pgbouncer`.

If DAGs do not appear:

- Confirm files are under `airflow/dags`.
- Check `make airflow-logs`.
- Confirm `airflow-dag-processor` is running.

If local files are created with unexpected ownership on Linux, adjust ownership
on the mounted `airflow/logs`, `airflow/dags`, `airflow/plugins`, or
`airflow/config` folders from the host.
