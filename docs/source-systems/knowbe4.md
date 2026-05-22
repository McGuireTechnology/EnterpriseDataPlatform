# KnowBe4

KnowBe4 is a source system for security awareness training, simulated phishing, user risk, campaign participation, and compliance evidence.

It should be documented separately from security operations platforms. KnowBe4 is usually the system of record for awareness training assignment, completion, phishing simulation results, and risk scoring, while SIEM, SOAR, ticketing, identity, and email platforms provide surrounding operational context.

## Overview

EDP should use KnowBe4 data to support:

- Security awareness training completion reporting
- Phishing simulation campaign analytics
- User risk score trend reporting
- Group and department training compliance
- New-hire and annual training validation
- Remedial training tracking
- Compliance evidence for audit and governance
- Cross-system reconciliation with HR, Active Directory, Microsoft 365, identity provider, and service desk data

## Ownership

| Role | Responsibility |
| --- | --- |
| Source system owner | Owns KnowBe4 tenant administration, campaign configuration, training assignments, and reporting expectations |
| Technical owner | Supports API keys, webhooks, exports, access control, and connector setup |
| Data steward | Defines training, campaign, risk, group, and compliance reporting meaning for EDP consumers |
| Platform owner | Runs the connector, raw landing, transformations, quality checks, and downstream models |

## Data Domains

Initial KnowBe4 data domains:

- Users
- Groups and smart groups
- Training campaigns
- Training enrollments and completion status
- Phishing campaigns
- Phishing recipients and interaction results
- User risk scores and phish-prone percentage
- Reported phishing activity where available
- User events
- Account and console metadata

Later domains may include:

- PhishER or phishing triage data where licensed and approved
- SecurityCoach or product-specific event data where licensed and approved
- Roll-up reporting for multi-account environments
- Webhook event streams for selected operational workflows

## Connector Options

| Connector Option | When It Fits | Notes |
| --- | --- | --- |
| KnowBe4 Reporting API | Preferred production pattern for reporting data | Supports reporting-oriented phishing, training, user, and group data where the subscription includes API access |
| KnowBe4 Graph API | Useful when richer KSAT product queries or mutations are needed | Should be scoped carefully and treated as a higher-privilege integration surface |
| KnowBe4 User Event API | Useful for pushing custom user events into KnowBe4 | This is primarily an inbound event pattern, but event definitions should still be documented in EDP |
| KnowBe4 Product API | Useful for product-specific capabilities where approved | Validate product, license, and permission requirements before implementation |
| Webhooks | Useful for event-driven workflows | Should complement scheduled reconciliation jobs rather than replace them |
| Report export or CSV export | Useful as an interim or fallback approach | Should be treated as a bridge until API collection is available |
| Manual seed | Acceptable only for early testing or static reference data | Should not be used for production operational reporting |

## Prebuilt Package Status

Status: planned.

A reusable KnowBe4 connector package should include:

- Containerized KnowBe4 connector runtime
- Configuration schema for region, base URL, object sets, schedules, report windows, and webhook options
- Required API permission and subscription documentation
- API key creation, storage, and rotation guide
- Connection test
- Pagination, rate limit, retry, and backoff handling
- Airflow DAG template
- Raw landing tables for users, groups, campaigns, enrollments, phishing results, risk scores, events, and collection runs
- dbt source definitions
- ODS identity, training, campaign, event, risk, and compliance mappings
- Data Vault hub, link, and satellite templates
- Data quality tests
- Operational runbook

## Required Access

Document these items before production use:

- KnowBe4 account or tenant identifier
- KnowBe4 region or API base URL
- API key or approved service credential
- Required API feature availability for the customer subscription
- Required administrator role or permission level
- Object types and report windows to collect
- Webhook endpoints and signing or validation pattern where webhooks are used
- Token or API key rotation pattern
- Network egress requirements
- Approval from the security awareness owner and data steward

Use least-privilege access. Avoid collecting message content or sensitive user event detail unless the reporting use case and retention controls are clearly approved.

## Raw Landing Design

Recommended raw tables:

| Raw Table | Purpose |
| --- | --- |
| `raw.knowbe4_users` | User payloads and source metadata |
| `raw.knowbe4_groups` | Group and smart group payloads |
| `raw.knowbe4_group_memberships` | User-to-group membership edges |
| `raw.knowbe4_training_campaigns` | Training campaign payloads |
| `raw.knowbe4_training_enrollments` | User training enrollment and completion payloads |
| `raw.knowbe4_phishing_campaigns` | Phishing campaign payloads |
| `raw.knowbe4_phishing_results` | Recipient and interaction result payloads |
| `raw.knowbe4_risk_scores` | User risk score and phish-prone percentage observations |
| `raw.knowbe4_user_events` | User event payloads where collected |
| `raw.knowbe4_webhook_events` | Webhook event payloads where enabled |
| `raw.knowbe4_collection_runs` | Connector run metadata, counts, timing, and status |

