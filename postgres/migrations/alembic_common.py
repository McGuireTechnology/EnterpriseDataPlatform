from __future__ import annotations

import os
from logging.config import fileConfig

from alembic import context
from sqlalchemy import MetaData, engine_from_config, pool, text


def include_object(
    object_: object,
    name: str | None,
    type_: str,
    reflected: bool,
    compare_to: object | None,
) -> bool:
    if type_ == "table" and reflected and compare_to is None and name == "alembic_version":
        return False
    return True


def run_migrations(database_url_envvar: str, target_metadata: MetaData) -> None:
    config = context.config

    if config.config_file_name is not None:
        fileConfig(config.config_file_name)

    def database_url() -> str:
        return os.getenv(
            database_url_envvar,
            config.get_section_option(config.config_ini_section, "sqlalchemy.url"),
        )

    if context.is_offline_mode():
        context.configure(
            url=database_url(),
            target_metadata=target_metadata,
            literal_binds=True,
            dialect_opts={"paramstyle": "named"},
            include_schemas=True,
            version_table_schema="meta",
            include_object=include_object,
        )

        with context.begin_transaction():
            context.run_migrations()
        return

    section = config.get_section(config.config_ini_section, {})
    section["sqlalchemy.url"] = database_url()

    connectable = engine_from_config(
        section,
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        connection.execute(text("CREATE SCHEMA IF NOT EXISTS meta"))
        connection.commit()
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            include_schemas=True,
            version_table_schema="meta",
            include_object=include_object,
        )

        with context.begin_transaction():
            context.run_migrations()
