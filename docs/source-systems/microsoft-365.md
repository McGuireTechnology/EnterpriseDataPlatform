# M365

M365 is a core EDP source system for cloud productivity, collaboration, licensing, usage, and service metadata. It should be documented separately from on-premises AD because it uses Microsoft Graph and cloud service APIs, has different identifiers, and exposes different operational data.

## Overview

M365 can provide EDP with cloud-side identity, group, license, collaboration, usage, and service information.

EDP should use M365 data to support:

- Cloud identity and account visibility
- License assignment and utilization reporting
- Group and M365 group visibility
- Teams and channel visibility
- Collaboration governance
- User activity and adoption reporting
- Cross-system identity correlation
- Onboarding and offboarding validation
- Access review and membership analysis
- Operational dashboards for cloud service usage

## Ownership

| Role | Responsibility |
| --- | --- |
| Source system owner | Owns M365 tenant operations, licensing, access policies, and service configuration |
| Technical owner | Supports app registrations, Graph permissions, admin consent, and connector access |
| Data steward | Defines license, group, team, channel, and usage reporting meaning for EDP consumers |
| Platform owner | Runs the connector, raw landing, transformations, quality checks, and downstream models |

## Data Domains

Initial M365 data domains:

- Users
- Groups and M365 groups
- Group memberships and ownership
- Teams
- Channels
- License SKUs
- User license assignments
- Service plans
- Usage reports
- Tenant and service metadata

Later domains may include:

- SharePoint sites
- OneDrive usage
- Exchange mailbox metadata
- Planner metadata
- Audit and activity reports where licensing and permissions allow
- Administrative role assignments

## Connector Options

| Connector Option | When It Fits | Notes |
| --- | --- | --- |
| Microsoft Graph API | Preferred production pattern for most M365 entities | Supports users, groups, Teams, licenses, reports, and many cloud resources |
| Microsoft Graph reports API | Preferred for M365 usage and adoption reports | Useful for usage reporting and service adoption dashboards |
| PowerShell-assisted export | Useful when an administrative module exposes needed data more easily | Should still produce governed files or API results into raw landing |
| Admin center export | Useful as an interim or fallback approach | Should be treated as a temporary bridge, not a long-term connector pattern |
| Manual seed | Acceptable only for early testing or static reference data | Should not be used for production operational reporting |

## Prebuilt Package Status

Status: prebuilt planned.

A reusable M365 connector package should include:

- Containerized Graph connector runtime
- Configuration schema for tenant, endpoints, object sets, schedules, and report periods
- Required Graph permission documentation
- App registration and admin consent setup guide
- Connection test
- Microsoft Graph throttling and retry handling
- Airflow DAG template
- Raw landing tables for users, groups, memberships, Teams, channels, licenses, and usage reports
- dbt source definitions
- ODS identity, account, group, team, channel, license, and usage mappings
- Data Vault hub, link, and satellite templates
- Data quality tests
- Operational runbook

## Required Access

The connector should use an approved Microsoft Entra app registration or managed identity pattern where available. Permissions should be application permissions or delegated permissions based on the deployment model, using least privilege wherever practical.

Document these items before production use:

- Tenant identifier
- App registration or managed identity
- Required Graph permissions
- Admin consent status
- Certificate or secret rotation pattern
- Object types and endpoints to collect
- Report periods and usage report requirements
- Throttling and retry behavior
- Network egress requirements
- Approval from the M365 tenant owner

Permission requirements vary by endpoint. Keep the exact permission list with the connector package and review it whenever Microsoft Graph endpoints or requested data domains change.

## Raw Landing Design

Recommended raw tables:

| Raw Table | Purpose |
| --- | --- |
| `raw.m365_users` | M365 or Entra user payloads and source metadata |
| `raw.m365_groups` | Group and M365 group payloads |
| `raw.m365_group_memberships` | Group membership and ownership edges |
| `raw.m365_teams` | Team payloads and metadata |
| `raw.m365_channels` | Team channel payloads and metadata |
| `raw.m365_subscribed_skus` | Tenant license SKU inventory |
| `raw.m365_user_license_details` | User license and service plan assignments |
| `raw.m365_usage_reports` | Usage and adoption report payloads |
| `raw.m365_collection_runs` | Connector run metadata, counts, timing, and status |

