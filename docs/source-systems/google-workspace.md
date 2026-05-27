# Google Workspace

Google Workspace is a core EDP source system for cloud identity, collaboration, licensing, device, usage, audit, and administrative visibility. It should be documented separately from M365 because it uses Google Workspace Admin APIs, Google Cloud authentication patterns, and Google-specific identifiers.

## Overview

Google Workspace can provide EDP with tenant-side visibility into accounts, groups, organizational units, shared collaboration services, ChromeOS devices, mobile devices, application access, audit events, and administrative alerts.

EDP should use Google Workspace data to support:

- Cloud account and identity visibility
- Group and membership reporting
- Organizational unit and policy context
- License assignment and service entitlement analysis
- Gmail, Drive, Calendar, Meet, and Admin activity reporting
- ChromeOS and mobile device inventory
- Security alert and audit evidence collection
- Onboarding and offboarding validation
- Access review and collaboration governance
- Cross-system identity correlation with AD, HR, and service desk data

## Ownership

| Role | Responsibility |
| --- | --- |
| Source system owner | Owns Google Workspace tenant operations, admin configuration, licensing, and service policy |
| Technical owner | Supports Google Cloud project setup, service accounts, OAuth scopes, domain-wide delegation, and API access |
| Data steward | Defines account, group, device, license, audit, and collaboration reporting meaning for EDP consumers |
| Platform owner | Runs the connector, raw landing, transformations, quality checks, and downstream models |

## Data Domains

Initial Google Workspace data domains:

- Users
- Groups
- Group memberships
- Organizational units
- Roles and administrative assignments
- Domain aliases and tenant metadata
- ChromeOS devices
- Mobile devices
- License assignments
- Application tokens and connected apps where approved
- Usage reports
- Audit activities
- Alert Center alerts

Later domains may include:

- Drive files and shared drive metadata
- Calendar resources and events metadata
- Gmail settings and delegated mailbox context
- Meet activity and meeting events
- Chat spaces and memberships
- Workspace Events API subscriptions where near-real-time behavior is needed

## Connector Options

| Connector Option | When It Fits | Notes |
| --- | --- | --- |
| Admin SDK Directory API | Preferred production pattern for users, groups, members, organizational units, roles, and devices | Good baseline for tenant inventory and identity correlation |
| Admin SDK Reports API | Preferred for audit events and usage reporting | Useful for activity history, service usage, admin events, login events, and governance reporting |
| Enterprise License Manager API | Useful for license assignment reporting where enabled | Keep license semantics separate from actual service usage |
| Alert Center API | Useful for security and operational alert evidence | Treat alerts as security events with owner, status, and response workflow context |
| Google Workspace Events API | Useful for event-driven collection when supported by the needed resource type | Use with reconciliation jobs because event subscriptions rarely replace full inventory collection |
| Admin console export | Useful as an interim or fallback approach | Should be treated as a temporary bridge, not a long-term connector pattern |
| Manual seed | Acceptable only for early testing or static reference data | Should not be used for production operational reporting |

## Prebuilt Package Status

Status: planned.

A reusable Google Workspace connector package should include:

- Containerized Google Workspace connector runtime
- Configuration schema for customer ID, domains, object sets, schedules, report periods, and API scopes
- Google Cloud project, service account, OAuth scope, and domain-wide delegation setup guide
- Connection test
- Pagination, quota, retry, and backoff handling
- Airflow DAG template
- Raw landing tables for users, groups, memberships, organizational units, devices, licenses, usage reports, audit activities, and alerts
- dbt source definitions
- ODS identity, account, group, membership, device, license, usage, alert, and audit mappings
- Data Vault hub, link, and satellite templates
- Data quality tests
- Operational runbook

## Required Access

The connector should use an approved Google Cloud project and service account with domain-wide delegation when collecting administrator-scoped tenant data. Use least-privilege OAuth scopes and document the exact scopes required for each enabled data domain.

Document these items before production use:

- Customer ID and primary domain
- Google Cloud project
- Service account identifier
- Domain-wide delegation status
- Required OAuth scopes
- Admin role or source-owner approval
- Object types and APIs to collect
- Report periods and audit application names
- Quota, retry, and backoff behavior
- Network egress requirements
- Secret or key rotation pattern
- Approval from the Google Workspace tenant owner

Permission requirements vary by API and endpoint. Keep the exact scope list with the connector package and review it whenever Google APIs, object domains, or requested reports change.

## Raw Landing Design

Recommended raw tables:

| Raw Table | Purpose |
| --- | --- |
| `raw.google_workspace_users` | User payloads and source metadata |
| `raw.google_workspace_groups` | Group payloads |
| `raw.google_workspace_group_memberships` | Group membership edges |
| `raw.google_workspace_org_units` | Organizational unit hierarchy and policy context |
| `raw.google_workspace_roles` | Admin roles and assignments |
| `raw.google_workspace_chromeos_devices` | ChromeOS device inventory payloads |
| `raw.google_workspace_mobile_devices` | Mobile device inventory payloads |
| `raw.google_workspace_license_assignments` | License assignment payloads |
| `raw.google_workspace_usage_reports` | Usage report payloads and report metadata |
| `raw.google_workspace_audit_activities` | Audit activity payloads |
| `raw.google_workspace_alerts` | Alert Center payloads |
| `raw.google_workspace_collection_runs` | Connector run metadata, counts, timing, and status |

