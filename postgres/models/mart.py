from __future__ import annotations

import sqlalchemy as sa

from models.common import metadata


metadata_obj = metadata()

refresh_log = sa.Table(
    "refresh_log",
    metadata_obj,
    sa.Column("id", sa.BigInteger(), sa.Identity(always=False), primary_key=True),
    sa.Column("object_schema", sa.Text(), nullable=False),
    sa.Column("object_name", sa.Text(), nullable=False),
    sa.Column("refresh_status", sa.Text(), nullable=False),
    sa.Column("started_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    sa.Column("finished_at", sa.DateTime(timezone=True), nullable=True),
    sa.Column("row_count", sa.BigInteger(), nullable=True),
    schema="meta",
)

platform_health_daily = sa.Table(
    "platform_health_daily",
    metadata_obj,
    sa.Column("health_date", sa.Date(), primary_key=True),
    sa.Column("source_system_count", sa.Integer(), nullable=False, server_default=sa.text("0")),
    sa.Column("successful_run_count", sa.Integer(), nullable=False, server_default=sa.text("0")),
    sa.Column("failed_run_count", sa.Integer(), nullable=False, server_default=sa.text("0")),
    sa.Column("loaded_record_count", sa.BigInteger(), nullable=False, server_default=sa.text("0")),
    schema="mart",
)
