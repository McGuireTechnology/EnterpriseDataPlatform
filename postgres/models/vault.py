from __future__ import annotations

import sqlalchemy as sa

from models.common import metadata


metadata_obj = metadata()

hub_record_source = sa.Table(
    "hub_record_source",
    metadata_obj,
    sa.Column("record_source_hash", sa.LargeBinary(length=32), primary_key=True),
    sa.Column("record_source_code", sa.Text(), nullable=False),
    sa.Column("load_datetime", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    sa.UniqueConstraint("record_source_code", name="uq_hub_record_source_code"),
    schema="vault",
)
