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
