# Enterprise Data Platform

Canonical version: see `VERSION`.

Public website: https://edp.mcguire.technology/

Enterprise Data Platform is a collection of tools and data processing patterns for collecting cross-system operational data, landing it in a raw data store, normalizing and enriching it into an Operational Data Store, historizing it in a Data Vault, and publishing focused Data Marts for reporting and application use.

Requirements

- Python 3.8 or higher
- Node.js 14 or higher

Documentation Development

```sh
make docs-install
make docs-dev
```

Local PostgreSQL Development

This repo includes a Docker Compose PostgreSQL instance and Alembic migrations
for multiple databases and schemas.

```sh
python -m venv .venv
source .venv/bin/activate
pip install -r postgres/requirements.txt
cp .env.example .env
make postgres-up
make db-upgrade
```

The local container creates:

- EDP-owned data and application databases: `edp_raw`, `edp_ods`, `edp_vault`, `edp_mart`, and `edp_app`.
- Component metadata databases: `airflow` and `superset`.

Postgres bootstrap settings and local database URLs are documented in
`.env.example`. Docker Compose uses `POSTGRES_USER`, `POSTGRES_PASSWORD`, and
`POSTGRES_DB`; the database init script uses `POSTGRES_USER` as the owner for
the local databases it creates.

Use Alembic for database DDL that needs repeatable promotion between
environments. The `airflow` and `superset` databases are intentionally not
managed by these migrations because those applications manage their own
metadata schemas. Use dbt for transformation models, tests, documentation, and
lineage once data is landing in PostgreSQL.

The SQLAlchemy modeling layer lives in `postgres/models/`. Update those
models first, then create migrations with:

```sh
alembic -c postgres/alembic.ini -n <database> revision --autogenerate -m "describe change"
```

Verify drift with `make db-check`.
