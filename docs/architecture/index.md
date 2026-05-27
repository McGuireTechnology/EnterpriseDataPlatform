# Architecture

Enterprise Data Platform is not a single tool. It is a collection of tools paired with a shared data lifecycle for collecting, processing, historizing, and publishing cross-system operational data.

## Tool Categories

- Connectors and data movement tools bring data in from source systems and external services.
- Orchestration and workflow tools schedule, coordinate, monitor, and recover platform workflows.
- Storage, transformation, quality, catalog, and governance tools turn raw data into trusted products.
- Consumer tools, APIs, and custom applications expose governed data to users and workflows.

## Data Lifecycle

Data is collected across systems into a raw data store. From there, it is normalized, correlated, and enriched into an Operational Data Store. Dimensional modeling and historical processing are then applied into a Data Vault. The Data Vault is pared down into focused Data Marts for reporting, dashboards, applications, and downstream analytics.

## Architecture Notes

Use this section to explain how the platform is assembled, how data moves through each layer, and where teams should look before changing shared platform behavior.

## Recommended Pages

- System context diagram
- [Implementation planning decisions](/guide/implementation-planning)
- [Runtime infrastructure and operating system environment](/architecture/runtime-infrastructure)
- [Connector and ingestion patterns](/architecture/tool-categories)
- [Suggested tooling by category](/architecture/tooling-recommendations)
- [Raw data store, Operational Data Store, Data Vault, and Data Mart layers](/architecture/data-lifecycle)
- [Data workflow and reprocessing pattern](/architecture/data-workflow)
- [Database and persistence recommendations](/architecture/data-persistence)
- [Orchestration and recovery patterns](/architecture/orchestration)
- Custom application integration patterns
- [Dashboard, application, and visualization consumption patterns](/architecture/consumer-tools)
- [Platform positioning and differentiation](/architecture/platform-positioning)
- Access, identity, and authorization model
- Observability and reliability model
- Environment strategy and GitOps deployment model

## Ownership

Create a clear owner map for platform services, datasets, deployment pipelines, and operational runbooks. Good ownership docs make incidents shorter and onboarding calmer.
