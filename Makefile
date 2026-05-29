.PHONY: postgres-up postgres-down postgres-reset db-port-up db-port-down pgadmin-up pgadmin-down pgadmin-logs airflow-up airflow-init airflow-down airflow-logs airflow-cli superset-up superset-init superset-down superset-logs openmetadata-up openmetadata-migrate openmetadata-down openmetadata-logs ckan-up ckan-init ckan-down ckan-logs minio-up minio-init minio-down minio-logs minio-ls dbt-debug dbt-run dbt-test dbt-docs-generate gx-version gx-cli opa-up opa-down opa-logs opa-test opa-eval-asbr opa-eval-third-party-export openbao-up openbao-init openbao-down openbao-logs openbao-status openbao-list openbao-read-local pgbackrest-stanza pgbackrest-check pgbackrest-backup pgbackrest-info pgbackrest-restore db-upgrade db-downgrade db-current db-history db-check docs-install docs-dev docs-build docs-preview

COMPOSE = docker compose -f compose.yaml
ALEMBIC = alembic -c postgres/alembic.ini

ifneq (,$(wildcard .env))
include .env
export
endif

postgres-up:
	$(COMPOSE) up -d postgres pgbouncer pgadmin

postgres-down:
	$(COMPOSE) down

postgres-reset:
	$(COMPOSE) down -v
	$(COMPOSE) up -d postgres pgbouncer pgadmin

db-port-up:
	$(COMPOSE) --profile db-port up -d pgbouncer-public

db-port-down:
	$(COMPOSE) --profile db-port stop pgbouncer-public

pgadmin-up:
	$(COMPOSE) up -d postgres pgbouncer pgadmin

pgadmin-down:
	$(COMPOSE) stop pgadmin

pgadmin-logs:
	$(COMPOSE) logs -f pgadmin

airflow-up:
	$(COMPOSE) up -d postgres pgbouncer airflow-init airflow-apiserver airflow-scheduler airflow-dag-processor

airflow-init:
	$(COMPOSE) up airflow-init

airflow-down:
	$(COMPOSE) stop airflow-apiserver airflow-scheduler airflow-dag-processor

airflow-logs:
	$(COMPOSE) logs -f airflow-apiserver airflow-scheduler airflow-dag-processor

airflow-cli:
	$(COMPOSE) run --rm airflow-apiserver airflow version

superset-up:
	$(COMPOSE) up -d postgres pgbouncer superset-init superset

superset-init:
	$(COMPOSE) up superset-init

superset-down:
	$(COMPOSE) stop superset

superset-logs:
	$(COMPOSE) logs -f superset

openmetadata-up:
	$(COMPOSE) up -d postgres pgbouncer openmetadata-elasticsearch openmetadata-migrate openmetadata-server openmetadata-ingestion

openmetadata-migrate:
	$(COMPOSE) up openmetadata-migrate

openmetadata-down:
	$(COMPOSE) stop openmetadata-server openmetadata-ingestion openmetadata-elasticsearch

openmetadata-logs:
	$(COMPOSE) logs -f openmetadata-server openmetadata-ingestion openmetadata-elasticsearch

ckan-up:
	$(COMPOSE) up -d postgres pgbouncer ckan-solr ckan-redis ckan-datapusher ckan-init ckan

ckan-init:
	$(COMPOSE) up ckan-init

ckan-down:
	$(COMPOSE) stop ckan ckan-datapusher ckan-solr ckan-redis

ckan-logs:
	$(COMPOSE) logs -f ckan ckan-datapusher ckan-solr ckan-redis

minio-up:
	$(COMPOSE) up -d minio minio-init

minio-init:
	$(COMPOSE) up minio-init

minio-down:
	$(COMPOSE) stop minio

minio-logs:
	$(COMPOSE) logs -f minio

minio-ls:
	$(COMPOSE) --profile tools run --rm minio-client

dbt-debug:
	$(COMPOSE) --profile tools run --rm dbt dbt debug

dbt-run:
	$(COMPOSE) --profile tools run --rm dbt dbt run

dbt-test:
	$(COMPOSE) --profile tools run --rm dbt dbt test

dbt-docs-generate:
	$(COMPOSE) --profile tools run --rm dbt dbt docs generate

gx-version:
	$(COMPOSE) --profile tools run --rm gx great_expectations --version

gx-cli:
	$(COMPOSE) --profile tools run --rm gx great_expectations --help

opa-up:
	$(COMPOSE) up -d opa

opa-down:
	$(COMPOSE) stop opa

opa-logs:
	$(COMPOSE) logs -f opa

opa-test:
	$(COMPOSE) --profile tools run --rm opa-tools check /workspace/opa/policies

opa-eval-asbr:
	$(COMPOSE) --profile tools run --rm opa-tools eval --format pretty --data /workspace/opa/policies --input /workspace/opa/examples/publish-public-asbr.json "data.edp"

opa-eval-third-party-export:
	$(COMPOSE) --profile tools run --rm opa-tools eval --format pretty --data /workspace/opa/policies --input /workspace/opa/examples/blocked-third-party-export.json "data.edp"

openbao-up:
	$(COMPOSE) up -d openbao

openbao-init:
	$(COMPOSE) --profile tools run --rm --entrypoint sh openbao-tools /workspace/openbao/scripts/init-local.sh

openbao-down:
	$(COMPOSE) stop openbao

openbao-logs:
	$(COMPOSE) logs -f openbao

openbao-status:
	$(COMPOSE) --profile tools run --rm openbao-tools status

openbao-list:
	$(COMPOSE) --profile tools run --rm openbao-tools kv list edp/

openbao-read-local:
	$(COMPOSE) --profile tools run --rm openbao-tools kv get edp/local/postgres

pgbackrest-stanza:
	$(COMPOSE) exec -u postgres postgres pgbackrest --stanza=edp stanza-create

pgbackrest-check:
	$(COMPOSE) exec -u postgres postgres pgbackrest --stanza=edp check

pgbackrest-backup:
	$(COMPOSE) exec -u postgres postgres pgbackrest --stanza=edp --type=full backup

pgbackrest-info:
	$(COMPOSE) exec -u postgres postgres pgbackrest info

pgbackrest-restore:
	$(COMPOSE) stop pgbouncer pgadmin airflow-apiserver airflow-scheduler airflow-dag-processor superset openmetadata-server openmetadata-ingestion postgres
	$(COMPOSE) --profile tools run --rm pgbackrest-tools --stanza=edp --delta restore

db-upgrade:
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n raw upgrade head
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n ods upgrade head
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n vault upgrade head
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n mart upgrade head
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n app upgrade head

db-downgrade:
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n app downgrade base
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n mart downgrade base
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n vault downgrade base
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n ods downgrade base
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n raw downgrade base

db-current:
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n raw current
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n ods current
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n vault current
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n mart current
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n app current

db-history:
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n raw history
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n ods history
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n vault history
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n mart history
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n app history

db-check:
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n raw check
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n ods check
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n vault check
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n mart check
	$(COMPOSE) --profile tools run --rm db-tools $(ALEMBIC) -n app check

docs-install:
	npm --prefix docs install

docs-dev:
	npm --prefix docs run docs:dev

docs-build:
	npm --prefix docs run docs:build

docs-preview:
	npm --prefix docs run docs:preview
