# Contrib

Contrib is the local reference-document area for source material that informs EDP target features but should not be committed to Git.

Use it for documents such as CIS Controls workbooks, framework mappings, control catalogs, policy templates, and other external references that help shape models, runbooks, dashboards, and governance features.

## Repository Policy

- Commit scripts, documentation, mappings, derived notes, and source citations.
- Do not commit downloaded workbooks, PDFs, organization-specific policy files, or licensed source material.
- Keep local source documents under root `contrib/`, which is ignored except for its README and ignore rules.
- When a source document creates a durable EDP requirement, capture the requirement in docs, models, migrations, dbt, or tests rather than relying on the raw source file.

## Gather Documents

Set `EDP_CONTRIB_SOURCE_ROOT` to a local folder that contains approved reference collections, then run:

```powershell
.\scripts\Sync-ContribDocuments.ps1
```

To copy a specific collection:

```powershell
.\scripts\Sync-ContribDocuments.ps1 -SourceRoot "C:\path\to\reference-resources" -Collections "CIS Controls"
```

To refresh a local collection from source:

```powershell
.\scripts\Sync-ContribDocuments.ps1 -SourceRoot "C:\path\to\reference-resources" -Collections "CIS Controls" -Clean
```

The script writes copied files into root `contrib/` and records a local `manifest.json`. Those gathered files remain local-only.

## CIS Controls

CIS Controls references are high-value inputs for:

- Governance and GRC target features
- Control and safeguard catalog design
- Evidence collection requirements
- Risk and finding models
- Superset dashboard requirements
- Mappings between controls, assets, identities, and source-system observations

Derived EDP artifacts should use concise module names such as `AD` and `M365` when referencing source-system coverage.
