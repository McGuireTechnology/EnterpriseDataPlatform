# Source System Inventory

Use this page to document systems that EDP may collect from. The inventory should include both active integrations and candidate systems.

## Inventory Fields

| Field | Description |
| --- | --- |
| Source system | Name of the system or platform |
| Business capability | What operational domain the system supports |
| System owner | Team or role responsible for the system |
| Technical owner | Team or role responsible for integration support |
| Data steward | Person or role responsible for definitions and data quality |
| Integration status | Candidate, planned, active, paused, deprecated, or retired |
| Connector status | None, custom planned, custom active, prebuilt available, prebuilt active |
| Integration pattern | API, webhook, file drop, database read, CDC, export, SDK, or manual seed |
| Authentication method | OAuth, service account, API key, certificate, database credential, or other |
| Required credentials | Non-secret description of required credentials, scopes, roles, or grants |
| Data domains | Identities, assets, tickets, licenses, memberships, finance, operations, etc. |
| Data sensitivity | Public, internal, confidential, restricted, regulated, or organization-defined class |
| Refresh cadence | Near-real-time, hourly, daily, weekly, monthly, on demand |
| Historical availability | Whether the source exposes current state, history, events, or snapshots |
| Rate limits | Known API or export limits |
| Backfill support | Whether historical data can be backfilled |
| Raw landing target | Raw schema/table or object storage target |
| ODS entities | Normalized entities produced by this source |
| Vault structures | Hubs, links, and satellites supported by this source |
| Data marts | Marts or reports fed by this source |
| Operational risks | Access limits, licensing constraints, data quality concerns, API instability |
| Support path | Where connector or source issues should be escalated |
| Documentation link | Link to source-specific setup or vendor documentation |

## Starter Inventory

| Source System | Business Capability | Integration Status | Connector Status | Integration Pattern | Data Domains |
| --- | --- | --- | --- | --- | --- |
| [Active Directory](/source-systems/active-directory) | Identity and access management | Planned | Prebuilt planned | LDAPS, LDAP, PowerShell export, or scheduled directory query | Users, groups, computers, OUs, memberships |
| [Microsoft 365](/source-systems/microsoft-365) | Cloud productivity and collaboration | Planned | Prebuilt planned | Microsoft Graph API, reports API, admin exports where needed | Users, groups, teams, channels, licenses, usage, service metadata |
| HR or workforce system | Workforce lifecycle | Candidate | Candidate | API, export, secure file transfer | Employees, departments, managers, job status, hire and termination dates |
| Identity provider | Identity and access management | Candidate | Planned | API or directory query | Identities, groups, memberships |
| Collaboration platform | Communication and collaboration | Candidate | Planned | API | Teams, channels, memberships, activity |
| Endpoint management | Device and endpoint operations | Candidate | Planned | API or export | Devices, users, compliance, inventory |
| Service desk | Tickets and operational work | Candidate | Planned | API | Incidents, requests, changes, assets |
| Security awareness platform | Training and awareness | Candidate | Planned | API or export | Users, assignments, completions |
| Virtualization platform | Infrastructure operations | Candidate | Planned | API | Hosts, VMs, clusters, capacity |
| Backup or disaster recovery platform | Operational resilience | Candidate | Candidate | API or export | Backup jobs, restore points, protected assets, success and failure status |

## Source Documentation Template

Create a dedicated page for each important source system when it becomes active or near-term.

Recommended page sections:

- Overview
- Ownership
- Data domains
- Integration pattern
- Required access
- Connector options
- Prebuilt package status
- Raw landing design
- ODS mapping
- Data Vault mapping
- Data Mart outputs
- Quality checks
- Refresh schedule
- Operational runbook
- Known limitations
