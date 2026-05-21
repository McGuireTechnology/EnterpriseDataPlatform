# Common Source Systems

After Active Directory and Microsoft 365, EDP should prioritize source systems that improve lifecycle visibility, operational correlation, governance, and audit readiness.

This page lists common systems to consider. It is not a commitment to integrate every system. Use the source inventory, business value, access feasibility, and pilot goals to decide what comes next.

## Candidate Source System Categories

| Category | Systems to Consider | Why They Matter |
| --- | --- | --- |
| Identity and Access | Entra ID, Okta, Duo, Ping, Keycloak | Cloud identities, MFA, SSO, app assignments, access posture |
| HR and Workforce | Workday, UKG, ADP, BambooHR, Paylocity | Authoritative employee lifecycle, departments, managers, job status |
| Service Desk and ITSM | ServiceNow, Jira Service Management, Freshservice, ManageEngine ServiceDesk Plus | Tickets, requests, changes, incidents, assets, approvals |
| Endpoint Management | Intune, Jamf, SCCM or MECM, Tanium, NinjaOne, PDQ | Device inventory, compliance, ownership, patch posture |
| Security Platforms | Microsoft Defender, CrowdStrike, SentinelOne, Tenable, Rapid7, Qualys | Risk, vulnerabilities, endpoint security, exposure management |
| Email and Collaboration | Exchange Online, Teams, SharePoint, Slack, Zoom, Google Workspace | Communication, memberships, sites, mailboxes, collaboration governance |
| Network and Infrastructure | VMware vCenter, Hyper-V, Proxmox, Nutanix, Meraki, Fortinet, Palo Alto, Cisco | VMs, hosts, firewalls, VPNs, network inventory, capacity |
| Cloud Platforms | Azure, AWS, GCP | Cloud resources, IAM, costs, tags, inventory, policy posture |
| Backup and Disaster Recovery | Veeam, Rubrik, Cohesity, Commvault | Backup coverage, restore status, recovery readiness |
| Finance and ERP | NetSuite, Dynamics 365, SAP, Oracle, QuickBooks | Vendors, cost centers, assets, purchasing, financial context |
| CMDB and Asset | ServiceNow CMDB, Lansweeper, Snipe-IT, GLPI | Asset lifecycle, ownership, dependencies, inventory reconciliation |
| Monitoring and Observability | Datadog, New Relic, LogicMonitor, PRTG, Zabbix, Prometheus | Service health, alerts, uptime, infrastructure telemetry |
| Security Awareness and GRC | KnowBe4, Proofpoint, Archer, Drata, Vanta, OneTrust | Training, controls, risk, compliance evidence |
| Source Control and DevOps | GitHub, GitLab, Azure DevOps, Jenkins | Repositories, pipelines, deployments, change history |
| Data and Database Platforms | SQL Server, PostgreSQL, MySQL, Oracle, Snowflake | Existing operational databases and reporting sources |
| Facilities and Physical Security | Badge systems, camera systems, visitor management | Physical access and lifecycle correlation |
| Telephony and Contact Center | RingCentral, Teams Phone, Zoom Phone, Five9, Genesys | Call queues, users, licensing, operational metrics |

## Recommended Early Priority

After Active Directory and Microsoft 365, prioritize:

1. HR or workforce system
2. Service desk or ITSM system
3. Endpoint management platform
4. Security awareness or training platform
5. Virtualization or cloud platform
6. Backup or disaster recovery platform

## Why HR Matters Early

The HR or workforce system is often the missing authoritative source for identity lifecycle. Active Directory and Microsoft 365 can show accounts and access, but HR usually explains whether a person is active, starting, changing roles, on leave, terminated, assigned to a department, or reporting to a specific manager.

When EDP combines HR, Active Directory, Microsoft 365, and service desk data, it can answer lifecycle questions that usually require multiple spreadsheets:

- Has every new hire been provisioned correctly?
- Are terminated users disabled everywhere?
- Are active users assigned the right licenses?
- Are accounts missing managers, departments, or employee identifiers?
- Do access requests match role or department expectations?
- Are onboarding and offboarding tickets aligned with actual system state?

## Selection Criteria

Use these criteria when deciding which source system to integrate next:

- The system participates in a high-value operational workflow.
- The data crosses or reconciles with at least one existing source.
- The source owner is identified and willing to support the integration.
- A supported API, export, or access pattern exists.
- Required permissions can be granted safely.
- Data sensitivity and retention rules are understood.
- The integration creates reusable entities, marts, dashboards, or workflow value.
- The connector can be operated repeatably through the platform runtime.

## Documentation Expectations

Before a candidate becomes an active integration, document:

- Source owner
- Technical owner
- Data steward
- Access pattern
- Connector option
- Credential requirements
- Data sensitivity
- Refresh expectations
- Raw landing targets
- ODS entities
- Data Vault structures
- Data Mart outputs
- Quality checks
- Support path

Use the [Source System Inventory](/source-systems/inventory) and [Connector Standard](/source-systems/connector-standard) to keep these decisions consistent.
