---
title: "Incident Response Management Policy Template"
template_source: contrib/sources/cis/Policy Templates/Incident_Response_Management_Policy_Template_v8.1_for_Control_17__1_.docx
status: draft-template
owner: TBD
review_cadence: annual
source_label: "CIS Controls v8.1 Policy Template"
control_mappings:
  - "CIS Control 17"
---

# Incident Response Management Policy Template

CIS Critical Security Controls v8.1

August 2025

## Acknowledgments

The Center for Internet Security® (CIS) would like to thank the many security experts who volunteer their time and talent to support the CIS Critical Security Controls (CIS Controls) and other CIS work. CIS products represent the effort of a veritable army of volunteers from across the industry, generously giving their time and talent in the name of a more secure online experience for everyone.

As a nonprofit organization driven by its volunteers, we are always in the process of looking for new topics and assistance in creating cybersecurity guidance. If you are interested in volunteering and/or have questions, comments, or have identified ways to improve this guide, please write us at: controlsinfo@cisecurity.org.

All references to tools or other products in this guide are provided for informational purposes only, and do not represent the endorsement by CIS of any particular company, product, or technology.

Editor Joshua M Franklin, CIS

Contributors Tony Krzyzewski, SAM for Compliance Ltd

Staffan Huslid, Truesec

Diego Bolatti, Information Systems Engineer, Universidad Tecnológica Nacional (Argentina)

Bryan Chou, CISSP, GSEC, GCED, GCIH

Bryan Ferguson

Gavin Willbond, SSS - IT Security Specialists

Ken Muir

Keala Asato Jon Matthies Ginger Anderson, CIS

Robin Regnier, CIS

Valecia Stocchetti, CIS

This work is licensed under a Creative Commons Attribution-Non Commercial-No Derivatives 4.0 International Public License (the link can be found at https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode).

