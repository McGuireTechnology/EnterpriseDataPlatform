# EDP dbt Project

This project owns SQL transformations, model tests, model documentation, and lineage for EDP analytical layers.

Use Alembic and SQLAlchemy for foundational database DDL in `postgres/models/`.
Use dbt for select-based models that shape ODS, Data Vault, and Data Mart outputs.

Common commands:

```sh
make dbt-debug
make dbt-run
make dbt-test
make dbt-docs-generate
```

The default target is `mart`, which writes to `edp_mart`. Override it with `DBT_TARGET=ods`, `DBT_TARGET=vault`, or `DBT_TARGET=raw`.
