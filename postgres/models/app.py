from __future__ import annotations

import sqlalchemy as sa

from models.common import metadata


metadata_obj = metadata()

app_setting = sa.Table(
    "app_setting",
    metadata_obj,
    sa.Column("setting_key", sa.Text(), primary_key=True),
    sa.Column("setting_value", sa.Text(), nullable=False),
    sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    schema="app",
)
