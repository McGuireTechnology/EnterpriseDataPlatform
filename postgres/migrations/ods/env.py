from migrations.alembic_common import run_migrations
from models.ods import metadata_obj


run_migrations("EDP_ODS_DATABASE_URL", metadata_obj)
