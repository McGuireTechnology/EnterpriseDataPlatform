# Local OPA

Use Open Policy Agent, or OPA, to prototype policy-as-code decisions for EDP governance.

OPA does not replace application permissions by itself. It is a decision engine: services send structured input, OPA evaluates Rego policies, and the calling service enforces the allow or deny result.

## Start OPA

```sh
cp .env.example .env
make opa-up
```

OPA starts at:

- `http://127.0.0.1:8181`

The local policy directory is:

- `opa/policies`

## Common Commands

```sh
make opa-up
make opa-test
make opa-eval-asbr
make opa-eval-third-party-export
make opa-logs
make opa-down
```

## Starter Policy

The starter policy lives in:

- `opa/policies/edp.rego`

It demonstrates decisions for:

- Publishing approved public datasets to CKAN
- Blocking student-level records from CKAN publication
- Requiring approval before publication
- Requiring a data-sharing agreement before third-party exports

Example inputs live in:

- `opa/examples/publish-public-asbr.json`
- `opa/examples/blocked-third-party-export.json`

## EDP Use Cases

Good first OPA use cases include:

- Can this dataset be published to CKAN?
- Can this export go to a third party?
- Does this requester have the right role for a restricted dataset?
- Is a data-sharing agreement required?
- Does a pipeline config include a prohibited destination?
- Does a public dataset still contain record-level or sensitive fields?

OPA policies should be backed by human-readable governance docs. Use OPA for executable decisions, not as the only place where a policy is explained.

## Integration Pattern

A service should send OPA a JSON input such as:

```json
{
  "input": {
    "action": "publish_dataset",
    "channel": "ckan",
    "dataset": {
      "classification": "public",
      "contains_student_level_records": false,
      "contains_secrets": false,
      "approved": true
    }
  }
}
```

OPA returns policy documents such as `data.edp.allow` and `data.edp.deny`. The application, DAG, or publication workflow must enforce the result.

## Troubleshooting

If OPA does not start:

- Confirm `opa/policies/edp.rego` passes `make opa-test`.
- Check `make opa-logs`.

If a decision seems wrong:

- Run one of the `opa-eval-*` examples.
- Add a smaller example input that isolates the condition.
- Keep deny messages explicit so reviewers can understand the decision.
