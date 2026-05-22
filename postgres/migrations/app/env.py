from migrations.alembic_common import run_migrations
from models.app import metadata_obj


run_migrations("EDP_APP_DATABASE_URL", metadata_obj)
