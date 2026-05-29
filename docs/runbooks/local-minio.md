# Local MinIO

Use MinIO as the local S3-compatible object storage layer. It gives EDP a practical place for file-based raw landing, archives, exports, CKAN resources, and backup repositories while keeping the production storage choice open.

MinIO is the local adapter, not a permanent production decision. Production can later move to AWS S3, Azure Blob Storage or ADLS Gen2, Google Cloud Storage, Ceph, Garage, SeaweedFS, or another object store.

## Start MinIO

```sh
cp .env.example .env
make minio-up
```

MinIO starts at:

- Console: `http://127.0.0.1:9001`
- S3 API: `http://127.0.0.1:9000`

The default local credentials are:

- Username: `minioadmin`
- Password: `minioadmin`

Change the `MINIO_ROOT_*` values in `.env` before running this outside disposable local development.

## Buckets

The `minio-init` service creates these local buckets:

- `edp-raw` for file-based raw landing
- `edp-archive` for retained extracts and immutable archives
- `edp-exports` for generated outbound files
- `edp-ckan` for CKAN-oriented publication resources
- `edp-backups` for backup repository experiments

Bucket names are configurable in `.env`.

## Common Commands

```sh
make minio-up
make minio-init
make minio-ls
make minio-logs
make minio-down
```

## EDP Usage Pattern

Use MinIO for:

- Raw API response archives too large or too file-shaped for PostgreSQL
- CSV, JSON, Parquet, PDF, image, and log extracts
- Generated files for CKAN publication workflows
- Data export staging before approved delivery
- Backup repository experiments before choosing production storage

Keep searchable operational metadata in PostgreSQL. Store large objects in MinIO and reference them from raw metadata tables, OpenMetadata assets, CKAN resources, or audit records.

## Migration Later

To migrate away from local MinIO:

- Keep application code using S3-compatible configuration where possible.
- Store bucket names and endpoints in environment configuration.
- Avoid hardcoding `localhost:9000` in DAGs, dbt models, or application code.
- Use object keys that are portable across providers.
- Document whether the production target is S3, ADLS, GCS, Ceph, or another object store.

For Microsoft-heavy public school environments, Azure Blob Storage or ADLS Gen2 may be the production target. MinIO still works well locally because the development pattern remains close to S3-style object storage.

## Troubleshooting

If MinIO does not start:

- Check `make minio-logs`.
- Confirm ports `9000` and `9001` are available.

If buckets are missing:

- Re-run `make minio-init`.
- Check `make minio-ls`.

If a service cannot connect:

- Use `http://minio:9000` from inside Compose.
- Use `http://127.0.0.1:9000` from host tools.
