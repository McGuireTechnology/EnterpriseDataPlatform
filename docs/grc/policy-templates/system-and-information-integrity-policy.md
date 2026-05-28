---
title: "System and Information Integrity Policy"
template_source: contrib/sources/policy-templates/System-and-Information-Integrity-Policy.docx
status: draft-template
owner: TBD
review_cadence: annual
control_mappings: []
---

# System and Information Integrity Policy

| Policy #: | Title: | Effective Date: |
| --- | --- | --- |
| x.xx | System and Information Integrity Policy | MM/DD/YYYY |

PURPOSE _______________________________________________________________

To ensure that Information Technology (IT) resources and information systems are established with system integrity monitoring to include areas of concern such as malware, application and source code flaws, industry supplied alerts and remediation of detected or disclosed integrity issues.

REFERENCE _______________________________________________________________

National Institute of Standards and Technology (NIST) Special Publications (SP): NIST SP 800-53a – System and Information Integrity (SI), NIST SP 800-12, NIST SP 800-40, NIST SP 800-45, NIST SP 800-83, NIST SP 800-61, NIST SP800-83, NIST SP 800-92, NIST SP 800-100, NIST SP 800-128, NIST SP 800-137, NIST SP 800-147, NIST SP 800-155

POLICY _______________________________________________________________

This policy is applicable to all departments and users of IT resources and assets.

FLAW REMEDIATION

IT Department shall:

Identify, report, and correct information system flaws.

Test software and firmware updates related to flaw remediation for effectiveness and potential side effects before installation.

Install security-relevant software and firmware updates within [entity defined time period] of the release of the updates.

Incorporate flaw remediation into the configuration management process.

Employ automated mechanisms [entity defined frequency] to determine the state of information system components with regard to flaw remediation.

MALICIOUS CODE PROTECTION

IT Department shall:

Employ malicious code protection mechanisms at information system entry and exit points to detect and eradicate malicious code.

Update malicious code protection mechanisms whenever new releases are available in accordance with configuration management policy and procedures.

Configure malicious code protection mechanisms to:

Perform periodic scans of the information system [entity defined frequency] and real-time scans of files from external sources at endpoint; network entry/exit points as the files are downloaded, opened, or executed in accordance with the security policy.

Block malicious code; quarantine malicious code; send alert to administrator; [entity defined action] in response to malicious code detection.

Address the receipt of false positives during malicious code detection and eradication and the resulting potential impact on the availability of the information system.

INFORMATION SYSTEM MONITORING

IT Department shall:

Monitor the information system to detect:

Attacks and indicators of potential attacks.

Unauthorized local, network, and remote connections.

Identify unauthorized use of the information system through defined techniques and methods.

Deploy monitoring devices strategically within the information system to collect [entity determined essential information] and at ad hoc locations within the system to track specific types of transactions of interest to the entity.

Protect information obtained from intrusion-monitoring tools from unauthorized access, modification, and deletion.

Heighten the level of information system monitoring activity whenever there is an indication of increased risk to operations and assets, individuals, other organizations, or based on law enforcement information, intelligence information, or other credible sources of information.

Obtain legal opinion with regard to information system monitoring activities in accordance with applicable state and federal laws, directives, policies, or regulations.

Provide information system monitoring information to authorized personnel or business units as needed.

SYSTEM-GENERATED ALERTS

IT Department shall ensure that:

The information system that may be generated from a variety of sources, including, for example, audit records or inputs from malicious code protection mechanisms, intrusion detection or prevention mechanisms, or boundary protection devices such as firewalls, gateways, and routers will be disseminated to authorized personnel or business units that shall take appropriate action on the alert(s).

Alerts be transmitted telephonically, electronic mail messages, or by text messaging as required. Personnel on the notification list can include system administrators, mission/business owners, system owners, or information system security officers.

SECURITY ALERTS, ADVISORIES, AND DIRECTIVES

IT Department shall:

Receive information system security alerts, advisories, and directives from [entity defined external organizations] on an ongoing basis.

Generate internal security alerts, advisories, and directives as deemed necessary.

Disseminate security alerts, advisories, and directives to: [entity defined personnel or roles]; [entity defined elements within the organization]; [entity defined external organizations].

Implement security directives in accordance with established time frames, or notifies the issuing organization of the degree of noncompliance.

SOFTWARE, FIRMWARE, AND INFORMATION INTEGRITY

IT Department shall:

Employ integrity verification tools to detect unauthorized changes to [entity defined software, firmware, and information];

Ensure the information system performs an integrity check of [entity defined software, firmware, and information] at startup, and/or at [entity defined transitional states or security-relevant events], [entity defined frequency].

Incorporate the detection of unauthorized [entity defined security-relevant changes to the information system] into the incident response capability.

SPAM PROTECTION

IT Department shall:

Employ spam protection mechanisms at information system entry and exit points to detect and take action on unsolicited messages.

Update spam protection mechanisms when new releases are available in accordance with the configuration management policy and procedures.

Manage spam protection mechanisms centrally.

Ensure information systems automatically update spam protection mechanisms.

INFORMATION INPUT VALIDATION

IT Department shall:

Ensure the information system:

Checks the validity of [entity defined information inputs].

Provides a manual override capability for input validation of [entity defined inputs].

Restricts the use of the manual override capability to only [entity defined authorized individuals].

Audits the use of the manual override capability.

Reviews and resolve within input validation errors.

Behaves in a predictable and documented manner that reflects system objectives when invalid inputs are received.

ERROR HANDLING

IT Department shall:

Ensure the information system:

Generates error messages that provide information necessary for corrective actions without revealing information that could be exploited by adversaries.

Reveals error messages only to [entity defined personnel or roles].

INFORMATION HANDLING AND RETENTION

IT Department shall:

Handle and retain information within the information system and information output from the system in accordance with applicable state and federal laws, directives, policies, regulations, standards, and operational requirements.

MEMORY PROTECTION

IT Department shall:

Ensure the information system implements [entity defined security safeguards] to protect its memory from unauthorized code execution.

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
