# Tooling Recommendations

EDP should prefer open-source, PostgreSQL-centered, container-friendly, Git-managed tools where practical. Add complexity only when a category earns it through scale, governance needs, operational risk, or user demand.

## Suggested Tooling by Category

| Category | Recommended Starting Tooling | Later or Optional |
| --- | --- | --- |
| Connectors and Data Movement | Custom Python connectors, Airbyte, Meltano | Debezium for CDC, Kafka or Redpanda for event streams |
| Orchestration and Workflow | Apache Airflow | Dagster for asset-centric orchestration, Temporal for durable business workflows |
| Storage and Persistence | PostgreSQL, MinIO for local S3-compatible object storage | Cloud object storage plus Parquet, ClickHouse, TimescaleDB |
| Backup and Recovery | pgBackRest for PostgreSQL physical backups and WAL archiving | Object-storage repositories, managed PITR, cross-region replicas |
| Transformation and Modeling | dbt | SQLMesh, custom Python transforms |
| Data Quality and Validation | dbt tests, Great Expectations / GX Core, Soda Core | Deequ for Spark-heavy environments |
| Catalog, Metadata, and Lineage | OpenMetadata | DataHub for larger metadata and governance programs |
| Semantic Layer and Metrics | dbt semantic layer concepts, Superset semantic layer | Cube, Lightdash, commercial semantic layers |
| Consumer Experience | Apache Superset, CKAN, Grafana, FastAPI plus Vue | Metabase, Evidence.dev, Power BI |
| Custom Applications and APIs | FastAPI, Vue, NGINX | React, .NET APIs, internal developer portals |
| Identity and Access | Existing identity provider, Keycloak if self-hosting, Open Policy Agent for policy-as-code | OPA Gatekeeper for Kubernetes admission control |
| Secrets and Configuration | SOPS plus age, OpenBao for local secret-management integration | Managed secret stores, HashiCorp Vault |
| Observability and Monitoring | Prometheus, Grafana, Loki | OpenTelemetry, Tempo, Alertmanager |
| DevOps, GitOps, and CI/CD | GitHub Actions, Docker, Kubernetes manifests | Argo CD, Flux, Helm, Renovate |
| Search and Indexing | PostgreSQL full-text search | OpenSearch when search becomes central |
| Documentation and Knowledge | VitePress, Markdown, ADRs | OpenMetadata docs, Evidence.dev reports |
| Privacy and Governance Controls | PostgreSQL roles and views, dbt tests, documented classifications | Data masking, policy engines, catalog-driven classification |

## Recommended Starter Stack

Start with:

- PostgreSQL for persistence
- pgBackRest for PostgreSQL backup and restore testing
- MinIO for local object storage, with migration paths to S3, Azure Blob or ADLS, GCS, Ceph, or another object store
- PostgreSQL schemas for raw, ODS, Data Vault, Data Marts, platform metadata, and application state
- Airflow for orchestration
- dbt for transformations, tests, lineage, and model documentation
- Great Expectations for reusable data quality suites and validation results
- OpenMetadata for catalog, ownership, glossary, metadata ingestion, and lineage
- Superset for the main BI portal
- CKAN for public dataset publication, statutory reporting packages, and transparency disclosures
- Open Policy Agent for executable governance decisions around access, publication, and exports
- OpenBao for local secret storage, policy experiments, and future dynamic-credential patterns
- Grafana for platform and operational dashboards
- FastAPI plus Vue for workflow-oriented applications
- VitePress for documentation
- Docker, Kubernetes-ready manifests, and GitHub Actions for delivery
- GitOps-friendly deployment definitions that can be repeatedly applied to a target environment

This stack is broad enough to prove the EDP concept while staying understandable for a small platform team.

See [Runtime Infrastructure](/architecture/runtime-infrastructure) for recommended hosting, operating system, container, and GitOps patterns.

## Phase Guidance

Phase 1 should establish the platform core:

- PostgreSQL
- pgBackRest
- MinIO
- Airflow
- dbt
- Great Expectations
- OpenMetadata
- Superset
- CKAN
- Open Policy Agent
- OpenBao
- Grafana
- VitePress
- GitHub Actions

Phase 2 should improve trust, operations, and governance:

- Great Expectations or Soda Core
- Broader OpenMetadata lineage, ownership, and glossary workflows
- SOPS plus age
- OpenBao auth, policy, audit, and rotation workflows
- Prometheus
- Loki
- Alertmanager

Phase 3 should scale integration and user-facing value:

- Airbyte or Meltano for connector scale
- Debezium for change data capture
- Evidence.dev for curated report pages
- FastAPI and Vue applications for operational workflows

Phase 4 should add specialized scale and mature operations:

- Object storage plus Parquet for large raw history
- ClickHouse for high-volume analytical workloads
- TimescaleDB for serious time-series needs
- Temporal for durable workflow applications
- OpenSearch for cross-entity search
- Managed secret stores or Vault for mature secrets management when OpenBao is not the chosen production target

## Selection Principles

Start with the fewest tools that can operate the full data lifecycle safely.

Prefer tools that integrate cleanly with Git, containers, PostgreSQL, SQL, Python, and the platform documentation workflow.

Avoid duplicating responsibilities. For example, dashboards should not own transformation logic, custom applications should not maintain private reporting models, and notebooks should not become production pipelines.

Introduce specialized systems when there is a specific pain they solve: scale, durability, governance, lineage, search, real-time events, or consumer usability.
