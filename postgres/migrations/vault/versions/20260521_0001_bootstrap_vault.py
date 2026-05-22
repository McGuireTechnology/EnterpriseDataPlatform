"""bootstrap data vault database

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
    op.execute(sa.text('CREATE SCHEMA IF NOT EXISTS "vault"'))

    op.create_table(
        "hub_record_source",
        sa.Column("record_source_hash", sa.LargeBinary(length=32), primary_key=True),
        sa.Column("record_source_code", sa.Text(), nullable=False),
        sa.Column("load_datetime", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("record_source_code", name="uq_hub_record_source_code"),
        schema="vault",
    )


def downgrade() -> None:
    op.drop_table("hub_record_source", schema="vault")
    op.execute(sa.text('DROP SCHEMA IF EXISTS "vault"'))
