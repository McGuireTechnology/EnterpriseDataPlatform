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
| [AD](/source-systems/active-directory) | Identity and access management | Planned | Prebuilt planned | LDAPS, LDAP, PowerShell export, or scheduled directory query | Users, groups, computers, OUs, memberships |
| [M365](/source-systems/microsoft-365) | Cloud productivity and collaboration | Planned | Prebuilt planned | Microsoft Graph API, reports API, admin exports where needed | Users, groups, teams, channels, licenses, usage, service metadata |
| [Google Workspace](/source-systems/google-workspace) | Cloud productivity, identity, collaboration, devices, audit, and administration | Planned | Planned | Admin SDK Directory API, Admin SDK Reports API, Alert Center API, Events API, admin exports where needed | Users, groups, memberships, org units, roles, licenses, devices, usage, audit events, alerts |
| [Infinite Campus](/source-systems/infinite-campus) | Student information and academic operations | Planned | Planned | OneRoster API, customer-approved MS SQL read access, OneRoster CSV export, ad hoc reports, vendor-supported integration | Students, guardians, staff, schools, terms, courses, sections, rosters, assignments, grades, attendance |
| [Canvas LMS](/source-systems/canvas-lms) | Learning management and digital instruction | Planned | Planned | Canvas REST API, Canvas Data 2, Live Events, SIS import/export reports, admin reports | Accounts, users, courses, sections, enrollments, assignments, submissions, grades, modules, activity |
| [Follett Destiny](/source-systems/follett-destiny) | Library, textbook, and resource management | Planned | Planned | Destiny Open APIs, scheduled exports, command-line utilities, approved database read where supported | Sites, patrons, titles, copies, resources, checkouts, returns, fines, fees, instructional materials |
| [Apple Business Manager and Apple School Manager](/source-systems/apple-business-school-manager) | Apple device enrollment, Managed Apple Accounts, Apps and Books, and education roster management | Planned | Planned | Apple School and Business Manager API, ASM Roster API, Apps and Books web services, export | Devices, MDM assignments, locations, managed accounts, apps, books, licenses, classes, rosters |
| [KnowBe4](/source-systems/knowbe4) | Security awareness training and phishing simulation | Planned | Planned | Reporting API, Graph API, User Event API, Product API, webhooks, export | Users, groups, training campaigns, enrollments, completions, phishing campaigns, risk scores, user events |
| [Cisco Meraki Dashboard](/source-systems/cisco-meraki-dashboard) | Cloud-managed network operations | Planned | Planned | Dashboard API v1, webhooks, syslog or SNMP export where needed | Organizations, networks, devices, clients, licenses, configuration, statuses, events, alerts |
| [ManageEngine ServiceDesk Plus](/source-systems/manageengine-servicedesk-plus) | IT service management and CMDB | Planned | Planned | Cloud API v3, on-prem API v3, webhooks, database read or export where approved | Requests, incidents, problems, changes, tasks, worklogs, requesters, technicians, assets, CIs, SLAs, approvals |
| [ManageEngine Endpoint Central](/source-systems/manageengine-endpoint-central) | Unified endpoint management | Planned | Planned | Cloud REST API, on-prem REST API, custom query reports, scheduled export | Endpoints, users, hardware, software, patches, deployments, configurations, groups, remote offices, compliance |
| HR or workforce system | Workforce lifecycle | Candidate | Candidate | API, export, secure file transfer | Employees, departments, managers, job status, hire and termination dates |
| Identity provider | Identity and access management | Candidate | Planned | API or directory query | Identities, groups, memberships |
| Collaboration platform | Communication and collaboration | Candidate | Planned | API | Teams, channels, memberships, activity |
| Other endpoint management | Device and endpoint operations | Candidate | Planned | API or export | Devices, users, compliance, inventory |
| Other service desk | Tickets and operational work | Candidate | Planned | API | Incidents, requests, changes, assets |
| Other security awareness platform | Training and awareness | Candidate | Planned | API or export | Users, assignments, completions |
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
