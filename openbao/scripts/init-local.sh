#!/bin/sh
set -eu

bao secrets enable -path=edp -version=2 kv >/dev/null 2>&1 || true

bao kv put edp/local/postgres \
  username=postgres \
  password=postgres \
  host=pgbouncer \
  port=6432

bao kv put edp/local/minio \
  endpoint=http://minio:9000 \
  access_key=minioadmin \
  secret_key=minioadmin

bao kv put edp/local/ckan \
  site_url=http://ckan:5000 \
  sysadmin_user=ckan_admin \
  sysadmin_password=admin

bao kv put edp/local/airflow \
  url=http://airflow-apiserver:8080 \
  username=airflow \
  password=airflow

bao kv put edp/local/superset \
  url=http://superset:8088 \
  username=admin \
  password=admin

bao kv list edp/
