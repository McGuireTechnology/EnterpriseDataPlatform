# Source Systems

The Source Systems area documents the systems EDP can collect from, the connector options available for each system, and the status of any prebuilt connector packages.

This section should help answer:

- What systems are candidates for integration?
- Who owns each source system?
- What data can be collected?
- What access, credentials, scopes, or service accounts are required?
- Which connector options are available?
- Is there a prebuilt connector or model package?
- What raw, ODS, Data Vault, and Data Mart outputs does the integration support?
- What operational risks, limits, or approval requirements apply?

## Pages

- [Active Directory](/source-systems/active-directory): first documented source system for identities, groups, computers, organizational units, and memberships.
- [Microsoft 365](/source-systems/microsoft-365): cloud productivity, collaboration, licensing, usage, and service metadata source.
- [Common Systems](/source-systems/common-systems): additional source-system categories and prioritization guidance.
- [Inventory](/source-systems/inventory): source system inventory and documentation template.
- [Connector Catalog](/source-systems/connector-catalog): catalog of connector options, prebuilt packages, and implementation status.
- [Connector Standard](/source-systems/connector-standard): expectations for building repeatable, supportable connectors.

## Documentation Principles

Every source system should have a clear owner, access model, integration pattern, sensitivity classification, expected refresh cadence, and support path.

Every connector should separate code, configuration, and secrets. A prebuilt connector should be deployable into a target environment by supplying credentials, endpoints, and environment-specific configuration rather than rewriting connector logic.
