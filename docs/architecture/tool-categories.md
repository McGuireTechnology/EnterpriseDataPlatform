# Tool Categories

EDP is a collection of tools working together across the data lifecycle. Tool choices can vary by environment, but each category should have a clear responsibility.

See [Tooling Recommendations](/architecture/tooling-recommendations) for suggested products and phase guidance for each category.

## Connectors and Data Movement

Connectors collect data from source systems through supported interfaces. They may use APIs, webhooks, file drops, database reads, command-line exports, or vendor SDKs.

Good connectors are observable, repeatable, rate-limit aware, and explicit about source metadata. They should capture enough detail to troubleshoot collection failures and reproduce a dataset when needed.

Source systems and connector options should be documented in the [Source Systems](/source-systems/) area.

## Orchestration and Workflow

Orchestration tools schedule and coordinate ingestion, transformation, validation, publication, and recovery workflows.

Orchestration should provide:

- Dependency management between jobs
- Retry and failure handling
- Runtime visibility and alerting
- Parameterized runs across environments
- Audit records for when data was collected, transformed, and published

See [Orchestration](/architecture/orchestration) for the recommended orchestration stack and selection guidance.

## Storage and Persistence

Storage and persistence tools hold raw source captures, current operational state, historical structures, curated marts, application state, and platform metadata.

Persistence choices should support the platform's data lifecycle without forcing every layer into the same physical pattern. See [Data Persistence](/architecture/data-persistence) for the recommended starting architecture.

## Transformation and Modeling

Transformation and modeling tools convert raw source captures into normalized ODS entities, Data Vault structures, and user-facing Data Marts.

These tools should keep model logic version controlled, testable, documented, and reusable across dashboards, APIs, and applications.

## Data Quality and Validation

Data quality tools test whether data is complete, fresh, valid, reconciled, and fit for use.

Quality checks should run close to ingestion and transformation workflows so failures are visible before users depend on incorrect dashboards, marts, or operational applications.

## Catalog, Metadata, and Lineage

Catalog and lineage tools help teams discover datasets, understand ownership, trace dependencies, document definitions, and analyze impact before changing shared models.

This category becomes more important as EDP grows from a small implementation into a governed platform with many data products.

## Semantic Layer and Metrics

A semantic layer defines shared metrics, dimensions, and business terminology so dashboards and applications do not recreate calculations independently.

This keeps official definitions close to the governed data model and reduces conflicting numbers across consumer tools.

## Consumer Experience

Consumer tools are the dashboards, reporting portals, narrative reports, and custom user interfaces that people log into to consume platform data.

See [Consumer Tools](/architecture/consumer-tools) for dashboard, reporting, and application recommendations.

## Custom Applications and APIs

Custom applications provide operational experiences that are not well served by generic dashboards. They may support review queues, remediation workflows, approval processes, CMDB-style views, administrative tools, or automation endpoints.

Applications should rely on shared platform models instead of maintaining their own private reporting logic.

See [Consumer Tools](/architecture/consumer-tools) for guidance on when to build custom applications instead of dashboards.

## Identity, Access, and Governance

Identity, access, and governance tools control who can access platform services, datasets, dashboards, APIs, and administrative workflows.

This category includes RBAC, row-level security, policy enforcement, approval workflows, and auditability.

## Secrets and Configuration

Secrets and configuration tools manage API keys, database passwords, service credentials, certificates, environment settings, and rotation workflows.

Secrets should not live in source code, documentation, container images, or ad hoc configuration files.

## Observability and Monitoring

Observability tools track pipeline health, service health, logs, metrics, traces, freshness, failures, latency, and platform capacity.

This category supports both platform operators and data consumers by making trust and freshness visible.

## DevOps, GitOps, and CI/CD

DevOps and GitOps tools build, test, release, deploy, and promote platform changes across environments.

This includes infrastructure changes, connector code, orchestration workflows, transformations, data models, applications, and documentation.

## Search and Indexing

Search and indexing tools provide fast lookup across operational entities, tickets, assets, identities, documents, logs, or other data that benefits from search-first access patterns.

Start simple with database search features and introduce a dedicated search platform only when search becomes a core consumer experience.

## Data Privacy and Protection

Privacy and protection tools classify sensitive data, apply masking or filtering, enforce retention rules, and support audit controls.

This category helps keep operational intelligence useful without exposing more sensitive data than necessary.

## Documentation and Knowledge Management

Documentation tools capture architecture, runbooks, data dictionaries, decision records, operating procedures, and model definitions.

The documentation system should evolve with the platform and remain close to the code, models, and operational workflows it describes.

## AI and Automation Assistants

AI and assistant capabilities are optional later-stage tools for guided remediation, summarization, triage, data exploration, and operational assistance.

They should build on governed datasets, documented definitions, and permission-aware APIs rather than bypassing platform controls.

## Reference Implementation Components

A reference implementation may include:

- Kubernetes or another container orchestration platform for workloads
- PostgreSQL for operational and analytical storage
- Connection pooling and database administration tools
- Workflow orchestration for pipelines and scheduled jobs
- Transformation tooling for modeling, testing, lineage, and documentation
- Data quality, catalog, lineage, and observability tools
- API services for integrations, automation, and operational endpoints
- Web application frameworks for custom interfaces
- Reverse proxy and ingress tooling for routing and TLS
- Caching or queue services for transient state and asynchronous work

These components are implementation choices, not the definition of EDP. The platform concept is the combination of cross-system collection, governed data modeling, operational applications, and trusted publication.

## Git-Based Platform Management

Infrastructure definitions, orchestration workflows, transformations, schemas, applications, and documentation should live in version control.

This operating model provides:

- Change traceability
- Peer review and approval workflows
- Rollback capability
- Standardized deployments
- Version-controlled data models and transformations
- Reduced dependency on tribal knowledge
- Documentation that evolves with the platform
