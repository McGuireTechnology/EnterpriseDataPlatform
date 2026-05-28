# AGENTS

## Preferred Entry Points

- Use `make` targets from `Makefile` instead of ad hoc `docker compose` commands when an equivalent target exists.
- Use the root npm scripts for docs work: `npm run docs:dev`, `npm run docs:build`, and `npm run docs:preview`.
- For database schema changes, update the SQLAlchemy models in `postgres/models/` first, then create Alembic revisions against the matching database name.

## Common Commands

### Documentation

- `npm install`
- `npm run docs:dev`
- `npm run docs:build`
- `npm run docs:preview`

### Local PostgreSQL and PgAdmin

- `cp .env.example .env`
- `make postgres-up`
- `make postgres-down`
- `make postgres-reset`
- `make db-port-up`
- `make db-port-down`
- `make pgadmin-up`
- `make pgadmin-logs`
- `make pgadmin-down`

### Airflow

- `make airflow-up`
- `make airflow-init`
- `make airflow-logs`
- `make airflow-cli`
- `make airflow-down`

### Superset

- `make superset-up`
- `make superset-init`
- `make superset-logs`
- `make superset-down`

### Database Migrations

- `make db-upgrade`
- `make db-downgrade`
- `make db-current`
- `make db-history`
- `make db-check`
- `docker compose -f compose.yaml --profile tools run --rm db-tools alembic -c postgres/alembic.ini -n raw revision --autogenerate -m "describe raw change"`
- Use the same Alembic pattern for `ods`, `vault`, `mart`, and `app`.

### Active Directory Schema Inventory

- `.\scripts\Get-ActiveDirectorySchemaInventory.ps1`
- `.\scripts\Get-ActiveDirectorySchemaInventory.ps1 -OutputPath .\ad-schema -Server dc01.contoso.com -Json`
