# Canvas LMS

Canvas LMS is a learning management system source for courses, sections, enrollments, users, assignments, submissions, grades, modules, pages, files, discussions, outcomes, and learning activity. For EDP, Canvas is often the operational bridge between SIS roster data and day-to-day digital instruction.

## Overview

Canvas can provide EDP with learning platform activity, course structure, enrollment state, and instructional workflow context. It is especially useful when correlated with Infinite Campus, Google Workspace, M365, Apple School Manager, and identity systems.

EDP should use Canvas data to support:

- LMS course, section, and enrollment visibility
- SIS-to-LMS roster reconciliation
- Student and teacher account validation
- Assignment, submission, and grade workflow reporting where approved
- Course activity and engagement reporting
- Digital learning governance
- Access review and enrollment review
- Support analytics for instructional technology teams

## Ownership

| Role | Responsibility |
| --- | --- |
| Source system owner | Owns Canvas tenant operations, account structure, SIS imports, and LMS policy |
| Technical owner | Supports developer keys, API tokens, OAuth, scopes, Canvas Data, and integration troubleshooting |
| Data steward | Defines course, section, enrollment, assignment, submission, activity, and grade reporting meaning |
| Platform owner | Runs the connector, raw landing, transformations, quality checks, and downstream models |

## Data Domains

Initial Canvas data domains:

- Accounts and subaccounts
- Users
- Courses
- Sections
- Enrollments
- Terms
- Groups and group memberships
- Assignments
- Submissions where approved
- Modules and module items
- Pages, files, discussions, and quizzes metadata where approved
- Course activity and analytics where available

Later domains may include:

- Outcomes and rubrics
- Gradebook history
- Communication channels
- Live events
- Canvas Data 2 extracts
- LTI tools and placements

## Connector Options

| Connector Option | When It Fits | Notes |
| --- | --- | --- |
| Canvas REST API | Preferred production pattern for courses, users, sections, enrollments, assignments, submissions, and account metadata | Canvas API access uses HTTPS against the institution's Canvas domain |
| Canvas Data 2 | Useful for bulk analytics and historical reporting where licensed and enabled | Good fit for larger reporting models and heavy analytical workloads |
| Live Events | Useful for event-driven activity capture where enabled | Should be paired with reconciliation jobs |
| SIS import/export reports | Useful for roster reconciliation and import audit evidence | Treat as operational evidence, not the only source of truth |
| Admin reports | Useful as an interim or fallback approach | Should be governed and scheduled where possible |
| Manual seed | Acceptable only for early testing or static reference data | Should not be used for production LMS reporting |

## Prebuilt Package Status

Status: planned.

A reusable Canvas connector package should include:

- Containerized Canvas connector runtime
- Configuration schema for Canvas domain, account IDs, terms, object sets, schedules, API scopes, and pagination limits
- Developer key or token setup guide
- Connection test
- Pagination, throttling, retry, and backoff handling
- Airflow DAG template
- Raw landing tables for accounts, users, courses, sections, enrollments, groups, assignments, submissions, modules, files, pages, discussions, and collection runs
- dbt source definitions
- ODS mappings for person, account, course, section, enrollment, assignment, submission, grade observation, and learning activity
- Data Vault hub, link, and satellite templates
- Data quality tests
- Operational runbook

## Required Access

The connector should use approved Canvas API credentials, preferably a scoped developer key or integration account with least-privilege permissions. Avoid personal access tokens for production connectors unless the institution explicitly approves that pattern.

Document these items before production use:

- Canvas base URL
- Root account and subaccount scope
- Authentication pattern
- Developer key or integration account owner
- Required scopes or permissions
- Terms, courses, and object types to collect
- Whether submissions, grades, activity, or communication data are approved
- Rate limits, pagination behavior, and retry expectations
- Approval from LMS, curriculum, and data governance owners

## Raw Landing Design

Recommended raw tables:

