# Data Persistence

EDP should start with a simple, reliable persistence model. The recommended default is PostgreSQL as the canonical database for early platform versions, with additional storage engines introduced only when the platform has a clear scale, performance, or workload reason.

## Primary Recommendation

Use PostgreSQL as the main persistence layer.

PostgreSQL fits the platform because it supports relational operational data, JSONB landing patterns, materialized views, indexing, constraints, partitioning, and standard SQL modeling. It also works well with common EDP tooling such as orchestration engines, transformation tools, dashboard platforms, APIs, and custom applications.

## Suggested Layer Mapping

| Layer | Suggested Persistence |
| --- | --- |
| Raw data store | PostgreSQL tables with JSONB payloads, source metadata, extraction timestamps, and ingestion run identifiers |
| Operational Data Store | PostgreSQL relational schemas, normalized tables, and current-state views |
| Data Vault | PostgreSQL hubs, links, satellites, load metadata, and historical relationship tables |
| Data Marts | PostgreSQL schemas, views, and materialized views shaped for reporting and applications |
| Custom applications | PostgreSQL application schemas for operational state and workflow data |
| Dashboarding | Dashboard and visualization tools reading governed PostgreSQL marts or ODS views |

## Recommended Starting Stack

Start with PostgreSQL for:

- Raw ingestion records
- ODS tables and views
- Data Vault structures
- Data Mart schemas
- Platform metadata
- Application state
- API-backed operational workflows

This keeps the first implementation understandable and maintainable. It also avoids introducing separate storage systems before the platform has enough usage data to justify them.

## Future Additions

Add object storage and Parquet when raw history becomes large or when immutable file-based retention is useful. In that pattern, raw extracts can be stored in S3-compatible storage, Azure Blob, or another durable object store while PostgreSQL keeps manifests, metadata, and searchable indexes.

For local development, use MinIO as the S3-compatible object storage adapter. It should hold large raw files, retained extracts, generated exports, CKAN publication resources, and backup repository experiments. Keep object endpoints and bucket names in configuration so production can later move to S3, Azure Blob or ADLS Gen2, Google Cloud Storage, Ceph, Garage, SeaweedFS, or another object store without rewriting platform logic.

Use DuckDB for local development, exploration, and ad hoc analytics against Parquet files. DuckDB is useful beside the platform, but it should not be treated as the central server database.

Consider ClickHouse when dashboard or analytical workloads outgrow PostgreSQL. It is strong for high-volume analytical queries, but it adds operational complexity and should be introduced for a clear workload need.

Consider TimescaleDB only when the platform has serious time-series requirements such as frequent snapshots, operational metrics, time-bucketed trends, retention policies, or event-like histories that benefit from time-series features.

## What Not To Start With

Do not begin with a full cloud warehouse or lakehouse stack unless the organization already needs cloud-scale analytics, very large data volumes, or managed enterprise warehouse features from day one.

For most early EDP implementations, PostgreSQL provides the best balance of simplicity, control, cost, and capability.

## Design Guidance

Keep EDP-owned databases separated by platform concern:

- `raw` for faithful source capture
- `ods` for normalized current-state operational models
- `vault` for historical business keys, relationships, and attributes
- `mart` for user-facing reporting and application datasets
- `app` for custom application state owned by EDP services

Within each EDP-owned database, use schemas to separate the layer's primary data
objects from local metadata. A `meta` schema in each database is a useful
default for Alembic versioning, refresh logs, lineage records, and operational
audit records that belong with that layer.

Keep component metadata databases separate from EDP data databases. Airflow and
Superset should use their own PostgreSQL databases and manage their own tables.

Design each layer so it can evolve independently. The raw layer should preserve source truth, the ODS should make current operations understandable, the Data Vault should preserve history, and Data Marts should make common user questions easy to answer.
