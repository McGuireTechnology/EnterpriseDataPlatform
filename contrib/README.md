# Contrib

This folder contains contrib reference material used to shape EDP target features, especially CIS Controls and related security-control sources.

## Layout

- `sources/cis`: Center for Internet Security material, including CIS Controls and SecureSuite exports.
- `sources/cisa`: Cybersecurity and Infrastructure Security Agency material.
- `sources/ieee`: IEEE SA reference material.
- `sources/nist`: NIST and OSCAL control catalogs.
- `sources/policy-templates`: policy and procedure templates.
- `sources/purple-knight`: Purple Knight assessment resources.
- `INDEX.md`: generated inventory for the local contrib source tree.

The contrib tree is visible to Git. Only files over GitHub's normal 100 MB blob limit are listed in `.gitignore`; those files stay local unless the repository adopts Git LFS or another large-artifact store.

## Maintenance

Run `scripts/Update-ContribIndex.ps1` after adding or moving source material:

```powershell
.\scripts\Update-ContribIndex.ps1
```

Use `scripts/Sync-ContribDocuments.ps1` to gather approved local reference collections into `contrib/sources` when needed:

```powershell
.\scripts\Sync-ContribDocuments.ps1 -SourceRoot "C:\path\to\reference-resources" -Collections "CIS Controls"
```

When a source document creates a durable EDP requirement, capture that requirement in docs, models, migrations, dbt assets, or tests so the platform does not depend on tribal knowledge inside raw reference files.
