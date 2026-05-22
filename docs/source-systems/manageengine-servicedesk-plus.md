# ManageEngine ServiceDesk Plus

ManageEngine ServiceDesk Plus is a source system for IT service management, service requests, incidents, problems, changes, assets, CMDB records, technicians, requesters, SLAs, approvals, and operational work history.

It should be documented separately from endpoint management platforms. ServiceDesk Plus is usually the service workflow and CMDB system, while tools such as ManageEngine Endpoint Central, Intune, Jamf, and Meraki provide endpoint or infrastructure state.

## Overview

EDP should use ManageEngine ServiceDesk Plus data to support:

- Incident, request, problem, and change analytics
- SLA performance and service operations reporting
- Technician, group, category, priority, and workload analysis
- Requester and department service consumption reporting
- Asset and CMDB reconciliation
- Approval and service catalog workflow visibility
- Onboarding, offboarding, and lifecycle ticket validation
- Cross-system correlation with Active Directory, Microsoft 365, HR, endpoint management, asset inventory, and security platforms

## Ownership

| Role | Responsibility |
| --- | --- |
| Source system owner | Owns ServiceDesk Plus administration, service workflow, categories, SLAs, service catalog, CMDB, and reporting expectations |
| Technical owner | Supports API access, OAuth or API credentials, cloud or on-prem connectivity, webhooks where used, and connector setup |
| Data steward | Defines request, incident, change, asset, CI, SLA, approval, and service catalog reporting meaning for EDP consumers |
| Platform owner | Runs the connector, raw landing, transformations, quality checks, and downstream models |

## Data Domains

Initial ManageEngine ServiceDesk Plus data domains:

- Requests and incidents
- Problems
- Changes and releases where licensed
- Tasks, notes, worklogs, attachments metadata, and resolutions
- Requesters
- Technicians and support groups
- Departments, sites, categories, priorities, impacts, urgencies, and statuses
- Service catalog templates and approvals
- Assets
- CMDB configuration items and relationships
- SLAs and operational timestamps

Later domains may include:

- Projects
- Purchase and contract records
- Knowledge base metadata
- Survey results
- Maintenance windows
- Custom modules and additional fields
- Analytics Plus extracts where used as a reporting layer

## Connector Options

| Connector Option | When It Fits | Notes |
| --- | --- | --- |
| ServiceDesk Plus Cloud API v3 | Preferred production pattern for cloud tenants | REST API supports web-client operations and OAuth-based integrations |
| ServiceDesk Plus on-prem API v3 | Preferred production pattern for supported on-prem builds | Use build-specific API documentation and validate V3 module coverage |
| CMDB and asset APIs | Required when EDP needs asset and CI data | Asset and CMDB API behavior can vary by build and migration state |
| Webhooks or custom triggers | Useful for event-driven workflows | Should complement scheduled reconciliation jobs |
| Database read or reporting replica | Useful only when approved by the source owner for on-prem deployments | Requires careful load control, schema-change monitoring, and support boundaries |
| Report export or CSV export | Useful as an interim or fallback approach | Should be treated as a bridge until API collection is available |
| Manual seed | Acceptable only for early testing or static reference data | Should not be used for production operational reporting |

## Prebuilt Package Status

Status: planned.

A reusable ManageEngine ServiceDesk Plus connector package should include:

- Containerized ServiceDesk Plus connector runtime
- Configuration schema for deployment type, base URL, authentication, object sets, schedules, filters, and report windows
- Required role, permission, OAuth, API key, and scope documentation
- Credential creation, storage, and rotation guide
- Connection test
- Pagination, rate limit, retry, and backoff handling
- Airflow DAG template
- Raw landing tables for requests, changes, problems, tasks, worklogs, requesters, technicians, groups, assets, CIs, approvals, SLAs, and collection runs
- dbt source definitions
- ODS ticket, workflow, asset, CI, identity, and service mapping models
- Data Vault hub, link, and satellite templates
- Data quality tests
- Operational runbook

## Required Access

Document these items before production use:

- ServiceDesk Plus deployment type: cloud or on-prem
- Instance URL and region where applicable
- API version and product build for on-prem deployments
- OAuth client, API key, or approved service credential
- Required roles and module permissions
- Modules, filters, and report windows to collect
- Custom fields and required field mappings
- Attachment handling policy
- Webhook endpoint and validation pattern where webhooks are used
- Credential rotation pattern
- Network egress or firewall requirements
- Approval from the service desk owner and data steward

Use least-privilege access. Avoid collecting full ticket descriptions, attachments, or comments unless the reporting use case and retention controls are clearly approved.

## Raw Landing Design

Recommended raw tables:

| Raw Table | Purpose |
| --- | --- |
| `raw.sdp_requests` | Request and incident payloads |
| `raw.sdp_request_notes` | Request note metadata or approved note payloads |
| `raw.sdp_request_worklogs` | Worklog payloads |
| `raw.sdp_tasks` | Task payloads |
| `raw.sdp_problems` | Problem payloads |
| `raw.sdp_changes` | Change payloads |
| `raw.sdp_approvals` | Approval payloads |
| `raw.sdp_requesters` | Requester payloads |
| `raw.sdp_technicians` | Technician payloads |
| `raw.sdp_groups` | Support group payloads |
| `raw.sdp_assets` | Asset payloads |
| `raw.sdp_cis` | CMDB configuration item payloads |
| `raw.sdp_ci_relationships` | CMDB relationship payloads |
| `raw.sdp_service_catalog` | Service catalog and template payloads |
| `raw.sdp_slas` | SLA payloads and related metadata |
| `raw.sdp_collection_runs` | Connector run metadata, counts, timing, and status |

