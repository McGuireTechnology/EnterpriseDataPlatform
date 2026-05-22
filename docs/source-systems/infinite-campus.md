# Infinite Campus

Infinite Campus is a student information system source for student, guardian, enrollment, course, section, roster, assignment, grade, attendance, calendar, and school context. For EDP, it is often an authoritative source for K-12 academic structure and student lifecycle data.

## Overview

Infinite Campus can provide EDP with SIS context that explains who students are, where they are enrolled, what courses and sections exist, who teaches those sections, and how academic activity relates to operational systems such as Canvas LMS, Google Workspace, Apple School Manager, and service desk workflows.

EDP should use Infinite Campus data to support:

- Student and guardian lifecycle visibility
- School, year, term, course, and section reporting
- Roster and enrollment reconciliation
- LMS provisioning and roster validation
- Student account and device assignment governance
- Academic operational dashboards
- Data quality checks across SIS, LMS, identity, and device platforms
- Compliance and audit evidence for educational systems

## Ownership

| Role | Responsibility |
| --- | --- |
| Source system owner | Owns Infinite Campus configuration, SIS operations, school-year setup, and data release decisions |
| Technical owner | Supports OneRoster configuration, credentials, OAuth, endpoint URLs, and integration troubleshooting |
| Data steward | Defines student, enrollment, course, section, roster, assignment, grade, and attendance reporting meaning |
| Platform owner | Runs the connector, raw landing, transformations, quality checks, and downstream models |

## Data Domains

Initial Infinite Campus data domains:

- Academic years and terms
- Schools
- Users
- Students
- Teachers and staff
- Guardians and contacts where approved
- Courses
- Classes and sections
- Enrollments and rosters
- Demographics where approved
- Assignments, scores, grades, and gradebook categories where enabled
- Attendance and calendar context where available

Later domains may include:

- Programs
- Fees
- Behavior
- Transportation
- Health or special program indicators, only with explicit governance approval

## Connector Options

| Connector Option | When It Fits | Notes |
| --- | --- | --- |
| OneRoster API | Preferred production pattern for roster, course, class, user, enrollment, assignment, and score data | Infinite Campus supports OneRoster 1.1 and 1.2; new connections use OAuth 2 |
| Customer-approved MS SQL read access | Useful when the customer chooses to expose read access to the Infinite Campus database for broader reporting coverage | Provides deeper coverage than OneRoster, but requires strict least privilege, query controls, schema-change monitoring, and source-owner approval |
| OneRoster CSV export | Useful for scheduled file-based integration or early implementation | Requires strong file validation, naming, and retention controls |
| Ad hoc reports or data extracts | Useful for fields not exposed through OneRoster | Should be governed by the SIS owner and treated as source-specific extracts |
| Vendor-supported integration | Useful when the district has an approved partner integration | Confirm exact data domains and whether the integration is read-only or bidirectional |
| Manual seed | Acceptable only for early testing or static reference data | Should not be used for production academic reporting |

## Prebuilt Package Status

Status: planned.

A reusable Infinite Campus connector package should include:

- Containerized OneRoster connector runtime
- Configuration schema for base URL, token URL, OAuth credentials, OneRoster version, MS SQL connection details where approved, schools, terms, and object sets
- OneRoster 1.1 and 1.2 endpoint support where practical
- Optional SQL extraction templates for customer-approved database read scenarios
- Pagination, filtering, retry, and error handling
- Airflow DAG template
- Raw landing tables for academic sessions, orgs, users, courses, classes, enrollments, assignments, results, and line items
- Raw landing patterns for customer-approved SQL extracts when the customer exposes broader database access
- dbt source definitions
- ODS mappings for student, staff, guardian, school, term, course, section, roster, assignment, grade, and attendance context
- Data Vault hub, link, and satellite templates
- Data quality tests
- Operational runbook

## Required Access

The connector should use an approved OneRoster connection configured in Infinite Campus. New connections should use OAuth 2 where available.

If the customer elects to expose the Infinite Campus MS SQL database, the connector may use customer-approved read-only database access instead of, or in addition to, OneRoster. This path should be treated as a higher-governance integration because it can expose the full SIS data model rather than the narrower OneRoster integration surface.

Document these items before production use:

- District or tenant identifier
- Base URL
- Token URL
- OneRoster version
- Client ID and credential owner
- Enabled connection type
- MS SQL host, database, read-only role, allowed schemas, and query boundaries where database access is used
- Schools, years, and terms included
- Whether assignment, score, and grade data are enabled
- Data excluded by district policy or source configuration
- Rate limits, caching behavior, and retry expectations
- Approval from SIS, curriculum, and data governance owners

