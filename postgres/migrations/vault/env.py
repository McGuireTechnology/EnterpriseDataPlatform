from migrations.alembic_common import run_migrations
from models.vault import metadata_obj


run_migrations("EDP_VAULT_DATABASE_URL", metadata_obj)
