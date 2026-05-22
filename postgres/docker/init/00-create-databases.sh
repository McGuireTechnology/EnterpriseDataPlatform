#!/usr/bin/env bash
set -euo pipefail

create_database() {
  local database_name="$1"

  psql \
    --username "$POSTGRES_USER" \
    --dbname "$POSTGRES_DB" \
    --set "ON_ERROR_STOP=1" \
    --set "database_name=$database_name" \
    --set "database_owner=$POSTGRES_USER" <<'SQL'
SELECT format('CREATE DATABASE %I OWNER %I', :'database_name', :'database_owner')
WHERE NOT EXISTS (
  SELECT 1
  FROM pg_database
  WHERE datname = :'database_name'
)
\gexec
SQL
}

create_database edp_raw
create_database edp_ods
create_database edp_vault
create_database edp_mart
create_database edp_app
create_database airflow
create_database superset