Each raw record should include:

- KnowBe4 account or tenant identifier
- Source endpoint, report, or event name
- Source object identifier
- Source object type
- Report window or event timestamp where applicable
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
- `ods.training_campaign`
- `ods.training_assignment`
- `ods.training_completion`
- `ods.phishing_campaign`
- `ods.phishing_result`
- `ods.risk_score_observation`
- `ods.security_awareness_event`
- `ods.compliance_evidence`
- `ods.source_record`

Common mapping rules:

- Correlate KnowBe4 users to enterprise identities through approved identifiers such as email address, employee identifier, or identity provider attributes.
- Preserve KnowBe4 user identifiers as source keys because email addresses can change.
- Treat risk scores and phish-prone percentage as time-bound observations, not static identity attributes.
- Model training assignment separately from training completion.
- Model phishing campaign recipients separately from interaction outcomes.
- Keep group membership lineage clear because smart groups may be dynamic and rule-based.
- Separate KnowBe4 compliance evidence from HR job status, identity account state, and service desk workflow data.

## Data Vault Mapping

Recommended Data Vault structures:

- Hub: identity
- Hub: KnowBe4 account
- Hub: group
- Hub: training campaign
- Hub: training module
- Hub: phishing campaign
- Hub: security awareness event
- Link: identity to KnowBe4 account
- Link: KnowBe4 account to group
- Link: KnowBe4 account to training campaign
- Link: KnowBe4 account to phishing campaign
- Link: KnowBe4 account to security awareness event
- Satellites: user attributes, group attributes, campaign attributes, assignment status, completion status, phishing outcome, risk observations, event detail, source metadata, and classification history

The Data Vault should preserve historical changes in group membership, campaign enrollment, completion status, phishing results, user risk score, and compliance evidence when collected over time.

## Data Mart Outputs

Initial KnowBe4 marts:

- Security awareness training compliance mart
- New-hire training completion mart
- Annual training completion mart
- Phishing campaign performance mart
- High-risk user trend mart
- Department or group risk mart
- Remedial training mart
- Audit evidence mart
- Identity lifecycle reconciliation mart

These marts should support security awareness operations, compliance reviews, audit evidence, leadership reporting, and identity lifecycle validation.

## Quality Checks

Recommended checks:

- Collection run completed successfully.
- User, group, campaign, enrollment, and phishing result counts are within expected ranges.
- Source object identifiers are present and unique within each object type.
- Training enrollments resolve to known users and campaigns.
- Phishing results resolve to known users and campaigns.
- Risk score observations have valid observation timestamps.
- Group membership references resolve to known users and groups where available.
- Expected training campaigns and report windows arrive on schedule.
- Webhook events are validated and deduplicated where webhooks are enabled.
- Freshness meets the expected schedule.

## Refresh Schedule

Start with daily collection for users, groups, campaign definitions, training enrollments, completion status, phishing campaign results, and risk observations.

Use more frequent collection when operational needs require closer tracking, such as active phishing simulations, overdue training notifications, onboarding, offboarding, or compliance reporting deadlines.

## Operational Runbook

The KnowBe4 connector runbook should include:

- How to create or validate API access
- How to confirm subscription and feature availability
- How to run a connection test
- How to run a manual collection
- How to review collection counts
- How to handle permission failures
- How to rotate API keys
- How to validate report windows and campaign filters
- How to replay or deduplicate webhook events
- How to disable the connector safely

## Known Limitations

KnowBe4 API availability and data coverage can depend on product, subscription level, region, and enabled features. Document the licensed capabilities and endpoint coverage for each implementation.

Training, phishing, and user risk data can affect employee privacy and performance perceptions. Apply appropriate classification, retention, and access controls before making user-level detail broadly available.

Smart group membership may be dynamic. Store collection timestamps and group membership lineage so reports do not imply a static membership state when the source evaluates membership rules over time.

## References

- [KnowBe4 API Documentation](https://developer.knowbe4.com/)
- [Reporting API Overview](https://support.knowbe4.com/hc/en-us/articles/115016090908-Reporting-API-Overview)
- [KnowBe4 Graph API Overview](https://support.knowbe4.com/hc/en-us/articles/4404258222099-KnowBe4-Graph-API-Overview)
- [User Event API Overview](https://support.knowbe4.com/hc/en-us/articles/360024863474-User-Event-API-Overview)
- [API Change Log](https://support.knowbe4.com/hc/en-us/articles/37449905326995-API-Change-Log)
