# ManageEngine Endpoint Central

ManageEngine Endpoint Central is a source system for unified endpoint management, endpoint inventory, patch management, software deployment, configuration management, remote control metadata, mobile device management, compliance, and endpoint security posture.

It should be documented separately from ManageEngine ServiceDesk Plus. Endpoint Central is usually the endpoint operations authority, while ServiceDesk Plus is the ITSM workflow and CMDB system.

## Overview

EDP should use ManageEngine Endpoint Central data to support:

- Endpoint inventory and lifecycle reporting
- Patch compliance and vulnerability remediation tracking
- Software inventory and deployment reporting
- Configuration and policy compliance
- Device ownership and user correlation
- Mobile device management visibility where enabled
- Remote office, site, and scope-of-management reporting
- Endpoint-to-ticket and endpoint-to-asset reconciliation
- Cross-system correlation with AD, M365, ServiceDesk Plus, asset inventory, security tools, and network platforms

## Ownership

| Role | Responsibility |
| --- | --- |
| Source system owner | Owns Endpoint Central administration, endpoint agents, patch policy, configuration deployment, inventory scans, and reporting expectations |
| Technical owner | Supports API access, OAuth or API credentials, cloud or on-prem connectivity, agent scope, and connector setup |
| Data steward | Defines endpoint, patch, software, user, compliance, and deployment reporting meaning for EDP consumers |
| Platform owner | Runs the connector, raw landing, transformations, quality checks, and downstream models |

## Data Domains

Initial ManageEngine Endpoint Central data domains:

- Managed computers and devices
- Users associated with managed devices
- Agents and scope of management
- Hardware inventory
- Software inventory
- Patch inventory and patch deployment status
- Missing patches and vulnerability posture
- Configuration collections and deployment status
- Remote offices, domains, sites, and groups
- Mobile devices where MDM is enabled
- Compliance status and reports

Later domains may include:

- BitLocker or encryption status where available
- Browser and extension inventory
- USB or device control posture
- Endpoint security add-on data
- Remote control audit metadata
- Custom reports and query outputs
- Server, desktop, laptop, and mobile product-specific modules

## Connector Options

| Connector Option | When It Fits | Notes |
| --- | --- | --- |
| Endpoint Central Cloud REST API | Preferred production pattern for cloud tenants | Uses OAuth 2.0 for API authorization and authentication |
| Endpoint Central on-prem REST API | Preferred production pattern for supported on-prem deployments | Validate product build, base URL, and API coverage before implementation |
| Custom query reports | Useful when supported APIs do not expose a required report shape | Should be governed and versioned like other exports |
| Scheduled report export | Useful as an interim or fallback approach | Should be treated as a bridge until API collection is available |
| Database read or reporting replica | Useful only when approved by the source owner for on-prem deployments | Requires careful load control, schema-change monitoring, and support boundaries |
| Manual seed | Acceptable only for early testing or static reference data | Should not be used for production operational reporting |

## Prebuilt Package Status

Status: planned.

A reusable ManageEngine Endpoint Central connector package should include:

- Containerized Endpoint Central connector runtime
- Configuration schema for deployment type, base URL, region, authentication, object sets, schedules, filters, and report windows
- Required role, permission, OAuth, API key, and scope documentation
- Credential creation, storage, and rotation guide
- Connection test
- Pagination, rate limit, retry, and backoff handling
- Airflow DAG template
- Raw landing tables for devices, users, hardware, software, patches, deployments, configurations, groups, remote offices, MDM devices, compliance, and collection runs
- dbt source definitions
- ODS endpoint, software, patch, deployment, compliance, user, and asset mapping models
- Data Vault hub, link, and satellite templates
- Data quality tests
- Operational runbook

## Required Access

Document these items before production use:

- Endpoint Central deployment type: cloud or on-prem
- Instance URL and region where applicable
- API version and product build for on-prem deployments
- OAuth client, API key, or approved service credential
- Required roles and API permissions
- Device groups, domains, remote offices, and scopes to collect
- Object types and report windows to collect
- Custom reports or custom query definitions where used
- Credential rotation pattern
- Network egress or firewall requirements
- Approval from the endpoint management owner and data steward

Use least-privilege access. Avoid collecting remote-control details, user activity, or security-sensitive endpoint data unless the reporting use case and retention controls are approved.

## Raw Landing Design

Recommended raw tables:

| Raw Table | Purpose |
| --- | --- |
| `raw.endpointcentral_devices` | Managed endpoint payloads |
| `raw.endpointcentral_device_users` | Device-to-user association payloads |
| `raw.endpointcentral_agents` | Agent and scope-of-management payloads |
| `raw.endpointcentral_hardware_inventory` | Hardware inventory payloads |
| `raw.endpointcentral_software_inventory` | Software inventory payloads |
| `raw.endpointcentral_patches` | Patch catalog and patch metadata |
| `raw.endpointcentral_missing_patches` | Missing patch observations |
| `raw.endpointcentral_patch_deployments` | Patch deployment payloads |
| `raw.endpointcentral_configurations` | Configuration collection payloads |
| `raw.endpointcentral_configuration_deployments` | Configuration deployment status payloads |
| `raw.endpointcentral_groups` | Device group and custom group payloads |
| `raw.endpointcentral_remote_offices` | Remote office and site payloads |
| `raw.endpointcentral_mdm_devices` | Mobile device payloads where MDM is enabled |
| `raw.endpointcentral_compliance` | Compliance report payloads |
| `raw.endpointcentral_collection_runs` | Connector run metadata, counts, timing, and status |

