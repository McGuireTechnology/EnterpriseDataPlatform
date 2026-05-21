# Data Lifecycle

EDP organizes operational data into layers. Each layer has a distinct purpose so teams can ingest quickly, normalize carefully, preserve history, and publish focused data products without mixing concerns.

## Source Systems

Source systems are the operational tools of record. They may include identity providers, collaboration suites, endpoint platforms, service desks, infrastructure systems, security tools, business applications, SaaS platforms, and departmental systems.

EDP should respect source-system ownership. The platform reads from source systems through approved APIs, exports, events, or database access patterns, then records how each dataset was collected.

## Raw Data Store

The raw data store captures source data with minimal transformation. It supports traceability, replay, debugging, and historical retention.

Raw data should preserve source identifiers, extraction timestamps, source payload shape, and enough metadata to explain where the record came from. This layer is optimized for faithful capture, not user-facing reporting.

## Operational Data Store

The Operational Data Store normalizes, correlates, and enriches raw data into current-state operational views. It is the working layer for near-real-time visibility and operational workflows.

Common ODS responsibilities include:

- Normalizing identities, assets, permissions, tickets, licenses, and memberships
- Resolving cross-system identifiers into shared entities
- Highlighting mismatches, missing assignments, orphaned records, or stale records
- Supporting dashboards, alerts, and operational applications that need current state

## Data Vault

The Data Vault preserves historical relationships and changes across the enterprise. It is the durable history layer for dimensional modeling, trend analysis, audit evidence, and long-term analytics.

This layer should capture business keys, relationships, descriptive attributes, load timestamps, source metadata, and history in a way that can survive source-system changes and model evolution.

## Data Marts

Data Marts are focused, consumable datasets built for specific reporting, dashboard, application, or analytical needs. They are intentionally narrower than the Data Vault and shaped around user questions.

Examples include:

- Identity lifecycle mart
- Access review mart
- Licensing and utilization mart
- Endpoint and asset inventory mart
- Service operations mart
- Governance and audit evidence mart

## Presentation and Application Layer

Dashboards, reports, alerts, APIs, and custom applications should consume governed marts or ODS views rather than rebuilding logic from raw extracts. This keeps user-facing outputs aligned with shared definitions and reduces duplicate reporting logic.

See [Consumer Tools](/architecture/consumer-tools) for recommended tools and patterns for the user-facing layer.
