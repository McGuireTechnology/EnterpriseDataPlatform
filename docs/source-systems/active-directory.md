# AD

AD is the first documented EDP source system. It provides foundational identity, group, computer, organizational unit, and membership data for identity lifecycle visibility and cross-system correlation.

This page describes an on-premises AD DS source. Entra ID or M365 should be documented as separate source systems because their APIs, identifiers, permissions, and data shapes differ.

## Overview

AD is commonly used as a system of record or synchronization source for users, groups, computers, service accounts, organizational units, and access control structures.

EDP should use AD data to support:

- Identity lifecycle reporting
- Onboarding and offboarding validation
- User and service account inventory
- Group and nested group membership visibility
- Computer and endpoint correlation
- Organizational unit and directory structure visibility
- Access review support
- Cross-system identity matching
- Audit and governance evidence

## Ownership

| Role | Responsibility |
| --- | --- |
| Source system owner | Owns AD service health, access policies, and operational use |
| Technical owner | Supports connector access, directory queries, and network reachability |
| Data steward | Defines identity, group, computer, and membership meaning for EDP consumers |
| Platform owner | Runs the connector, raw landing, transformations, quality checks, and downstream models |

## Data Domains

Initial AD data domains:

- Users
- Groups
- Group memberships
- Computers
- Organizational units
- Contacts where useful
- Service accounts where distinguishable
- Directory metadata such as domains, naming contexts, and collection timestamps

Later domains may include:

- Group policy metadata
- Password and account policy metadata
- Delegation and administrative control metadata
- Selected security descriptors where governance requirements justify the sensitivity

## Connector Options

| Connector Option | When It Fits | Notes |
| --- | --- | --- |
| LDAPS query | Preferred production pattern when direct directory queries are allowed | Uses encrypted LDAP; supports repeatable scheduled collection |
| LDAP query | Useful only in trusted internal environments where LDAPS is unavailable | Should be avoided when credentials or sensitive attributes may traverse the network |
| PowerShell export | Useful when a Windows-based collection host is easier to approve | Can export CSV or JSON into a landing location for ingestion |
| Scheduled file export | Useful when direct connector access is not allowed | Requires strong file naming, validation, and transfer controls |
| Manual seed | Acceptable only for early testing | Should not be used as a production identity source |

## Prebuilt Package Status

Status: prebuilt planned.

A reusable AD connector package should include:

- Containerized connector runtime where feasible
- Optional Windows-based export pattern if direct Linux container LDAP access is not approved
- Configuration schema for domain controllers, base DNs, object classes, attributes, and schedules
- Credential requirements for a least-privilege read-only service account
- Connection test
- Airflow DAG template
- Raw landing tables for users, groups, computers, OUs, and memberships
- dbt source definitions
- ODS identity, group, device, and membership mappings
- Data Vault hub, link, and satellite templates
- Data quality tests
- Operational runbook

## Required Access

The connector should use a read-only service account with the minimum directory permissions required to read approved objects and attributes.

Document these items before production use:

- Domain or forest scope
- Domain controllers or discovery method
- Base distinguished names
- Object classes to collect
- Attribute allowlist
- Authentication method
- Network path and firewall requirements
- TLS or certificate requirements for LDAPS
- Account lockout and rotation expectations
- Approval from the directory owner

Sensitive attributes should be excluded unless there is a clear operational need and an approved governance decision.

## Raw Landing Design

Recommended raw tables:

| Raw Table | Purpose |
| --- | --- |
| `raw.ad_users` | User account payloads and source metadata |
| `raw.ad_groups` | Group payloads and source metadata |
| `raw.ad_group_memberships` | Direct group membership edges |
| `raw.ad_computers` | Computer account payloads and source metadata |
| `raw.ad_organizational_units` | OU payloads and directory hierarchy metadata |
| `raw.ad_collection_runs` | Connector run metadata, counts, timing, and status |

Each raw record should include:

- Domain
- Distinguished name
- Object GUID
- Security identifier when available and approved
- Source object class
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
- `ods.device`
- `ods.org_unit`
- `ods.source_record`

Common mapping rules:

- Use immutable source identifiers such as object GUIDs for source identity.
- Preserve distinguished names as source attributes because they can change.
- Normalize enabled or disabled account state.
- Normalize user, service account, and shared account classifications where possible.
- Model direct group memberships first.
- Add nested membership expansion as a derived model with clear lineage.
- Keep source-specific attributes available without making every attribute part of the canonical identity model.

## Data Vault Mapping

Recommended Data Vault structures:

- Hub: identity
- Hub: account
- Hub: group
- Hub: device
- Hub: organizational unit
- Link: account to identity
- Link: account to group
- Link: group to group for nested membership
- Link: account or device to organizational unit
- Satellites: descriptive attributes, status history, source metadata, and classification history

The Data Vault should preserve historical changes in memberships, account state, OU placement, and key descriptive attributes when those changes are collected over time.

## Data Mart Outputs

Initial AD marts:

- Identity lifecycle mart
- Disabled and stale accounts mart
- Group membership mart
- Nested membership mart
- Privileged group visibility mart
- Computer inventory mart
- OU structure mart
- Access review support mart

These marts should be designed for dashboards, access reviews, operational reconciliation, and downstream correlation with service desk, endpoint, collaboration, licensing, and HR data.

## Quality Checks

Recommended checks:

- Collection run completed successfully.
- User, group, computer, and membership counts are within expected ranges.
- Object GUIDs are present and unique within each object type.
- Distinguished names are present.
- Group membership references resolve to known users, groups, contacts, or computers where possible.
- Required attributes are populated for active accounts.
- Disabled, expired, locked, or stale account flags are normalized consistently.
- Nested group expansion does not produce cycles without detection.
- Freshness meets the expected schedule.

## Refresh Schedule

Start with daily collection for most directory inventory and membership data.

Use more frequent collection when the use case requires near-current operational visibility, such as onboarding, offboarding, privileged group review, or access remediation.

Historical changes should be preserved in the Data Vault or snapshot structures when source history is not available directly.

## Operational Runbook

The AD connector runbook should include:

- How to validate service account access
- How to test LDAPS connectivity
- How to run a manual collection
- How to review object and membership counts
- How to handle domain controller reachability failures
- How to handle schema or attribute changes
- How to backfill or reprocess a collection
- How to rotate connector credentials
- How to disable the connector safely

## Known Limitations

AD may not contain all authoritative identity lifecycle information. HR, Entra ID, M365, endpoint management, service desk, and application systems may each hold different parts of the lifecycle.

Distinguished names and account names can change. Use immutable source identifiers for durable correlation.

Nested group memberships require careful expansion and cycle handling.

Some useful attributes may be sensitive. Attribute collection should be allowlisted and approved.
