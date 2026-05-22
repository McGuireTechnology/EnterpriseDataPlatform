# Local Superset

Use the local Superset container for early dashboard development, semantic layer experiments, and Data Mart validation. It is a developer convenience, not the production deployment pattern.

## Start Superset

```sh
cp .env.example .env
make superset-up
```

Superset starts at:

- `http://127.0.0.1:8088`

The default local administrator account is:

- Username: `admin`
- Password: `admin`

Change the `SUPERSET_ADMIN_*` values in `.env` before running this outside disposable local development.

## Metadata Database

Superset stores its application metadata in the existing local PostgreSQL `superset` database.

The local Compose service uses:

```sh
SUPERSET_DATABSE_URI=postgresql+psycopg2://superset:superset@pgbouncer:6432/superset
```

The local PostgreSQL init script creates the `superset` database with the `SUPERSET_DATABASE_USER` role as owner.

The `superset-init` service runs:

- `superset db upgrade`
- `superset fab create-admin`
- `superset init`
- EDP database connection provisioning

The `superset` service then runs the web application on port `8088`.

## Connect To EDP Databases

The bootstrap process provisions Superset connections for all EDP databases:

- EDP Raw
- EDP ODS
- EDP Vault
- EDP Mart
- EDP App

These connections use the `EDP_*_DATABASE_URL` values from `.env.example`.

Use Data Marts or governed ODS views for most dashboard users. Keep Raw, Vault,
and App database access limited to platform operators or clearly scoped
development use.

## Common Commands

```sh
make superset-up
make superset-init
make superset-logs
make superset-down
```

Use `make postgres-down` to stop the full local Compose stack.

## Configuration

Superset configuration lives in:

- `superset/superset_config.py`

The local secret key is provided by `SUPERSET_SECRET_KEY` in `.env`. The value in `.env.example` is intentionally not production-safe.

## Troubleshooting

If Superset cannot connect to its metadata database:

- Confirm `make postgres-up` succeeds.
- Confirm the `superset` database exists.
- Confirm `SUPERSET_DATABSE_URI` uses the Compose hostname `pgbouncer`.

If the admin user already exists, `superset-init` may print an admin creation warning and continue.

If the web service starts but dashboards cannot query marts:

- Confirm migrations have been applied with `make db-upgrade`.
- Confirm the Superset database connection uses `postgres` as the host inside Compose.
- Confirm the target mart tables or views exist in `edp_mart`.
