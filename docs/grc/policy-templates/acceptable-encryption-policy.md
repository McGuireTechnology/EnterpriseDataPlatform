---
title: "Acceptable Encryption Policy"
template_source: contrib/sources/policy-templates/Acceptable-Encryption-Policy.docx
status: draft-template
owner: TBD
review_cadence: annual
control_mappings: []
---

# Acceptable Encryption Policy

Free Use Disclaimer: This policy was created by or for the SANS Institute for the Internet community. All or parts of this policy can be freely used for your organization. There is no prior approval required. If you would like to contribute a new policy or updated version of this policy, please send email to policy-resources@sans.org.

Last Update Status: Updated June 2014

## Overview

See Purpose.

## Purpose

The purpose of this policy is to provide guidance that limits the use of encryption to those algorithms that have received substantial public review and have been proven to work effectively. Additionally, this policy provides direction to ensure that Federal regulations are followed, and legal authority is granted for the dissemination and use of encryption technologies outside of the United States.

## Scope

This policy applies to all [Company Name] employees and affiliates.

## Policy

- Algorithm Requirements

- Ciphers in use must meet or exceed the set defined as "AES-compatible" or "partially AES-compatible" according to the IETF/IRTF Cipher Catalog, or the set defined for use in the United States National Institute of Standards and Technology (NIST) publication FIPS 140-2, or any superseding documents according to the date of implementation. The use of the Advanced Encryption Standard (AES) is strongly recommended for symmetric encryption.

- Algorithms in use must meet the standards defined for use in NIST publication FIPS 140-2 or any superseding document, according to date of implementation. The use of the RSA and Elliptic Curve Cryptography (ECC) algorithms is strongly recommended for asymmetric encryption.

- Signature Algorithms

| Algorithm | Key Length / (min) | Additional Comment |
| --- | --- | --- |
| ECDSA | P-256 | Consider RFC6090 to avoid patent infringement. |
| RSA | 2048 | Must use a secure padding scheme. PKCS#7 padding scheme is recommended. Message hashing required. |
| LDWM | SHA256 | Refer to LDWM Hash-based Signatures Draft |

#### Hash Function Requirements

In general, [Company Name] adheres to the NIST Policy on Hash Functions.

#### Key Agreement and Authentication

##### Key exchanges must use one of the following cryptographic protocols: Diffie-Hellman, IKE, or Elliptic curve Diffie-Hellman (ECDH).

##### End points must be authenticated prior to the exchange or derivation of session keys.

##### Public keys used to establish trust must be authenticated prior to use. Examples of authentication include transmission via cryptographically signed message or manual verification of the public key hash.

##### All servers used for authentication (for example, RADIUS or TACACS) must have installed a valid certificate signed by a known trusted provider.

##### All servers and applications using SSL or TLS must have the certificates signed by a known, trusted provider.

##### Key Generation

##### Cryptographic keys must be generated and stored in a secure manner that prevents loss, theft, or compromise.

##### Key generation must be seeded from an industry standard random number generator (RNG). For examples, see NIST Annex C: Approved Random Number Generators for FIPS PUB 140-2.

## Policy Compliance

- Compliance Measurement

- The Infosec team will verify compliance to this policy through various methods, including but not limited to, business tool reports, internal and external audits, and feedback to the policy owner.

## Exceptions

- Any exception to the policy must be approved by the Infosec team in advance.

## Non-Compliance

- An employee found to have violated this policy may be subject to disciplinary action, up to and including termination of employment.

## Related Standards, Policies and Processes

National Institute of Standards and Technology (NIST) publication FIPS 140-2,

NIST Policy on Hash Functions

## Definitions and Terms

The following definition and terms can be found in the SANS Glossary located at:

https://www.sans.org/security-resources/glossary-of-terms/

- Proprietary Encryption

## Revision History

| Date of Change | Responsible | Summary of Change |
| --- | --- | --- |
| June 2014 | SANS Policy Team | Updated and converted to new format. |
|   |   |   |
