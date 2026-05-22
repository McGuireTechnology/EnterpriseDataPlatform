# Getting Started

Use this page as the entry point for engineers, analysts, and platform operators joining the Enterprise Data Platform.

The platform combines connectors, orchestration, custom applications, and dashboard or visualization tools with a data lifecycle that moves information from raw collection through an Operational Data Store, Data Vault, and curated Data Marts.

Start with the [Platform Charter](/guide/platform-charter) for the generalized project purpose, scope, success measures, and delivery phases. Use [Implementation Planning](/guide/implementation-planning) to identify the decisions that should be made before construction begins.

## Prerequisites

- Access to the source repository.
- Access to the required cloud, data, and CI/CD environments.
- Local development tools installed for the services you own.

## Local Docs Workflow

Install dependencies:

```sh
make docs-install
```

Run the docs site locally:

```sh
make docs-dev
```

Build the static site:

```sh
make docs-build
```

Preview the production build:

```sh
make docs-preview
```

## First Content Pass

Start by replacing these starter pages with the platform details that answer:

- What systems make up the platform?
- Who owns each system?
- How does data move from source to consumer?
- Which tools are connectors, orchestration services, custom applications, or dashboards?
- Which data layer does each dataset belong to?
- How are changes tested, approved, and released?
- What should someone do when a pipeline or service fails?
