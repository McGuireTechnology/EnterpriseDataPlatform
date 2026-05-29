# Local OpenMetadata

Use the local OpenMetadata containers for catalog, discovery, ownership, glossary, metadata ingestion, and lineage experiments. This is a developer convenience, not the production deployment pattern.

## Start OpenMetadata

```sh
cp .env.example .env
make openmetadata-up
```

OpenMetadata starts at:

- `http://127.0.0.1:8585`

The default local administrator account is:

- Username: `admin@open-metadata.org`
- Password: `admin`

The OpenMetadata ingestion Airflow service is exposed at:

- `http://127.0.0.1:8081`

It uses port `8081` on the host so the EDP Airflow UI can keep using port `8080`.

## Services

The local scaffold uses the OpenMetadata server, its ingestion service, Elasticsearch for catalog search, and the existing local PostgreSQL stack for metadata storage.

Compose services:

- `openmetadata-elasticsearch`
- `openmetadata-migrate`
- `openmetadata-server`
- `openmetadata-ingestion`
- `postgres`
- `pgbouncer`

The `openmetadata-migrate` service applies OpenMetadata application migrations before the web service starts.

## Metadata Databases

OpenMetadata stores its application metadata in the local PostgreSQL `openmetadata` database. Its ingestion service stores its Airflow metadata in the separate `openmetadata_airflow` database.

The local PostgreSQL init script creates both databases with separate owners:

- `openmetadata`
- `openmetadata_airflow`

These databases are application-owned and are not managed by EDP Alembic revisions.

## Common Commands

```sh
make openmetadata-up
make openmetadata-migrate
make openmetadata-logs
make openmetadata-down
```

Use `make postgres-down` to stop the full local Compose stack.

## Configuration

OpenMetadata configuration is primarily environment-driven in `compose.yaml` and `.env`.

Important local values:

- `OPENMETADATA_DATABASE_USER`
- `OPENMETADATA_DATABASE_PASSWORD`
- `OPENMETADATA_DATABASE`
- `OPENMETADATA_AIRFLOW_DATABASE_USER`
- `OPENMETADATA_AIRFLOW_DATABASE_PASSWORD`
- `OPENMETADATA_AIRFLOW_DATABASE`
- `OPENMETADATA_AUTHENTICATION_PROVIDER`
- `OPENMETADATA_AIRFLOW_USERNAME`
- `OPENMETADATA_AIRFLOW_PASSWORD`
- `OPENMETADATA_FERNET_KEY`

The values in `.env.example` are intentionally not production-safe.

## Local Catalog Guidance

Use OpenMetadata to catalog governed EDP assets first:

- `edp_ods` current-state entities and views
- `edp_vault` hubs, links, and satellites when lineage or history matters
- `edp_mart` reporting datasets and dashboard-facing views
- Superset dashboards and charts once they become shared assets
- Airflow pipelines that publish reusable datasets

Avoid treating the catalog as a replacement for version-controlled models, migrations, and runbooks. OpenMetadata should describe and govern assets; source control should remain the system of record for platform code and schema definitions.

## Troubleshooting

If OpenMetadata cannot connect to its metadata database:

- Confirm `make postgres-up` succeeds.
- Confirm the `openmetadata` and `openmetadata_airflow` databases exist.
- Confirm OpenMetadata database settings use the Compose hostname `pgbouncer`.
- If the local Postgres volume was created before OpenMetadata was added, create the two databases manually or rebuild the disposable local volume with `make postgres-reset`.

If search or the UI is slow to become ready:

- Check `make openmetadata-logs`.
- Confirm `openmetadata-elasticsearch` is healthy.
- Give the first startup enough time to apply migrations and initialize indexes.

If the ingestion service collides with another local service:

- Change the host-side port mapping for `openmetadata-ingestion` in `compose.yaml`.
