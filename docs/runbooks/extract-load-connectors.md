# Extract And Load Connectors

This runbook tracks connector rollout, naming, and operations for EDP extract/load integrations.

## Connector Inventory

| Integration | Domain | Snapshot Mode | Raw Landing | ODS Processing | Status |
| --- | --- | --- | --- | --- | --- |
| AD DS | Identity and access | Full and incremental | `edp_raw.ad` | Planned processing DAG | In progress |
| M365 / Entra ID | Identity and collaboration | Full and incremental | `edp_raw.m365` | `edp_ods.m365` | In progress |
| KnowBe4 | Security awareness | Full and incremental | Planned | Planned | Planned |
| Microsoft Exchange | Messaging | Full and incremental | Planned | Planned | Planned |
| Microsoft Teams | Collaboration | Full and incremental | Included with `m365` connector | `edp_ods.m365` | In progress |

## Naming Convention

Prefer database and schema boundaries over table prefixes.

- Raw source-shaped data: `edp_raw.<source_schema>.<entity>`
- ODS current state: `edp_ods.<source_schema>.<entity>`
- Curated reporting: `edp_mart.<domain>_<entity>_<grain>`

Examples:

- `edp_raw.ad.users`
- `edp_raw.ad.group_memberships`
- `edp_raw.m365.teams`
- `edp_ods.m365.channel_memberships`

## AD

DAGs:

- `ad_full_snapshot`
- `ad_incremental_snapshot`
- `ad_process_snapshots`

Airflow configuration:

- `ad_sources`: JSON array of source mappings.
- `ad_target_conn_id`: Airflow connection id for raw PostgreSQL writes. Defaults to `postgres_raw`.
- Legacy names are still read by the DAG for existing Airflow environments.

Required raw tables:

- `ad.sync_runs`
- `ad.sync_state`
- `ad.users`
- `ad.groups`
- `ad.group_memberships`
- `ad.computers`

Operational checks:

- Confirm the target connection points to `edp_raw`.
- Confirm `sync_state` cursors are advancing for incremental runs.
- Compare user, group, computer, and membership counts to expected source ranges.
- Use `ad_reset_sync_state=true` only when intentionally forcing cursor reset.

## M365

DAGs:

- `m365_full_snapshot`
- `m365_incremental_snapshot`
- `m365_process_snapshots`

Airflow configuration:

- `m365_identity_source`: JSON object with `airflow_conn_id` and optional `source_key`.
- `m365_identity_target_conn_id`: raw database connection id. Defaults to `postgres_raw`.
- `m365_identity_ods_conn_id`: ODS database connection id. Defaults to `postgres_ods`.

Required raw tables:

- `m365.sync_runs`
- `m365.users`
- `m365.groups`
- `m365.group_memberships`
- `m365.teams`
- `m365.channels`
- `m365.team_memberships`
- `m365.channel_memberships`

Required ODS tables:

- `m365.users`
- `m365.groups`
- `m365.group_memberships`
- `m365.teams`
- `m365.channels`
- `m365.team_memberships`
- `m365.channel_memberships`

Operational checks:

- Confirm Graph app credentials are stored in the Airflow connection referenced by `m365_identity_source`.
- Confirm app permissions include the Graph application permissions required by collected endpoints.
- Review `m365.sync_runs` for failures and row count anomalies.
- Confirm `m365_process_snapshots` runs after successful raw syncs.
- For standard Teams channels, expect inherited membership rows derived from team membership.

## Reprocessing

Use bounded reprocessing by source key, run id, and snapshot timestamp. Avoid direct manual edits to ODS rows when raw data can be replayed.

Recommended order:

1. Re-run or backfill raw connector tasks for the affected source window.
2. Re-run the ODS processing DAG for that source and window.
3. Rebuild affected mart or dashboard-facing outputs.

Keep failed runs visible in run metadata. Do not delete failed run records unless they contain sensitive test data and the cleanup is documented.
