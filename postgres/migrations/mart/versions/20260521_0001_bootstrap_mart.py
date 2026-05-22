"""bootstrap data mart database

Revision ID: 20260521_0001
Revises:
Create Date: 2026-05-21 00:00:00.000000+00:00
"""

from __future__ import annotations

from alembic import op
import sqlalchemy as sa


revision = "20260521_0001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute(sa.text('CREATE SCHEMA IF NOT EXISTS "mart"'))

    op.create_table(
        "refresh_log",
        sa.Column("id", sa.BigInteger(), sa.Identity(always=False), primary_key=True),
        sa.Column("object_schema", sa.Text(), nullable=False),
        sa.Column("object_name", sa.Text(), nullable=False),
        sa.Column("refresh_status", sa.Text(), nullable=False),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("finished_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("row_count", sa.BigInteger(), nullable=True),
        schema="meta",
    )

    op.create_table(
        "platform_health_daily",
        sa.Column("health_date", sa.Date(), primary_key=True),
        sa.Column("source_system_count", sa.Integer(), nullable=False, server_default=sa.text("0")),
        sa.Column("successful_run_count", sa.Integer(), nullable=False, server_default=sa.text("0")),
        sa.Column("failed_run_count", sa.Integer(), nullable=False, server_default=sa.text("0")),
        sa.Column("loaded_record_count", sa.BigInteger(), nullable=False, server_default=sa.text("0")),
        schema="mart",
    )


def downgrade() -> None:
    op.drop_table("platform_health_daily", schema="mart")
    op.drop_table("refresh_log", schema="meta")
    op.execute(sa.text('DROP SCHEMA IF EXISTS "mart"'))
