# Local pgBackRest

Use pgBackRest for local PostgreSQL physical backup and restore testing. This is a developer convenience and proof point for the production backup pattern, not a substitute for environment-specific backup design.

## Start PostgreSQL

```sh
cp .env.example .env
make postgres-up
```

The local PostgreSQL image includes pgBackRest and starts with WAL archiving enabled:

- `archive_mode=on`
- `archive_command=pgbackrest --stanza=edp archive-push %p`
- `wal_level=replica`

pgBackRest configuration lives in:

- `postgres/pgbackrest.conf`

The local repository uses the named Docker volume:

- `edp-pgbackrest`

## Initialize the Stanza

Run this once after the PostgreSQL service is healthy:

```sh
make pgbackrest-stanza
make pgbackrest-check
```

The configured stanza name is:

- `edp`

## Take a Backup

```sh
make pgbackrest-backup
make pgbackrest-info
```

The default Make target creates a full backup. WAL archives are pushed through PostgreSQL's archive command while the database is running.

## Restore

Restore is intentionally a stop-the-world local operation. The target stops services that may be using PostgreSQL, then runs pgBackRest restore against the shared Postgres data volume:

```sh
make pgbackrest-restore
```

After restore, start services again:

```sh
make postgres-up
```

Only use this against disposable local development data unless the backup and restore procedure has been tested for the target environment.

## Common Commands

```sh
make pgbackrest-stanza
make pgbackrest-check
make pgbackrest-backup
make pgbackrest-info
make pgbackrest-restore
```

## Troubleshooting

If stanza creation fails:

- Confirm `make postgres-up` succeeds.
- Confirm the PostgreSQL service is healthy.
- Confirm `postgres/pgbackrest.conf` is mounted at `/etc/pgbackrest/pgbackrest.conf`.

If backup fails because WAL was not archived:

- Run `make pgbackrest-check`.
- Check the PostgreSQL logs for archive command failures.
- Confirm the `edp-pgbackrest` volume is writable by the `postgres` user.

If restore fails:

- Confirm PostgreSQL is stopped.
- Confirm `make pgbackrest-info` shows at least one complete backup.
- Use `make postgres-reset` only when you intentionally want to discard all local state and rebuild from scratch.