Each raw record should include:

- Tenant identifier
- Source endpoint or report name
- Source object identifier
- Source object type
- Report period where applicable
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
- `ods.team`
- `ods.team_channel`
- `ods.license_sku`
- `ods.license_assignment`
- `ods.service_plan`
- `ods.usage_metric`
- `ods.source_record`

Common mapping rules:

- Use stable Microsoft cloud object identifiers for source identity.
- Preserve user principal name and mail attributes as descriptive attributes because they can change.
- Correlate cloud accounts to AD accounts through immutable identifiers, synchronization attributes, UPN, mail, or approved matching rules.
- Model direct group and team memberships first.
- Add ownership and nested membership expansions as derived models with clear lineage.
- Keep license assignments separate from license utilization.
- Treat usage reports as measured observations with report periods, not as current-state identity attributes.

## Data Vault Mapping

Recommended Data Vault structures:

- Hub: identity
- Hub: cloud account
- Hub: group
- Hub: team
- Hub: channel
- Hub: license SKU
- Hub: service plan
- Link: identity to cloud account
- Link: cloud account to group
- Link: cloud account to team
- Link: team to channel
- Link: cloud account to license SKU
- Link: license SKU to service plan
- Satellites: descriptive attributes, assignment history, usage observations, source metadata, and classification history

The Data Vault should preserve historical changes in license assignments, group memberships, team memberships, service plan status, and usage observations when collected over time.

## Data Mart Outputs

Initial M365 marts:

- License assignment mart
- License utilization mart
- M365 group mart
- Teams and channel visibility mart
- User cloud account mart
- Inactive or stale cloud account mart
- Collaboration governance mart
- Identity lifecycle reconciliation mart
- Usage and adoption mart

These marts should support operational dashboards, access reviews, licensing decisions, collaboration governance, and identity lifecycle validation.

## Quality Checks

Recommended checks:

- Collection run completed successfully.
- User, group, team, channel, license, and usage counts are within expected ranges.
- Source object identifiers are present and unique within each object type.
- Membership references resolve to known users, groups, teams, or service principals where possible.
- License assignments reference known SKUs and service plans.
- Usage report periods are complete and not duplicated.
- Expected report periods arrive on schedule.
- Graph throttling responses are handled with backoff and retry behavior.
- Freshness meets the expected schedule.

## Refresh Schedule

Start with daily collection for tenant inventory, users, groups, Teams, channels, memberships, and license assignments.

Usage reports may have different availability windows and reporting periods. Store report period metadata and avoid treating usage reports as immediate real-time signals.

Use more frequent collection when operational needs require closer tracking, such as license assignment changes, onboarding, offboarding, or membership review.

## Operational Runbook

The M365 connector runbook should include:

- How to validate app registration or managed identity access
- How to confirm Graph permissions and admin consent
- How to run a connection test
- How to run a manual collection
- How to review collection counts
- How to handle Graph throttling and `Retry-After` responses
- How to handle permission failures
- How to rotate certificates or secrets
- How to backfill report periods
- How to disable the connector safely

## Known Limitations

M365 APIs may throttle requests. Connector logic should respect throttling responses and use backoff behavior.

Some reports are aggregated, delayed, anonymized, licensed, or limited by tenant settings. Document report behavior for each data domain.

M365 and AD may contain related but different identity records. Correlation rules should be explicit and auditable.

Permission requirements can change as endpoints and data domains expand. Keep permissions reviewed and documented with the connector package.

## References

- [Microsoft Graph throttling guidance](https://learn.microsoft.com/en-us/graph/throttling)
- [Microsoft Graph reports API overview](https://learn.microsoft.com/en-us/graph/reportroot-concept-overview)
- [M365 usage reports in Microsoft Graph](https://learn.microsoft.com/en-us/graph/api/resources/report?view=graph-rest-1.0)
