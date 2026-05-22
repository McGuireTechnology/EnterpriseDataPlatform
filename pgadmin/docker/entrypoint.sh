#!/bin/sh
set -eu

cat > /tmp/pgpass <<EOF
pgbouncer:6432:*:${POSTGRES_USER}:${POSTGRES_PASSWORD}
pgbouncer:6432:airflow:${AIRFLOW_DATABASE_USER}:${AIRFLOW_DATABASE_PASSWORD}
pgbouncer:6432:superset:${SUPERSET_DATABASE_USER}:${SUPERSET_DATABASE_PASSWORD}
EOF

chmod 600 /tmp/pgpass

cat > /tmp/pgadmin-servers.json <<EOF
{
  "Servers": {
    "1": {
      "Name": "EDP Raw",
      "Group": "EDP Databases",
      "Host": "pgbouncer",
      "Port": 6432,
      "MaintenanceDB": "edp_raw",
      "Username": "${POSTGRES_USER}",
      "ConnectionParameters": {
        "sslmode": "prefer",
        "passfile": "/tmp/pgpass"
      }
    },
    "2": {
      "Name": "EDP ODS",
      "Group": "EDP Databases",
      "Host": "pgbouncer",
      "Port": 6432,
      "MaintenanceDB": "edp_ods",
      "Username": "${POSTGRES_USER}",
      "ConnectionParameters": {
        "sslmode": "prefer",
        "passfile": "/tmp/pgpass"
      }
    },
    "3": {
      "Name": "EDP Vault",
      "Group": "EDP Databases",
      "Host": "pgbouncer",
      "Port": 6432,
      "MaintenanceDB": "edp_vault",
      "Username": "${POSTGRES_USER}",
      "ConnectionParameters": {
        "sslmode": "prefer",
        "passfile": "/tmp/pgpass"
      }
    },
    "4": {
      "Name": "EDP Mart",
      "Group": "EDP Databases",
      "Host": "pgbouncer",
      "Port": 6432,
      "MaintenanceDB": "edp_mart",
      "Username": "${POSTGRES_USER}",
      "ConnectionParameters": {
        "sslmode": "prefer",
        "passfile": "/tmp/pgpass"
      }
    },
    "5": {
      "Name": "EDP App",
      "Group": "EDP Databases",
      "Host": "pgbouncer",
      "Port": 6432,
      "MaintenanceDB": "edp_app",
      "Username": "${POSTGRES_USER}",
      "ConnectionParameters": {
        "sslmode": "prefer",
        "passfile": "/tmp/pgpass"
      }
    },
    "6": {
      "Name": "Airflow Metadata",
      "Group": "Component Metadata",
      "Host": "pgbouncer",
      "Port": 6432,
      "MaintenanceDB": "airflow",
      "Username": "${AIRFLOW_DATABASE_USER}",
      "ConnectionParameters": {
        "sslmode": "prefer",
        "passfile": "/tmp/pgpass"
      }
    },
    "7": {
      "Name": "Superset Metadata",
      "Group": "Component Metadata",
      "Host": "pgbouncer",
      "Port": 6432,
      "MaintenanceDB": "superset",
      "Username": "${SUPERSET_DATABASE_USER}",
      "ConnectionParameters": {
        "sslmode": "prefer",
        "passfile": "/tmp/pgpass"
      }
    }
  }
}
EOF

exec /entrypoint.sh
