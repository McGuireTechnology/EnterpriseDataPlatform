.PHONY: postgres-up postgres-down postgres-reset db-upgrade db-downgrade db-current db-history db-check docs-install docs-dev docs-build docs-preview

COMPOSE = docker compose -f compose.yaml
ALEMBIC = alembic -c postgres/alembic.ini

ifneq (,$(wildcard .env))
include .env
export
endif

postgres-up:
	$(COMPOSE) up -d postgres

postgres-down:
	$(COMPOSE) down

postgres-reset:
	$(COMPOSE) down -v
	$(COMPOSE) up -d postgres

db-upgrade:
	$(ALEMBIC) -n raw upgrade head
	$(ALEMBIC) -n ods upgrade head
	$(ALEMBIC) -n vault upgrade head
	$(ALEMBIC) -n mart upgrade head
	$(ALEMBIC) -n app upgrade head

db-downgrade:
	$(ALEMBIC) -n app downgrade base
	$(ALEMBIC) -n mart downgrade base
	$(ALEMBIC) -n vault downgrade base
	$(ALEMBIC) -n ods downgrade base
	$(ALEMBIC) -n raw downgrade base

db-current:
	$(ALEMBIC) -n raw current
	$(ALEMBIC) -n ods current
	$(ALEMBIC) -n vault current
	$(ALEMBIC) -n mart current
	$(ALEMBIC) -n app current

db-history:
	$(ALEMBIC) -n raw history
	$(ALEMBIC) -n ods history
	$(ALEMBIC) -n vault history
	$(ALEMBIC) -n mart history
	$(ALEMBIC) -n app history

db-check:
	$(ALEMBIC) -n raw check
	$(ALEMBIC) -n ods check
	$(ALEMBIC) -n vault check
	$(ALEMBIC) -n mart check
	$(ALEMBIC) -n app check

docs-install:
	npm --prefix docs install

docs-dev:
	npm --prefix docs run docs:dev

docs-build:
	npm --prefix docs run docs:build

docs-preview:
	npm --prefix docs run docs:preview
