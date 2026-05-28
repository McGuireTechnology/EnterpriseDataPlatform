---
title: "Software Asset Management Policy Template"
template_source: contrib/sources/cis/Policy Templates/Software_Asset_Management_Policy_Template_v8.1_for_Control_2.docx
status: draft-template
owner: TBD
review_cadence: annual
source_label: "CIS Controls v8.1 Policy Template"
control_mappings:
  - "CIS Control 2"
---

# Software Asset Management Policy Template

CIS Critical Security Controls v8.1

August 2025

## Acknowledgments

The Center for Internet Security® (CIS) would like to thank the many security experts who volunteer their time and talent to support the CIS Critical Security Controls (CIS Controls) and other CIS work. CIS products represent the effort of a veritable army of volunteers from across the industry, generously giving their time and talent in the name of a more secure online experience for everyone.

As a nonprofit organization driven by its volunteers, we are always in the process of looking for new topics and assistance in creating cybersecurity guidance. If you are interested in volunteering and/or have questions, comments, or have identified ways to improve this guide, please write us at: controlsinfo@cisecurity.org.

All references to tools or other products in this guide are provided for informational purposes only, and do not represent the endorsement by CIS of any particular company, product, or technology.

Editor Joshua M Franklin, CIS

Contributors Tony Krzyzewski, SAM for Compliance Ltd Dave Tchozewski

Jon Matthies Edsel Medina Staffan Huslid, Truesec Jamie Fike Ken Muir Luke McFadden Diego Bolatti, Information Systems Engineer, Universidad Tecnológica Nacional (Argentina)

Bryan Chou

Keala Asato Gavin Willbond, SSS – IT Security Specialists Robin Regnier, CIS Valecia Stocchetti, CIS

This work is licensed under a Creative Commons Attribution-Non Commercial-No Derivatives 4.0 International Public License (the link can be found at https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode).

