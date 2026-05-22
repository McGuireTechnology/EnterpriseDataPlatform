# Cisco Meraki Dashboard

Cisco Meraki Dashboard is a source system for cloud-managed network inventory, configuration, telemetry, licensing, client activity, and alert events.

It should be documented separately from generic network infrastructure. Meraki Dashboard is the cloud control plane for Meraki organizations, networks, devices, clients, wireless, switching, security appliance, camera, sensor, and Systems Manager data.

## Overview

EDP should use Cisco Meraki Dashboard data to support:

- Network organization and site inventory
- Meraki device inventory and lifecycle reporting
- Network, SSID, VLAN, switch port, appliance, and wireless configuration visibility
- Client and endpoint network activity correlation
- Device health, status, uplink, and connectivity reporting
- License and subscription tracking
- Configuration change visibility
- Alert and webhook event processing
- Cross-system reconciliation with asset inventory, service desk, CMDB, identity, endpoint management, and security platforms

## Ownership

| Role | Responsibility |
| --- | --- |
| Source system owner | Owns Meraki Dashboard administration, organizations, networks, licensing, configuration, and operational reporting expectations |
| Technical owner | Supports API access, dashboard permissions, webhook configuration, rate-limit handling, and connector setup |
| Data steward | Defines network, device, client, license, event, and site reporting meaning for EDP consumers |
| Platform owner | Runs the connector, raw landing, transformations, quality checks, and downstream models |

## Data Domains

Initial Cisco Meraki Dashboard data domains:

- Organizations
- Networks
- Devices
- Device statuses and uplinks
- Inventory and claimed devices
- Clients
- Admins and dashboard access
- Licenses and subscriptions
- Configuration templates
- SSIDs, VLANs, switch ports, appliance settings, and wireless settings
- Events and alerts
- Webhook deliveries
- Configuration changes

Later domains may include:

- Cameras
- Sensors
- Systems Manager devices
- Secure SD-WAN, appliance, and VPN telemetry
- Wireless health and assurance metrics
- Switch port utilization and power data
- Location analytics where licensed and approved

## Connector Options

| Connector Option | When It Fits | Notes |
| --- | --- | --- |
| Meraki Dashboard API v1 | Preferred production pattern for inventory, configuration, status, licensing, and event data | REST API for managing and monitoring Meraki networks at scale |
| Meraki webhooks | Useful for alert-driven workflows | Should complement scheduled reconciliation jobs because alerts are event-driven |
| Meraki Python library | Useful implementation helper for a custom connector | Wraps the Dashboard API and can reduce boilerplate for pagination and retries |
| Syslog, SNMP, or NetFlow export | Useful for telemetry or event streams that should flow through network monitoring tooling | Treat as operational telemetry, not a replacement for Dashboard inventory |
| Dashboard export | Useful as an interim or validation approach | Should be treated as a temporary bridge or audit artifact |
| Manual seed | Acceptable only for early testing or static reference data | Should not be used for production operational reporting |

## Prebuilt Package Status

Status: planned.

A reusable Cisco Meraki Dashboard connector package should include:

- Containerized Meraki connector runtime
- Configuration schema for API base URL, organizations, networks, object sets, schedules, and webhook options
- Required Dashboard role, permission, and API key documentation
- API key creation, storage, and rotation guide
- Connection test
- Pagination, rate limit, retry, and backoff handling
- Airflow DAG template
- Raw landing tables for organizations, networks, devices, clients, licenses, statuses, configuration, events, webhooks, and collection runs
- dbt source definitions
- ODS network, site, device, client, license, event, and configuration mappings
- Data Vault hub, link, and satellite templates
- Data quality tests
- Operational runbook

## Required Access

Document these items before production use:

- Meraki organization identifiers
- API base URL and region-specific endpoint where applicable
- API key or approved service credential
- Required Dashboard role and organization or network access
- Networks, tags, product types, and object sets to collect
- Webhook receivers, shared secret, and validation pattern where webhooks are used
- API key rotation pattern
- Rate-limit and retry behavior
- Network egress requirements
- Approval from the network owner and data steward

Use least-privilege access. Read-only Dashboard API access is preferred for inventory and reporting connectors.

## Raw Landing Design

Recommended raw tables:

| Raw Table | Purpose |
| --- | --- |
| `raw.meraki_organizations` | Organization payloads and source metadata |
| `raw.meraki_networks` | Network payloads |
| `raw.meraki_devices` | Device inventory and device payloads |
| `raw.meraki_device_statuses` | Device status, availability, and connectivity observations |
| `raw.meraki_device_uplinks` | Uplink and WAN status observations |
| `raw.meraki_clients` | Client payloads and observed client metadata |
| `raw.meraki_admins` | Dashboard admin and access payloads where approved |
| `raw.meraki_licenses` | License and subscription payloads |
| `raw.meraki_config_templates` | Configuration template payloads |
| `raw.meraki_ssids` | Wireless SSID configuration payloads |
| `raw.meraki_vlans` | VLAN and subnet configuration payloads |
| `raw.meraki_switch_ports` | Switch port configuration and status payloads |
| `raw.meraki_events` | Network event log payloads |
| `raw.meraki_webhook_events` | Alert webhook payloads where enabled |
| `raw.meraki_configuration_changes` | Dashboard configuration change payloads |
| `raw.meraki_collection_runs` | Connector run metadata, counts, timing, and status |

