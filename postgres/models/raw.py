from __future__ import annotations

import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

from models.common import metadata


metadata_obj = metadata()

source_system = sa.Table(
    "source_system",
    metadata_obj,
    sa.Column("id", sa.BigInteger(), sa.Identity(always=False), primary_key=True),
    sa.Column("code", sa.Text(), nullable=False),
    sa.Column("name", sa.Text(), nullable=False),
    sa.Column("category", sa.Text(), nullable=True),
    sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
    sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    sa.UniqueConstraint("code", name="uq_source_system_code"),
    schema="meta",
)

ingestion_run = sa.Table(
    "ingestion_run",
    metadata_obj,
    sa.Column("id", sa.BigInteger(), sa.Identity(always=False), primary_key=True),
    sa.Column("source_system_id", sa.BigInteger(), nullable=False),
    sa.Column("run_key", sa.Text(), nullable=False),
    sa.Column("status", sa.Text(), nullable=False),
    sa.Column("started_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    sa.Column("finished_at", sa.DateTime(timezone=True), nullable=True),
    sa.Column("record_count", sa.BigInteger(), nullable=True),
    sa.Column("error_message", sa.Text(), nullable=True),
    sa.ForeignKeyConstraint(
        ["source_system_id"],
        ["meta.source_system.id"],
        name="fk_ingestion_run_source_system",
    ),
    sa.UniqueConstraint("run_key", name="uq_ingestion_run_run_key"),
    schema="meta",
)

ad_object_record = sa.Table(
    "object_record",
    metadata_obj,
    sa.Column("id", sa.BigInteger(), sa.Identity(always=False), primary_key=True),
    sa.Column("source_system_id", sa.BigInteger(), nullable=False),
    sa.Column("ingestion_run_id", sa.BigInteger(), nullable=False),
    sa.Column("source_object_key", sa.Text(), nullable=False),
    sa.Column("object_class", sa.Text(), nullable=False),
    sa.Column("distinguished_name", sa.Text(), nullable=True),
    sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
    sa.Column("extracted_at", sa.DateTime(timezone=True), nullable=False),
    sa.Column("loaded_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    sa.ForeignKeyConstraint(
        ["source_system_id"],
        ["meta.source_system.id"],
        name="fk_ad_object_record_source_system",
    ),
    sa.ForeignKeyConstraint(
        ["ingestion_run_id"],
        ["meta.ingestion_run.id"],
        name="fk_ad_object_record_ingestion_run",
    ),
    sa.UniqueConstraint(
        "source_system_id",
        "source_object_key",
        "extracted_at",
        name="uq_ad_object_record_natural_load",
    ),
    sa.Index("ix_ad_object_record_payload_gin", "payload", postgresql_using="gin"),
    schema="ad",
)
