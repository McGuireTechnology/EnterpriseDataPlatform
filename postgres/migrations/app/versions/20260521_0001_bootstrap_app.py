"""bootstrap app database

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
    op.execute(sa.text('CREATE SCHEMA IF NOT EXISTS "app"'))

    op.create_table(
        "app_setting",
        sa.Column("setting_key", sa.Text(), primary_key=True),
        sa.Column("setting_value", sa.Text(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        schema="app",
    )


def downgrade() -> None:
    op.drop_table("app_setting", schema="app")
    op.execute(sa.text('DROP SCHEMA IF EXISTS "app"'))

