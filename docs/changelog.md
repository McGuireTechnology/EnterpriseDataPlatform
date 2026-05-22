# Changelog

The canonical project version is maintained in the root `VERSION` file.

## 26.5.2

Added:

- Root `requirements.txt` that references subproject Python requirement files
- Root npm `package.json` workspace and lockfile for project-level docs commands
- Local Apache Airflow Compose scaffold, DAG folder structure, healthcheck DAG, Make targets, and runbook
- Local Apache Superset Compose scaffold, configuration, bootstrap script, Make targets, and runbook
- PgBouncer and PgAdmin services for the local containerized database stack, with database port exposure disabled by default
- Pinned local Superset and PgAdmin container image versions for repeatable startup
- Google Workspace source-system documentation and connector catalog entries
- Infinite Campus, Canvas LMS, and Follett Destiny source-system documentation and connector catalog entries

Changed:

- Updated README setup examples to use root dependency entry points

## 26.5.1

Added:

- Local PostgreSQL Docker Compose setup for EDP development
- Separate EDP databases for raw, ODS, vault, mart, and custom app state
- Component metadata databases for Airflow and Superset
- Alembic migration environments for each EDP-owned database
- SQLAlchemy modeling layer for Alembic autogeneration
- Source-specific raw schema convention, starting with Active Directory
- Local PostgreSQL runbook and lifecycle examples showing raw to ODS to vault to mart flow
- Custom operational app example for endpoint exception review workflows

Changed:

- Moved VitePress package files under `docs`
- Moved PostgreSQL migration, model, and init files under `postgres`
- Added root Makefile commands for docs, Postgres, and migration workflows

## 26.5.0

Initial public documentation release for the Enterprise Data Platform.

Added:

- VitePress documentation site for GitHub Pages
- Custom domain support for `edp.mcguire.technology`
- Platform charter and implementation planning guidance
- Architecture documentation for runtime infrastructure, data lifecycle, persistence, orchestration, consumer tools, tool categories, tooling recommendations, and platform positioning
- Source Systems documentation area
- Initial source system pages for Active Directory and Microsoft 365
- Common source system roadmap
- Connector catalog and connector standard
- Version file as the canonical version source
- GitHub Actions workflow for GitHub Pages deployment
