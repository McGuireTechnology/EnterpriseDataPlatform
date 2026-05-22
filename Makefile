.PHONY: postgres-up postgres-down postgres-reset db-port-up db-port-down pgadmin-up pgadmin-down pgadmin-logs airflow-up airflow-init airflow-down airflow-logs airflow-cli superset-up superset-init superset-down superset-logs db-upgrade db-downgrade db-current db-history db-check docs-install docs-dev docs-build docs-preview

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
