"""add m365 ods tables

Revision ID: 20260527_0002
Revises: 20260521_0001
Create Date: 2026-05-27 00:00:00.000000+00:00
"""

from __future__ import annotations

from alembic import op
import sqlalchemy as sa


revision = "20260527_0002"
down_revision = "20260521_0001"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute(sa.text('CREATE SCHEMA IF NOT EXISTS "m365"'))

    op.create_table(
        "users",
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
        schema="m365",
    )
    op.create_index("ix_m365_ods_users_upn", "users", ["user_principal_name"], schema="m365")

    op.create_table(
        "groups",
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

    op.create_table(
        "group_memberships",
        sa.Column("id", sa.Text(), primary_key=True),
        sa.Column("source_key", sa.Text(), nullable=False),
        sa.Column("group_object_id", sa.Text(), nullable=False),
        sa.Column("member_object_id", sa.Text(), nullable=False),
        sa.Column("source_snapshot_ts", sa.DateTime(timezone=True), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint(
            "source_key",
            "group_object_id",
            "member_object_id",
            name="uq_m365_group_memberships_source_group_member",
        ),
        schema="m365",
    )
    op.create_index("ix_m365_ods_group_memberships_group", "group_memberships", ["group_object_id"], schema="m365")
    op.create_index("ix_m365_ods_group_memberships_member", "group_memberships", ["member_object_id"], schema="m365")

    op.create_table(
        "teams",
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

    op.create_table(
        "channels",
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

    op.create_table(
        "team_memberships",
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

    op.create_table(
        "channel_memberships",
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
        schema="m365",
    )
    op.create_index(
        "ix_m365_ods_channel_memberships_channel",
        "channel_memberships",
        ["team_id", "channel_id"],
        schema="m365",
    )
    op.create_index(
        "ix_m365_ods_channel_memberships_member",
        "channel_memberships",
        ["member_object_id"],
        schema="m365",
    )


def downgrade() -> None:
    for table in (
        "channel_memberships",
        "team_memberships",
        "channels",
        "teams",
        "group_memberships",
        "groups",
        "users",
    ):
        op.drop_table(table, schema="m365")

    op.execute(sa.text('DROP SCHEMA IF EXISTS "m365"'))
