from __future__ import annotations

import sqlalchemy as sa

from models.common import metadata


metadata_obj = metadata()

entity_index = sa.Table(
    "entity_index",
    metadata_obj,
    sa.Column("id", sa.BigInteger(), sa.Identity(always=False), primary_key=True),
    sa.Column("entity_type", sa.Text(), nullable=False),
    sa.Column("business_key", sa.Text(), nullable=False),
    sa.Column("display_name", sa.Text(), nullable=True),
    sa.Column("source_system_code", sa.Text(), nullable=False),
    sa.Column("last_seen_at", sa.DateTime(timezone=True), nullable=False),
    sa.UniqueConstraint(
        "entity_type",
        "business_key",
        name="uq_entity_index_type_business_key",
    ),
    schema="ods",
)

m365_users = sa.Table(
    "users",
    metadata_obj,
    sa.Column("id", sa.Text(), primary_key=True),
    sa.Column("source_key", sa.Text(), nullable=False),
    sa.Column("source_object_id", sa.Text(), nullable=False),
    sa.Column("user_principal_name", sa.Text(), nullable=True),
    sa.Column("display_name", sa.Text(), nullable=True),
    sa.Column("email", sa.Text(), nullable=True),
    sa.Column("enabled", sa.Text(), nullable=True),
    sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
    sa.Column("source_snapshot_ts", sa.DateTime(timezone=True), nullable=True),
    sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    sa.UniqueConstraint("source_key", "source_object_id", name="uq_m365_users_source_object"),
    sa.Index("ix_m365_ods_users_upn", "user_principal_name"),
    schema="m365",
)

m365_groups = sa.Table(
    "groups",
    metadata_obj,
    sa.Column("id", sa.Text(), primary_key=True),
    sa.Column("source_key", sa.Text(), nullable=False),
    sa.Column("source_object_id", sa.Text(), nullable=False),
    sa.Column("display_name", sa.Text(), nullable=True),
    sa.Column("mail_enabled", sa.Text(), nullable=True),
    sa.Column("security_enabled", sa.Text(), nullable=True),
    sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
    sa.Column("source_snapshot_ts", sa.DateTime(timezone=True), nullable=True),
    sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    sa.UniqueConstraint("source_key", "source_object_id", name="uq_m365_groups_source_object"),
    schema="m365",
)

m365_group_memberships = sa.Table(
    "group_memberships",
    metadata_obj,
    sa.Column("id", sa.Text(), primary_key=True),
    sa.Column("source_key", sa.Text(), nullable=False),
    sa.Column("group_object_id", sa.Text(), nullable=False),
    sa.Column("member_object_id", sa.Text(), nullable=False),
    sa.Column("source_snapshot_ts", sa.DateTime(timezone=True), nullable=True),
    sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    sa.UniqueConstraint("source_key", "group_object_id", "member_object_id", name="uq_m365_group_memberships_source_group_member"),
    sa.Index("ix_m365_ods_group_memberships_group", "group_object_id"),
    sa.Index("ix_m365_ods_group_memberships_member", "member_object_id"),
    schema="m365",
)

m365_teams = sa.Table(
    "teams",
    metadata_obj,
    sa.Column("id", sa.Text(), primary_key=True),
    sa.Column("source_key", sa.Text(), nullable=False),
    sa.Column("team_id", sa.Text(), nullable=False),
    sa.Column("display_name", sa.Text(), nullable=True),
    sa.Column("description", sa.Text(), nullable=True),
    sa.Column("visibility", sa.Text(), nullable=True),
    sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
    sa.Column("source_snapshot_ts", sa.DateTime(timezone=True), nullable=True),
    sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    sa.UniqueConstraint("source_key", "team_id", name="uq_m365_teams_source_team"),
    schema="m365",
)

m365_channels = sa.Table(
    "channels",
    metadata_obj,
    sa.Column("id", sa.Text(), primary_key=True),
    sa.Column("source_key", sa.Text(), nullable=False),
    sa.Column("team_id", sa.Text(), nullable=False),
    sa.Column("channel_id", sa.Text(), nullable=False),
    sa.Column("display_name", sa.Text(), nullable=True),
    sa.Column("membership_type", sa.Text(), nullable=True),
    sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
    sa.Column("source_snapshot_ts", sa.DateTime(timezone=True), nullable=True),
    sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    sa.UniqueConstraint("source_key", "team_id", "channel_id", name="uq_m365_channels_source_team_channel"),
    schema="m365",
)

m365_team_memberships = sa.Table(
    "team_memberships",
    metadata_obj,
    sa.Column("id", sa.Text(), primary_key=True),
    sa.Column("source_key", sa.Text(), nullable=False),
    sa.Column("team_id", sa.Text(), nullable=False),
    sa.Column("member_object_id", sa.Text(), nullable=False),
    sa.Column("member_ref_id", sa.Text(), nullable=True),
    sa.Column("roles", sa.Text(), nullable=True),
    sa.Column("source_snapshot_ts", sa.DateTime(timezone=True), nullable=True),
    sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    sa.UniqueConstraint("source_key", "team_id", "member_object_id", name="uq_m365_team_memberships_source_team_member"),
    schema="m365",
)

m365_channel_memberships = sa.Table(
    "channel_memberships",
    metadata_obj,
    sa.Column("id", sa.Text(), primary_key=True),
    sa.Column("source_key", sa.Text(), nullable=False),
    sa.Column("team_id", sa.Text(), nullable=False),
    sa.Column("channel_id", sa.Text(), nullable=False),
    sa.Column("member_object_id", sa.Text(), nullable=False),
    sa.Column("member_ref_id", sa.Text(), nullable=True),
    sa.Column("roles", sa.Text(), nullable=True),
    sa.Column("is_inherited", sa.Boolean(), nullable=False, server_default=sa.text("false")),
    sa.Column("source_snapshot_ts", sa.DateTime(timezone=True), nullable=True),
    sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    sa.UniqueConstraint(
        "source_key",
        "team_id",
        "channel_id",
        "member_object_id",
        name="uq_m365_channel_memberships_source_channel_member",
    ),
    sa.Index("ix_m365_ods_channel_memberships_channel", "team_id", "channel_id"),
    sa.Index("ix_m365_ods_channel_memberships_member", "member_object_id"),
    schema="m365",
)
