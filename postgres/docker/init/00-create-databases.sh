#!/usr/bin/env bash
set -euo pipefail

create_database() {
  local database_name="$1"
  local database_owner="${2:-$POSTGRES_USER}"

  psql \
    --username "$POSTGRES_USER" \
    --dbname "$POSTGRES_DB" \
    --set "ON_ERROR_STOP=1" \
    --set "database_name=$database_name" \
    --set "database_owner=$database_owner" <<'SQL'
SELECT format('CREATE DATABASE %I OWNER %I', :'database_name', :'database_owner')
WHERE NOT EXISTS (
  SELECT 1
  FROM pg_database
  WHERE datname = :'database_name'
)
\gexec
SQL
}

create_role() {
  local role_name="$1"
  local role_password="$2"

  psql \
    --username "$POSTGRES_USER" \
    --dbname "$POSTGRES_DB" \
    --set "ON_ERROR_STOP=1" \
    --set "role_name=$role_name" \
    --set "role_password=$role_password" <<'SQL'
SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'role_name', :'role_password')
WHERE NOT EXISTS (
  SELECT 1
  FROM pg_roles
  WHERE rolname = :'role_name'
)
\gexec

SELECT format('ALTER ROLE %I WITH PASSWORD %L', :'role_name', :'role_password')
\gexec
SQL
}

AIRFLOW_DATABASE_USER="${AIRFLOW_DATABASE_USER:-airflow}"
AIRFLOW_DATABASE_PASSWORD="${AIRFLOW_DATABASE_PASSWORD:-airflow}"
SUPERSET_DATABASE_USER="${SUPERSET_DATABASE_USER:-superset}"
SUPERSET_DATABASE_PASSWORD="${SUPERSET_DATABASE_PASSWORD:-superset}"
OPENMETADATA_DATABASE_USER="${OPENMETADATA_DATABASE_USER:-openmetadata}"
OPENMETADATA_DATABASE_PASSWORD="${OPENMETADATA_DATABASE_PASSWORD:-openmetadata}"
OPENMETADATA_AIRFLOW_DATABASE_USER="${OPENMETADATA_AIRFLOW_DATABASE_USER:-openmetadata_airflow}"
OPENMETADATA_AIRFLOW_DATABASE_PASSWORD="${OPENMETADATA_AIRFLOW_DATABASE_PASSWORD:-openmetadata_airflow}"
CKAN_DATABASE_USER="${CKAN_DATABASE_USER:-ckan}"
CKAN_DATABASE_PASSWORD="${CKAN_DATABASE_PASSWORD:-ckan}"
CKAN_DATASTORE_READONLY_USER="${CKAN_DATASTORE_READONLY_USER:-ckan_datastore_readonly}"
CKAN_DATASTORE_READONLY_PASSWORD="${CKAN_DATASTORE_READONLY_PASSWORD:-ckan_datastore_readonly}"

create_role "$AIRFLOW_DATABASE_USER" "$AIRFLOW_DATABASE_PASSWORD"
create_role "$SUPERSET_DATABASE_USER" "$SUPERSET_DATABASE_PASSWORD"
create_role "$OPENMETADATA_DATABASE_USER" "$OPENMETADATA_DATABASE_PASSWORD"
create_role "$OPENMETADATA_AIRFLOW_DATABASE_USER" "$OPENMETADATA_AIRFLOW_DATABASE_PASSWORD"
create_role "$CKAN_DATABASE_USER" "$CKAN_DATABASE_PASSWORD"
create_role "$CKAN_DATASTORE_READONLY_USER" "$CKAN_DATASTORE_READONLY_PASSWORD"

create_database edp_raw
create_database edp_ods
create_database edp_vault
create_database edp_mart
create_database edp_app
create_database airflow "$AIRFLOW_DATABASE_USER"
create_database superset "$SUPERSET_DATABASE_USER"
create_database openmetadata "$OPENMETADATA_DATABASE_USER"
create_database openmetadata_airflow "$OPENMETADATA_AIRFLOW_DATABASE_USER"
create_database ckan "$CKAN_DATABASE_USER"
create_database ckan_datastore "$CKAN_DATABASE_USER"
