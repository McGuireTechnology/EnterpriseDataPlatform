# Local OpenBao

Use OpenBao as the local secrets-management service for EDP. It gives the stack a place to practice moving credentials out of application config and into a controlled secret store before adopting a production secret-management pattern.

This local service runs in OpenBao dev mode. It is useful for development and integration testing, but it is not production-safe because it starts unsealed with a known root token and in-memory storage.

## Start OpenBao

```sh
make openbao-up
```

OpenBao starts at:

- API and UI: `http://127.0.0.1:8200`
- Local root token: `OPENBAO_DEV_ROOT_TOKEN_ID` from `.env`

The default local token in `.env.example` is intentionally not secret.

## Seed Local Secrets

```sh
make openbao-init
```

The local seed script creates a KV v2 mount at `edp/` and writes sample local credentials for:

- PostgreSQL
- MinIO
- CKAN
- Airflow
- Superset

These values are examples only. They mirror the local defaults so developers can test secret retrieval without putting real credentials in Git.

## Inspect Secrets

```sh
make openbao-status
make openbao-list
make openbao-read-local
```

The tools container uses:

- `BAO_ADDR=http://openbao:8200`
- `BAO_TOKEN=$OPENBAO_DEV_ROOT_TOKEN_ID`

## Role in EDP

OpenBao should own secrets such as:

- Database passwords
- API tokens
- OAuth client secrets
- Webhook signing secrets
- Service-account credentials
- Encryption keys and certificates

Applications should receive short-lived credentials or runtime-injected secret values instead of reading committed `.env` secrets. `.env.example` should remain a non-secret template.

## Production Notes

Before production use:

- Run OpenBao outside dev mode.
- Use durable storage such as integrated Raft or a managed backend.
- Initialize and unseal with a documented break-glass process.
- Avoid long-lived root-token use after bootstrap.
- Enable audit devices.
- Configure identity-based auth such as OIDC, Kubernetes auth, AppRole, or cloud IAM auth.
- Write least-privilege policies per service.
- Define rotation ownership and recovery procedures.

For early production, SOPS plus age may be enough. OpenBao becomes more attractive when EDP needs dynamic credentials, centralized access control, audit trails, and automated rotation.

## Useful Commands

```sh
make openbao-up
make openbao-init
make openbao-status
make openbao-list
make openbao-read-local
make openbao-logs
make openbao-down
```

## Troubleshooting

If OpenBao does not start:

- Confirm host port `8200` is free.
- Check `make openbao-logs`.
- Confirm the image configured by `OPENBAO_IMAGE` can be pulled.

If reads fail:

- Confirm `make openbao-init` has run after the latest `make openbao-up`.
- Confirm `OPENBAO_DEV_ROOT_TOKEN_ID` matches the token used by `openbao-tools`.
- Remember that dev-mode data is in memory and is lost when the container is recreated.
