# Data Lifecycle

EDP organizes operational data into layers. Each layer has a distinct purpose so teams can ingest quickly, normalize carefully, preserve history, and publish focused data products without mixing concerns.

## Source Systems

Source systems are the operational tools of record. They may include identity providers, collaboration suites, endpoint platforms, service desks, infrastructure systems, security tools, business applications, SaaS platforms, and departmental systems.

EDP should respect source-system ownership. The platform reads from source systems through approved APIs, exports, events, or database access patterns, then records how each dataset was collected.

## Raw Data Store

The raw data store captures source data with minimal transformation. It supports traceability, replay, debugging, and historical retention.

Raw data should preserve source identifiers, extraction timestamps, source payload shape, and enough metadata to explain where the record came from. This layer is optimized for faithful capture, not user-facing reporting.

Within `edp_raw`, use one schema per source system or connector package. Active
Directory raw tables should live under `edp_raw.ad`, Microsoft 365 under
`edp_raw.m365`, a hypothetical FleetTrack connector under
`edp_raw.fleettrack`, and so on. This keeps source-specific payloads and naming
close to their origin while still sharing common raw metadata patterns.

## Operational Data Store

The Operational Data Store normalizes, correlates, and enriches raw data into current-state operational views. It is the working layer for near-real-time visibility and operational workflows.

Common ODS responsibilities include:

- Normalizing identities, assets, permissions, tickets, licenses, and memberships
- Resolving cross-system identifiers into shared entities
- Highlighting mismatches, missing assignments, orphaned records, or stale records
- Supporting dashboards, alerts, and operational applications that need current state

## Data Vault

The Data Vault preserves historical relationships and changes across the enterprise. It is the durable history layer for dimensional modeling, trend analysis, audit evidence, and long-term analytics.

This layer should capture business keys, relationships, descriptive attributes, load timestamps, source metadata, and history in a way that can survive source-system changes and model evolution.

## Data Marts

Data Marts are focused, consumable datasets built for specific reporting, dashboard, application, or analytical needs. They are intentionally narrower than the Data Vault and shaped around user questions.

Examples include:

- Identity lifecycle mart
- Access review mart
- Licensing and utilization mart
- Endpoint and asset inventory mart
- Service operations mart
- Governance and audit evidence mart

## Presentation and Application Layer

Dashboards, reports, alerts, APIs, and custom applications should consume governed marts or ODS views rather than rebuilding logic from raw extracts. This keeps user-facing outputs aligned with shared definitions and reduces duplicate reporting logic.

See [Consumer Tools](/architecture/consumer-tools) for recommended tools and patterns for the user-facing layer.

## Example Flow

Imagine a hypothetical endpoint management system called FleetTrack. FleetTrack
has an API that returns device inventory, assigned users, encryption status,
last check-in time, operating system version, and warranty expiration.

In `edp_raw`, the connector stores each API response with minimal reshaping in a
source-specific schema. FleetTrack records would land in tables such as
`fleettrack.device_record` or `fleettrack.assignment_record`. Active Directory
objects would land in tables such as `ad.object_record`. Each raw row keeps the
source identifier, the full JSON payload, the extraction timestamp, the
ingestion run identifier, and source metadata. If a source changes an attribute
name or sends an unexpected value, the raw record still preserves what the
source actually returned.

In `edp_ods`, the platform turns those raw payloads into current operational
tables such as `ods.device`, `ods.device_assignment`, and
`ods.device_compliance_status`. The ODS resolves FleetTrack user identifiers to
the shared person or account records used by the platform, normalizes operating
system names, flags stale check-ins, and exposes the current state of each
device.

In `edp_vault`, the platform historizes the business keys, relationships, and
descriptive changes. A device hub preserves the durable device key, a person hub
preserves the durable person key, a device-assignment link records the
relationship between device and person, and satellites preserve changing
attributes such as encryption status, operating system version, department, and
last observed owner over time. This makes it possible to answer historical
questions even after FleetTrack has overwritten its current state.

In `edp_mart`, the platform publishes focused reporting datasets such as
`mart.device_compliance_daily`, `mart.stale_device_inventory`, and
`mart.endpoint_owner_summary`. These marts are shaped for dashboards and
operational review: which devices are stale, which departments have encryption
exceptions, which owners have multiple devices, and whether compliance is
improving over time.

In the presentation layer, Superset might show endpoint compliance dashboards
from `edp_mart`, while an operational application might use governed ODS views
to show the current queue of devices needing review.

## Typical Columns

The exact tables will vary by source package and domain, but each database
should have a recognizable column pattern.

### `edp_raw`

Raw tables preserve source truth and ingestion context. Each source system gets
its own raw schema, so Active Directory tables live under `edp_raw.ad`, Microsoft
365 tables under `edp_raw.m365`, and FleetTrack tables under
`edp_raw.fleettrack`.

A table such as `ad.object_record` will typically include:

