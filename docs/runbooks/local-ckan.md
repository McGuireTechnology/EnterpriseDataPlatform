# Local CKAN

Use CKAN as the local public data portal for transparency publishing. In EDP, CKAN is the place for public or semi-public dataset packages, statutory reporting artifacts such as ASBR publications, downloadable resources, and plain-language disclosures about data shared with third parties.

OpenMetadata remains the internal catalog for lineage, ownership, glossary, and impact analysis. CKAN is the outward-facing publication surface.

## Start CKAN

```sh
cp .env.example .env
make ckan-up
```

CKAN starts at:

- `http://127.0.0.1:5000`

The default local sysadmin account is:

- Username: `ckan_admin`
- Password: `admin`

Change the `CKAN_SYSADMIN_*` values in `.env` before running this outside disposable local development.

## Services

Compose services:

- `ckan`
- `ckan-init`
- `ckan-solr`
- `ckan-redis`
- `ckan-datapusher`
- `postgres`
- `pgbouncer`

CKAN uses Solr for search, Redis for cache and job support, and DataPusher to load supported tabular files into CKAN DataStore.

## Metadata Databases

The local PostgreSQL init script creates:

- `ckan`
- `ckan_datastore`

The main CKAN database is owned by `CKAN_DATABASE_USER`. The DataStore database is writable by CKAN and readable through `CKAN_DATASTORE_READONLY_USER`.

These are application-owned databases and are not managed by EDP Alembic revisions.

## Common Commands

```sh
make ckan-up
make ckan-init
make ckan-logs
make ckan-down
```

Use `make postgres-down` to stop the full local Compose stack.

## Publishing Guidance

Use CKAN for:

- ASBR publication packages
- Board-facing or public statutory reporting datasets
- Downloadable CSV, XLSX, PDF, and supporting documentation resources
- Dataset landing pages with plain-language definitions
- Data-sharing transparency records for third-party systems
- Public inventories of what data categories are collected, processed, retained, and shared

Good CKAN package metadata should answer:

- What is this dataset or report?
- Who owns it?
- What source systems contributed to it?
- How often is it refreshed?
- What fields or data categories are included?
- Which third parties receive related data?
- What legal, operational, or reporting purpose supports the publication or sharing?
- What privacy suppression, aggregation, or redaction rules were applied?

## ASBR Pattern

For ASBR-style reporting, create a CKAN dataset package per reporting year or reporting cycle. Attach:

- Final published report
- Machine-readable tables where appropriate
- Data dictionary
- Methodology or calculation notes
- Approval or submission metadata
- Prior-year comparison files when useful

Keep internal working tables, validation queries, and draft transformations in PostgreSQL/dbt/OpenMetadata. Publish only the approved reporting outputs and explanatory materials to CKAN.

## Third-Party Transparency Pattern

Create a CKAN organization or group for data-sharing transparency. Publish dataset packages for major systems or sharing categories, such as:

- Student information system exports
- Identity and account provisioning
- Learning application rostering
- Transportation, nutrition, library, or assessment integrations
- Security and device management telemetry

Each package should describe the data categories, recipient, purpose, refresh cadence, retention expectations, and contact owner. Avoid exposing secrets, internal endpoints, student-level records, or operational details that would create security risk.

## Troubleshooting

If CKAN cannot connect to PostgreSQL:

- Confirm `make postgres-up` succeeds.
- Confirm `ckan` and `ckan_datastore` databases exist.
- Confirm CKAN connection strings use the Compose hostname `pgbouncer`.

If search does not work:

- Confirm `ckan-solr` is healthy.
- Check `make ckan-logs`.

If DataStore previews do not work:

- Confirm `ckan-datapusher` is running.
- Confirm DataStore permissions were applied by `ckan-init`.
- Re-run `make ckan-init` after resetting local CKAN databases.
