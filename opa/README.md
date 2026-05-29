# EDP OPA Policies

Open Policy Agent evaluates policy-as-code decisions for EDP.

Starter policy package:

- `opa/policies/edp.rego`

Example inputs:

- `opa/examples/publish-public-asbr.json`
- `opa/examples/blocked-third-party-export.json`

Common commands:

```sh
make opa-up
make opa-test
make opa-eval-asbr
make opa-eval-third-party-export
```

The starter policy is intentionally small. It demonstrates how CKAN publication, dataset exports, and third-party data-sharing decisions can be moved from prose-only rules into executable policy checks.
