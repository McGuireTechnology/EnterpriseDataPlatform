# Local dbt

Use the local dbt container for SQL transformations, model tests, model documentation, and lineage metadata. dbt should own select-based models; Alembic and SQLAlchemy should continue to own foundational database DDL.

## Start From the Local Stack

```sh
cp .env.example .env
make postgres-up
make db-upgrade
make dbt-debug
```

The dbt project lives in:

- `dbt/`

The dbt Compose service runs with:

- `DBT_PROFILES_DIR=/workspace/dbt`
- Working directory `/workspace/dbt`

## Common Commands

```sh
make dbt-debug
make dbt-run
make dbt-test
make dbt-docs-generate
```

The default local target is `mart`, which writes to `edp_mart`.

Override targets with:

```sh
DBT_TARGET=ods make dbt-run
DBT_TARGET=vault make dbt-run
DBT_TARGET=raw make dbt-run
```

## Project Layout

- `dbt/models/staging` for source-shaped cleanup and typed projections
- `dbt/models/intermediate` for reusable business logic and cross-source joins
- `dbt/models/marts` for dashboard-facing and application-facing datasets
- `dbt/tests` for custom data tests
- `dbt/macros` for reusable SQL helpers
- `dbt/seeds` for small controlled reference datasets
- `dbt/snapshots` for dbt-managed snapshots when they are a better fit than EDP Data Vault history

## Guidance

Use dbt for:

- Views and tables derived from existing raw, ODS, Vault, or Mart structures
- Data tests such as uniqueness, accepted values, relationships, and freshness
- Model documentation and lineage
- Reusable analytical transformations

Use Alembic for:

- Schemas
- Base tables
- Primary keys and foreign keys
- Indexes
- Database extensions
- Operational application tables

## Troubleshooting

If `make dbt-debug` cannot connect:

- Confirm `make postgres-up` succeeds.
- Confirm `DBT_PG_HOST` is `pgbouncer` for Compose-based runs.
- Confirm `DBT_PG_USER` and `DBT_PG_PASSWORD` match `.env`.
- Confirm the target database exists.

If dbt reports no models:

- Add SQL files under `dbt/models/staging`, `dbt/models/intermediate`, or `dbt/models/marts`.