| Column | Purpose |
| --- | --- |
| `id` | Platform-generated row identifier |
| `source_system_id` | Reference to the source system metadata record |
| `ingestion_run_id` | Reference to the connector run that loaded the record |
| `source_object_key` | Stable source-side identifier, such as an object GUID or device ID |
| `object_class` | Source object type, such as user, group, computer, or device |
| `distinguished_name` | Source hierarchy or path when the source provides one |
| `payload` | Full JSONB source payload as received or minimally normalized |
| `extracted_at` | Time the source data was read from the source system |
| `loaded_at` | Time the platform wrote the raw record |
| `payload_hash` | Optional hash used to detect payload changes |
| `source_endpoint` | Optional API endpoint, export name, or source object name |
| `schema_version` | Optional connector or source payload version |

Raw metadata tables in `meta` usually include source code, source name, run key,
run status, start and finish timestamps, record count, and error message
columns. The source-specific schemas hold source records; `meta` explains how
and when they were collected.

### `edp_ods`

ODS tables represent current operational state in a normalized form. A table
such as `ods.device` will typically include:

| Column | Purpose |
| --- | --- |
| `device_id` | Platform-generated or deterministic device identifier |
| `source_system_code` | Source system where the current record came from |
| `source_device_key` | Source-side device identifier |
| `asset_tag` | Human-facing asset tag, when available |
| `serial_number` | Hardware serial number |
| `hostname` | Current device hostname |
| `assigned_person_id` | Resolved person or account identifier |
| `operating_system` | Normalized operating system family/name |
| `os_version` | Operating system version |
| `encryption_status` | Current normalized encryption state |
| `last_check_in_at` | Most recent source-reported check-in time |
| `is_stale` | Current-state flag derived from last check-in rules |
| `first_seen_at` | First time the platform observed the device |
| `last_seen_at` | Most recent time the platform observed the device |
| `updated_at` | Time the ODS row was last refreshed |

Relationship tables such as `ods.device_assignment` typically include device
IDs, person IDs, source keys, assignment type, effective dates where available,
and current-state flags.

### `edp_vault`

Vault tables preserve durable keys, relationships, and historical attributes.
They usually follow hub, link, and satellite patterns.

A hub such as `vault.hub_device` will typically include:

| Column | Purpose |
| --- | --- |
| `device_hash_key` | Deterministic hash key for the device business key |
| `device_business_key` | Durable business key, such as serial number or source key |
| `record_source` | Source system that supplied the key |
| `load_datetime` | Time the vault record was loaded |

A link such as `vault.link_device_person_assignment` will typically include:

| Column | Purpose |
| --- | --- |
| `assignment_hash_key` | Deterministic hash key for the relationship |
| `device_hash_key` | Reference to the device hub key |
| `person_hash_key` | Reference to the person hub key |
| `record_source` | Source system that supplied the relationship |
| `load_datetime` | Time the relationship was loaded |

A satellite such as `vault.sat_device_status` will typically include:

| Column | Purpose |
| --- | --- |
| `device_hash_key` | Parent hub key |
| `hash_diff` | Hash of descriptive attributes used to detect change |
| `encryption_status` | Historical descriptive attribute |
| `operating_system` | Historical descriptive attribute |
| `os_version` | Historical descriptive attribute |
| `last_check_in_at` | Historical source observation |
| `effective_from` | Start of the attribute version |
| `effective_to` | End of the attribute version, when closed |
| `is_current` | Convenience flag for the latest satellite row |
| `record_source` | Source system that supplied the attributes |
| `load_datetime` | Time the satellite row was loaded |

### `edp_mart`

Mart tables are shaped around user questions and dashboard performance. A table
such as `mart.device_compliance_daily` will typically include:

| Column | Purpose |
| --- | --- |
| `snapshot_date` | Reporting date for the row |
| `department_name` | Reporting dimension |
| `manager_name` | Reporting dimension |
| `device_count` | Total devices in scope |
| `encrypted_device_count` | Devices meeting encryption policy |
| `unencrypted_device_count` | Devices not meeting encryption policy |
| `stale_device_count` | Devices past the check-in freshness threshold |
| `compliance_rate` | Derived percentage or ratio |
| `exception_count` | Devices with accepted or active exceptions |
| `open_ticket_count` | Related remediation tickets |
| `refreshed_at` | Time the mart row was last built |

Marts often denormalize names, categories, dates, and counts so dashboard tools
can answer common questions without rebuilding joins or business rules.

### `edp_app`

Application tables store workflow state created by EDP custom applications, not
source-system facts. A table such as `app.endpoint_exception_review` will
typically include:

| Column | Purpose |
| --- | --- |
| `review_id` | Application-generated review identifier |
| `device_id` | Reference to the governed ODS device identifier |
| `assigned_reviewer` | User responsible for review |
| `review_status` | Workflow state, such as open, accepted, remediating, closed |
| `risk_level` | App-assigned or reviewer-assigned risk classification |
| `exception_reason` | Reason the exception exists |
| `review_notes` | Human-entered review notes |
| `due_at` | Date or time the review is due |
| `accepted_until` | Expiration date for a temporary risk acceptance |
| `remediation_ticket_key` | Related service desk ticket or work item |
| `created_at` | Time the app workflow record was created |
| `updated_at` | Time the app workflow record was last changed |
| `closed_at` | Time the workflow was completed, when applicable |

The app database should avoid copying broad source payloads. It should store the
state, decisions, assignments, notes, and workflow transitions that the source
systems do not own.
