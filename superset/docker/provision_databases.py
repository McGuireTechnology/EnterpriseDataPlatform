from __future__ import annotations

import os

from superset import app, db
from superset.models.core import Database


DATABASES = {
    "EDP Raw": "EDP_RAW_DATABASE_URL",
    "EDP ODS": "EDP_ODS_DATABASE_URL",
    "EDP Vault": "EDP_VAULT_DATABASE_URL",
    "EDP Mart": "EDP_MART_DATABASE_URL",
    "EDP App": "EDP_APP_DATABASE_URL",
}


def provision_database(name: str, env_var: str) -> None:
    sqlalchemy_uri = os.environ.get(env_var)

    if not sqlalchemy_uri:
        print(f"Skipping {name}: {env_var} is not set.")
        return

    database = db.session.query(Database).filter_by(database_name=name).one_or_none()

    if database is None:
        database = Database(database_name=name)
        db.session.add(database)

    database.sqlalchemy_uri = sqlalchemy_uri
    database.allow_run_async = False
    database.allow_ctas = False
    database.allow_cvas = False
    database.allow_dml = False
    database.expose_in_sqllab = True

    print(f"Provisioned Superset database connection: {name}")


with app.app_context():
    for database_name, environment_variable in DATABASES.items():
        provision_database(database_name, environment_variable)

    db.session.commit()
