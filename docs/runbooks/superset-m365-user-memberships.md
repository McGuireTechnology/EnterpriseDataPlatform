# Superset M365 User Memberships

This runbook builds a Superset dataset and dashboard for M365 user group, team, and channel memberships.

## Goal

Given a selected user, show:

- User attributes
- M365 group memberships
- Teams memberships
- Channel memberships

## Virtual Dataset SQL

Create a SQL dataset against the EDP ODS connection:

```sql
with base_users as (
    select
        u.source_key,
        u.source_object_id as user_id,
        u.display_name as user_display_name,
        u.user_principal_name,
        u.email,
        u.enabled,
        u.source_snapshot_ts as user_snapshot_ts
    from m365.users u
),
group_rows as (
    select
        bu.source_key,
        bu.user_id,
        bu.user_display_name,
        bu.user_principal_name,
        bu.email,
        bu.enabled,
        bu.user_snapshot_ts,
        'group'::text as membership_type,
        gm.group_object_id as parent_id,
        g.display_name as parent_name,
        null::text as team_id,
        null::text as team_name,
        null::text as channel_id,
        null::text as channel_name,
        false as is_inherited,
        gm.source_snapshot_ts as membership_snapshot_ts
    from base_users bu
    join m365.group_memberships gm
      on gm.source_key = bu.source_key
     and gm.member_object_id = bu.user_id
    left join m365.groups g
      on g.source_key = gm.source_key
     and g.source_object_id = gm.group_object_id
),
team_rows as (
    select
        bu.source_key,
        bu.user_id,
        bu.user_display_name,
        bu.user_principal_name,
        bu.email,
        bu.enabled,
        bu.user_snapshot_ts,
        'team'::text as membership_type,
        tm.team_id as parent_id,
        t.display_name as parent_name,
        tm.team_id,
        t.display_name as team_name,
        null::text as channel_id,
        null::text as channel_name,
        false as is_inherited,
        tm.source_snapshot_ts as membership_snapshot_ts
    from base_users bu
    join m365.team_memberships tm
      on tm.source_key = bu.source_key
     and tm.member_object_id = bu.user_id
    left join m365.teams t
      on t.source_key = tm.source_key
     and t.team_id = tm.team_id
),
channel_rows as (
    select
        bu.source_key,
        bu.user_id,
        bu.user_display_name,
        bu.user_principal_name,
        bu.email,
        bu.enabled,
        bu.user_snapshot_ts,
        'channel'::text as membership_type,
        concat(cm.team_id, ':', cm.channel_id) as parent_id,
        coalesce(ch.display_name, cm.channel_id) as parent_name,
        cm.team_id,
        t.display_name as team_name,
        cm.channel_id,
        ch.display_name as channel_name,
        cm.is_inherited,
        cm.source_snapshot_ts as membership_snapshot_ts
    from base_users bu
    join m365.channel_memberships cm
      on cm.source_key = bu.source_key
     and cm.member_object_id = bu.user_id
    left join m365.channels ch
      on ch.source_key = cm.source_key
     and ch.team_id = cm.team_id
     and ch.channel_id = cm.channel_id
    left join m365.teams t
      on t.source_key = cm.source_key
     and t.team_id = cm.team_id
)
select * from group_rows
union all
select * from team_rows
union all
select * from channel_rows;
```

Save the dataset as `vds_ods_m365_user_memberships_membership`.

## Dashboard Build

Create these table charts:

- User attributes: `user_display_name`, `user_principal_name`, `email`, `enabled`
- Groups: filter `membership_type = 'group'`, show `parent_name`, `parent_id`
- Teams: filter `membership_type = 'team'`, show `team_name`, `team_id`
- Channels: filter `membership_type = 'channel'`, show `team_name`, `channel_name`, `channel_id`, `is_inherited`

Add dashboard filters:

- `user_principal_name`
- `user_display_name`
- `membership_type`
- `source_key` when multiple tenants are ingested

## Recommended Enhancements

- Add a KPI chart that counts memberships by `membership_type`.
- Materialize the query into `edp_mart` if it becomes slow.
- Add freshness context from `membership_snapshot_ts` and `user_snapshot_ts`.
