# Platform Positioning

The Enterprise Data Platform does not replace specialized monitoring, security, audit, or vendor-specific tools. It complements them by correlating operational data across systems and turning that data into reusable models, dashboards, applications, and automation foundations.

## Relationship to SIEM Platforms

Security Information and Event Management platforms are designed for security event collection, log aggregation, threat detection, alerting, incident response, and security operations workflows.

EDP has a different focus:

- Operational visibility
- Cross-system business and IT reporting
- Data normalization and correlation
- Identity lifecycle operations
- Historical operational analytics
- Governance and operational intelligence
- Enterprise data integration
- Custom operational applications

SIEM platforms and EDP may share data sources, but they serve different purposes. A SIEM prioritizes security telemetry and incident response. EDP prioritizes operational intelligence, governed reporting, and cross-system lifecycle visibility.

## Relationship to Vendor-Specific Reporting

Vendor-specific reporting tools are valuable within their own domains. They may provide deep reporting for a directory, endpoint platform, service desk, application suite, or security product.

EDP extends beyond those boundaries by correlating data across systems. For example, a vendor tool might report a directory group membership change. EDP can correlate that change with collaboration memberships, service desk tickets, license assignments, endpoint inventory, training status, and provisioning workflows.

The result is a complete operational lifecycle view instead of a single-system report.

## Reducing Spreadmarts

A spreadmart is an unofficial reporting system built from exported CSV files, manually maintained spreadsheets, local data copies, formulas, and ad hoc business logic.

Spreadmarts often appear when centralized reporting and cross-system visibility are missing. They create conflicting sources of truth, inconsistent calculations, duplicated effort, data quality problems, weak auditability, and knowledge silos.

EDP reduces spreadmarts by replacing repeated exports and manual joins with:

- Automated ingestion pipelines
- Centralized operational datasets
- Version-controlled transformations
- Shared enterprise data models
- Governed dashboards and queries
- Documented data definitions
- Historical reporting
- Automated refresh schedules

## Operational Example

Without EDP, an onboarding review may require exporting users, group memberships, collaboration memberships, license assignments, endpoint inventory, training records, and tickets into separate spreadsheets. Someone then manually compares records, updates a tracker, and emails status reports.

With EDP, the platform ingests each source system, correlates identities centrally, surfaces missing assignments, tracks lifecycle status, preserves history, and presents dashboards or workflow views from governed data.

The strategic outcome is simple: teams operate from shared operational data instead of isolated spreadsheets and vendor-specific reports.