To further clarify the Creative Commons license related to the CIS Controls® content, you are authorized to copy and redistribute the content as a framework for use by you, within your organization and outside of your organization for non-commercial purposes only, provided that (i) appropriate credit is given to CIS, and (ii) a link to the license is provided. Additionally, if you remix, transform, or build upon the CIS Controls, you may not distribute the modified materials. Users of the CIS Controls framework are also required to refer to (http://www.cisecurity.org/controls/) when referring to the CIS Controls in order to ensure that users are employing the most up-to-date guidance. Commercial use of the CIS Controls is subject to the prior approval of the Center for Internet Security, Inc. (CIS®).

## Introduction

A comprehensive cybersecurity program includes protections, detections, response, and recovery capabilities. Often, the final two get overlooked in immature enterprises, or the response technique for compromised systems is to solely re-image them to original state, and move on. The primary goal of incident response is to identify threats on the enterprise, respond to them before they can spread, and remediate them before they can cause harm. Without understanding the full scope of an incident, how it occurred, and what can be done to prevent it from happening again, defenders will just be in a perpetual “whack-a-mole” pattern.

We cannot expect our protections to be effective 100% of the time. When an incident occurs, if an enterprise does not have a documented plan—even with good people—it is almost impossible to know the right investigative procedures, reporting, data collection, management responsibility, legal protocols, and communications strategy that will allow the enterprise to successfully understand, manage, and recover.

Along with detection, containment, and eradication, communication to stakeholders is key. If we are to reduce the probability of material impact due to a cyber event, the enterprise’s leadership must know what potential impact there could be, so that they can help prioritize remediation or restoration decisions that best support the enterprise. These business decisions could be based on regulatory compliance, disclosure rules, service-level agreements with partners or customers, revenue, or mission impacts.

Dwell time from when an attack happens to when it is identified can be days, weeks, or months. The longer the attacker is in the enterprise’s infrastructure, the more embedded they become. They will likely develop more ways to maintain persistent access for when they are eventually discovered. With the rise of ransomware, which is a stable moneymaker for attackers, this dwell time is critical, especially with modern tactics of stealing data before encrypting it for ransom.

### Purpose

The CIS Critical Security Controls® (CIS Controls®) recommend multiple information security policies that an enterprise should have in place. This Incident Response Policy is meant as a foundational guide for organizations needing to draft their own policies, and provides specific, high-level steps that should be part of any comprehensive incident response plan. Enterprises are encouraged to use this policy template in whole or in part. With that said, there are multiple decision points and areas that must be tailored to your enterprise. In CIS Controls v8.1, Control 17 states:

Control 17 – Incident Response Management Establish a program to develop and maintain an incident response capability (e.g., policies, plans, procedures, defined roles, training, and communications) to prepare, detect, and quickly respond to an attack.

### Events vs Incidents

There are many ways to define an incident. The authors of this document consider the following factors when defining an incident:

- An event or situation, either intentional or unintentional, internal to the enterprise or external,

- Caused by an individual, enterprise, nation state, or natural event that,

- Impacts an enterprise’s ability to accomplish its mission (critically or otherwise), and

- This event may or may not lead to loss of data.

Examples of deliberate hacking incidents include attacks against Supermarket Chain Coop’s and those affected by the SolarWinds Attacks. Incidents aren’t always hacking-oriented as was the case with a French data center that was affected by fires, meaning natural disasters can also trigger the incident response plan. It can sometimes be difficult to interpret something as an event or an incident. NIST defines an incident as a “cybersecurity event that has been determined to have an impact on the organization prompting the need for response and recovery.” Some view an event as any occurrence that can be observed, verified, and documented, whereas an incident is one or more related events that negatively affect the company and/or impact its security posture. Sometimes one business unit within an enterprise will interpret an action as an event whereas another business unit will define it as an incident. This distinction matters, as an incident will trigger different enterprise responses, such as activating the incident response plan. Having clearly established definitions of events versus incident can be very beneficial for this reason. For example, an enterprise may determine that anytime leadership is actively involved in an event, it will be classified as an incident. Ultimately, this is a judgement call. Note that events can become incidents as more information is gathered.

#### Scope

This policy template is meant to supplement the CIS Controls v8.1. The policy statements included within this document can be used by all CIS Implementation Groups (IGs), but are geared towards Safeguards in Implementation Group 1 (IG1). Additional Safeguards from IG2 are included within this policy template, since they are commonly included as requirements from cyber insurance providers. These Safeguards are 17.4, 17.5, and 17.6. In Appendix E, Safeguards unique to IG1 are specifically highlighted for ease of use. For more information on the CIS Implementation Groups, see Appendix A. Additionally, a glossary in Appendix C is provided for guidance on terminology used throughout the document. Future versions of this template may expand the scope to Implementation Group 2 (IG2) Safeguards. IG2 and IG3 enterprises may feel the need to add sections that go beyond IG1, and are welcome to do so. Depending on an enterprise’s sector or mission, other policy statements may also need to be added or removed. This is encouraged as this policy needs to be molded and fit to the enterprise’s needs.

## Incident Response Plan Lifecycle

This Incident Response Policy Template is divided into multiple sections based on usage patterns of assets within an enterprise. There are many ways to organize the incident response process. The NIST Cybersecurity Framework (CSF) provides one, as does NIST 800-61 Revision 2: Computer Security Incident Handling Guide. The lifecycle presented below in Figure 1 is an abstracted way to view the incident response process and house the policy statements provided by this document in an organized manner. High-level “steps” of the incident responses process are presented, followed by a detailed description of what each step entails.

Figure 1. Incident Response Process

- Plan – Develop documentation for all procedures necessary to handle an incident.

- Detect – Monitor enterprise assets and analyze intelligence to understand if an incident has occurred.

- Respond – Activate the incident response plan to deal with an incident.

- Update – Understand which portions of the incident response plan have been effective or not and update the plan accordingly.

### Plan

When an incident occurs, the first step is to consult the incident response plan for the next steps that the enterprise should take. The plan should remain available in case enterprise systems are no longer functioning as intended; common methods include storing the plan on an external system or keeping a paper copy on hand. An incident will be a stressful time and this plan should provide step-by-step instructions that prevents guesswork during the heat of the moment. There are a variety of incident response plans available online that enterprises can consult when writing their own plan. Plans will vary from enterprise to enterprise, but the level of detail will often be dictated by the maturity of the cybersecurity program. One of the most common aspects of an incident response plan is to name specific individuals to perform defined functions during this process. There will likely need to be someone who is responsible for the entire process, often the incident manager. Any external support from third parties should also be named, which often includes contractors or technical organizations offering support. Detailed contact information should be provided for all individuals named in the plan. Once written, this plan will change over time as experience is gained, and the process gradually iterates to be in sync with the needs of the enterprise. Testing the plan via tabletop exercises is a great way to gain familiarity with the plan.

While larger enterprises may place procedures for responding to a natural disaster within a business continuity plan, smaller enterprises may place these policies within the incident response plan. Either approach is acceptable, and enterprises are encouraged to seek out how this is typically done in similar enterprises in their localities. Regulatory requirements may specifically note where these policies and procedures belong.

There is a need for a defined process for a user to report any identified event, or potential event. This process should be documented to facilitate clarity and ease of implementation. This is a separate plan or process from the Incident Response Plan. Users should be taught this process during the mandatory training for security awareness, therefore it must be easy to implement. The information should also be placed on internal intranet places and other logical places that would make the information readily available and accessible to all users.

### Detect

Detecting if an incident occurred is difficult. Especially if the attack was subtle from advanced actors. To combat this, enterprises typically leverage a variety of methods to identify incidents such as data, anti-malware, and security awareness training. Data will often take the form of logs that must be analyzed. These logs may contain information to help you understand if an incident has occurred. Anti-malware tools such as endpoint detection and response (EDR) are tailor made for detecting these types of attacks. Finally, employees should be regularly trained in how to spot and report incidents. This means that IT must monitor employee reports of computer incidents and actively investigate such reports.

### Respond

Once an incident has been reported or detected, IT, or the business units charged with security, must activate the incident response plan as developed in the planning phase. This response also begins the recovery process. The response team will often be composed of internal and external users all working together to carry out the incident response plan. It’s common for smaller enterprises to contact any contractors helping to manage its IT infrastructure or any state/federal government entities offering free or low-cost services. Ultimately, the individual specified in the incident response plan as the incident manager is charged with ensuring the incident has been properly managed and is following established standard operating procedures (SOPs). It’s best practice for the incident manager to be an individual trained in incident response with excellent communication skills, the capacity to prioritize the incident. This individual must have the authority to communicate business impacts with external organizations such as lawyers, regulators, cyber insurance companies, local cyber incident response teams (CIRT) and potentially law enforcement. Generally, this is not a senior executive; but this is not always practical with smaller entities. External incident response expertise may be required. This individual will also be responsible for making the determination that the incident has come to a conclusion.

### Update

The update phase of this lifecycle ensures that the incident response plan and process is gradually improving from the experiences of recent incidents, tabletop exercises, and scheduled regular review. Lessons learned from recent incidents should be discussed with the relevant stakeholders involved in the incident response process. Appropriate changes to the incident response plan based on recent incidents should be made, alongside the standard operating procedures. Where applicable, communicate and train staff on changes to the IR plan. During the incident response process, it’s common for data to be collected and used to help guide actions of all involved. These collected data artifacts should be archived or deleted in a manner consistent with the Data Management Policy and documented in the custodial chain of evidence if appropriate.

## Incident Response Management Policy Template

### Purpose

Incident response includes planning for and actively managing incidents that can prevent an enterprise from leveraging its assets to meet its goals. Most commonly this takes the form of unauthorized access into a computer system, physical security intrusions, or if a natural disaster occurs. The Incident Response Policy provides the processes and procedures for ensuring incidents are properly handled with as little impact to the enterprise as possible, and to begin the recovery plan. This policy applies to all departments and all assets connected to the enterprise network.

### Responsibility

The IT business unit is responsible for managing all incident response functions. While all IT staff are required to follow the written incident response plan, real world deviations are expected and must be handled gracefully. Third-party organizations involved in the incident response process must be managed by the incident manager. Users are responsible for reporting incidents that they are aware of to the appropriate business unit or personnel as specified in the incident reporting process. Users are responsible for attending training for recognizing and reporting incidents within the enterprise.

### Policy

#### Plan

- IT must develop and maintain a written incident response plan.

1. This process must be documented and approved.

1. This plan must include a process for responding to incidents.

1. At a minimum, the incident response process must be reviewed on an annual basis or following significant changes within the enterprise.

1. . This review may also occur following an incident or tabletop exercise.

1. An incident manager and backup incident manager must be specifically identified by name within the plan.

1. If an external party is the incident manager, then one internal individual must be specified to oversee the response process.

1. Contact information must be recorded in the incident response plan.

1. Any parties that need to be made aware of a security incident must be documented.

1. The plan must address any regulatory or other compliance requirements.

1. The plan must address communications.

- IT must develop and maintain a written process for users to report incidents.

1. This process must include approved methods for reporting incidents including:

1. Primary and secondary methods for reporting.

1. Specific recipients to receive incident reports.

1. Any minimum information needed.

1. Timeframes for reporting incidents.

1. At a minimum, the incident reporting process must be reviewed on an annual basis or following significant changes within the enterprise.

#### Detect

There are no IG1 Safeguards that support this portion of the incident response process.

#### Respond

There are no IG1 Safeguards that support this portion of the security awareness training process.

#### Update

- IT must develop and maintain a written incident response plan.

## Revision History

Each time you update this document, this table should be updated.

| Version | Revision Date | Revision Description | Name |
| --- | --- | --- | --- |
|   |   |   |   |
|   |   |   |   |
|   |   |   |   |
|   |   |   |   |
|   |   |   |   |

## Appendix A: CIS Controls Implementation Groups

The CIS Critical Security Controls® (CIS Controls®) are a prioritized set of actions which collectively form a defense-in-depth set of best practices that mitigate the most common attacks against systems and networks. They are developed by a community of information technology (IT) experts who apply their first-hand experience as cyber defenders to create these globally accepted security best practices. The experts who develop the CIS Controls come from a wide range of sectors, including retail, manufacturing, healthcare, education, government, defense, and others. It is important to note that while the CIS Controls address general best practices that enterprises should implement to protect their environment, some operational environments may present unique requirements not addressed by the CIS Controls or require deviations from best practices.

### Implementation Groups

The Implementation Group methodology was developed as a new way to prioritize the CIS Controls. These IGs provide a simple and accessible way to help enterprises of different classes focus their scarce security resources, while still leveraging the value of the CIS Controls program, community, and complementary tools and working aids. More about the Implementation Groups can be found in our Guide to Implementation Groups (IG): CIS Critical Security Controls v8.1.

IG1

An IG1 enterprise is small to medium-sized with limited IT and cybersecurity expertise to dedicate toward protecting IT assets and personnel. The principal concern of these enterprises is to keep the business operational, as they have a limited tolerance for downtime. The sensitivity of the data that they are trying to protect is low and principally surrounds employee and financial information. Safeguards selected for IG1 should be implementable with limited cybersecurity expertise and aimed to thwart general, non-targeted attacks. These Safeguards will also typically be designed to work in conjunction with small or home office commercial off-the-shelf (COTS) hardware and software.

IG2

An IG2 enterprise employs individuals responsible for managing and protecting IT infrastructure. These enterprises support multiple departments with differing risk profiles based on job function and mission. Small enterprise units may have regulatory compliance burdens. IG2 enterprises often store and process sensitive client or enterprise information and can withstand short interruptions of service. A major concern is loss of public confidence if a breach occurs. Safeguards selected for IG2 help security teams cope with increased operational complexity. Some Safeguards will depend on enterprise-grade technology and specialized expertise to properly install and configure.

IG3

An IG3 enterprise employs security experts that specialize in the different facets of cybersecurity (e.g., risk management, penetration testing, application security). IG3 assets and data contain sensitive information or functions that are subject to regulatory and compliance oversight. An IG3 enterprise must address availability of services and the confidentiality and integrity of sensitive data. Successful attacks can cause significant harm to the public welfare. Safeguards selected for IG3 must abate targeted attacks from a sophisticated adversary and reduce the impact of zero-day attacks.

If you would like to know more about the Implementation Groups and how they pertain to enterprises of all sizes, there are many resources that explore the Implementation Groups and the CIS Controls in general on our website at https://www.cisecurity.org/controls/cis-controls-list/.

## Appendix B: Acronyms and Abbreviations

| CIS | Center for Internet Security |
| --- | --- |
| CIS Controls | Center for Internet Security Critical Security Controls |
| CIRT | Cyber Incident Response Team |
| COTS | Commercial-off-the-shelf |
| CSF | Cybersecurity Framework |
| EDR | Endpoint Detection and Response |
| IG | Implementation Group |
| IR | Incident Response |
| ISAC | Information Sharing and Analysis Center |
| IT | Information Technology |
| OSINT | Open-source intelligence |
| SOP | Standard Operating Procedure |

## Appendix C: Glossary

| Asset | Anything that has value to an organization, including, but not limited to, another organization, person, computing device, information technology (IT) system, IT network, IT circuit, software (both an installed instance and a physical instance), virtual computing platform (common in cloud and virtualized computing), and related hardware (e.g., locks, cabinets, keyboards). / Source: Asset(s) - Glossary \| CSRC (nist.gov) |
| --- | --- |
| Cloud environment | A virtualized environment that provides convenient, on-demand network access to a shared pool of configurable resources such as network, computing, storage, applications, and services. There are five essential characteristics to a cloud environment: on-demand self-service, broad network access, resource pooling, rapid elasticity, and measured service. Some services offered through cloud environments include Software as a Service (SaaS), Platform as a Service (PaaS), and Infrastructure as a Service (IaaS). |
| Enterprise assets | Assets with the potential to store or process data. For the purpose of this document, enterprise assets include end-user devices, network devices, non-computing/Internet of Things (IoT) devices, and servers, in virtual, cloud-based, and physical environments. |
| End-user devices | Information technology (IT) assets used among members of an enterprise during work or off-hours. End-user devices include desktops and workstations, as well as portable and mobile devices such as laptops, smartphones, and tablets. For the purpose of this document, end-user devices are a subset of enterprise assets. |
| Enterprise asset identifier | Often a sticker or tag with a unique number or alphanumeric string that can be tracked within an enterprise asset inventory. |
| Mobile end-user devices | Small, enterprise-issued end-user devices with intrinsic wireless capability, such as smartphones and tablets. For the purpose of this document, mobile devices are a subset of portable devices. |
| Network devices | Electronic devices required for communication and interaction between devices on a computer network. Network devices include wireless access points, firewalls, physical/virtual gateways, routers, and switches. These devices consist of physical hardware as well as virtual and cloud-based devices. For the purpose of this document, network devices are a subset of enterprise assets. |
| Non-computing/Internet of Things (IoT) devices | Devices embedded with sensors, software, and other technologies for the purpose of connecting, storing, and exchanging data with other devices and systems over the internet. While these devices are not used for computational processes, they support an enterprise’s ability to conduct business processes. Examples of these devices include printers, smart screens, physical security sensors, industrial control systems, and information technology sensors. For the purpose of this document, non-computing/IoT devices are a subset of enterprise assets. |
| Physical environment | Physical hardware parts that make up a network, including cables and routers. The hardware is required for communication and interaction between devices on a network. |
| Portable end-user devices | Transportable, end-user devices that have the capability to wirelessly connect to a network. Portable end-user devices can include laptops which may require external hardware for connectivity and mobile devices, such as smartphones and tablets. For the purpose of this document, portable devices are a subset of end-user devices. |
| Remote devices | Any enterprise asset capable of connecting to a network remotely, usually from public internet. This can include enterprise assets such as end-user devices, network devices, non-computing/Internet of Things (IoT) devices, and servers. |
| Servers | A device or system that provides resources, data, services, or programs to other devices on either a local area network or wide area network. Servers can provide resources and use them from another system at the same time. Servers can exist in datacenters, public/private/hybrid cloud environments, including temporal containers or serverless workloads. Examples of servers include web servers, application servers, mail servers, and file servers. For the purpose of this document, servers are a subset of enterprise assets. |
| User | Employees, third-party vendors, contractors, service providers, consultants, or any other person who is authorized to access an enterprise asset. This also includes user, administrator, and service accounts. |
| Virtual environment | Simulates hardware to allow a software environment to run without the need to use a lot of actual hardware. Virtualized environments are used to make a small number of resources act as many with plenty of processing, memory, storage, and network capacity. Virtualization is a fundamental technology that allows cloud computing to work. |

## Appendix D: Links and Resources

CIS Critical Security Controls (CIS Controls) v8.1: Learn more about the CIS Controls, including how to get started, why each Control is critical, procedures and tools to use during implementation, and a complete listing of Safeguards for each Control.

CIS Community Defense Model (CDM) v2.0: A guide published by CIS that leverages the open availability of comprehensive summaries of attacks and security incidents, and the industry-endorsed ecosystem that is developing around the MITRE ATT&CK Framework.

CIS Controls Assessment Specification: Provides an understanding of what should be measured in order to verify that the Safeguards are properly implemented.

CIS Controls Navigator: Learn more about the Controls and Safeguards and see how they map to other security standards (e.g., CMMC, NIST SP 800-53 Rev. 5, PCI DSS, MITRE ATT&CK). Available for CIS Controls versions 8.1, 8, and 7.1.

CIS Controls Self Assessment Tool (CIS CSAT): Enables enterprises to assess and track their implementation of the CIS Controls for versions 8.1, 8, and 7.1.

CIS Cost of Cyber Defense: IG1 v1.1: CIS has published The CIS Cost of Cyber Defense: Implementation Group 1 (IG1), to help you answer these questions: Which protections to start with? Which tools will be needed to implement those protections? and How much will an implementation will cost?

CIS Risk Assessment Method (CIS RAM) v2.1: An information security risk assessment method that helps enterprises implement and assess their security posture against the CIS Controls.

Establishing Essential Cyber Hygiene: IG1 is essential cyber hygiene and represents a minimum standard of information security for all enterprises. This guide will help enterprises establish essential cyber hygiene.

Guide to Asset Classes: In v8.1, CIS restructured Asset Classes and their respective definitions to ensure consistency throughout the Controls. Learn more about our naming conventions and what they mean.

CIS WorkBench: Get involved in one of our many communities.

Council of Registered Security Testers (CREST) Cyber Security Incident Response Guide: This guide offers practical, step-by-step advice for procuring cyber security incident response services, including defining requirements, evaluating and selecting qualified suppliers, and integrating outsourced expertise into your incident response program.

MS-ISAC® Service: Cyber Incident Response Team (CIRT): SLTT governments can report incidents to the MS-ISAC Call 866-787-4722 or email soc@cisecurity.org for assistance from the MS-ISAC/EI-ISAC Security Operations Center (SOC) and Cyber Incident Response Team (CIRT).

NIST SP 800-61 Rev. 2 Computer Security Incident Handling Guide: Provides comprehensive, platform-agnostic guidance on establishing and operating an effective incident response capability.

NIST SP 800-184 Guide for Cybersecurity Event Recovery: Provides strategic and tactical guidance for preparing, building, testing, and continually improving cybersecurity event recovery plans and playbooks.

## Appendix E: CIS Safeguards Mapping v8.1

CIS Controls & Safeguards Covered by this Policy

This policy helps to bolster IG1 Safeguards in CIS Control 17: Incident Response Management. The table below shows which IG1 Safeguards are covered by this policy.

| CIS Control | Policy Statement | CIS Safeguard | CIS Safeguard Description |
| --- | --- | --- | --- |
| 17.1 | Plan 1d | Designate Personnel to Manage Incident Handling | Designate one key person, and at least one backup, who will manage the enterprise’s incident handling process. Management personnel are responsible for the coordination and documentation of incident response and recovery efforts and can consist of employees internal to the enterprise, service providers, or a hybrid approach. If using a service provider, designate at least one person internal to the enterprise to oversee any third-party work. Review annually, or when significant enterprise changes occur that could impact this Safeguard. |
| 17.2 | Plan 1db | Establish and Maintain Contact Information for Reporting Security Incidents | Establish and maintain contact information for parties that need to be informed of security incidents. Contacts may include internal staff, service providers, law enforcement, cyber insurance providers, relevant government agencies, Information Sharing and Analysis Center (ISAC) partners, or other stakeholders. Verify contacts annually to ensure that information is up-to-date. |
| 17.3 | Plan 2 | Establish and Maintain an Enterprise Process for Reporting Incidents | Establish and maintain a documented enterprise process for the workforce to report security incidents. The process includes reporting timeframe, personnel to report to, mechanism for reporting, and the minimum information to be reported. Ensure the process is publicly available to all of the workforce. Review annually, or when significant enterprise changes occur that could impact this Safeguard. |
| 17.4 | Plan 1 | Establish and Maintain an Incident Response Process | Establish and maintain a documented incident response process that addresses roles and responsibilities, compliance requirements, and a communication plan. Review annually, or when significant enterprise changes occur that could impact this Safeguard. |
| 17.5 | Plan 1de | Assign Key Roles and Responsibilities | Assign key roles and responsibilities for incident response, including staff from legal, IT, information security, facilities, public relations, human resources, incident responders, analysts, and relevant third parties. Review annually, or when significant enterprise changes occur that could impact this Safeguard. |
| 17.6 | Plan 1g | Define Mechanisms for Communicating During Incident Response | Determine which primary and secondary mechanisms will be used to communicate and report during a security incident. Mechanisms can include phone calls, emails, secure chat, or notification letters. Keep in mind that certain mechanisms, such as emails, can be affected during a security incident. Review annually, or when significant enterprise changes occur that could impact this Safeguard. |
