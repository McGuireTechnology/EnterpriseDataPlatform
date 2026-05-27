# Superset Naming

Use these conventions so Superset datasets, charts, and dashboards are predictable and easy to operate.

## Principles

- Use lowercase `snake_case` for dataset names.
- Use concise title case for chart and dashboard display names.
- Encode layer, domain, entity, and grain in dataset names.
- Prefer stable names over date, version, or owner suffixes.
- Keep Superset names aligned with database objects.

## Virtual Datasets

Pattern:

```text
vds_<layer>_<domain>_<entity>_<grain>
```

Examples:

- `vds_ods_m365_user_attributes_user`
- `vds_ods_m365_user_groups_membership`
- `vds_ods_m365_user_teams_membership`
- `vds_ods_m365_user_channels_membership`

Use `vds_` only for Superset virtual datasets. The grain should describe row-level uniqueness, such as `user`, `membership`, or `daily`.

## Physical Datasets

Pattern:

```text
<schema>.<domain>_<entity>_<grain>
```

Examples:

- `reporting.m365_user_attributes`
- `reporting.m365_user_group_memberships`
- `reporting.m365_user_team_memberships`
- `reporting.m365_user_channel_memberships`

Do not include `vds` in physical object names.

## Charts

Pattern:

```text
<Domain> - <Subject> - <Visualization>
```

Examples:

- `M365 - User Attributes - Table`
- `M365 - User Groups - Table`
- `M365 - User Teams - Table`
- `M365 - User Channels - Table`

Name charts by business content, not implementation detail.

## Dashboards

Pattern:

```text
<Domain> - <Audience Or Use Case>
```

Examples:

- `M365 - User Access Explorer`
- `M365 - Identity Membership Audit`

Dashboard names should describe the decision or workflow they support.

## Filters

Use labels people recognize:

- `User Principal Name`
- `Display Name`
- `Group`
- `Team`
- `Channel`
- `Source Tenant`

Avoid exposing internal field names unless the audience needs them.

## Metrics

Pattern:

```text
<Measure> <Entity>
```

Examples:

- `Count Users`
- `Count Group Memberships`
- `Count Team Memberships`
- `Count Channel Memberships`
- `Count Channels Inherited`
- `Count Channels Direct`

## Anti-Patterns

- Mixed separators, such as `M365-userGroups`
- Ambiguous names, such as `users` or `groups`
- Environment suffixes in governed business objects
- Personal names in shared dashboard object names
- Date or version suffixes for active production objects
