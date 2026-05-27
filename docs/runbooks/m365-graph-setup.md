# M365 Graph Setup

This runbook configures the M365 identity and collaboration connector.

## Scope

The connector uses Microsoft Graph to collect users, groups, group memberships, Teams, channels, team memberships, and channel memberships.

Data lands in `edp_raw.m365` and is merged into `edp_ods.m365` by `m365_process_snapshots`.

## App Registration

1. In Microsoft Entra ID, create an app registration for EDP.
2. Use a single-tenant app unless a multi-tenant deployment is explicitly required.
3. Create a client secret or certificate.
4. Record the tenant id, client id, and secret or certificate reference.

## Required Permissions

Start with these Microsoft Graph application permissions:

- `User.Read.All`
- `Group.Read.All`
- `Directory.Read.All`
- `Team.ReadBasic.All`
- `TeamMember.Read.All`
- `Channel.ReadBasic.All`
- `ChannelMember.Read.All`

Grant admin consent after permissions are added. Review permissions whenever the connector adds endpoints.

## Airflow Connection

Create an Airflow connection named `m365_graph`.

Use the client id as the login and the client secret as the password. Store this extra JSON:

```json
{
  "tenant_id": "<tenant-id>",
  "graph_base": "https://graph.microsoft.com/v1.0"
}
```

## Airflow Variables

Set `m365_identity_source`:

```json
{"airflow_conn_id":"m365_graph","source_key":"microsoft-entra"}
```

Set `m365_identity_target_conn_id` to the raw PostgreSQL Airflow connection:

```text
postgres_raw
```

Set `m365_identity_ods_conn_id` to the ODS PostgreSQL Airflow connection:

```text
postgres_ods
```

## Database Setup

Apply migrations before the first run:

```sh
make db-upgrade
```

The connector expects `m365` tables in both `edp_raw` and `edp_ods`.

## Run Order

Trigger one of the raw snapshot DAGs:

- `m365_full_snapshot`
- `m365_incremental_snapshot`

Each snapshot DAG triggers:

- `m365_process_snapshots`

## Validation

Check raw counts:

- `edp_raw.m365.users`
- `edp_raw.m365.groups`
- `edp_raw.m365.group_memberships`
- `edp_raw.m365.teams`
- `edp_raw.m365.channels`
- `edp_raw.m365.team_memberships`
- `edp_raw.m365.channel_memberships`
- `edp_raw.m365.sync_runs`

Check ODS counts:

- `edp_ods.m365.users`
- `edp_ods.m365.groups`
- `edp_ods.m365.group_memberships`
- `edp_ods.m365.teams`
- `edp_ods.m365.channels`
- `edp_ods.m365.team_memberships`
- `edp_ods.m365.channel_memberships`

Review `sync_runs.status`, `rows_read`, `rows_written`, and `error_message` when counts are missing or unexpectedly low.
