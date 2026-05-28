---
title: "Identification and Authentication Policy"
template_source: contrib/sources/policy-templates/Identification-and-Authentication-Policy.docx
status: draft-template
owner: TBD
review_cadence: annual
control_mappings: []
---

# Identification and Authentication Policy

| Policy #: | Title: | Effective Date: |
| --- | --- | --- |
| x.xxx | Identification and Authentication Policy | MM/DD/YY |

PURPOSE _______________________________________________________________

To ensure that only properly identified and authenticated users and devices are granted access to Information Technology (IT) resources in compliance with IT security policies, standards, and procedures.

REFERENCE _______________________________________________________________

National Institute of Standards and Technology (NIST) Special Publication (SP) 800-53a – Identification and Authentication (IA), NIST SP 800-12, NIST SP 800-63, NIST SP 800-73, NIST SP 800-76, NIST SP 800-78, NIST SP 800-100, NIST SP 800-116;

Homeland Security Presidential Directive (HSPD) 12 Policy for a Common Identification Standard for Federal Employees and Contractors; Federal Information Processing Standards (FIPS): FIPS 201, FIPS 140

POLICY _______________________________________________________________

This policy is applicable to all departments and users of IT resources and assets.

IDENTIFICATION AND AUTHENTICATION

IT Department shall:

Ensure that information systems uniquely identify and authenticate users or processes acting on behalf of [entity] users.

Ensure that information systems implement multifactor authentication for network access to privileged accounts.

Ensure that information systems implement multifactor authentication for network access to non-privileged accounts.

Ensure that information systems implement multifactor authentication for local access to privileged accounts.

Ensure that information systems implement replay-resistant authentication mechanisms for network access to privileged accounts.

Ensure that information systems implement multifactor authentication for remote access to privileged and non-privileged accounts such that one of the factors is provided by a device separate from the system gaining access and the device utilizes a cryptographic strength mechanisms that protects the primary authentication token (secret key, private key or one-time password) against compromise by protocol threats including: eavesdropper, replay, online guessing, verifier impersonation and man-in-the-middle attacks.

Ensure that information systems accept and electronically verify Personal Identity Verification (PIV) credentials.

DEVICE IDENTIFICATION AND AUTHENTICATION

IT Department shall:

Ensure that information systems uniquely identify and authenticate all devices before establishing a network connection.

IDENTIFIER MANAGEMENT

IT Department, through department information systems owners, shall:

Ensure that the [entity] manages information system identifiers by receiving authorization from [entity defined personnel or roles] to assign an individual, group, role, or device identifier.

Select an identifier that identifies an individual, group, role, or device.

Assign the identifier to the intended individual, group, role, or device.

Prevent reuse of identifiers for 90 days.

Disable the identifier after 30 days of inactivity.

AUTHENTICATOR MANAGEMENT

IT Department shall:

Manage information system authenticators by verifying, as part of the initial authenticator distribution, the identity of the individual, group, role, or device receiving the authenticator.

Establish initial authenticator content for authenticators defined by the organization.

Ensure that authenticators have sufficient strength of mechanism for their intended use.

Establish and implement administrative procedures for initial authenticator distribution, for lost/compromised or damaged authenticators, and for revoking authenticators.

Change default content of authenticators prior to information system installation.

Establish minimum and maximum lifetime restrictions and reuse conditions for authenticators.

Change/refresh authenticators every 90 days.

Protect authenticator content from unauthorized disclosure and modification.

Require individuals and devices to implement specific security safeguards to protect authenticators.

Change authenticators for group/role accounts when membership to those account changes.

Ensure that information systems, for password-based authentication enforce minimum password complexity that must not contain the user's entire Account Name value or entire Full Name value.

Ensure passwords must contain characters from three of the following five categories:

Uppercase characters of European languages (A through Z, with diacritic marks, Greek and Cyrillic characters);

Lowercase characters of European languages (a through z, sharp-s, with diacritic marks, Greek and Cyrillic characters);

Base 10 digits (0 through 9);

Non-alphanumeric characters ~!@#$%^&*_-+=`|\(){}[]:;"'<>,.?/; and

Any Unicode character that is categorized as an alphabetic character, but is not uppercase or lowercase. This includes Unicode characters from Asian languages.

Require passwords to have a minimum length of 8 characters.

Enforce at least one changed character when new passwords are created.

Store and transmit only cryptographically-protected passwords.

Enforce password minimum and maximum lifetime restrictions of one day and 120 days respectively.

Prohibit password reuse for 12 generations.

Allow the use of a temporary password for system logons with an immediate change to a permanent password.

Ensure that information system, for PKI-based authentication, validates certifications by constructing and verifying a certification path to an accepted trust anchor including checking certificate status information.

Enforce authorized access to the corresponding private key.

Map the authenticated identity to the account of the individual or group.

Implement a local cache of revocation data to support path discovery and validation in case of inability to access revocation information via the network.

Require that the registration process to receive [entity defined types of and/or specific authenticators] be conducted in person or by a trusted third party before [entity defined registration authority] with authorization by [entity defined personnel or roles].

Ensure that the information system, for hardware token-based authentication, employs mechanisms that satisfy [entity defined token quality requirements].

AUTHENTICATOR FEEDBACK

IT Department shall:

Ensure that information systems obscure feedback of authentication information during the authentication process to protect the information from possible exploitation/use by unauthorized individuals.

CRYPTOGRAPHIC MODULE AUTHENTICATION

IT Department shall:

Ensure that information systems implement mechanisms for authentication to a cryptographic module that meet the requirements of applicable state and federal laws, directives, policies, regulations, standards, and guidance for such authentication.

IDENTIFICATION AND AUTHENTICATION

IT Department shall:

Ensure that information systems uniquely identify and authenticate non-entity users or processes acting on behalf of non-entity users.

Ensure that information systems accept and electronically verify Personal Identity Verification (PIV) credentials from other government agencies.

Ensure that information systems accept only Federal Identity, Credential, and Access Management (FICAM) Trust Framework Solutions initiative approved third-party credentials.

Ensure that the organization employs only FICAM-approved information system components in [entity defined information systems] to accept third-party credentials.

COMPLIANCE

_______________________________________________________________

Employees who violate this policy may be subject to appropriate disciplinary action up to and including discharge as well as both civil and criminal penalties. Non-employees, including, without limitation, contractors, may be subject to termination of contractual agreements, denial of access to IT resources, and other actions as well as both civil and criminal penalties.

POLICY EXCEPTIONS

_______________________________________________________________

Requests for exceptions to this policy shall be reviewed by the Chief Information Security Officer (CISO) and the Chief Information Officer (CIO). Departments requesting exceptions shall provide such requests to the CIO. The request should specifically state the scope of the exception along with justification for granting the exception, the potential impact or risk attendant upon granting the exception, risk mitigation measures to be undertaken by the IT Department, initiatives, actions and a time-frame for achieving the minimum compliance level with the policies set forth herein. The CIO shall review such requests; confer with the requesting department.

RESPONSIBLE DEPARTMENT _______________________________________________________________

Chief Information Office and Information System Owners

DATE ISSUED/DATE REVIEWED _______________________________________________________________

| Date Issued: | MM/DD/YYYY |
| --- | --- |
| Date Reviewed: | MM/DD/YYYY |
