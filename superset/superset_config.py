import os


SECRET_KEY = os.environ["SUPERSET_SECRET_KEY"]

SQLALCHEMY_DATABASE_URI = os.environ.get(
    "SUPERSET_DATABSE_URI",
    "postgresql+psycopg2://postgres:postgres@postgres:5432/superset",
)

WTF_CSRF_ENABLED = True
TALISMAN_ENABLED = False

FEATURE_FLAGS = {
    "ALERT_REPORTS": False,
}

SQLALCHEMY_ENGINE_OPTIONS = {
    "pool_pre_ping": True,
}