Each raw record should include:

- Instance identifier
- Source endpoint or report name
- Source object identifier
- Source object type
- Device identifier or resource identifier where applicable
- Observation timestamp where applicable
- Extraction timestamp
- Ingestion run identifier
- Connector version
- Raw payload

## ODS Mapping

Recommended ODS entities:

- `ods.endpoint`
- `ods.endpoint_agent`
- `ods.endpoint_user_assignment`
- `ods.hardware_component`
- `ods.software_installation`
- `ods.software_product`
- `ods.patch`
- `ods.patch_status`
- `ods.deployment`
- `ods.configuration_policy`
- `ods.compliance_observation`
- `ods.device_group`
- `ods.site`
- `ods.source_record`

Common mapping rules:

- Preserve Endpoint Central resource identifiers as source keys.
- Correlate endpoints to enterprise assets by serial number, service tag, hostname, domain, MAC address, and approved matching rules.
- Correlate endpoint users to identities through approved identifiers such as username, UPN, email address, employee identifier, or directory object.
- Treat patch, software, compliance, and agent status as time-bound observations.
- Keep desired configuration, deployment status, and observed endpoint state as separate entities.
- Reconcile Endpoint Central inventory with ServiceDesk Plus, AD, M365, Intune, Jamf, Meraki, and security platform data using explicit source-of-authority rules.

## Data Vault Mapping

Recommended Data Vault structures:

- Hub: endpoint
- Hub: identity
- Hub: software product
- Hub: patch
- Hub: deployment
- Hub: configuration policy
- Hub: device group
- Hub: site
- Link: endpoint to identity
- Link: endpoint to software product
- Link: endpoint to patch
- Link: endpoint to deployment
- Link: endpoint to configuration policy
- Link: endpoint to device group
- Satellites: endpoint attributes, agent state, hardware observations, software installation observations, patch status, deployment status, compliance observations, source metadata, and classification history

The Data Vault should preserve historical changes in endpoint inventory, user association, software installation, patch status, compliance state, configuration deployment, and group membership when collected over time.

## Data Mart Outputs

Initial Endpoint Central marts:

- Endpoint inventory mart
- Patch compliance mart
- Missing patch and vulnerability remediation mart
- Software inventory mart
- Software deployment mart
- Endpoint compliance mart
- Agent health mart
- Device ownership and lifecycle mart
- Endpoint-to-ServiceDesk Plus reconciliation mart
- Asset and CMDB reconciliation mart

These marts should support endpoint operations, patch governance, audit readiness, software management, service desk correlation, and lifecycle validation.

## Quality Checks

Recommended checks:

- Collection run completed successfully.
- Device, software, patch, deployment, compliance, group, and remote office counts are within expected ranges.
- Source object identifiers are present and unique within each object type.
- Device records include hostname and at least one stable hardware or agent identifier where available.
- Patch and deployment records resolve to known devices.
- Software installation records resolve to known devices and products.
- User associations resolve to known identities where available.
- Custom reports expected by downstream models are present and current.
- API rate-limit responses are handled with backoff and retry behavior.
- Freshness meets the expected schedule.

## Refresh Schedule

Start with daily collection for endpoint inventory, users, hardware, software, patch status, configuration status, groups, remote offices, and compliance reports.

Use more frequent collection when operational needs require closer tracking, such as active patch remediation, critical vulnerability response, endpoint lifecycle campaigns, or compliance reporting deadlines.

## Operational Runbook

The Endpoint Central connector runbook should include:

- How to validate API access
- How to confirm cloud or on-prem API version and build
- How to run a connection test
- How to run a manual collection
- How to review collection counts
- How to handle permission failures
- How to handle API rate limits and retries
- How to rotate credentials
- How to validate custom reports
- How to disable the connector safely

## Known Limitations

Endpoint Central API coverage can differ between cloud and on-prem deployments and across product builds. Document the exact deployment type, build, API version, enabled modules, and custom reports for each implementation.

Endpoint data can include sensitive user, device, vulnerability, and security posture details. Apply classification, masking, retention, and role-based access controls before making detailed endpoint records broadly available.

Endpoint Central and ServiceDesk Plus may both contain asset records. Keep source-of-authority rules explicit and reconcile rather than overwriting one source with the other.

## References

- [Endpoint Central Cloud API documentation](https://www.manageengine.com/products/desktop-central/api/cloud_index.html)
- [Endpoint Central API documentation](https://www.manageengine.com/products/desktop-central/api-doc.html)
- [How Endpoint Central works](https://download.manageengine.com/products/desktop-central/help/getting_started/working_of_desktop_central.html)
- [Endpoint Central custom query reports](https://info.manageengine.com/products/desktop-central/help/mobile_device_management/reports/mdm-custom_query_report.html)
