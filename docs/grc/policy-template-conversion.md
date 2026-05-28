# Policy Template Conversion

Use this page as the working spot for converting source policy templates into Markdown.

The durable GRC representation should be text-first. Markdown is the preferred editable source for converted policy templates because it preserves headings, sections, lists, and citations without carrying binary document formatting into EDP.

## Source Locations

Policy template source material currently lives in:

- `contrib/sources/policy-templates`
- `contrib/sources/cis/Policy Templates`

Converted Markdown should live under:

- `docs/grc/policy-templates`

## Conversion Rules

- Preserve the original policy title.
- Preserve heading hierarchy using Markdown headings.
- Preserve section numbers when they exist.
- Keep boilerplate review notes in a clearly labeled front matter or metadata block.
- Replace organization-specific placeholders with bracketed tokens such as `[Organization Name]`.
- Avoid embedding binary images or screenshots.
- Use tables only when the table structure adds meaning.
- Add a source note that identifies the original template filename.

## Suggested Front Matter

```yaml
---
title: Access Control Policy
template_source: contrib/sources/policy-templates/Access-Control-Policy.docx
status: draft-template
owner: TBD
review_cadence: annual
control_mappings: []
---
```

## Fragment-Friendly Formatting

Policy sections should be easy to split into fragments.

Prefer this:

```markdown
## 4.2 MFA Requirements

Privileged users must use MFA when accessing administrative interfaces.
```

Avoid this:

```markdown
## Requirements

4.2 Privileged users must use MFA when accessing administrative interfaces.
```

The first form gives EDP a stable section heading and a clean citation target.

## Next Templates

Use this checklist to track conversion candidates.

- [ ] Access Control Policy
- [ ] Account Management Access Control Standard
- [ ] Identification and Authentication Policy
- [ ] Password Protection Policy
- [ ] Incident Response Policy
- [ ] Information Security Policy
- [ ] Risk Assessment Policy
- [ ] Vulnerability Scanning Standard
- [ ] Security Awareness and Training Policy

