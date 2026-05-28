---
title: "Router and Switch Security Policy"
template_source: contrib/sources/policy-templates/Router-and-Switch-Security-Policy.docx
status: draft-template
owner: TBD
review_cadence: annual
control_mappings: []
---

# Router and Switch Security Policy

Free Use Disclaimer: This policy was created by or for the SANS Institute for the Internet community. All or parts of this policy can be freely used for your organization. There is no prior approval required. If you would like to contribute a new policy or updated version of this policy, please send email to policy-resources@sans.org.

Last Update Status: Updated June 2014

## Overview

See Purpose.

## Purpose

This document describes a required minimal security configuration for all routers and switches connecting to a production network or used in a production capacity at or on behalf of [Company Name].

## Scope

All employees, contractors, consultants, temporary and other workers at [Company Name] and its subsidiaries must adhere to this policy. All routers and switches connected to [Company Name] production networks are affected.

## Policy

Every router must meet the following configuration standards:

No local user accounts are configured on the router. Routers and switches must use TACACS+ for all user authentication.

The enable password on the router or switch must be kept in a secure encrypted form. The router or switch must have the enable password set to the current production router/switch password from the device’s support organization.

The following services or features must be disabled:

IP directed broadcasts

Incoming packets at the router/switch sourced with invalid addresses such as RFC1918 addresses

TCP small services

UDP small services

All source routing and switching

All web services running on router

[Company Name] discovery protocol on Internet connected interfaces

Telnet, FTP, and HTTP services

Auto-configuration

The following services should be disabled unless a business justification is provided:

[Company Name] discovery protocol and other discovery protocols

Dynamic trunking

Scripting environments, such as the TCL shell

The following services must be configured:

Password-encryption

NTP configured to a corporate standard source

All routing updates shall be done using secure routing updates.

Use corporate standardized SNMP community strings. Default strings, such as public or private must be removed. SNMP must be configured to use the most secure version of the protocol allowed for by the combination of the device and management systems.

Access control lists must be used to limit the source and type of traffic that can terminate on the device itself.

Access control lists for transiting the device are to be added as business needs arise.

The router must be included in the corporate enterprise management system with a designated point of contact.

Each router must have the following statement presented for all forms of login whether remote or local:

"UNAUTHORIZED ACCESS TO THIS NETWORK DEVICE IS PROHIBITED. You must have explicit permission to access or configure this device. All activities performed on this device may be logged, and violations of this policy may result in disciplinary action, and may be reported to law enforcement. There is no right to privacy on this device. Use of this system shall constitute consent to monitoring."

Telnet may never be used across any network to manage a router, unless there is a secure tunnel protecting the entire communication path. SSH version 2 is the preferred management protocol.

Dynamic routing protocols must use authentication in routing updates sent to neighbors. Password hashing for the authentication string must be enabled when supported.

The corporate router configuration standard will define the category of sensitive routing and switching devices, and require additional services or configuration on sensitive devices including:

IP access list accounting

Device logging

Incoming packets at the router sourced with invalid addresses, such as RFC1918 addresses, or those that could be used to spoof network traffic shall be dropped

Router console and modem access must be restricted by additional security controls

## Policy Compliance

- Compliance Measurement

- The Infosec team will verify compliance to this policy through various methods, including but not limited to, periodic walk-thrus, video monitoring, business tool reports, internal and external audits, and feedback to the policy owner.

## Exceptions

- Any exception to the policy must be approved by the Infosec team in advance.

## Non-Compliance

- An employee found to have violated this policy may be subject to disciplinary action, up to and including termination of employment.

## Related Standards, Policies and Processes

None.

## Definitions and Terms

None.

## Revision History

| Date of Change | Responsible | Summary of Change |
| --- | --- | --- |
| June 2014 | SANS Policy Team | Updated and converted to new format. |
|   |   |   |
