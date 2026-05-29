# Local Great Expectations

Use Great Expectations, also called GX Core, for data quality validation across raw, ODS, Data Vault, and Data Mart layers.

dbt tests are excellent for model-adjacent checks. GX is useful when validations need reusable expectation suites, validation results, quality documentation, and checkpoint-style execution that can be orchestrated by Airflow.

## Start From the Local Stack

```sh
cp .env.example .env
make postgres-up
make db-upgrade
make gx-version
```

The GX workspace lives in:

- `gx/`

The local Compose service runs with:

- `GX_HOME=/workspace/gx`
- Working directory `/workspace/gx`

## Common Commands

```sh
make gx-version
make gx-cli
```

Use the generic tools container for project-specific GX commands:

```sh
docker compose -f compose.yaml --profile tools run --rm gx great_expectations --help
```

## Configuration

The GX container receives these database URLs:

- `GX_RAW_DATABASE_URL`
- `GX_ODS_DATABASE_URL`
- `GX_VAULT_DATABASE_URL`
- `GX_MART_DATABASE_URL`

The default validation target is:

- `GX_TARGET=mart`

## What To Validate

Start with high-signal checks:

- Source freshness by connector and entity
- Row count deltas between raw snapshots and downstream models
- Required identifiers are not null
- Business keys are unique where expected
- Accepted values for status, type, and category fields
- Relationship checks between ODS entities
- Reconciliation checks between ODS, Vault, and Mart outputs
- Suppression or aggregation checks before CKAN publication

## Public Reporting Guidance

For public-school reporting and transparency workflows, run GX checks before publishing approved outputs to CKAN. ASBR and third-party disclosure packages should have validation evidence that confirms the published files are complete, current, and safe to release.

Keep sensitive record-level validation results internal. Publish summarized quality notes when they help users understand the dataset.

## Troubleshooting

If GX cannot connect to PostgreSQL:

- Confirm `make postgres-up` succeeds.
- Confirm database URLs use the Compose hostname `pgbouncer`.
- Confirm credentials match `.env`.

If a validation is slow:

- Push filtering into the SQL query or batch definition.
- Validate curated ODS or mart views before validating large raw payload tables.
- Keep expectation suites focused on decisions people actually need to trust.