To further clarify the Creative Commons license related to the CIS Controls® content, you are authorized to copy and redistribute the content as a framework for use by you, within your organization and outside of your organization for non-commercial purposes only, provided that (i) appropriate credit is given to CIS, and (ii) a link to the license is provided. Additionally, if you remix, transform, or build upon the CIS Controls, you may not distribute the modified materials. Users of the CIS Controls framework are also required to refer to (http://www.cisecurity.org/controls/) when referring to the CIS Controls in order to ensure that users are employing the most up-to-date guidance. Commercial use of the CIS Controls is subject to the prior approval of the Center for Internet Security, Inc. (CIS®).

## Introduction

Software asset management is the process of procuring, identifying, tracking, maintaining, and removing software on enterprise assets. Software asset management is a difficult problem for an enterprise of any size. New software is constantly acquired within an enterprise. Software must be maintained, updated, and ultimately uninstalled. Additionally, users may attempt to install unauthorized software on enterprise assets. With work from home becoming more prominent, software may be regularly used on enterprise assets that do not connect to the enterprise network. This requires that software may be managed by an enterprise’s Information Technology (IT) personnel.

### Purpose

The Center for Internet Security® (CIS®) recommends several policies that an enterprise should have in place. One of those policies, a Software Asset Management Policy, is meant as a foundational guide for enterprises that need help drafting their own software asset management policy. Enterprises are encouraged to use this policy template in whole or in part. With that said, there are multiple decision points and areas that must be tailored to your enterprise. As an example, deciding and documenting which “departments” or “business units” are responsible for asset management. In CIS Controls v8.1, Control 2 states:

Control 2 –Inventory and Control of Software Assets Actively manage (inventory, track, and correct) all software (operating systems and applications) on the network so that only authorized software is installed and can execute, and that unauthorized and unmanaged software is found and prevented from installation or execution.

To support this Safeguard, it is important for an enterprise to develop a software asset management process. This process should include establishing and maintaining a detailed software asset inventory, ensuring that software is currently supported (e.g., not end-of-life or end-of-support), and addressing unauthorized software, at a minimum. This document supports the development of a process for managing software assets and the implementation of this CIS Control.

### Types of Software Assets

There are many types of software assets that can exist on enterprise assets. For the purposes of this document and as defined in the CIS Critical Security Controls® (CIS Controls®), software is defined as sets of data and instructions used to direct a computer to complete a specific task. Software assets include operating systems and applications. Both may contain services, libraries, or Application Programming Interfaces (APIs). An API is a set of rules and interfaces for software components to interact with each other in a standardized way. Software assets include both operating systems and applications. An operating system is system software on enterprise assets that manages computer hardware and software resources, and provides common services for programs. Operating systems are considered a software asset and can be single- and multi-tasking, single- and multi-user, distributed, templated, embedded, real-time, and library. An application is a program, or a group of programs, running on top of an operating system hosted on an enterprise asset. Applications are considered a software asset in this document. Examples include web, database, cloud-based, and mobile applications.

Additionally, there are multiple components that make up applications and operating systems, including services and libraries. A service refers to specialized programs that perform well-defined critical tasks for the operating system. Services provide a mechanism to enable access to one or more capabilities, where the access is provided using a prescribed interface and based on the identity of the requestor per the enterprise’s usage policies. A library is a shareable pre-compiled codebase to include classes, procedures, scripts, configuration data, and more, used to develop software programs and applications. It is designed to assist both the programmer and the programming language compiler in building and executing software

Figure . Software assets, as defined in CIS Controls v8.1

There are also several different categories of software revolving around their owner, cost, and the ability to modify and redistribute the code. The following list provides general definitions for use within this document.

- Free software: Completely free to download, modify, distribute, and use software.

- Freeware: No-cost software that often includes a limited license to specific groups of users (e.g., students). Modification of source code is generally prohibited.

- Open source: Free software for download and use, but the license will dictate stipulations for modification and redistribution.

- Commercial off the Shelf (COTS) Software: Software that is publicly available for purchase. Patrons are generally not authorized to modify the software.

- Internally Developed Applications: Software applications created and maintained by an enterprise and their contractors. The enterprise generally owns all rights save for any licenses used in development stipulating otherwise.

- Shareware: Often a type of software offered with a time-limited license, and potentially limited feature sets. Full versions are made available for purchase.

- Scripts (e.g., PowerShell, Bash): A program that provides a series of instructions to the operating system, typically to accomplish a series of more basic tasks.

#### Scope

This policy template is meant to supplement the CIS Controls v8.1. The policy statements included within this document can be used by all CIS Implementation Groups (IGs), but are specifically geared towards Safeguards in Implementation Group 1 (IG1). In Appendix E, Safeguards unique to IG1 are specifically highlighted for ease of use. For more information on the CIS Implementation Groups, see Appendix A. Additionally, a glossary in Appendix C is provided for guidance on terminology used throughout the document. Future versions of this template may expand the scope to both Implementation Group 2 (IG2) Safeguards. IG2 and IG3 enterprises may feel the need to add sections that go beyond IG1, and are welcome to do so. Depending on an enterprise’s sector or mission, other policy statements may also need to be added or removed. This is encouraged as this policy needs to be molded and fit to the enterprise’s needs.

## Software Asset Management Lifecycle

Identifying and tracking software assets is an important process in the Software Asset Management Lifecycle. In order to protect a network and its assets, an enterprise must first know what software is on a network. In addition, many other security controls are dependent on the software asset inventory, such as secure configurations, account management, access control, and more. The high-level “steps” of the Software Asset Lifecycle, is shown below in Figure 2, followed by a detailed description.

- Procurement – Acquiring new software from software vendors and managing software licenses.

- Installation – Deploying new software products to employee assets, to include phones, tablets, desktops, servers, and cloud infrastructure.

- Discovery – The identification of software by actively searching systems connected to the enterprise network.

- Usage – The authorized use of approved software by employees.

- Update and Upgrade – Applying minor software patches or replacing a software asset with new functionality.

- Removal – Deleting or retiring software from enterprise assets.

### Procurement

Procurement involves acquiring new software from external vendors, including from managed service providers (MSPs) and cloud service providers (CSPs), or obtaining new software by transfer from another business unit within the same enterprise. Those individuals charged with making purchasing decisions, often from the IT or financial business units, should evaluate all vendors before making a purchase. There should be a pre-defined process in place to ensure the vendor is reputable and that major components are not left out of any contracts.

CIS provides a simple template for starting a software asset inventory, but many enterprises will quickly find the need to move to something more robust, such as a third-party tool or database. Note that the software asset inventory is likely to contain sensitive information that could be leveraged by malicious parties. Therefore, the inventory should have sufficient access control to prevent unauthorized access and modification.

### Installation

The installation process consists of deploying new services or software required for business functions to enterprise assets, including laptops, desktops, phones, tablets, servers, and cloud infrastructure. This process varies for each software and the device on which it is installed. However, in general it requires code to be copied to local folders on the asset to facilitate access by the operating system. Installation includes the creation of necessary directories and registering environment variables. During this process, IT would ensure the software is configured appropriately, not only for execution but also security purposes.

### Discovery

Once software applications are installed on enterprise assets, the maintenance process begins. This process consists of searching for new software on your enterprise assets through the use of discovery tools. Any new software identified should be added to the software asset inventory.

Once the inventory is updated, either via discovery or other means, it is time to check all discovered software against the known list of approved software. This may take some time, but it is critical from a cybersecurity perspective. Any unauthorized software must be investigated to understand if this is new software that needs to be added to the approved inventory listing or if the software is unauthorized and needs to be removed. Some software may be malicious in nature and must be removed. If a software is deemed to be malicious, it may be pertinent to activate the enterprise’s incident response process.

### Usage

During this phase, employees utilize provisioned software to perform their everyday work tasks. A set of rules governing how a user can leverage software to perform their job should be in place and properly communicated to the user. Accordingly, the usage phase of this document contains a sample set of policy statements. It is commonplace for these rules to be placed within a separate policy document called an Acceptable Use Policy. The owner of this Software Asset Management Policy may choose to delete all content in the usage section and refer to an external Acceptable Use Policy that may already be in place. Note that the statements contained within the Usage phase of this document are insufficient to act as a fully realized Acceptable Use Policy.

### Update & Upgrade

The upgrade process for software entails replacing the software asset with a newer version provided by the developer. Newer versions of software are usually accompanied by major changes or security enhancements, and often drastically change the application, operating system, or software. The update process is the act of modifying already installed software, which consists of patches and ad hoc updates that do not consist of major changes to the software. Some enterprises may wish to test updates before they are integrated into production environments. Updates are part of a regular operational process whereas upgrades occur when the enterprise requires additional features or otherwise retire the existing version. This means that software updates occur more frequently than software upgrades, and upgrades may never occur depending on budget or the developer. For additional information please refer to the Vulnerability Management Policy Template.

### Removal

Software removal involves uninstalling software from an enterprise asset or enterprise environment. Removal may be necessary if the software is now deemed unauthorized or is no longer necessary for the enterprise’s business functions or mission. Additionally, contracts with vendors may have ended, or software may simply have been superseded by another application. It’s often common to remove software and data from assets when sending a device back for warranty or repair. Removal can be completed manually or with the assistance of tooling. It is important to remember that components of the software may be located in different directories and folders.

### License Management

All software has a license associated with it. This may be a commercial, open source or an implicit free license. A software license states what can and cannot be done with the software, under what conditions it can be used or modified, for how long, any bounds surrounding distributing the software to others, and potentially more. Abiding to each license is best practice and often the law. Tracking user licenses, maintaining registration fees, complying with licensing terms, and most importantly, determining relevance for each license is a necessity. Most enterprises have a wide range of software and licenses in use every day. A license management system allows enterprises to have a clear view and understanding of the licenses and entitlements that they own, and how they are being used within their environment.

## Software Asset Management Policy Template

### Purpose

Software asset management is the process of procuring, identifying, tracking, maintaining, and removing software on enterprise assets. This Software Asset Management Policy provides the policies for governing the software asset lifecycle while an enterprise is using a software asset. A software inventory must be created and maintained to support the enterprise’s mission and to help ensure only authorized software is installed and used. This software inventory must be up-to-date and reflect the current state of software across the enterprise.

### Responsibility

The IT business unit is responsible for all software asset management functions. This information is relayed to other business units within the enterprise such as finance, accounting, and cybersecurity as needed. IT is responsible for informing all users of their responsibilities in the use of any assets assigned to them.

### Exceptions

Exceptions to this policy are likely to occur. Requests for exception must be made in writing and must contain:

- The reason for the request,

- Risk to the enterprise of not following the written policy,

- Specific mitigations that will not be implemented,

- Technical and other difficulties, and

- Date of review.

### Policy

#### Procurement

1. Only individuals from IT are approved to procure software.

1. IT must maintain a list of approved software vendors.

1. Software must only be purchased from vendors on the approved software list.

#### Installation

1. Any software installed on enterprise assets, alongside other relevant information within the software asset, must be recorded within the software inventory. This must include:

1. Title of software

1. Developer or publisher of software

1. Date of acquisition

1. Date of installation

1. Duration of usage

1. Business purpose

1. App Store(s)

1. Version(s)

1. Uniform Resource Locator (URL)

1. Deployment mechanism

1. End-of-support (EoS) date, if known

1. End-of-life (EoL) date, if known

1. Any relevant licensing information

1. Decommission date

1. IT must verify the software asset inventory every six months, or more frequently as needed.

1. Only software that has been approved by IT may be installed.

1. Only cloud services that have been approved by IT may be used within the enterprise.

1. Mobile devices may only obtain software from IT approved sources.

#### Usage

In general, refer to the enterprise’s Acceptable Use Policy. The following can substitute until an appropriate policy is created, or you may leverage the policy offered by the Center for Internet Security.

There are no IG1 safeguards that support this portion of the software asset management process.

#### Discovery

1. IT must review all software installed on enterprise assets on a monthly basis.

1. All installed software on enterprise assets must be reported to IT on a regular basis.

1. All newly discovered software must be checked against the list of approved software in the software asset inventory.

1. Identified software not included within this inventory must be investigated as the software may be unauthorized.

1. Assets containing unauthorized software must be removed from the network unless temporary access is granted by the IT business unit.

1. The presence of unauthorized software must be properly investigated.

1. All newly discovered (authorized) software must be added to the software inventory.

1. Unauthorized software must be removed from use on enterprise assets or receive a documented exception.

#### Update and Upgrade

- All updates and upgrades must be approved by IT prior to installation. IT configuring a device for automatic updates, or directing users to do so, constitutes a tacit approval.

#### Removal

1. Software to be decommissioned must be removed from all enterprise assets.

1. Assets containing retired software must be protected with additional defensive mitigations, such as removal from the network or isolation.

1. IT must make a copy of the user data as needed.

1. Ensure that any retired software did not store data in other servers or cloud infrastructure not owned by the enterprise.

## Revision History

Each time you update this document, this table should be updated.

| Version | Revision Date | Revision Description | Name |
| --- | --- | --- | --- |
|   |   |   |   |
|   |   |   |   |
|   |   |   |   |
|   |   |   |   |
|   |   |   |   |

## Appendix A: CIS Controls

The CIS Critical Security Controls® (CIS Controls®) are a prioritized set of actions which collectively form a defense-in-depth set of best practices that mitigate the most common attacks against systems and networks. They are developed by a community of information technology (IT) experts who apply their first-hand experience as cyber defenders to create these globally accepted security best practices. The experts who develop the CIS Controls come from a wide range of sectors, including retail, manufacturing, healthcare, education, government, defense, and others. It is important to note that while the CIS Controls address general best practices that enterprises should implement to protect their environment, some operational environments may present unique requirements not addressed by the CIS Controls or require deviations from best practices.

### Implementation Groups

The Implementation Group methodology was developed as a new way to prioritize the CIS Controls. These IGs provide a simple and accessible way to help enterprises of different classes focus their scarce security resources, while still leveraging the value of the CIS Controls program, community, and complementary tools and working aids. More about the Implementation Groups can be found in our Guide to Implementation Groups (IG): CIS Critical

Security Controls v8.1.

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
| COTS | Commercial-off-the-shelf |
| CSPs | Cloud Service Providers |
| EoL | End of Life |
| EoS | End of Support |
| IG | Implementation Group |
| IoT | Internet of Things |
| IT | Information Technology |
| MSPs | Managed service provider |
| URL | Uniform Resource Locator |

## Appendix C: Glossary

| Asset | Anything that has value to an organization, including, but not limited to, another organization, person, computing device, information technology (IT) system, IT network, IT circuit, software (both an installed instance and a physical instance), virtual computing platform (common in cloud and virtualized computing), and related hardware (e.g., locks, cabinets, keyboards). / Source: Asset(s) - Glossary \| CSRC (nist.gov) |
| --- | --- |
| Asset inventory | An asset inventory is a register, repository or comprehensive list of an enterprise’s assets and specific information about those assets. / Source: Asset Inventory \| FTA (dot.gov) |
| Asset owner | The department, business unit, or individual responsible for an enterprise asset. |
| Cloud environment | A virtualized environment that provides convenient, on-demand network access to a shared pool of configurable resources such as network, computing, storage, applications, and services. There are five essential characteristics to a cloud environment: on-demand self-service, broad network access, resource pooling, rapid elasticity, and measured service. Some services offered through cloud environments include Software as a Service (SaaS), Platform as a Service (PaaS), and Infrastructure as a Service (IaaS). |
| Enterprise assets | Assets with the potential to store or process data. For the purpose of this document, enterprise assets include end-user devices, network devices, non-computing/Internet of Things (IoT) devices, and servers, in virtual, cloud-based, and physical environments. |
| End-user devices | Information technology (IT) assets used among members of an enterprise during work or off-hours. End-user devices include desktops and workstations, as well as portable and mobile devices such as laptops, smartphones, and tablets. For the purpose of this document, end-user devices are a subset of enterprise assets. |
| Enterprise asset identifier | Often a sticker or tag with a unique number or alphanumeric string that can be tracked within an enterprise asset inventory. |
| Mobile end-user devices | Small, enterprise-issued end-user devices with intrinsic wireless capability, such as smartphones and tablets. For the purpose of this document, mobile devices are a subset of portable devices. |
| Network devices | Electronic devices required for communication and interaction between devices on a computer network. Network devices include wireless access points, firewalls, physical/virtual gateways, routers, and switches. These devices consist of physical hardware, as well as virtual and cloud-based devices. For the purpose of this document, network devices are a subset of enterprise assets. Note that network devices are listed under Enterprise Assets because they are managed much like other devices, however, they also play a dual role in the Network Asset Class when related to the communication over a network. |
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

## Appendix E: CIS Safeguards Mapping v8.1

CIS Controls & Safeguards Covered by this Policy

This policy helps to bolster IG1 Safeguards in CIS Control 2: Inventory and Control of Software Assets. The table below shows which IG1 Safeguards are covered by this policy.

| CIS Control | Policy Statement | CIS Safeguard | CIS Safeguard Description |
| --- | --- | --- | --- |
| 2.1 | Installation 1, 2, 3 Discovery 2c | Establish and Maintain a Software Inventory | Establish and maintain a detailed inventory of all licensed software installed on enterprise assets. The software inventory must document the title, publisher, initial install/use date, and business purpose for each entry; where appropriate, include the Uniform Resource Locator (URL), app store(s), version(s), deployment mechanism, decommission date, and number of licenses. Review and update the software inventory bi-annually, or more frequently. |
| 2.2 | Procurement 1, 2, 3 / Installation 3, 4, 5 / Update & Upgrade1 | Ensure Authorized Software is Currently Supported | Ensure that only currently supported software is designated as authorized in the software inventory for enterprise assets. If software is unsupported, yet necessary for the fulfillment of the enterprise’s mission, document an exception detailing mitigating controls and residual risk acceptance. For any unsupported software without an exception documentation, designate as unauthorized. Review the software list to verify software support at least monthly, or more frequently. |
| 2.3 | Discovery 1, 1a, 1b, 2, 2a, 2b / Removal 1, 2, 3 | Address Unauthorized Software | Ensure that unauthorized software is either removed from use on enterprise assets or receives a documented exception. Review monthly, or more frequently. |