Each raw record should include:

- Meraki organization identifier
- Network identifier where applicable
- Device serial where applicable
- Source endpoint or event type
- Source object identifier
- Source object type
- Observation timestamp or event timestamp where applicable
- Extraction timestamp
- Ingestion run identifier
- Connector version
- Raw payload

## ODS Mapping

Recommended ODS entities:

- `ods.organization`
- `ods.site`
- `ods.network`
- `ods.network_device`
- `ods.network_interface`
- `ods.network_client`
- `ods.network_license`
- `ods.network_configuration`
- `ods.network_event`
- `ods.alert_event`
- `ods.admin_account`
- `ods.source_record`

Common mapping rules:

- Use Meraki organization, network, and device serial values as stable source keys.
- Correlate Meraki devices to asset inventory and CMDB records by serial number, MAC address, model, hostname, and approved matching rules.
- Correlate clients to identities and endpoint records cautiously because MAC addresses, hostnames, and usernames can be incomplete or reused.
- Treat device status, uplink state, client activity, and health metrics as time-bound observations.
- Keep desired configuration, observed status, and alert events as separate entities.
- Preserve Dashboard admin data only when access governance reporting is approved.

## Data Vault Mapping

Recommended Data Vault structures:

- Hub: organization
- Hub: site
- Hub: network
- Hub: network device
- Hub: network client
- Hub: license
- Hub: alert event
- Link: organization to network
- Link: network to device
- Link: network to client
- Link: device to license
- Link: network to configuration template
- Link: admin account to organization or network
- Satellites: organization attributes, network attributes, device attributes, client observations, license state, configuration state, status observations, event detail, source metadata, and classification history

The Data Vault should preserve historical changes in device assignment, network configuration, license state, device status, client observations, and alert events when collected over time.

## Data Mart Outputs

Initial Cisco Meraki Dashboard marts:

- Meraki network inventory mart
- Meraki device lifecycle mart
- Network health and availability mart
- WAN uplink status mart
- Wireless and SSID configuration mart
- Switch port utilization mart
- License and subscription mart
- Configuration change mart
- Alert and incident correlation mart
- Asset and CMDB reconciliation mart

These marts should support network operations, asset governance, service management, license planning, security review, and audit readiness.

## Quality Checks

Recommended checks:

- Collection run completed successfully.
- Organization, network, device, client, license, and event counts are within expected ranges.
- Source object identifiers are present and unique within each object type.
- Device records include serial number, model, product type, and network assignment where available.
- Device status observations resolve to known devices.
- Client observations resolve to known networks and observation windows.
- License records resolve to known organizations or devices where applicable.
- Webhook events are validated and deduplicated where webhooks are enabled.
- API rate-limit responses are handled with backoff and retry behavior.
- Freshness meets the expected schedule.

## Refresh Schedule

Start with daily collection for organizations, networks, devices, licensing, configuration, admins, and templates.

Collect device status, uplink status, client observations, and event data more frequently when operational reporting requires it. Use webhooks for alert-driven workflows, but keep scheduled collection for reconciliation.

## Operational Runbook

The Cisco Meraki Dashboard connector runbook should include:

- How to enable Dashboard API access
- How to create or validate API key access
- How to confirm organization and network permissions
- How to run a connection test
- How to run a manual collection
- How to review collection counts
- How to handle API rate limits and retry behavior
- How to configure and validate webhooks
- How to rotate API keys
- How to disable the connector safely

## Known Limitations

Meraki API coverage depends on product type, licensing, organization settings, and Dashboard permissions. Document collected product families and endpoint coverage for each implementation.

Client telemetry can include sensitive endpoint and user activity signals. Apply appropriate classification, retention, and access controls before making client-level detail broadly available.

Some operational telemetry is better collected through monitoring tools, syslog, SNMP, NetFlow, or SIEM pipelines. Use Dashboard API data as the cloud management source of authority and combine it with telemetry platforms where needed.

## References

- [Meraki Dashboard API v1 Getting Started](https://developer.cisco.com/meraki/api-v1/getting-started/)
- [Meraki Dashboard API v1 API Index](https://developer.cisco.com/meraki/api-v1/api-index/)
- [Cisco Meraki Dashboard API](https://documentation.meraki.com/General_Administration/Other_Topics/Cisco_Meraki_Dashboard_API)
- [Cisco Meraki Webhooks](https://documentation.meraki.com/General_Administration/Operate_and_Maintain/How-Tos/Webhooks)
- [Meraki Device Reporting: Syslog, SNMP, and API](https://documentation.meraki.com/General_Administration/Monitoring_and_Reporting/Meraki_Device_Reporting_-_Syslog%2C_SNMP%2C_and_API)
