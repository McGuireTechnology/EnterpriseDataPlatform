"""bootstrap ods database

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
    op.execute(sa.text('CREATE SCHEMA IF NOT EXISTS "ods"'))

    op.create_table(
        "entity_index",
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


def downgrade() -> None:
    op.drop_table("entity_index", schema="ods")
    op.execute(sa.text('DROP SCHEMA IF EXISTS "ods"'))