Each raw record should include:

- Customer ID
- Primary domain
- Source API and endpoint
- Source object identifier
- Source object type
- Report period or event timestamp where applicable
- Extraction timestamp
- Ingestion run identifier
- Connector version
- Raw payload

## ODS Mapping

Recommended ODS entities:

- `ods.identity`
- `ods.account`
- `ods.group`
- `ods.group_membership`
- `ods.organizational_unit`
- `ods.admin_role_assignment`
- `ods.device`
- `ods.license_assignment`
- `ods.usage_metric`
- `ods.audit_event`
- `ods.security_alert`
- `ods.source_record`

Common mapping rules:

- Use stable Google user IDs and group IDs as source identifiers.
- Preserve primary email, aliases, and suspended status as descriptive attributes because they can change over time.
- Correlate Google Workspace accounts to AD, HR, and service desk records through employee identifiers, email, UPN, or approved matching rules.
- Keep group membership and administrative role assignments as auditable relationships.
- Model usage reports and audit events as observations, not current-state identity attributes.
- Keep device inventory separate from account inventory, then link through assigned users where supported.
- Treat deleted, suspended, archived, and unmanaged states explicitly.

## Data Vault Mapping

Recommended Data Vault structures:

- Hub: identity
- Hub: cloud account
- Hub: group
- Hub: organizational unit
- Hub: device
- Hub: license
- Hub: alert
- Link: identity to cloud account
- Link: cloud account to group
- Link: cloud account to admin role
- Link: cloud account to device
- Link: cloud account to license
- Link: group to group for nested groups where collected
- Satellites: descriptive attributes, assignment history, membership history, usage observations, audit events, alert status, source metadata, and classification history

The Data Vault should preserve historical changes in account state, group membership, role assignment, license assignment, device assignment, and alert lifecycle when collected over time.

## Data Mart Outputs

Initial Google Workspace marts:

- Google account mart
- Google group and membership mart
- Google admin role assignment mart
- Google license assignment mart
- Google usage and adoption mart
- Google audit activity mart
- Google alert mart
- ChromeOS and mobile device mart
- Inactive or suspended account mart
- Identity lifecycle reconciliation mart
- Collaboration governance mart

These marts should support operational dashboards, access reviews, license decisions, device governance, security monitoring, and lifecycle validation.

## Quality Checks

Recommended checks:

- Collection run completed successfully.
- User, group, membership, device, license, usage, audit, and alert counts are within expected ranges.
- Source object identifiers are present and unique within each object type.
- Group membership references resolve to known users, groups, or service accounts where possible.
- Organizational unit paths resolve to known organizational units.
- License assignments reference known products and SKUs where collected.
- Usage report periods are complete and not duplicated.
- Audit activity timestamps are present and normalized.
- API quota and retry responses are handled with backoff.
- Freshness meets the expected schedule.

## Refresh Schedule

Start with daily collection for tenant inventory, users, groups, memberships, organizational units, devices, and license assignments.

Usage reports and audit events may have different availability windows. Store report period and event timestamp metadata, and avoid treating aggregated usage reports as immediate real-time signals.

Use more frequent collection when operational needs require closer tracking, such as onboarding, offboarding, administrative role changes, security alerts, or event-driven workflows.

## Operational Runbook

The Google Workspace connector runbook should include:

- How to validate Google Cloud project and API enablement
- How to confirm service account and domain-wide delegation setup
- How to verify OAuth scopes and admin approval
- How to run a connection test
- How to run a manual collection
- How to review collection counts
- How to handle API quota, retry, and backoff behavior
- How to handle permission failures
- How to rotate service account keys or adopt keyless authentication where available
- How to backfill report periods
- How to disable the connector safely

## Known Limitations

Google Workspace APIs may enforce quotas, page limits, eventual consistency, and report availability delays. Connector logic should handle pagination, retries, and backoff.

Some audit, security, investigation, and reporting data can depend on Google Workspace edition, tenant settings, retention periods, and administrator privileges.

Google Workspace accounts and AD accounts may represent the same person but use different identifiers. Correlation rules should be explicit and auditable.

Permission requirements can change as endpoints and data domains expand. Keep OAuth scopes reviewed and documented with the connector package.

## References

- [Admin SDK Directory API](https://developers.google.com/workspace/admin/directory/reference/rest)
- [Admin SDK Reports API](https://developers.google.com/workspace/admin/reports/reference/rest)
- [Google Workspace Alert Center API](https://developers.google.com/workspace/admin/alertcenter/reference/rest)
- [Google Workspace Events API](https://developers.google.com/workspace/events)
