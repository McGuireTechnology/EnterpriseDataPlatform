# Consumer Tools

Consumer tools are the user-facing layer of EDP. They are what people log into to view dashboards, explore governed data, review operational state, and take action from ODS, Data Vault, and Data Mart outputs.

Use a tiered approach instead of expecting one tool to handle every consumer experience.

## Primary Recommendation

Start with Apache Superset as the main BI and dashboard portal.

Superset is a strong default for EDP because it connects well to SQL databases, supports charts and dashboards, includes a semantic layer, and fits naturally with PostgreSQL, Airflow, dbt, and governed Data Marts.

Use CKAN when EDP needs a public or semi-public publication portal. CKAN fits statutory reporting packages, downloadable datasets, open-data style pages, and transparency records that explain what data is collected, processed, and shared with third parties.

## Suggested Tool Mapping

| Consumer Need | Recommended Tool |
| --- | --- |
| Standard dashboards and BI portal | Apache Superset |
| Public dataset publication and transparency portal | CKAN |
| Simple self-service business questions | Metabase |
| Operational and technical monitoring dashboards | Grafana |
| Curated narrative data products | Evidence.dev |
| Custom operational workflows and applications | FastAPI plus Vue |
| Microsoft-heavy enterprise reporting | Power BI, optional |

## Apache Superset

Use Superset for the main consumer analytics portal.

Good Superset use cases include:

- Executive and operational dashboards
- Data Mart reporting
- Filterable ODS views
- Departmental dashboards
- Published governed datasets
- Internal BI portal experiences

Superset should generally query Data Marts or governed ODS views. Avoid pointing casual users directly at raw tables or deeply normalized Data Vault structures.

## CKAN

Use CKAN for published data products that need dataset pages, resources, downloads, metadata, and public-facing discovery.

Good CKAN use cases include:

- ASBR and other statutory reporting packages
- Approved CSV, XLSX, PDF, and supporting documentation downloads
- Public or board-facing data inventories
- Data-sharing transparency records for third-party systems
- Dataset pages with ownership, refresh cadence, methodology, and contact details

CKAN should publish approved outputs, not internal working tables. Keep internal lineage, ownership, model definitions, and impact analysis in OpenMetadata and source control. Use CKAN to communicate what is safe and appropriate for the public or an authorized audience to inspect.

## Metabase

Use Metabase when the organization needs a simpler self-service experience for non-technical users.

Metabase can be a good fit for users who want to ask questions, build lightweight dashboards, explore tables, or use a friendlier query interface without learning a heavier BI tool.

Add Metabase when Superset feels too heavy for casual self-service users, not as a required first component.

## Grafana

Use Grafana for operational visibility and technical dashboards.

Good Grafana use cases include:

- Pipeline health
- Data freshness checks
- Ingestion status
- Infrastructure metrics
- Alert dashboards
- Time-series operational views
- Platform service status

Grafana is excellent for operators, but it should not be the primary business BI portal.

## Evidence.dev

Use Evidence.dev for curated, version-controlled data products.

Evidence is useful for:

- Narrative reports
- Documentation-adjacent analytics
- Public or internal data stories
- SQL-backed Markdown reports
- Static or semi-static published views

This can pair well with the docs-as-code model when a data product should read more like a guided report than a dashboard workspace.

## FastAPI and Vue

Use custom applications when users need to do work, not just view data.

Good custom application candidates include:

- Identity lifecycle review screens
- Access remediation queues
- CMDB-style operational views
- Approval workflows
- Administrative tools
- Exception handling
- Guided operational processes

Dashboards are good for seeing. Custom applications are better when users need to review, approve, remediate, annotate, or trigger workflow actions.

Custom applications should consume governed ODS views, Data Marts, or purpose-built application APIs. They should not duplicate transformation logic that belongs in dbt or the platform data model.

### Example Custom App

Consider an Endpoint Exception Review app. Source systems can show device
facts: FleetTrack knows whether a laptop checked in, Entra ID knows the assigned
user, the HR system knows the manager and department, and the service desk knows
whether a ticket exists. None of those source systems owns the cross-system
workflow of deciding whether an exception is acceptable, who reviewed it, when
it should be revisited, or what remediation action was agreed to.

The custom app fills that operational gap. It reads governed current-state data
from `edp_ods`, such as device owner, department, encryption status, last
check-in, and existing service ticket references. It may also read summary
context from `edp_mart`, such as department-level exception trends or stale
device counts. The app stores its own workflow state in `edp_app`: assigned
reviewer, review status, risk acceptance notes, due date, escalation history,
and links to remediation tickets.

That separation matters. FleetTrack remains the source of device facts, the ODS
remains the current-state operational model, the mart remains the reporting
surface, and the app database owns only the workflow state that no upstream
source system naturally captures.

## Power BI

Power BI can be useful in Microsoft-heavy environments, especially where users already live in M365 and business teams have existing Power BI skills.

Treat Power BI as an optional enterprise reporting endpoint rather than the default platform dependency. If used, it should consume governed Data Marts or semantic models instead of rebuilding logic in isolated reports.

## Consumption Rules

Consumer tools should mostly query:

- Data Marts for business reporting and analytics
- Governed ODS views for current-state operational visibility
- Purpose-built APIs for custom applications and workflows
- Platform metadata for pipeline health, freshness, and audit dashboards

Consumer tools should generally avoid:

- Direct raw table access for normal users
- Direct Data Vault access for casual reporting
- Rebuilding business logic inside dashboard calculations
- Tool-specific copies of official definitions
- Uncontrolled exports that recreate spreadmarts

## Starting Stack

Start with:

- Apache Superset for the main BI portal
- Grafana for platform and pipeline operations
- FastAPI plus Vue when a dashboard becomes an operational workflow

Add Evidence.dev when the platform needs version-controlled narrative data products.

Add Metabase only if casual self-service exploration becomes a clear need.