| Raw Table | Purpose |
| --- | --- |
| `raw.canvas_accounts` | Account and subaccount payloads |
| `raw.canvas_terms` | Enrollment term payloads |
| `raw.canvas_users` | Canvas user payloads |
| `raw.canvas_courses` | Course payloads |
| `raw.canvas_sections` | Section payloads |
| `raw.canvas_enrollments` | Enrollment payloads |
| `raw.canvas_groups` | Group payloads |
| `raw.canvas_group_memberships` | Group membership payloads |
| `raw.canvas_assignments` | Assignment payloads |
| `raw.canvas_submissions` | Submission and grade payloads where approved |
| `raw.canvas_modules` | Module and module-item payloads |
| `raw.canvas_course_assets` | Page, file, discussion, and quiz metadata where approved |
| `raw.canvas_collection_runs` | Connector run metadata, counts, timing, and status |

Each raw record should include:

- Canvas domain
- Account ID
- Source endpoint
- Source object identifier
- Term ID and course ID where applicable
- Extraction timestamp
- Ingestion run identifier
- Connector version
- Raw payload

## ODS Mapping

Recommended ODS entities:

- `ods.person`
- `ods.learning_account`
- `ods.learning_course`
- `ods.learning_section`
- `ods.learning_enrollment`
- `ods.learning_group`
- `ods.learning_assignment`
- `ods.learning_submission`
- `ods.learning_activity`
- `ods.source_record`

Common mapping rules:

- Preserve Canvas IDs and SIS IDs separately.
- Use SIS IDs for cross-system correlation only when their source and meaning are documented.
- Treat course and section lifecycle state explicitly.
- Keep enrollments separate from identity/account state.
- Treat submissions, grades, messages, and activity as sensitive learning records requiring explicit approval.
- Model activity and submissions as observations with timestamps, not current-state person attributes.

## Data Vault Mapping

Recommended Data Vault structures:

- Hub: person
- Hub: Canvas account
- Hub: course
- Hub: section
- Hub: term
- Hub: assignment
- Link: person to Canvas account
- Link: Canvas account to course
- Link: Canvas account to section
- Link: section to course
- Link: course to term
- Link: assignment to course
- Satellites: course attributes, enrollment history, assignment attributes, submission observations, activity observations, source metadata, and classification history

## Data Mart Outputs

Initial Canvas marts:

- Canvas course mart
- Canvas enrollment mart
- SIS-to-Canvas roster reconciliation mart
- Canvas account lifecycle mart
- Assignment and submission workflow mart where approved
- Course activity mart where approved
- Digital learning support mart

## Quality Checks

Recommended checks:

- Collection run completed successfully.
- Account, user, course, section, enrollment, and assignment counts are within expected ranges.
- Source identifiers are present and unique within each object type.
- Enrollments reference known users, courses, and sections.
- Courses and sections reference known terms and accounts where available.
- SIS IDs align to approved source-system identifiers.
- Sensitive records are collected only for approved terms, courses, and populations.
- Freshness meets the expected schedule.

## Refresh Schedule

Start with daily collection for accounts, terms, users, courses, sections, and enrollments.

Use more frequent collection during back-to-school, add/drop periods, or active roster sync windows. Assignment, submission, grade, and activity data may require separate schedules and stronger governance approval.

## Operational Runbook

The Canvas connector runbook should include:

- How to validate Canvas base URL and API access
- How to confirm developer key, token, or OAuth setup
- How to test scopes and account permissions
- How to run a manual collection
- How to review collection counts
- How to handle pagination and throttling
- How to backfill a term or course set
- How to coordinate SIS import reconciliation
- How to disable the connector safely

## Known Limitations

Canvas data availability depends on institution configuration, API permissions, course state, term state, Canvas product licensing, and whether Canvas Data or Live Events are enabled.

Grades, submissions, messages, analytics, and activity data are sensitive learning records. Collection should be explicitly approved and minimized to the reporting use case.

## References

- [Canvas LMS REST API Documentation](https://canvas.instructure.com/doc/api/index.html)
- [Instructure Developer Documentation Portal](https://developerdocs.instructure.com/get_started)
- [Canvas API Resources](https://documentation.instructure.com/doc/api/all_resources.html)
