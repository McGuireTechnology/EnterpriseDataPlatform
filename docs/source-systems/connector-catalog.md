# Connector Catalog

The connector catalog tracks available connector options and whether EDP has a prebuilt, reusable package for each source system.

Connector status should be explicit so teams know what can be deployed quickly, what requires new work, and what is not yet supported.

## Connector Status Values

| Status | Meaning |
| --- | --- |
| Candidate | The system is under consideration, but connector design has not started |
| Planned | A connector is approved or expected, but not yet built |
| Custom Active | A working custom connector exists for a specific implementation |
| Prebuilt Available | A reusable connector package exists, but may not be deployed in every environment |
| Prebuilt Active | A reusable connector package is deployed and running |
| Paused | Work is paused because of access, priority, licensing, or technical constraints |
| Deprecated | The connector still exists but should not be used for new integrations |
| Retired | The connector is no longer supported |

## Connector Catalog

| Source Type | Common Connector Options | Prebuilt Status | Notes |
| --- | --- | --- | --- |
| [Active Directory](/source-systems/active-directory) | LDAPS query, LDAP query, PowerShell export, scheduled file export | Prebuilt planned | First source system; supports identity lifecycle, access visibility, and membership correlation |
| [Microsoft 365](/source-systems/microsoft-365) | Microsoft Graph API, reports API, admin exports, PowerShell-assisted export | Prebuilt planned | Supports users, groups, Teams, licenses, usage, and cloud collaboration visibility |
| Identity provider | API, directory query, export, vendor SDK | Planned | Common first integration for identity lifecycle and access visibility |
| Collaboration platform | API, audit exports, webhook where available | Planned | Useful for team, channel, membership, and communication governance |
| Endpoint management | API, scheduled export, vendor connector | Planned | Supports device inventory, compliance, ownership, and lifecycle views |
| Service desk | REST API, database replica, export | Planned | Supports ticket analytics, workload views, service operations, and CMDB patterns |
| Security awareness platform | API, CSV export | Planned | Supports training status, campaign completion, and compliance evidence |
| Virtualization platform | API, inventory export | Planned | Supports VM, host, cluster, capacity, and ownership visibility |
| HR or workforce system | API, export, secure file transfer | Candidate | Often important for identity lifecycle, but sensitive and governance-heavy |
| Backup or disaster recovery platform | API, scheduled export, reporting database | Candidate | Supports backup coverage, recovery readiness, and audit evidence |
| Finance or ERP system | API, database view, export | Candidate | Usually later-phase because access and definitions require stronger governance |
| Monitoring platform | API, metrics export, webhook | Candidate | Useful for correlating infrastructure health with operational records |
| Asset inventory | API, database read, export | Candidate | May overlap with endpoint, service desk, procurement, and CMDB systems |

## Prebuilt Connector Package Contents

A prebuilt connector package should include:

- Container image or build definition
- Connector configuration schema
- Required credential and permission documentation
- Connection test command or health check
- Airflow DAG or orchestration template
- Raw landing table definition
- Source metadata fields
- dbt source definitions
- ODS mapping models where available
- Data Vault mapping templates where available
- Data quality tests
- Operational runbook
- Example dashboard or mart outputs where useful

## Connector Option Types

API connectors are preferred when the source provides stable, supported APIs with adequate permissions, pagination, filtering, and rate limits.

Webhook or event connectors are useful when the source can push changes reliably, but they usually still require reconciliation jobs.

File drop connectors are useful for systems that can export scheduled CSV, JSON, XML, or Parquet files. They require strong naming, retention, validation, and duplicate-handling rules.

Database read connectors can be effective when supported by the source owner, but they need careful permissions, query load controls, and schema-change monitoring.

CDC connectors are appropriate when database change streams are available and the use case requires near-real-time or historical change capture.

Manual seed connectors are acceptable for early reference data, but they should be clearly labeled and eventually replaced with governed source integrations when possible.
