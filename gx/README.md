# EDP Great Expectations

Great Expectations, also called GX Core, is the EDP data quality validation layer.

Use it for checks that need reusable expectation suites, validation results, and quality documentation around source freshness, row counts, nullability, accepted values, relationships, and cross-layer reconciliation.

Common commands:

```sh
make gx-version
make gx-cli
```

The local container receives database URLs for the EDP raw, ODS, vault, and mart databases. Start by validating governed ODS and mart outputs, then add raw source checks where connector freshness or payload shape needs explicit monitoring.
