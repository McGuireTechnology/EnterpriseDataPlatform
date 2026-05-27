"""add AD and M365 raw tables

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


def _sync_run_table(schema: str) -> None:
    op.create_table(
        "sync_runs",
        sa.Column("id", sa.Text(), primary_key=True),
        sa.Column("source_key", sa.Text(), nullable=False),
        sa.Column("status", sa.Text(), nullable=False),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("ended_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("rows_read", sa.Integer(), nullable=False, server_default=sa.text("0")),
        sa.Column("rows_written", sa.Integer(), nullable=False, server_default=sa.text("0")),
        sa.Column("error_message", sa.Text(), nullable=True),
        schema=schema,
    )
    op.create_index(f"ix_{schema}_sync_runs_source_key", "sync_runs", ["source_key"], schema=schema)
    op.create_index(f"ix_{schema}_sync_runs_status", "sync_runs", ["status"], schema=schema)


def upgrade() -> None:
    op.execute(sa.text('CREATE SCHEMA IF NOT EXISTS "ad"'))
    op.execute(sa.text('CREATE SCHEMA IF NOT EXISTS "m365"'))

    _sync_run_table("ad")
    op.create_table(
        "sync_state",
        sa.Column("source_key", sa.Text(), primary_key=True),
        sa.Column("entity", sa.Text(), primary_key=True),
        sa.Column("last_cursor", sa.DateTime(timezone=True), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        schema="ad",
    )
    op.create_table(
        "users",
        sa.Column("id", sa.Text(), primary_key=True),
        sa.Column("source_key", sa.Text(), nullable=False),
        sa.Column("snapshot_mode", sa.Text(), nullable=False),
        sa.Column("snapshot_ts", sa.DateTime(timezone=True), nullable=False),
        sa.Column("object_guid", sa.Text(), nullable=False),
        sa.Column("distinguished_name", sa.Text(), nullable=True),
        sa.Column("sam_account_name", sa.Text(), nullable=True),
        sa.Column("user_principal_name", sa.Text(), nullable=True),
        sa.Column("display_name", sa.Text(), nullable=True),
        sa.Column("email", sa.Text(), nullable=True),
        sa.Column("enabled", sa.Text(), nullable=True),
        sa.Column("when_changed", sa.DateTime(timezone=True), nullable=True),
        sa.Column("sync_run_id", sa.Text(), nullable=True),
        sa.Column("ingested_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(
            ["sync_run_id"],
            ["ad.sync_runs.id"],
            name="fk_ad_users_sync_run_id",
            ondelete="SET NULL",
        ),
        schema="ad",
    )
    op.create_index("ix_ad_users_object_guid", "users", ["object_guid"], schema="ad")
    op.create_index("ix_ad_users_sam_account_name", "users", ["sam_account_name"], schema="ad")
    op.create_index(
        "ix_ad_users_user_principal_name",
        "users",
        ["user_principal_name"],
        schema="ad",
    )
    op.create_index("ix_ad_users_sync_run_id", "users", ["sync_run_id"], schema="ad")
    op.create_index("ix_ad_users_when_changed", "users", ["when_changed"], schema="ad")

    op.create_table(
        "groups",
        sa.Column("id", sa.Text(), primary_key=True),
        sa.Column("source_key", sa.Text(), nullable=False),
        sa.Column("snapshot_mode", sa.Text(), nullable=False),
        sa.Column("snapshot_ts", sa.DateTime(timezone=True), nullable=False),
        sa.Column("object_guid", sa.Text(), nullable=False),
        sa.Column("distinguished_name", sa.Text(), nullable=True),
        sa.Column("sam_account_name", sa.Text(), nullable=True),
        sa.Column("name", sa.Text(), nullable=True),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("when_changed", sa.DateTime(timezone=True), nullable=True),
        sa.Column("sync_run_id", sa.Text(), nullable=True),
        sa.Column("ingested_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(
            ["sync_run_id"],
            ["ad.sync_runs.id"],
            name="fk_ad_groups_sync_run_id",
            ondelete="SET NULL",
        ),
        schema="ad",
    )
    op.create_index("ix_ad_groups_object_guid", "groups", ["object_guid"], schema="ad")
    op.create_index("ix_ad_groups_sam_account_name", "groups", ["sam_account_name"], schema="ad")
    op.create_index("ix_ad_groups_sync_run_id", "groups", ["sync_run_id"], schema="ad")
    op.create_index("ix_ad_groups_when_changed", "groups", ["when_changed"], schema="ad")

    op.create_table(
        "group_memberships",
        sa.Column("id", sa.Text(), primary_key=True),
        sa.Column("source_key", sa.Text(), nullable=False),
        sa.Column("snapshot_mode", sa.Text(), nullable=False),
        sa.Column("snapshot_ts", sa.DateTime(timezone=True), nullable=False),
        sa.Column("group_guid", sa.Text(), nullable=False),
        sa.Column("member_guid", sa.Text(), nullable=False),
        sa.Column("member_type", sa.Text(), nullable=False),
        sa.Column("sync_run_id", sa.Text(), nullable=True),
        sa.Column("ingested_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(
            ["sync_run_id"],
            ["ad.sync_runs.id"],
            name="fk_ad_group_memberships_sync_run_id",
            ondelete="SET NULL",
        ),
        schema="ad",
    )
    op.create_index(
        "ix_ad_group_memberships_group_guid",
        "group_memberships",
        ["group_guid"],
        schema="ad",
    )
    op.create_index(
        "ix_ad_group_memberships_member_guid",
        "group_memberships",
        ["member_guid"],
        schema="ad",
    )
    op.create_index(
        "ix_ad_group_memberships_sync_run_id",
        "group_memberships",
        ["sync_run_id"],
        schema="ad",
    )

    op.create_table(
        "computers",
        sa.Column("id", sa.Text(), primary_key=True),
        sa.Column("source_key", sa.Text(), nullable=False),
        sa.Column("snapshot_mode", sa.Text(), nullable=False),
        sa.Column("snapshot_ts", sa.DateTime(timezone=True), nullable=False),
        sa.Column("object_guid", sa.Text(), nullable=False),
        sa.Column("distinguished_name", sa.Text(), nullable=True),
        sa.Column("sam_account_name", sa.Text(), nullable=True),
        sa.Column("dns_host_name", sa.Text(), nullable=True),
        sa.Column("operating_system", sa.Text(), nullable=True),
        sa.Column("when_changed", sa.DateTime(timezone=True), nullable=True),
        sa.Column("sync_run_id", sa.Text(), nullable=True),
        sa.Column("ingested_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(
            ["sync_run_id"],
            ["ad.sync_runs.id"],
            name="fk_ad_computers_sync_run_id",
            ondelete="SET NULL",
        ),
        schema="ad",
    )
    op.create_index("ix_ad_computers_object_guid", "computers", ["object_guid"], schema="ad")
    op.create_index(
        "ix_ad_computers_sam_account_name",
        "computers",
        ["sam_account_name"],
        schema="ad",
    )
    op.create_index("ix_ad_computers_sync_run_id", "computers", ["sync_run_id"], schema="ad")
    op.create_index("ix_ad_computers_when_changed", "computers", ["when_changed"], schema="ad")

    _sync_run_table("m365")
    op.create_table(
        "users",
        sa.Column("id", sa.Text(), primary_key=True),
        sa.Column("source_key", sa.Text(), nullable=False),
        sa.Column("snapshot_mode", sa.Text(), nullable=False),
        sa.Column("snapshot_ts", sa.DateTime(timezone=True), nullable=False),
        sa.Column("source_object_id", sa.Text(), nullable=True),
        sa.Column("user_principal_name", sa.Text(), nullable=True),
        sa.Column("display_name", sa.Text(), nullable=True),
        sa.Column("email", sa.Text(), nullable=True),
        sa.Column("enabled", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("sync_run_id", sa.Text(), nullable=True),
        sa.Column("ingested_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(["sync_run_id"], ["m365.sync_runs.id"], name="fk_m365_users_sync_run_id", ondelete="SET NULL"),
        schema="m365",
    )
    op.create_index("ix_m365_users_source_object_id", "users", ["source_object_id"], schema="m365")
    op.create_index("ix_m365_users_sync_run_id", "users", ["sync_run_id"], schema="m365")

    op.create_table(
        "groups",
        sa.Column("id", sa.Text(), primary_key=True),
        sa.Column("source_key", sa.Text(), nullable=False),
        sa.Column("snapshot_mode", sa.Text(), nullable=False),
        sa.Column("snapshot_ts", sa.DateTime(timezone=True), nullable=False),
        sa.Column("source_object_id", sa.Text(), nullable=True),
        sa.Column("display_name", sa.Text(), nullable=True),
        sa.Column("mail_enabled", sa.Text(), nullable=True),
        sa.Column("security_enabled", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("sync_run_id", sa.Text(), nullable=True),
        sa.Column("ingested_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(["sync_run_id"], ["m365.sync_runs.id"], name="fk_m365_groups_sync_run_id", ondelete="SET NULL"),
        schema="m365",
    )
    op.create_index("ix_m365_groups_source_object_id", "groups", ["source_object_id"], schema="m365")
    op.create_index("ix_m365_groups_sync_run_id", "groups", ["sync_run_id"], schema="m365")

    op.create_table(
        "group_memberships",
        sa.Column("id", sa.Text(), primary_key=True),
        sa.Column("source_key", sa.Text(), nullable=False),
        sa.Column("snapshot_mode", sa.Text(), nullable=False),
        sa.Column("snapshot_ts", sa.DateTime(timezone=True), nullable=False),
        sa.Column("group_object_id", sa.Text(), nullable=True),
        sa.Column("member_object_id", sa.Text(), nullable=True),
        sa.Column("sync_run_id", sa.Text(), nullable=True),
        sa.Column("ingested_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(
            ["sync_run_id"],
            ["m365.sync_runs.id"],
            name="fk_m365_group_memberships_sync_run_id",
            ondelete="SET NULL",
        ),
        schema="m365",
    )
    op.create_index(
        "ix_m365_group_memberships_group_object_id",
        "group_memberships",
        ["group_object_id"],
        schema="m365",
    )
    op.create_index(
        "ix_m365_group_memberships_member_object_id",
        "group_memberships",
        ["member_object_id"],
        schema="m365",
    )
    op.create_index("ix_m365_group_memberships_sync_run_id", "group_memberships", ["sync_run_id"], schema="m365")

    op.create_table(
        "teams",
        sa.Column("id", sa.Text(), primary_key=True),
        sa.Column("source_key", sa.Text(), nullable=False),
        sa.Column("snapshot_mode", sa.Text(), nullable=False),
        sa.Column("snapshot_ts", sa.DateTime(timezone=True), nullable=False),
        sa.Column("team_id", sa.Text(), nullable=False),
        sa.Column("display_name", sa.Text(), nullable=True),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("visibility", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("sync_run_id", sa.Text(), nullable=True),
        sa.Column("ingested_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(["sync_run_id"], ["m365.sync_runs.id"], name="fk_m365_teams_sync_run_id", ondelete="SET NULL"),
        schema="m365",
    )
    op.create_index("ix_m365_teams_team_id", "teams", ["team_id"], schema="m365")
    op.create_index("ix_m365_teams_sync_run_id", "teams", ["sync_run_id"], schema="m365")

    op.create_table(
        "channels",
        sa.Column("id", sa.Text(), primary_key=True),
        sa.Column("source_key", sa.Text(), nullable=False),
        sa.Column("snapshot_mode", sa.Text(), nullable=False),
        sa.Column("snapshot_ts", sa.DateTime(timezone=True), nullable=False),
        sa.Column("team_id", sa.Text(), nullable=False),
        sa.Column("channel_id", sa.Text(), nullable=False),
        sa.Column("display_name", sa.Text(), nullable=True),
        sa.Column("membership_type", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("sync_run_id", sa.Text(), nullable=True),
        sa.Column("ingested_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(["sync_run_id"], ["m365.sync_runs.id"], name="fk_m365_channels_sync_run_id", ondelete="SET NULL"),
        schema="m365",
    )
    op.create_index("ix_m365_channels_team_channel", "channels", ["team_id", "channel_id"], schema="m365")
    op.create_index("ix_m365_channels_sync_run_id", "channels", ["sync_run_id"], schema="m365")

    op.create_table(
        "team_memberships",
        sa.Column("id", sa.Text(), primary_key=True),
        sa.Column("source_key", sa.Text(), nullable=False),
        sa.Column("snapshot_mode", sa.Text(), nullable=False),
        sa.Column("snapshot_ts", sa.DateTime(timezone=True), nullable=False),
        sa.Column("team_id", sa.Text(), nullable=False),
        sa.Column("member_object_id", sa.Text(), nullable=False),
        sa.Column("member_ref_id", sa.Text(), nullable=True),
        sa.Column("roles", sa.Text(), nullable=True),
        sa.Column("sync_run_id", sa.Text(), nullable=True),
        sa.Column("ingested_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(
            ["sync_run_id"],
            ["m365.sync_runs.id"],
            name="fk_m365_team_memberships_sync_run_id",
            ondelete="SET NULL",
        ),
        schema="m365",
    )
    op.create_index("ix_m365_team_memberships_team_member", "team_memberships", ["team_id", "member_object_id"], schema="m365")
    op.create_index("ix_m365_team_memberships_sync_run_id", "team_memberships", ["sync_run_id"], schema="m365")

    op.create_table(
        "channel_memberships",
        sa.Column("id", sa.Text(), primary_key=True),
        sa.Column("source_key", sa.Text(), nullable=False),
        sa.Column("snapshot_mode", sa.Text(), nullable=False),
        sa.Column("snapshot_ts", sa.DateTime(timezone=True), nullable=False),
        sa.Column("team_id", sa.Text(), nullable=False),
        sa.Column("channel_id", sa.Text(), nullable=False),
        sa.Column("member_object_id", sa.Text(), nullable=False),
        sa.Column("member_ref_id", sa.Text(), nullable=True),
        sa.Column("roles", sa.Text(), nullable=True),
        sa.Column("sync_run_id", sa.Text(), nullable=True),
        sa.Column("ingested_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(
            ["sync_run_id"],
            ["m365.sync_runs.id"],
            name="fk_m365_channel_memberships_sync_run_id",
            ondelete="SET NULL",
        ),
        schema="m365",
    )
    op.create_index(
        "ix_m365_channel_memberships_channel_member",
        "channel_memberships",
        ["team_id", "channel_id", "member_object_id"],
        schema="m365",
    )
    op.create_index("ix_m365_channel_memberships_sync_run_id", "channel_memberships", ["sync_run_id"], schema="m365")


def downgrade() -> None:
    for table in (
        "channel_memberships",
        "team_memberships",
        "channels",
        "teams",
        "group_memberships",
        "groups",
        "users",
        "sync_runs",
    ):
        op.drop_table(table, schema="m365")

    for table in (
        "computers",
        "group_memberships",
        "groups",
        "users",
        "sync_state",
        "sync_runs",
    ):
        op.drop_table(table, schema="ad")

    op.execute(sa.text('DROP SCHEMA IF EXISTS "m365"'))
    op.execute(sa.text('DROP SCHEMA IF EXISTS "ad"'))
