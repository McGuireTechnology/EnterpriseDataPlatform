# Apple Business Manager and Apple School Manager

Apple Business Manager and Apple School Manager are source systems for Apple device enrollment, Managed Apple Accounts, organization locations, Apps and Books, and, for education environments, roster and class data.

They should be documented separately from MDM platforms such as Intune or Jamf. ABM and ASM are the Apple-owned enrollment and account authority, while the MDM platform is usually the operational management system that receives devices and enforces policy.

## Overview

EDP should use Apple Business Manager and Apple School Manager data to support:

- Apple device procurement and enrollment visibility
- Automated Device Enrollment assignment review
- MDM server assignment reconciliation
- Managed Apple Account governance
- Apple Apps and Books license visibility
- Location and organization hierarchy reporting
- Education roster, class, student, and teacher visibility where Apple School Manager is used
- Cross-system reconciliation with MDM, HR, identity provider, SIS, and asset inventory data
- Onboarding, offboarding, and device lifecycle validation

## Ownership

| Role | Responsibility |
| --- | --- |
| Source system owner | Owns Apple Business Manager or Apple School Manager administration, domains, locations, device enrollment, Apps and Books, and account configuration |
| Technical owner | Supports API access, token lifecycle, MDM server assignments, network access, and connector setup |
| Data steward | Defines device, location, account, app, book, roster, and class reporting meaning for EDP consumers |
| Platform owner | Runs the connector, raw landing, transformations, quality checks, and downstream models |

## Data Domains

Initial Apple Business Manager and Apple School Manager data domains:

- Organization metadata
- Locations
- Devices enrolled through Automated Device Enrollment
- Device-to-MDM-server assignments
- Managed Apple Accounts
- Roles and privileges where available
- Apps and Books locations, licenses, and assignments
- API accounts, server tokens, and integration metadata

Apple School Manager education-specific domains may include:

- Students
- Teachers
- Staff
- Classes
- Rosters
- SIS or SFTP import metadata

## Connector Options

| Connector Option | When It Fits | Notes |
| --- | --- | --- |
| Apple School and Business Manager API | Preferred production pattern for Apple device enrollment and MDM assignment data | Uses OAuth 2 credentials from an API account and supports device-management automation and device data access |
| Apple School Manager Roster API | Preferred for ASM person, class, location, and organization roster data | Requires ASM administrator authorization and education roster scopes |
| Apps and Books web services | Useful for app, book, content token, and license visibility | Usually complements MDM inventory and app deployment data |
| MDM vendor API | Useful when the MDM platform already mirrors Apple enrollment data | Treat as a downstream operational view, not the Apple source of authority |
| Apple admin export | Useful as an interim or validation approach | Should be treated as a temporary bridge or audit artifact |
| Manual seed | Acceptable only for early testing or static reference data | Should not be used for production operational reporting |

## Prebuilt Package Status

Status: planned.

A reusable Apple Business Manager and Apple School Manager connector package should include:

- Containerized Apple connector runtime
- Configuration schema for organization, API account, endpoints, object sets, locations, and schedules
- Required Apple role, API account, token, and scope documentation
- OAuth 2 credential setup and rotation guide
- Connection test
- Pagination, throttling, retry, and token refresh handling
- Airflow DAG template
- Raw landing tables for organizations, locations, devices, MDM assignments, accounts, Apps and Books data, and ASM roster data where enabled
- dbt source definitions
- ODS device, account, location, app, license, class, and roster mappings
- Data Vault hub, link, and satellite templates
- Data quality tests
- Operational runbook

## Required Access

Document these items before production use:

- Apple Business Manager or Apple School Manager organization identifier
- API account or service access configuration
- Required Apple roles and privileges
- OAuth 2 client credentials or token material
- Token expiration and rotation pattern
- MDM server identifiers and assignment scope
- Locations to collect
- Apps and Books token scope where license data is collected
- ASM roster authorization scopes where education data is collected
- Network egress requirements for Apple API endpoints
- Approval from the Apple platform owner and data steward

Use least-privilege access and separate device-enrollment, Apps and Books, and roster permissions when those duties belong to different teams.

## Raw Landing Design

Recommended raw tables:

| Raw Table | Purpose |
| --- | --- |
| `raw.apple_orgs` | Apple organization payloads and source metadata |
| `raw.apple_locations` | Apple location payloads |
| `raw.apple_devices` | Automated Device Enrollment device payloads |
| `raw.apple_device_mdm_assignments` | Device-to-MDM-server assignment state and changes |
| `raw.apple_mdm_servers` | MDM server metadata from Apple enrollment configuration |
| `raw.apple_managed_accounts` | Managed Apple Account payloads where available and approved |
| `raw.apple_apps_books_assets` | Apps and Books app, book, and asset payloads |
| `raw.apple_apps_books_assignments` | License and assignment payloads where available |
| `raw.apple_school_users` | ASM roster users, including students, teachers, and staff |
| `raw.apple_school_classes` | ASM class payloads |
| `raw.apple_school_class_memberships` | ASM class roster membership edges |
| `raw.apple_collection_runs` | Connector run metadata, counts, timing, and status |

