#!/usr/bin/env bash
set -euo pipefail

mkdir -p /var/lib/pgbackrest /var/log/pgbackrest /var/spool/pgbackrest
chown -R postgres:postgres /var/lib/pgbackrest /var/log/pgbackrest /var/spool/pgbackrest

exec docker-entrypoint.sh "$@"
