# Contrib

Contrib is the reference area for source material that informs EDP target features, especially CIS Controls, NIST/OSCAL catalogs, Purple Knight assessment content, and policy templates.

Use it for documents such as CIS Controls workbooks, framework mappings, control catalogs, policy templates, and other external references that help shape models, runbooks, dashboards, and governance features.

## Folder Layout

- `contrib/sources/cis`: Center for Internet Security material.
- `contrib/sources/cisa`: Cybersecurity and Infrastructure Security Agency material.
- `contrib/sources/ieee`: IEEE SA material.
- `contrib/sources/nist`: NIST and OSCAL control catalogs.
- `contrib/sources/policy-templates`: policy and procedure templates.
- `contrib/sources/purple-knight`: Purple Knight assessment resources.
- `contrib/INDEX.md`: generated source inventory.

The contrib folder is no longer broadly ignored. Only restored source packages larger than GitHub's normal 100 MB blob limit are excluded by `contrib/.gitignore`.

## Index Documents

Refresh the generated source index after adding, restoring, or moving contrib files:

```powershell
.\scripts\Update-ContribIndex.ps1
```

The index summarizes provider folders, file counts, total size, primary extensions, and the largest files so the restored source tree is searchable without manually walking every folder.

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

The script writes copied files into `contrib/sources` and records a `manifest.json` in that destination.

## CIS Controls

CIS Controls references are high-value inputs for:

- Governance and GRC target features
- Control and safeguard catalog design
- Evidence collection requirements
- Risk and finding models
- Superset dashboard requirements
- Mappings between controls, assets, identities, and source-system observations

Derived EDP artifacts should use concise module names such as `AD` and `M365` when referencing source-system coverage.