## Raw Landing Design

Recommended raw tables:

| Raw Table | Purpose |
| --- | --- |
| `raw.infinite_campus_academic_sessions` | School years, terms, grading periods, and session payloads |
| `raw.infinite_campus_orgs` | District, school, and organizational payloads |
| `raw.infinite_campus_users` | Student, teacher, staff, and contact payloads |
| `raw.infinite_campus_courses` | Course catalog payloads |
| `raw.infinite_campus_classes` | Section or class payloads |
| `raw.infinite_campus_enrollments` | Student and staff roster payloads |
| `raw.infinite_campus_line_items` | Assignment or gradebook item payloads where enabled |
| `raw.infinite_campus_results` | Scores or results where enabled |
| `raw.infinite_campus_sql_extracts` | Customer-approved SQL extract payloads or normalized extract batches when broader database access is used |
| `raw.infinite_campus_collection_runs` | Connector run metadata, counts, timing, and status |

Each raw record should include:

- District or customer identifier
- OneRoster version
- Source endpoint
- Source object identifier
- School year and term where applicable
- Extraction timestamp
- Ingestion run identifier
- Connector version
- Raw payload

## ODS Mapping

Recommended ODS entities:

- `ods.person`
- `ods.student`
- `ods.staff`
- `ods.guardian`
- `ods.school`
- `ods.academic_session`
- `ods.course`
- `ods.section`
- `ods.roster_membership`
- `ods.assignment`
- `ods.grade_result`
- `ods.source_record`

Common mapping rules:

- Preserve Infinite Campus sourced IDs as source identifiers.
- Treat school year and term as first-class context for rosters, sections, assignments, and results.
- Keep roster membership separate from account provisioning.
- Correlate students, staff, and guardians to identity systems through approved identifiers only.
- Treat grades, scores, attendance, behavior, health, and program data as sensitive and governance-controlled.

## Data Vault Mapping

Recommended Data Vault structures:

- Hub: person
- Hub: student
- Hub: staff
- Hub: school
- Hub: academic session
- Hub: course
- Hub: section
- Hub: assignment
- Link: student to school
- Link: student to section
- Link: staff to section
- Link: section to course
- Link: section to academic session
- Link: assignment to section
- Satellites: demographics, enrollment history, roster history, section attributes, assignment attributes, score observations, source metadata, and governance classification

## Data Mart Outputs

Initial Infinite Campus marts:

- Student enrollment mart
- Course and section mart
- Roster reconciliation mart
- LMS provisioning validation mart
- Student lifecycle mart
- SIS to identity reconciliation mart
- Academic operational quality mart

## Quality Checks

Recommended checks:

- Collection run completed successfully.
- Academic session, school, user, course, class, and enrollment counts are within expected ranges.
- Source identifiers are present and unique within each object type.
- Enrollments reference known users and classes.
- Classes reference known courses, schools, and academic sessions.
- Term and school-year filters match the approved collection scope.
- Sensitive fields are collected only when explicitly approved.
- Freshness meets the expected schedule.

## Refresh Schedule

Start with daily collection for schools, years, terms, users, courses, sections, and rosters.

Use more frequent collection during back-to-school, schedule changes, and LMS provisioning windows. Assignment, score, and grade data may require separate schedules and stronger approval.

## Operational Runbook

The Infinite Campus connector runbook should include:

- How to validate OneRoster credentials and token access
- How to confirm base URL, token URL, and OneRoster version
- How to verify school-year and term filters
- How to run a connection test
- How to review collection counts
- How to handle permission or scope failures
- How to coordinate back-to-school sync windows
- How to backfill a school year or term
- How to disable the connector safely

## Known Limitations

OneRoster availability, enabled endpoints, and writable behavior depend on district configuration, Infinite Campus connection type, partner status, and OneRoster version.

Customer-approved MS SQL access can expose far more data than EDP needs. Use read-only credentials, source-owned views where practical, query allowlists, extraction windows, and explicit field governance.

Some Infinite Campus data is highly sensitive. Student, guardian, grades, attendance, behavior, health, and program information require clear governance and least-privilege access.

## References

- [Infinite Campus OneRoster API](https://kb.infinitecampus.com/help/oneroster-api)
- [Infinite Campus OneRoster API Documentation for OAuth 2](https://kb.infinitecampus.com/help/oneroster-api-documentation-oauth-2)
- [Infinite Campus OneRoster 1.1 Data Models](https://kb.infinitecampus.com/help/oneroster-11-data-models)
