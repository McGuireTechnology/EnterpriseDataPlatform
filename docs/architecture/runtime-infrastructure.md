# Runtime Infrastructure

EDP should be designed to run repeatably. The goal is to package platform services, connectors, data models, dashboards, and operational applications so they can be rebuilt from source control and deployed into a target environment with minimal manual work.

The ideal pattern is: code and configuration define the platform, containers run the workloads, GitOps applies the desired state, and credentials are supplied by the target environment.

## Runtime Goals

The platform runtime should support:

- Repeatable deployments from Git
- Containerized services and jobs
- Prebuilt connector and model packages
- Environment-specific credentials and endpoints
- Clear separation between code, configuration, and secrets
- Development, test, and production environments
- Backup, restore, and disaster recovery
- Observability, logging, and operational alerting
- Secure ingress, TLS, identity integration, and access control

## Recommended Runtime Model

Use containers as the packaging boundary for EDP services.

Each major platform component should run as a containerized workload where practical:

- Connectors
- Airflow workers and schedulers
- dbt runners
- Superset
- Grafana
- FastAPI services
- Vue or static web frontends
- Metadata and observability services
- Supporting jobs such as migrations, seed loads, and validation checks

For production-like environments, Kubernetes is the recommended orchestration layer. It provides a common way to schedule services, run jobs, manage configuration, expose services, scale workloads, and recover failed containers.

For local development and small proof-of-concept environments, Docker Compose can be useful. It should be treated as a developer convenience, not the long-term production operating model.

## Operating System Environment

The preferred operating system environment is a minimal Linux host designed for container workloads.

Strong options include:

- Talos Linux for an immutable, Kubernetes-focused operating system
- Flatcar Container Linux for container-focused infrastructure
- Ubuntu Server or Debian for teams that need a familiar general-purpose Linux environment
- Enterprise Linux variants when organizational standards require them

The production host operating system should be kept boring, minimal, patched, observable, and dedicated to running platform workloads. Avoid treating the host as an application server where tools are manually installed and configured outside source control.

## Infrastructure Placement

EDP can run in several infrastructure models:

| Runtime Location | When It Fits |
| --- | --- |
| Existing virtualization infrastructure | Good for early adoption when the organization already has reliable VM operations |
| Dedicated on-premises hardware | Good when data locality, cost control, or isolated platform capacity matters |
| Managed Kubernetes | Good when cloud operations and managed control planes are available |
| Hybrid deployment | Good when some connectors must run near on-prem systems while dashboards or apps run elsewhere |
| Developer workstation or lab | Good for local testing, demos, and connector development |

The architecture should remain infrastructure-agnostic where possible. EDP should not depend on one specific hosting provider unless that is an intentional organizational decision.

## GitOps Model

GitOps means the desired platform state is declared in Git and applied automatically or semi-automatically to the runtime environment.

EDP should store these items in version control:

- Kubernetes manifests or Helm charts
- Container build definitions
- Airflow DAGs
- dbt projects and model definitions
- Database migration scripts
- Connector code and connector configuration templates
- Superset dashboard exports or provisioning definitions where practical
- Grafana dashboards and datasources
- API and application source code
- Documentation, runbooks, and architecture decisions

GitOps tools such as Argo CD or Flux can continuously reconcile the target environment with the desired state in Git.

## Credentials-Only Connection Setup

Connectors and prebuilt data models should be reusable across deployments. A new environment should not require rewriting connector logic or model code just to point at different systems.

Prefer this pattern:

- Connector code is packaged in containers.
- Source-specific settings are supplied through environment configuration.
- Secrets are supplied through the target environment's secret management system.
- Connection tests validate credentials before scheduled jobs run.
- dbt sources, schemas, and model variables are parameterized per environment.
- Dashboards and applications depend on governed views or marts, not hardcoded source details.

The platform should distinguish between:

- Code: connector logic, transformations, APIs, applications
- Configuration: endpoints, schedules, feature flags, schema names, environment identifiers
- Secrets: passwords, tokens, certificates, API keys, private keys

Secrets should never be committed to Git.

## Secrets Management

EDP should treat secret management as a platform capability, not an afterthought inside each tool.

For local development, OpenBao gives the stack a concrete secrets-management target. It lets connector code, orchestration jobs, and applications practice retrieving credentials from an API-backed secret store while keeping `.env.example` limited to disposable local defaults.

For production, choose the secret store that fits the hosting model:

- OpenBao when the organization wants an open-source, self-hosted Vault-compatible secrets platform.
- Vault when the organization already standardizes on HashiCorp operations or managed Vault services.
- Managed cloud secret stores when the platform runs mainly in AWS, Azure, or Google Cloud.
- SOPS plus age for Git-encrypted configuration where runtime secret APIs are not yet justified.

Regardless of product, the architecture should define who owns each secret, how it is rotated, which workloads can read it, how access is audited, and what the break-glass recovery process is.

## Prebuilt Models and Connectors

Repeatability improves when EDP provides reusable starter packages:

- Connector templates for common API and database patterns
- Standard raw landing tables and metadata fields
- ODS entity patterns for identities, assets, tickets, licenses, memberships, and source records
- Data Vault hub, link, and satellite templates
- Data Mart templates for common operational views
- dbt tests for freshness, uniqueness, accepted values, relationships, and source reconciliation
- Dashboard starter packs for operational health and common pilot use cases

The target environment should only need to supply credentials, endpoints, schedule choices, and organization-specific mapping decisions.

Document source-specific connector status, required credentials, supported modes, and prebuilt packages in the [Connector Catalog](/source-systems/connector-catalog).

## Environment Strategy

At minimum, plan for:

- Local development for connector and model work
- Development or sandbox environment for integration testing
- Production environment for trusted operational use

As the platform matures, add:

- Test data patterns
- Promotion gates
- Database migration review
- Backup and restore testing
- Rollback procedures
- Release notes
- Environment-specific access policies

## Storage and Stateful Services

Containers make services repeatable, but data remains stateful. Plan carefully for:

- PostgreSQL persistent volumes or managed database storage
- Backup and restore procedures
- Point-in-time recovery where required
- Object storage for large raw history or Parquet archives
- Database migration tooling
- Storage capacity monitoring
- Retention and archival policies

Do not treat stateful platform data as disposable just because the services are containerized.

## Network and Access

Runtime infrastructure should include:

- Ingress and reverse proxy configuration
- TLS certificate management
- Internal service DNS
- Network segmentation where appropriate
- Egress rules for connector access to source systems
- Identity provider integration for user-facing tools
- Service accounts for machine access
- Audit logging for administrative and data access

## Recommended Starting Pattern

For an early production-capable EDP environment:

- Run workloads in containers.
- Use Kubernetes when operationally feasible.
- Use Docker Compose only for local development or prototypes.
- Use PostgreSQL as the primary stateful database.
- Use object storage later for large raw history.
- Store deployment definitions in Git.
- Use GitHub Actions for build and validation.
- Use Argo CD or Flux when the deployment process is ready for GitOps reconciliation.
- Use SOPS plus age, OpenBao, Vault, or a managed secret store for credentials.
- Treat host operating systems as minimal container infrastructure, not manually managed application servers.

This approach keeps the platform portable, repeatable, and easier to rebuild when hardware, hosting, or organizational requirements change.
