from migrations.alembic_common import run_migrations
from models.raw import metadata_obj


run_migrations("EDP_RAW_DATABASE_URL", metadata_obj)
