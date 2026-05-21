# Connector Standard

Connectors should be repeatable, observable, secure, and easy to deploy into a new environment. A connector should not be a one-off script hidden on a workstation.

## Design Principles

Connectors should:

- Use supported source-system interfaces.
- Separate code, configuration, and secrets.
- Run in containers where practical.
- Be orchestrated by the platform scheduler.
- Record source metadata and ingestion metadata.
- Support connection tests before scheduled execution.
- Handle retries, pagination, rate limits, and partial failures.
- Emit logs and metrics that operators can use.
- Land raw data before transformation.
- Include data quality checks.
- Be documented with ownership, access requirements, and support paths.

## Required Metadata

Every raw record or ingestion batch should capture enough metadata to explain where data came from and how it was loaded.

Recommended metadata fields:

- Source system name
- Source object or endpoint
- Source record identifier when available
- Extraction timestamp
- Ingestion run identifier
- Connector version
- Load timestamp
- Payload hash or checksum where useful
- Source update timestamp when available
- Tenant, environment, or organization identifier where applicable

## Configuration and Secrets

Connector configuration may include:

- Source endpoint
- Tenant or environment identifier
- Schedule
- Page size or batch size
- Source object list
- Raw landing target
- Feature flags
- Backfill window

Connector secrets may include:

- API tokens
- OAuth client secrets
- Certificates
- Private keys
- Passwords
- Database credentials

Secrets must be supplied through the runtime environment's secret management system and must not be committed to Git.

## Prebuilt Connector Requirements

A connector is considered prebuilt when it can be reused across environments by supplying configuration and credentials.

Prebuilt connectors should include:

- Containerized runtime
- Versioned release artifact
- Documented configuration schema
- Documented credential requirements
- Connection test
- Airflow DAG or orchestration template
- Raw landing schema
- dbt source definition
- Baseline data quality tests
- Operational runbook
- Example environment configuration without secrets

## Operational Expectations

Every production connector should have:

- Owner
- Source system owner
- Support path
- Refresh schedule
- Freshness expectation
- Failure alerting
- Retry behavior
- Backfill procedure
- Rate-limit handling
- Change detection strategy
- Run history and audit records

## Promotion Checklist

Before promoting a connector to production:

- Source owner has approved the access pattern.
- Required credentials are documented and provisioned.
- Least-privilege permissions are used.
- Connection test passes.
- Raw landing table or object path is defined.
- ODS mapping is documented or intentionally deferred.
- Data quality checks are defined.
- Failure and retry behavior are tested.
- Logs and metrics are visible.
- Backfill behavior is understood.
- Runbook exists.
- Dashboard, mart, or consuming workflow owner is identified.
