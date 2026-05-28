# GRC

EDP should support Governance, Risk, and Compliance by making controls, policy text, evidence, findings, assessments, and remediation work queryable together.

This is not intended to make EDP the primary policy authoring or approval system. Policy documents can still live in SharePoint, a document management system, or another GRC tool. EDP keeps enough text, structure, references, and version metadata to explain posture changes and support audit-ready traceability.

## OSCAL-Based Control Assessment

Open Security Controls Assessment Language (OSCAL) gives EDP a structured way to represent control catalogs, baselines, system implementations, assessment outputs, and POA&M work.

NIST describes OSCAL as layered models:

- Control layer: catalog and profile models for controls and tailored baselines.
- Implementation layer: SSP and component definition models for describing how a system or component satisfies controls.
- Assessment layer: assessment plan, assessment results, and POA&M models for planning assessment work, recording findings, and tracking remediation.

EDP should use OSCAL as a GRC interchange and correlation format. The platform can ingest OSCAL catalogs and profiles from contrib sources, normalize them into GRC tables, and connect them to source-system evidence such as AD state, M365 settings, endpoint inventory, tickets, vulnerability records, policy fragments, and manual attestations.

## Policy Revision Impact

Policy content is still useful inside EDP, but the goal is traceability rather than document management.

EDP should be able to answer:

- Which policy revision supports a control, safeguard, objective, or assessment requirement?
- Which section or clause of that revision is the cited support?
- Did a newer policy revision improve posture for a specific objective?
- Which findings, evidence gaps, or POA&M items were reduced after the policy revision became effective?
- Which controls still lack explicit policy support?

Example:

> Access Control Policy v2.1 added a stronger MFA requirement in section 4.2. After that revision became effective, M365 MFA evidence coverage improved and CIS Safeguard 6.3 moved from partially supported to supported.

## Policy Storage Shape

Store policy content as text and sanitized HTML, not as binary documents. The source document can be imported temporarily, but the durable EDP record should be readable, diffable, searchable, and referenceable.

Useful policy entities:

- `policy`: stable identity, such as `Access Control Policy`.
- `policy_revision`: version, source URL, source system, effective date, extracted text, HTML, and hashes.
- `policy_fragment`: addressable sections, paragraphs, clauses, list items, or table rows inside a revision.
- `policy_control_mapping`: links fragments to OSCAL controls, CIS Safeguards, objectives, or internal control requirements.
- `policy_posture_impact`: links a policy revision or fragment to measured posture changes.

Policy fragments should have stable citation keys such as:

```text
POL-ACCESS-CONTROL@2.1#section-4.2
POL-ACCESS-CONTROL@2.1#mfa-requirement
```

These keys let reports cite the specific policy text that supports a control instead of referencing an entire document.

## Candidate Data Products

- Control catalog explorer.
- Policy-to-control coverage matrix.
- Evidence freshness dashboard.
- Control posture snapshot by system and objective.
- Policy revision impact timeline.
- POA&M aging and remediation status dashboard.
- Export-ready OSCAL JSON for selected models.

## MVP

1. Ingest OSCAL catalog and profile JSON from `contrib/sources/nist` and CIS OSCAL files.
2. Ingest Markdown policy templates from `docs/grc/policy-templates`.
3. Parse policy headings and sections into policy fragments.
4. Map policy fragments to controls, safeguards, and objectives.
5. Attach source-system evidence to controls and objectives.
6. Track posture snapshots before and after policy revisions.
7. Publish a Superset dashboard for policy coverage and evidence freshness.

## References

- [NIST OSCAL](https://pages.nist.gov/OSCAL/)
- [OSCAL Layers and Models](https://pages.nist.gov/OSCAL/learn/concepts/layer/)
- [OSCAL Assessment Layer](https://pages.nist.gov/OSCAL/learn/concepts/layer/assessment/)
- [OSCAL SSP Model](https://pages.nist.gov/OSCAL/learn/concepts/layer/implementation/ssp/)

