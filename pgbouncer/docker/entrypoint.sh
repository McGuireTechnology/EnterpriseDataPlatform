#!/bin/sh
set -eu

cat > /tmp/pgbouncer-userlist.txt <<EOF
"${POSTGRES_USER}" "${POSTGRES_PASSWORD}"
"${AIRFLOW_DATABASE_USER}" "${AIRFLOW_DATABASE_PASSWORD}"
"${SUPERSET_DATABASE_USER}" "${SUPERSET_DATABASE_PASSWORD}"
EOF

exec pgbouncer /etc/pgbouncer/pgbouncer.ini
