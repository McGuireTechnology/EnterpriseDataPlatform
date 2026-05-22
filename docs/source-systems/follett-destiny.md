# Follett Destiny

Follett Destiny is a K-12 library, textbook, instructional material, and resource management source. For EDP, Destiny can provide catalog, patron, checkout, fine, fee, textbook, library, and resource inventory context that helps connect educational assets to people, schools, and operational workflows.

## Overview

Follett Destiny can provide EDP with visibility into library collections, instructional materials, resource assignments, patron activity, checkouts, fines, fees, and site-level resource operations. It is especially valuable when correlated with SIS data from Infinite Campus, identity data, service desk tickets, and endpoint or device inventory.

EDP should use Destiny data to support:

- Library and textbook inventory visibility
- Student and staff patron reconciliation
- Resource assignment and checkout reporting
- Lost item, fine, and fee analysis
- Site-level collection and circulation dashboards
- Instructional material lifecycle reporting
- Student lifecycle and asset return workflows
- Operational support for library, curriculum, and technology teams

## Ownership

| Role | Responsibility |
| --- | --- |
| Source system owner | Owns Destiny configuration, library/resource workflows, patron policies, and data release decisions |
| Technical owner | Supports API accounts, hosted or self-hosted access, SSO, imports, exports, and integration troubleshooting |
| Data steward | Defines item, patron, checkout, fine, fee, resource, and collection reporting meaning |
| Platform owner | Runs the connector, raw landing, transformations, quality checks, and downstream models |

## Data Domains

Initial Follett Destiny data domains:

- Sites and libraries
- Patrons
- Patron checkout information
- Titles and bibliographic records
- Copies and barcodes
- Resources and resource templates
- Textbooks and instructional materials where licensed
- Checkouts and returns
- Holds where available
- Fines and fees
- Recently read or digital resource activity where approved

Later domains may include:

- Collection analysis exports
- Inventory audit results
- Transfer records
- Digital platform integration data
- SSO and authentication configuration evidence

## Connector Options

| Connector Option | When It Fits | Notes |
| --- | --- | --- |
| Destiny Open APIs | Preferred production pattern where enabled | API accounts can be configured with services such as Fines, Self Service, Patron Info, and Resources |
| Scheduled exports | Useful for catalog, patron, circulation, textbook, resource, and fine/fee reporting | Requires strong file validation, naming, retention, and duplicate-handling rules |
| Command-line utilities | Useful for automated uploads or exports in Destiny Cloud and supported workflows | Good fit for approved batch processes |
| Database read | Only where self-hosted and explicitly approved by Follett and the district | Must avoid unsupported load or schema assumptions |
| Manual seed | Acceptable only for early testing or static reference data | Should not be used for production circulation or resource reporting |

## Prebuilt Package Status

Status: planned.

A reusable Follett Destiny connector package should include:

- Containerized Destiny connector runtime
- Configuration schema for Destiny host URL, site scope, API services, schedules, and export locations
- API account setup guide
- Connection test
- Pagination, retry, and error handling
- Airflow DAG template
- Raw landing tables for sites, patrons, titles, copies, resources, checkouts, fines, fees, and collection runs
- dbt source definitions
- ODS mappings for patron, school, library site, title, copy, resource, checkout, fine, fee, and assignment entities
- Data Vault hub, link, and satellite templates
- Data quality tests
- Operational runbook

## Required Access

The connector should use an approved Destiny API account or approved scheduled export pattern. API accounts should be scoped to only the required services and managed by a Destiny Administrator.

Document these items before production use:

- Destiny host URL
- Cloud or self-hosted deployment model
- API account name and owner
- Enabled API services
- Site and district scope
- Export paths or API endpoints
- Patron matching identifiers
- Fine, fee, checkout, and circulation data approval
- Network allowlisting requirements where applicable
- Credential rotation pattern
- Approval from library, curriculum, finance, and data governance owners where needed

## Raw Landing Design

Recommended raw tables:

| Raw Table | Purpose |
| --- | --- |
| `raw.follett_destiny_sites` | District, site, and library payloads |
| `raw.follett_destiny_patrons` | Patron payloads and source metadata |
| `raw.follett_destiny_titles` | Title and bibliographic payloads |
| `raw.follett_destiny_copies` | Copy, barcode, and item payloads |
| `raw.follett_destiny_resources` | Resource and resource-template payloads |
| `raw.follett_destiny_checkouts` | Checkout and return payloads |
| `raw.follett_destiny_fines_fees` | Fine and fee payloads |
| `raw.follett_destiny_collection_runs` | Connector run metadata, counts, timing, and status |

Each raw record should include:

- Destiny host or district identifier
- Site identifier where applicable
- Source service or export name
- Source object identifier
- Source object type
- Extraction timestamp
- Ingestion run identifier
- Connector version
- Raw payload

## ODS Mapping

Recommended ODS entities:

- `ods.person`
- `ods.patron`
- `ods.school`
- `ods.library_site`
- `ods.library_title`
- `ods.library_copy`
- `ods.resource`
- `ods.resource_assignment`
- `ods.checkout`
- `ods.fine_fee`
- `ods.source_record`

Common mapping rules:

- Preserve Destiny patron IDs, barcode values, title identifiers, copy identifiers, and resource identifiers separately.
- Correlate patrons to SIS and identity records through approved student/staff identifiers.
- Keep copy-level inventory separate from title-level catalog records.
- Model checkouts, returns, fines, and fees as time-bound events or obligations.
- Treat circulation history and fine/fee information as sensitive student and financial records requiring approval.

## Data Vault Mapping

Recommended Data Vault structures:

- Hub: person
- Hub: patron
- Hub: school
- Hub: library site
- Hub: title
- Hub: copy
- Hub: resource
- Hub: fine or fee
- Link: person to patron
- Link: patron to checkout
- Link: checkout to copy
- Link: copy to title
- Link: resource to school
- Link: patron to fine or fee
- Satellites: patron attributes, title metadata, copy status history, checkout history, resource attributes, fine/fee lifecycle, source metadata, and classification history

## Data Mart Outputs

Initial Follett Destiny marts:

- Patron reconciliation mart
- Library collection mart
- Copy and barcode inventory mart
- Checkout and circulation mart
- Fine and fee mart
- Textbook and resource assignment mart
- Student asset return mart
- Site-level library operations mart

## Quality Checks

Recommended checks:

- Collection run completed successfully.
- Site, patron, title, copy, checkout, resource, and fine/fee counts are within expected ranges.
- Source object identifiers are present and unique within each object type.
- Checkouts reference known patrons and copies where possible.
- Copies reference known titles.
- Resources reference known sites, templates, or resource types.
- Patron identifiers correlate to SIS or identity records where expected.
- Sensitive fields are collected only when approved.
- Freshness meets the expected schedule.

## Refresh Schedule

Start with daily collection for sites, patrons, titles, copies, resources, checkouts, and fines/fees.

Use more frequent collection during school-year checkout, textbook distribution, device/material return campaigns, and inventory windows.

## Operational Runbook

The Follett Destiny connector runbook should include:

- How to validate Destiny host access
- How to confirm API account services and credentials
- How to test each enabled API service or export
- How to run a manual collection
- How to review collection counts
- How to handle permission failures
- How to coordinate patron and SIS reconciliation
- How to handle school-year inventory windows
- How to rotate API credentials
- How to disable the connector safely

## Known Limitations

Destiny data availability depends on product modules, licensing, deployment model, API services enabled, site scope, and district configuration.

Open API coverage may not expose every field needed for reporting. Some use cases may require scheduled exports or approved operational reports.

Circulation history, patron data, and fines/fees can be sensitive. Collection should be explicitly approved and scoped to the reporting use case.

## References

- [Follett Destiny Product Documentation](https://follettsoftware.com/destiny-educator-platform/destiny-product-documentation/)
- [Follett Destiny Manage API Accounts](https://destinyhelp200en.follettsoftware.com/content/c_manage_api_accounts.htm)
- [Follett Destiny Cloud](https://legacyhelp.follettsoftware.com/Content/c_hosted.htm)