Each raw record should include:

- Instance identifier
- Source endpoint or module
- Source object identifier
- Source object type
- Updated timestamp where available
- Extraction timestamp
- Ingestion run identifier
- Connector version
- Raw payload

## ODS Mapping

Recommended ODS entities:

- `ods.ticket`
- `ods.ticket_worklog`
- `ods.ticket_task`
- `ods.problem`
- `ods.change`
- `ods.approval`
- `ods.identity`
- `ods.account`
- `ods.support_group`
- `ods.asset`
- `ods.configuration_item`
- `ods.configuration_item_relationship`
- `ods.service_catalog_item`
- `ods.sla_observation`
- `ods.source_record`

Common mapping rules:

- Preserve ServiceDesk Plus request, problem, change, asset, and CI identifiers as source keys.
- Correlate requesters and technicians to identities through approved identifiers such as email address, employee identifier, or directory account.
- Model requests, problems, and changes separately even when they are linked in the source.
- Treat status, assignment, SLA, and approval changes as lifecycle events when history is available.
- Keep ticket text and attachment content out of broad reporting models unless explicitly approved.
- Reconcile ServiceDesk Plus assets and CIs with Endpoint Central, AD, Microsoft 365, Meraki, and procurement sources using approved matching rules.

## Data Vault Mapping

Recommended Data Vault structures:

- Hub: ticket
- Hub: problem
- Hub: change
- Hub: identity
- Hub: support group
- Hub: asset
- Hub: configuration item
- Hub: service catalog item
- Link: requester to ticket
- Link: technician to ticket
- Link: support group to ticket
- Link: ticket to asset
- Link: ticket to change or problem
- Link: configuration item to configuration item
- Satellites: ticket attributes, status history, assignment history, SLA observations, approval state, worklog summary, asset attributes, CI attributes, source metadata, and classification history

The Data Vault should preserve historical changes in ticket status, assignment, approval, SLA state, asset state, CI relationships, and workflow outcomes when collected over time.

## Data Mart Outputs

Initial ServiceDesk Plus marts:

- Service desk request mart
- Incident and SLA mart
- Technician workload mart
- Request backlog and aging mart
- Change management mart
- Problem management mart
- Service catalog demand mart
- Asset and CMDB reconciliation mart
- Onboarding and offboarding ticket mart
- Audit evidence mart

These marts should support service operations, governance, asset reconciliation, leadership reporting, compliance evidence, and lifecycle validation.

## Quality Checks

Recommended checks:

- Collection run completed successfully.
- Request, problem, change, asset, CI, requester, and technician counts are within expected ranges.
- Source object identifiers are present and unique within each object type.
- Tickets resolve to known requesters, technicians, statuses, and support groups where available.
- Worklogs, tasks, approvals, and notes resolve to known parent records.
- Assets and CIs resolve to known products, states, sites, or owners where available.
- Custom fields expected by downstream models are present.
- API rate-limit responses are handled with backoff and retry behavior.
- Freshness meets the expected schedule.

## Refresh Schedule

Start with daily collection for reference data, service catalog metadata, assets, CIs, and closed historical records.

Collect active requests, incidents, problems, changes, tasks, approvals, and worklogs more frequently when operational reporting requires it. Use incremental updated-time filters where available.

## Operational Runbook

The ServiceDesk Plus connector runbook should include:

- How to validate API access
- How to confirm cloud or on-prem API version and build
- How to run a connection test
- How to run a manual collection
- How to review collection counts
- How to handle permission failures
- How to handle API rate limits and retries
- How to rotate credentials
- How to update custom-field mappings
- How to disable the connector safely

## Known Limitations

ServiceDesk Plus API behavior and module coverage can differ between cloud and on-prem deployments and across product builds. Document the exact deployment type, build, API version, and enabled modules for each implementation.

Ticket descriptions, notes, attachments, and worklogs can contain sensitive employee, customer, security, or incident details. Apply classification, masking, retention, and role-based access controls before making detailed records broadly available.

CMDB and asset data may overlap with endpoint, network, procurement, and discovery sources. Keep source-of-authority rules explicit.

## References

- [ServiceDesk Plus Cloud API v3 documentation](https://www.manageengine.com/products/service-desk/sdpod-v3-api/)
- [ServiceDesk Plus on-prem API v3 documentation](https://www.manageengine.com/products/service-desk/sdpop-v3-api/)
- [ServiceDesk Plus API migration guide](https://help.servicedeskplus.com/api/how-to-migrate-to-v3-api.html)
- [ServiceDesk Plus asset API changes](https://help.servicedeskplus.com/asset-api-changes)
- [ServiceDesk Plus CMDB API V1 and V3 comparison](https://help.servicedeskplus.com/cmdb-api-v1-and-v3-comparison)