Each raw record should include:

- Apple organization identifier
- Source endpoint or export name
- Source object identifier
- Source object type
- Location identifier where applicable
- Extraction timestamp
- Ingestion run identifier
- Connector version
- Raw payload

## ODS Mapping

Recommended ODS entities:

- `ods.device`
- `ods.device_enrollment`
- `ods.device_management_assignment`
- `ods.mdm_server`
- `ods.identity`
- `ods.account`
- `ods.location`
- `ods.application`
- `ods.software_license`
- `ods.software_assignment`
- `ods.class`
- `ods.class_membership`
- `ods.source_record`

Common mapping rules:

- Use stable Apple identifiers as source keys and preserve serial numbers as sensitive matching attributes.
- Correlate Apple devices to MDM and asset inventory records by serial number, hardware identifiers, and approved matching rules.
- Correlate Managed Apple Accounts to HR, identity provider, Microsoft 365, Google Workspace, or SIS identities through approved identifiers only.
- Keep Apple enrollment assignment separate from MDM compliance or configuration state.
- Treat Apps and Books licenses as entitlement records that may differ from actual app installation state.
- Treat ASM roster records as education lifecycle data and apply student-data governance requirements.

## Data Vault Mapping

Recommended Data Vault structures:

- Hub: device
- Hub: Apple account
- Hub: location
- Hub: MDM server
- Hub: application or book
- Hub: software license
- Hub: class
- Link: device to Apple organization
- Link: device to MDM server
- Link: Apple account to identity
- Link: Apple account to location
- Link: Apple account to app or book license
- Link: student or teacher to class
- Satellites: descriptive attributes, assignment history, license state, roster attributes, source metadata, and classification history

The Data Vault should preserve historical changes in device assignment, location membership, app and book entitlements, Managed Apple Account state, and roster membership when collected over time.

## Data Mart Outputs

Initial Apple marts:

- Apple device enrollment mart
- Apple-to-MDM assignment reconciliation mart
- Unassigned or misassigned Apple device mart
- Managed Apple Account governance mart
- Apps and Books license utilization mart
- Education roster and class mart
- Apple device lifecycle reconciliation mart
- Identity lifecycle reconciliation mart

These marts should support device operations, procurement reconciliation, MDM governance, education reporting, license management, and audit readiness.

## Quality Checks

Recommended checks:

- Collection run completed successfully.
- Device, location, account, app, license, user, and class counts are within expected ranges.
- Source object identifiers are present and unique within each object type.
- Serial numbers are present for device records where Apple exposes them.
- Device-to-MDM-server assignments resolve to known MDM servers.
- Apple devices reconcile to MDM inventory or are explicitly classified as not yet enrolled.
- Apps and Books licenses reconcile to known apps, books, locations, or assignments where available.
- ASM class memberships resolve to known roster users and classes.
- Token expiration and rotation dates are monitored.
- Freshness meets the expected schedule.

## Refresh Schedule

Start with daily collection for organization metadata, locations, devices, MDM assignments, Managed Apple Accounts, Apps and Books inventory, and ASM roster data.

Use more frequent collection only when operational needs require closer tracking, such as procurement intake, school-year rollover, MDM migration, device reassignment, or license reconciliation.

## Operational Runbook

The Apple connector runbook should include:

- How to create or validate the Apple API account
- How to confirm required Apple roles, privileges, and scopes
- How to run a connection test
- How to run a manual collection
- How to review collection counts
- How to handle authorization and token expiration failures
- How to rotate credentials and content tokens
- How to validate MDM server assignment data
- How to handle school-year rollover and ASM roster changes
- How to disable the connector safely

## Known Limitations

Apple Business Manager and Apple School Manager are not replacements for an MDM platform. They provide enrollment, assignment, account, location, app, book, and roster authority, while the MDM provides device configuration, compliance, inventory detail, and operational management state.

Serial numbers and student roster data can be sensitive. Apply appropriate data classification, masking, and access controls before making these fields broadly available.

API capabilities, roles, and scopes can change. Keep permissions reviewed and documented with the connector package.

## References

- [Apple School Manager and Apple Business APIs](https://developer.apple.com/documentation/apple-school-and-business-manager-api)
- [Apple School Manager Roster API](https://developer.apple.com/documentation/RosterAPI)
- [Managing Apps and Books Through Web Services](https://developer.apple.com/documentation/devicemanagement/managing-apps-and-books-through-web-services)
- [Create an API account in Apple Business Manager](https://support.apple.com/guide/apple-business-manager/axm33189f66a/web)
- [About Managed Apple Accounts](https://support.apple.com/guide/deployment/depdc4ba8d82/web)
