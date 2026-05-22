from migrations.alembic_common import run_migrations
from models.mart import metadata_obj


run_migrations("EDP_MART_DATABASE_URL", metadata_obj)
