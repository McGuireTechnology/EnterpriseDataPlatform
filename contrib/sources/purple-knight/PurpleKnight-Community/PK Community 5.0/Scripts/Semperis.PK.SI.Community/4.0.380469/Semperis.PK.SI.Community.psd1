@{
    GUID = ''
    RootModule = 'Semperis.PK.SI.Community.psm1'
    ModuleVersion = '4.0.380469'
    RequiredModules = @(
        @{ ModuleName = "Semperis.SI.ChangesToAdminContextMenuPK"; RequiredVersion="1.290.0"; GUID="4483e0c7-5ebe-4ee6-8845-731b2a1f9e06" }
        @{ ModuleName = "Semperis.SI.ChangesToDomainOrDCPolicies"; RequiredVersion="1.240.0"; GUID="9094ccca-30b3-4add-bfbb-0836aa9f074e" }
        @{ ModuleName = "Semperis.SI.ZeroLogonPK"; RequiredVersion="1.310.0"; GUID="9c6bb8f6-7950-4d87-8e49-87fc89bf6ba6" }
        @{ ModuleName = "Semperis.SI.AAD_AllowedInstancePropertyLock"; RequiredVersion="1.290.0"; GUID="445677dc-509f-4cc2-809d-a2aa850e1d7f" }
        @{ ModuleName = "Semperis.SI.AAD_AllowUserConsentForRiskyApps"; RequiredVersion="1.290.0"; GUID="356e37ca-c8eb-4c3a-bdfc-1b6b6f142338" }
        @{ ModuleName = "Semperis.SI.AAD_ApplicationNameAndGeographicLocationMFA"; RequiredVersion="1.290.0"; GUID="bfdae692-a6bd-40c3-ac0d-17e9e1cd43a6" }
        @{ ModuleName = "Semperis.SI.AAD_CAEDisabled"; RequiredVersion="1.290.0"; GUID="adbb44d3-028b-4f24-bbdd-34dca7565400" }
        @{ ModuleName = "Semperis.SI.AAD_CBAPersistence"; RequiredVersion="1.290.0"; GUID="1ab76648-ae7d-4431-80a8-93437401b772" }
        @{ ModuleName = "Semperis.SI.AAD_CheckAdministrativeUnits"; RequiredVersion="1.290.0"; GUID="be5021e0-da08-4266-9c43-0b8010838af6" }
        @{ ModuleName = "Semperis.SI.AAD_CheckConditionalPrivateAddress"; RequiredVersion="1.290.0"; GUID="0fe1c7ee-8406-4362-84dc-aa71ba3a9508" }
        @{ ModuleName = "Semperis.SI.AAD_CheckGuestInvitePermission"; RequiredVersion="1.290.0"; GUID="87b41c04-d2bb-4de4-896d-212edeaf9e2e" }
        @{ ModuleName = "Semperis.SI.AAD_CheckInactivePrincipals"; RequiredVersion="1.312.0"; GUID="47bfb163-2e5d-42c8-9218-0b1e9609d0f6" }
        @{ ModuleName = "Semperis.SI.AAD_CheckLegacyAuthentication"; RequiredVersion="1.290.0"; GUID="cd191d30-9e68-4658-bec2-7d5c4c97c715" }
        @{ ModuleName = "Semperis.SI.AAD_CheckLegacyMFA"; RequiredVersion="1.290.0"; GUID="edeb01fd-375d-4046-9be4-c443d178872c" }
        @{ ModuleName = "Semperis.SI.AAD_CheckPrivigedGuests"; RequiredVersion="1.290.0"; GUID="5c8bd887-55ac-47d6-9835-6ed5370cda26" }
        @{ ModuleName = "Semperis.SI.AAD_CheckPrivilegedMFA"; RequiredVersion="1.319.0"; GUID="55019a5c-f4d1-4089-ac9e-5782400caced" }
        @{ ModuleName = "Semperis.SI.AAD_CheckRiskyRoles"; RequiredVersion="1.295.0"; GUID="a5a1346f-978b-4272-a90c-731b3a9b3da4" }
        @{ ModuleName = "Semperis.SI.AAD_CheckSecureMFA"; RequiredVersion="1.290.0"; GUID="831e6ae8-64da-4f0a-970d-7deaaae1d96f" }
        @{ ModuleName = "Semperis.SI.AAD_CheckSecurityDefaults"; RequiredVersion="1.290.0"; GUID="8fdabdf5-73e5-47c3-a70b-972f72a61b6f" }
        @{ ModuleName = "Semperis.SI.AAD_CheckSMTPMatch"; RequiredVersion="1.291.0"; GUID="326a11f8-0dbd-40a1-b3f2-0b4440981f99" }
        @{ ModuleName = "Semperis.SI.AAD_CheckUserConsent"; RequiredVersion="1.290.0"; GUID="8766ebb0-f5ef-4511-ad60-5f2c79f2dac4" }
        @{ ModuleName = "Semperis.SI.AAD_CustomBannedPasswordNotInUse"; RequiredVersion="1.290.0"; GUID="520293f5-38ff-4ee4-ba3e-3f374ebb76d7" }
        @{ ModuleName = "Semperis.SI.AAD_DisableAdminTokenPersistence"; RequiredVersion="1.290.0"; GUID="9a0da97a-9ae9-40f9-b7f3-dac25928cd3c" }
        @{ ModuleName = "Semperis.SI.AAD_ExpiredSecretsAndCertificates"; RequiredVersion="1.291.0"; GUID="804a13c6-46bf-4f00-96c7-dc3a1ca149c8" }
        @{ ModuleName = "Semperis.SI.AAD_FIDO2EnforceAttestation"; RequiredVersion="1.290.0"; GUID="40d6e492-e71f-48bf-99df-ce2f4c0267c4" }
        @{ ModuleName = "Semperis.SI.AAD_GetResetAADSyncUsers"; RequiredVersion="1.290.0"; GUID="4f964cc3-7ce9-4b44-b6d0-799622027adc" }
        @{ ModuleName = "Semperis.SI.AAD_GlobalAdministratorLastSignIn"; RequiredVersion="1.290.0"; GUID="ca3c2e9e-40bd-4090-868b-db2446fac627" }
        @{ ModuleName = "Semperis.SI.AAD_GuestUsersAreNotRestricted"; RequiredVersion="1.290.0"; GUID="7ecf71a0-20e0-4485-89e9-17b7e97095cf" }
        @{ ModuleName = "Semperis.SI.AAD_HiddenConsentGrant"; RequiredVersion="1.291.0"; GUID="a512f590-9e40-4c80-b448-ccb7086da504" }
        @{ ModuleName = "Semperis.SI.AAD_InactiveGuests"; RequiredVersion="1.290.0"; GUID="b7f86499-830c-445d-bca9-4d289fc8dc89" }
        @{ ModuleName = "Semperis.SI.AAD_LessThan2GAs"; RequiredVersion="1.290.0"; GUID="0ba04531-98ec-4cd3-a7fe-5bac5e99b454" }
        @{ ModuleName = "Semperis.SI.AAD_MFABombingOnPrivilegedAccounts"; RequiredVersion="1.317.0"; GUID="4e9faa14-dd01-4722-b1ed-dd7b5a2ecf45" }
        @{ ModuleName = "Semperis.SI.AAD_MFAGroupChange"; RequiredVersion="1.313.0"; GUID="fc2734ac-cb93-4673-b616-61df1e958ee4" }
        @{ ModuleName = "Semperis.SI.AAD_MoreThan10PrivilegedRoles"; RequiredVersion="1.290.0"; GUID="c687bf2a-e2b6-4a8e-8651-c0f7c79a4338" }
        @{ ModuleName = "Semperis.SI.AAD_MoreThan5GlobalAdministrators"; RequiredVersion="1.290.0"; GUID="62386a3a-9d27-4969-af4e-a3528763ba59" }
        @{ ModuleName = "Semperis.SI.AAD_PasswordHashSync"; RequiredVersion="1.290.0"; GUID="da8da200-a31e-4154-a84c-c20fc224cc8f" }
        @{ ModuleName = "Semperis.SI.AAD_PermanentActivePrivilegedRoleAssignment"; RequiredVersion="1.290.0"; GUID="4c280de7-6abd-4093-8773-277dbf166698" }
        @{ ModuleName = "Semperis.SI.AAD_privilegedAssociatedMailbox"; RequiredVersion="1.311.0"; GUID="dbc58c9d-2df6-49cc-a732-ba370486211e" }
        @{ ModuleName = "Semperis.SI.AAD_PrivilegedOnPremiseAndAAD"; RequiredVersion="1.290.0"; GUID="c117b6a5-00c8-4e77-93d2-e291e36b462a" }
        @{ ModuleName = "Semperis.SI.AAD_PrivilegedOnPremiseSyncedToAAD"; RequiredVersion="1.290.0"; GUID="5f6540a9-f226-4438-9e64-387a98beda2b" }
        @{ ModuleName = "Semperis.SI.AAD_ProhibitedPrivilegedRoles"; RequiredVersion="1.294.0"; GUID="e231380a-a77e-481f-ab03-6310b7b5cdfa" }
        @{ ModuleName = "Semperis.SI.AAD_RBCDOnSSOUser"; RequiredVersion="1.290.0"; GUID="3d6ff5b6-8d01-46b9-a261-7f5ab0c3b306" }
        @{ ModuleName = "Semperis.SI.AAD_ReportMFASuspiciousActivityIsEnabled"; RequiredVersion="1.290.0"; GUID="7b9dd975-4b16-4fce-8e5f-41b36e7dc816" }
        @{ ModuleName = "Semperis.SI.AAD_RequireMFAOnPrivilegedAccounts"; RequiredVersion="1.313.0"; GUID="22739cb9-e1f1-4789-88b4-b7c6c3c9cc0f" }
        @{ ModuleName = "Semperis.SI.AAD_RequireMFAOnRiskySignIns"; RequiredVersion="1.313.0"; GUID="84a90bda-81bf-4aa3-96e9-75a2fe0409ac" }
        @{ ModuleName = "Semperis.SI.AAD_RequirePasswordChangeHighRiskUser"; RequiredVersion="1.290.0"; GUID="390441db-53ba-4367-99e8-e8950ff8bb77" }
        @{ ModuleName = "Semperis.SI.AAD_RiskyCustomRolesPermissions"; RequiredVersion="1.290.0"; GUID="d80e37b8-8d8a-4964-88ac-5c51af1b0f3b" }
        @{ ModuleName = "Semperis.SI.AAD_RiskyUsers"; RequiredVersion="1.290.0"; GUID="931ddace-2ed0-4f70-998d-04e213e03f71" }
        @{ ModuleName = "Semperis.SI.AAD_SecurityQuestionInUse"; RequiredVersion="1.290.0"; GUID="16503719-3c1a-4766-830c-7aa4133652ee" }
        @{ ModuleName = "Semperis.SI.AAD_SSOConfiguredWithSAML"; RequiredVersion="1.290.0"; GUID="746e2299-10c9-4610-868d-349db02aa65d" }
        @{ ModuleName = "Semperis.SI.AAD_SSOOldPwdLastSet"; RequiredVersion="1.300.0"; GUID="86e00792-a38f-409b-bd74-76e7ceecb93e" }
        @{ ModuleName = "Semperis.SI.AAD_SSPRForAdmins"; RequiredVersion="1.290.0"; GUID="0cf1fcb7-9867-4f09-8644-49daaf2eb228" }
        @{ ModuleName = "Semperis.SI.AAD_StaleGuestsInvites"; RequiredVersion="1.290.0"; GUID="4c4029ed-2fdd-46c8-8d96-eebefd2d9799" }
        @{ ModuleName = "Semperis.SI.AAD_SuspiciousDirectorySynchronizationAccountRoleMember"; RequiredVersion="1.291.0"; GUID="0e9a08c9-9d01-4c87-9c01-5bad3b23a2dd" }
        @{ ModuleName = "Semperis.SI.AAD_UnprivilegedGroupOwner"; RequiredVersion="1.291.0"; GUID="36e3878e-e65c-47a1-a9b8-0444ce978683" }
        @{ ModuleName = "Semperis.SI.AAD_UnusedEligibleRole"; RequiredVersion="1.291.0"; GUID="7933368e-a218-4fdb-9f99-83882c677201" }
        @{ ModuleName = "Semperis.SI.AAD_UsersCanCreateSecurityGroups"; RequiredVersion="1.290.0"; GUID="7b1b04d3-216b-4031-9657-679443ab3c51" }
        @{ ModuleName = "Semperis.SI.AAD_UsersCanCreateTenants"; RequiredVersion="1.291.0"; GUID="1a1a74a5-c9a3-44ad-b4c2-9de7c8a10043" }
        @{ ModuleName = "Semperis.SI.AAD_UsersCanRegisterApplications"; RequiredVersion="1.290.0"; GUID="549cb64c-1995-47bf-98ac-6456e7f5662e" }
        @{ ModuleName = "Semperis.SI.AAD_UsersCapableMFA"; RequiredVersion="1.291.0"; GUID="128f2108-090d-4291-9c01-0cc98e61d12c" }
        @{ ModuleName = "Semperis.SI.AbnormalPasswordRefresh"; RequiredVersion="1.240.0"; GUID="f6c64dcf-bbcc-453e-a122-a81e998fe1af" }
        @{ ModuleName = "Semperis.SI.AccountsInCertPublishers"; RequiredVersion="1.240.0"; GUID="c4a19ff8-3bfd-46f9-b215-2b6c0179b0aa" }
        @{ ModuleName = "Semperis.SI.AdminPWNotChanged"; RequiredVersion="1.300.0"; GUID="82901792-3b6e-4b3f-94d7-64d4743273fb" }
        @{ ModuleName = "Semperis.SI.AdminSDHolderInheritance"; RequiredVersion="1.290.0"; GUID="216596bf-333e-4f59-a3f5-8af65acbba9b" }
        @{ ModuleName = "Semperis.SI.AdminSDHolderPermissionChange"; RequiredVersion="1.316.0"; GUID="39293315-4817-44f6-be2d-e76daeaf8208" }
        @{ ModuleName = "Semperis.SI.AdminUsedRecently"; RequiredVersion="1.240.0"; GUID="2c2b46b6-3bce-451c-bbc8-7c7652fecbf0" }
        @{ ModuleName = "Semperis.SI.altSecurityIdentitiesConfigured"; RequiredVersion="1.314.0"; GUID="59551a78-1f84-42fe-ad13-d38413d1c882" }
        @{ ModuleName = "Semperis.SI.AnonAccessonAD"; RequiredVersion="1.300.0"; GUID="79d857a6-23a7-421d-a63d-5a2f9df5d080" }
        @{ ModuleName = "Semperis.SI.AnonNSPIAccess"; RequiredVersion="1.300.0"; GUID="aace861d-9d2c-47df-9d3a-eb8f07008abb" }
        @{ ModuleName = "Semperis.SI.CertificatesNTAuthPermissions"; RequiredVersion="1.300.0"; GUID="e441aeb0-ba69-426b-bbc1-028bf258c3d8" }
        @{ ModuleName = "Semperis.SI.CertificateTemplatesAreVulnerable"; RequiredVersion="1.300.0"; GUID="d64cab17-754c-4643-872b-a9113fbb7808" }
        @{ ModuleName = "Semperis.SI.CertificateTemplatesPermissions"; RequiredVersion="1.300.0"; GUID="a76ea884-afef-4d00-9820-b24117a12661" }
        @{ ModuleName = "Semperis.SI.CertificateTemplatesWithSANAllowed"; RequiredVersion="1.300.0"; GUID="790e1c72-5786-4907-83cd-9f310db70f1b" }
        @{ ModuleName = "Semperis.SI.ChangesToDefaultSD"; RequiredVersion="1.290.0"; GUID="8c2e4eda-216e-47c5-89ea-a45a870f782b" }
        @{ ModuleName = "Semperis.SI.CompObsoleteOS"; RequiredVersion="1.290.0"; GUID="a0d33c5f-fda5-4a06-9b80-5196e099131e" }
        @{ ModuleName = "Semperis.SI.CompOldPwdLastSet"; RequiredVersion="1.300.0"; GUID="07362c0e-e675-4451-9d09-65ca46ab43a3" }
        @{ ModuleName = "Semperis.SI.CompOldPwdLastSetDC"; RequiredVersion="1.300.0"; GUID="bd287262-50dd-4e99-9daa-7754eb27cddb" }
        @{ ModuleName = "Semperis.SI.ComputersInPrivilegedGroup"; RequiredVersion="1.240.0"; GUID="113f7039-879b-4093-a42b-dce6b47b313c" }
        @{ ModuleName = "Semperis.SI.ComputerUserWithSPNUnconstrainedDelegation"; RequiredVersion="1.300.0"; GUID="5d5d5b9c-5685-4786-b3a4-eb2ab1480a69" }
        @{ ModuleName = "Semperis.SI.ConstrainedDelegationToKRBTGT"; RequiredVersion="1.300.0"; GUID="cfe3bfa1-f28e-4017-8e94-044bd6b914e3" }
        @{ ModuleName = "Semperis.SI.DangerousTrustAttributeSet"; RequiredVersion="1.300.0"; GUID="ffa8305f-ff2e-4196-b980-8d7cafce849d" }
        @{ ModuleName = "Semperis.SI.DCPrintSpooler"; RequiredVersion="1.310.0"; GUID="33ed032b-3cab-4105-b4f6-5477cb3c9aa1" }
        @{ ModuleName = "Semperis.SI.DCShadowInUse"; RequiredVersion="1.290.0"; GUID="fa5662bf-8e17-42c3-a998-3d252f73b505" }
        @{ ModuleName = "Semperis.SI.DelegateToGhostSPN"; RequiredVersion="1.300.0"; GUID="55f8f10b-deef-4f24-8567-1da71161340c" }
        @{ ModuleName = "Semperis.SI.DisabledPrivilegedUsers"; RequiredVersion="1.240.0"; GUID="87081486-fc4f-4027-842e-c5f17ec4f1bf" }
        @{ ModuleName = "Semperis.SI.DMSABadSuccessor"; RequiredVersion="1.309.0"; GUID="5e0a22b9-2da5-4fde-9de6-e3a77961d6e6" }
        @{ ModuleName = "Semperis.SI.DnsZonesWithUnsecureUpdate"; RequiredVersion="1.310.0"; GUID="3a1e0f73-4c81-4192-87f7-38465dd18ce0" }
        @{ ModuleName = "Semperis.SI.DomainControllerInconsistent"; RequiredVersion="1.300.0"; GUID="fce4fe73-2676-4c3c-bf7e-97529ca7d118" }
        @{ ModuleName = "Semperis.SI.DomainControllerOwnerPermissions"; RequiredVersion="1.300.0"; GUID="d2df85d9-abbc-4585-be11-123a6d90a871" }
        @{ ModuleName = "Semperis.SI.DomainObsoleteFunctionalLevel"; RequiredVersion="1.300.0"; GUID="ff50af43-c9c8-41c6-987f-eaaaedbca25c" }
        @{ ModuleName = "Semperis.SI.DPAPIKeysPermissions"; RequiredVersion="1.310.0"; GUID="4d30c9d8-375e-48cc-8244-0073107f29a4" }
        @{ ModuleName = "Semperis.SI.DwAdminSDExMaskSet"; RequiredVersion="1.300.0"; GUID="f2f975fd-6ce2-491b-8247-9662a0126187" }
        @{ ModuleName = "Semperis.SI.EID_SuspiciousMSSPCreds"; RequiredVersion="1.290.0"; GUID="9eccc815-24b8-48d9-b86b-c9a5c12b66ef" }
        @{ ModuleName = "Semperis.SI.EID_UnresolvedPrivilegedUsers"; RequiredVersion="1.291.0"; GUID="5e9faa14-dd01-4722-b1ed-dd7b5a2ecf46" }
        @{ ModuleName = "Semperis.SI.EnabledAdminsNotInUse"; RequiredVersion="1.300.0"; GUID="750c9233-57b3-430c-af56-1e899e81b202" }
        @{ ModuleName = "Semperis.SI.EnterpriseCAs"; RequiredVersion="1.291.0"; GUID="08612871-a9dc-4d18-a2cc-580e086e3199" }
        @{ ModuleName = "Semperis.SI.EnterpriseKeyAdminsFullControl"; RequiredVersion="1.300.0"; GUID="ec4a80dc-bec8-4557-b19f-cc3d15ed5517" }
        @{ ModuleName = "Semperis.SI.EphemeralAdmins"; RequiredVersion="1.270.0"; GUID="070e7b62-4784-4ca5-bdaa-82da2972e23a" }
        @{ ModuleName = "Semperis.SI.ExpirePasswordOnSmartCard"; RequiredVersion="1.300.0"; GUID="04ad3f4e-b67c-49c3-a668-528214dd6c63" }
        @{ ModuleName = "Semperis.SI.FGPPNotAppliedToAGroup"; RequiredVersion="1.290.0"; GUID="88725ad5-1a8c-43f7-a11f-a52b6eb3b601" }
        @{ ModuleName = "Semperis.SI.FSPInPrivilegedGroup"; RequiredVersion="1.290.0"; GUID="3bcaff82-ae70-4646-bc66-f7997be54e5e" }
        @{ ModuleName = "Semperis.SI.GMSANotInUse"; RequiredVersion="1.290.0"; GUID="93402830-3bdf-4086-8629-7bdc654651f9" }
        @{ ModuleName = "Semperis.SI.GMSAOldPwdLastSet"; RequiredVersion="1.240.0"; GUID="a7813b26-5472-4fbd-a6a4-1c93bfeb2784" }
        @{ ModuleName = "Semperis.SI.GMSAPasswordPermissions"; RequiredVersion="1.300.0"; GUID="5962cacc-495f-4487-9770-2a87ee8fc50a" }
        @{ ModuleName = "Semperis.SI.GPOBadShortcut"; RequiredVersion="1.301.0"; GUID="cfe6f680-8137-4690-8116-80aa3d4b9d52" }
        @{ ModuleName = "Semperis.SI.GPOLogonScripts"; RequiredVersion="1.240.0"; GUID="e999201f-84ab-4893-a207-8aac7f09df3f" }
        @{ ModuleName = "Semperis.SI.GPOScheduledTasks"; RequiredVersion="1.290.0"; GUID="20cacac3-f001-41ca-8a96-3dd02e429f37" }
        @{ ModuleName = "Semperis.SI.GPOUserRights"; RequiredVersion="1.310.0"; GUID="30a7fbd4-8ea3-42b2-b29d-41d27023c06a" }
        @{ ModuleName = "Semperis.SI.GPOWeakLMHashStorageEnabled"; RequiredVersion="1.290.0"; GUID="49368362-a307-4d9a-91b5-56eac7be35c5" }
        @{ ModuleName = "Semperis.SI.GPPrefPasswords"; RequiredVersion="1.240.0"; GUID="1d22bc08-5152-4e07-badf-3d0c15e5ecd9" }
        @{ ModuleName = "Semperis.SI.GuestAccountEnabled"; RequiredVersion="1.300.0"; GUID="d14af45f-009c-4840-8e35-36a97c979a8c" }
        @{ ModuleName = "Semperis.SI.InactiveDCs"; RequiredVersion="1.300.0"; GUID="1b6df9e8-e5ed-45f7-880c-44b4a9a7d6bd" }
        @{ ModuleName = "Semperis.SI.InstallReplicaPermissions"; RequiredVersion="1.270.0"; GUID="a5174a20-4a4d-480c-99e3-da8017a10450" }
        @{ ModuleName = "Semperis.SI.KerberosGoldenTicket"; RequiredVersion="1.300.0"; GUID="1e43868c-9a46-41e8-8daf-d8bfe57aaef7" }
        @{ ModuleName = "Semperis.SI.LapsSearchFlagsNonDefault"; RequiredVersion="1.219.0"; GUID="9ff5d86a-7523-423d-b657-ec28b36c904d" }
        @{ ModuleName = "Semperis.SI.LdapDenyList"; RequiredVersion="1.290.0"; GUID="9e2e34e4-a367-40a7-b8ea-f4b32e99d74f" }
        @{ ModuleName = "Semperis.SI.LdapSigningIsNotRequired"; RequiredVersion="1.310.0"; GUID="4fe825ed-07fb-4b06-913a-be5c9542ca54" }
        @{ ModuleName = "Semperis.SI.ManyAdministratorsInForest"; RequiredVersion="1.300.0"; GUID="9c9bfa49-9431-4043-a073-0f90f3008b54" }
        @{ ModuleName = "Semperis.SI.NewObjects"; RequiredVersion="1.290.0"; GUID="b3061191-07e0-468f-b2a0-bbf0485fa900" }
        @{ ModuleName = "Semperis.SI.NewPrivilegedUsers"; RequiredVersion="1.290.0"; GUID="c4218bf3-aca4-4d17-90a3-9ba3f4ec42e7" }
        @{ ModuleName = "Semperis.SI.NonEmptyDcomAndPerformanceLogGroups"; RequiredVersion="1.290.0"; GUID="0e61db1b-b877-457e-9550-607330143d92" }
        @{ ModuleName = "Semperis.SI.NonPrivilegedObjectsWithAdminCount"; RequiredVersion="1.240.0"; GUID="e08bbf6a-b17e-4417-a9cd-8f4b7b6210f9" }
        @{ ModuleName = "Semperis.SI.NonStandardPGID"; RequiredVersion="1.315.0"; GUID="16262280-22e2-40e2-a227-9934e63dadaa" }
        @{ ModuleName = "Semperis.SI.NonStandardSchemaPermissions"; RequiredVersion="1.301.0"; GUID="96995af9-8efb-46d4-b0f3-dfcfac74aaae" }
        @{ ModuleName = "Semperis.SI.NoPGID"; RequiredVersion="1.240.0"; GUID="f7659564-5968-4ea6-acb2-ce5abd47d8f6" }
        @{ ModuleName = "Semperis.SI.NTFRSSysvolReplication"; RequiredVersion="1.300.0"; GUID="ef678af3-8766-45f0-b4f7-7c3582bfea1a" }
        @{ ModuleName = "Semperis.SI.ObjectsCanReanimateTombstones"; RequiredVersion="1.318.0"; GUID="1a220cc3-cadb-4960-840d-37cf7b07e940" }
        @{ ModuleName = "Semperis.SI.ObjectsInPrivilegedGroupWithoutAdmincount"; RequiredVersion="1.290.0"; GUID="b5df966a-2202-401e-8c0c-0e212d7f666d" }
        @{ ModuleName = "Semperis.SI.ObjectsWithConstrainedDelegation"; RequiredVersion="1.290.0"; GUID="b332f034-f6b9-4bc2-8796-6ea044db909f" }
        @{ ModuleName = "Semperis.SI.ObjectsWithConstrainedDelegationDC"; RequiredVersion="1.290.0"; GUID="275b22b7-6386-46b8-a1bd-3f14965bf643" }
        @{ ModuleName = "Semperis.SI.ObjectsWithLapsRead"; RequiredVersion="1.290.0"; GUID="9f532969-6a43-40a5-9035-f4f2e9cf9e88" }
        @{ ModuleName = "Semperis.SI.ObjectsWithProtocolTranistion"; RequiredVersion="1.240.0"; GUID="74851f54-7ed4-456a-95c3-05e6090a9538" }
        @{ ModuleName = "Semperis.SI.ObjectsWithProtocolTransitionDC"; RequiredVersion="1.300.0"; GUID="31dcc5f6-ceb0-4132-a698-95bae64fe7df" }
        @{ ModuleName = "Semperis.SI.Okta_CustomRolesCreds"; RequiredVersion="1.290.0"; GUID="9f09273e-cbef-43c0-877f-020ad9503089" }
        @{ ModuleName = "Semperis.SI.OKTA_NewAdminGroup"; RequiredVersion="1.219.0"; GUID="4cc1d625-2fa7-40e0-bbc3-09cac81ecd2d" }
        @{ ModuleName = "Semperis.SI.OKTA_NewAdminUser"; RequiredVersion="1.219.0"; GUID="21a15341-8d4e-47d7-a5e5-af541f4fe0b9" }
        @{ ModuleName = "Semperis.SI.OKTA_NewAppAccessToken"; RequiredVersion="1.219.0"; GUID="fce1590d-01ea-4c23-a653-7d4d395ae36a" }
        @{ ModuleName = "Semperis.SI.OKTA_NewSuperadminGroup"; RequiredVersion="1.219.0"; GUID="74e7dd15-b715-4926-bb7e-71c12d3ced5a" }
        @{ ModuleName = "Semperis.SI.OKTA_NewSuperadminUser"; RequiredVersion="1.219.0"; GUID="4e25afc3-f7e1-4c1f-b092-eb7287c0f2d1" }
        @{ ModuleName = "Semperis.SI.OKTA_PasswordPolicyBestPractice"; RequiredVersion="1.290.0"; GUID="a4a97716-bca9-498e-844b-eef6ac402efa" }
        @{ ModuleName = "Semperis.SI.OKTA_UserActivate"; RequiredVersion="1.219.0"; GUID="ad1b3358-d94e-4e3d-abdc-5cf49a7b784f" }
        @{ ModuleName = "Semperis.SI.OKTA_UserDeactivate"; RequiredVersion="1.219.0"; GUID="9db6aed0-726a-4384-9d31-3cc64c9dbb76" }
        @{ ModuleName = "Semperis.SI.OKTA_UsersWithoutMFA"; RequiredVersion="1.219.0"; GUID="6e11c380-dd30-4407-88f8-c3f1037b292c" }
        @{ ModuleName = "Semperis.SI.OldPwdLastSet"; RequiredVersion="1.290.0"; GUID="4ef13866-3af9-477a-84d4-d2d7e39f3c0f" }
        @{ ModuleName = "Semperis.SI.OldPwdLastSetAdmin"; RequiredVersion="1.300.0"; GUID="dc8f6889-7df9-4414-9bf5-865f1e3e9e83" }
        @{ ModuleName = "Semperis.SI.OperatorsGroupsAreNotEmpty"; RequiredVersion="1.290.0"; GUID="681db401-004b-4cec-a4b8-07926a63e281" }
        @{ ModuleName = "Semperis.SI.OutboundForestTrustWithSIDHistory"; RequiredVersion="1.300.0"; GUID="13b327cf-1283-4362-8815-6c1acb24f4de" }
        @{ ModuleName = "Semperis.SI.OutboundTrustWithoutQuarantine"; RequiredVersion="1.300.0"; GUID="19a4b814-3561-4463-a083-2769fabf1490" }
        @{ ModuleName = "Semperis.SI.PreWin2KGroup"; RequiredVersion="1.290.0"; GUID="c0c929cf-ab95-4d8f-975b-8193054f520b" }
        @{ ModuleName = "Semperis.SI.PrimaryUsersWithSPN"; RequiredVersion="1.290.0"; GUID="868c36af-b784-465b-a15c-291bd3c66d47" }
        @{ ModuleName = "Semperis.SI.PrimaryUsersWithSPNNotSupportingAES"; RequiredVersion="1.300.0"; GUID="b608276e-3849-419d-bc34-6e5a362b3e79" }
        @{ ModuleName = "Semperis.SI.PrivilegedGroupChanges"; RequiredVersion="1.240.0"; GUID="3abeddaa-cdc0-4357-8834-3662c68cf073" }
        @{ ModuleName = "Semperis.SI.PrivilegedSPN"; RequiredVersion="1.300.0"; GUID="34d7d270-3b7b-4a0e-b0c4-15e8e2551c31" }
        @{ ModuleName = "Semperis.SI.PrivilegedUsersWeakPasswordPolicy"; RequiredVersion="1.300.0"; GUID="22388d19-f301-46bf-9503-4562a03f12fb" }
        @{ ModuleName = "Semperis.SI.ProtectedUsersNotUsed"; RequiredVersion="1.300.0"; GUID="b4ee6e7c-5b7c-4e63-82cd-668d3d0b3354" }
        @{ ModuleName = "Semperis.SI.RBCD"; RequiredVersion="1.240.0"; GUID="88040bb0-ce23-48a8-850f-277edaafbac7" }
        @{ ModuleName = "Semperis.SI.RBCDOnDC"; RequiredVersion="1.300.0"; GUID="6df6c2ee-a77b-411b-8540-4357e5d0a1fb" }
        @{ ModuleName = "Semperis.SI.RBCDOnkrbtgt"; RequiredVersion="1.300.0"; GUID="3aaa510c-74ef-404e-a5e8-03ddbc89e4c7" }
        @{ ModuleName = "Semperis.SI.RBCDWriteOnDC"; RequiredVersion="1.240.0"; GUID="af90ba77-f497-479a-aa57-ed106191e302" }
        @{ ModuleName = "Semperis.SI.RBCDWriteOnkrbtgt"; RequiredVersion="1.240.0"; GUID="eb99e786-3ce1-4172-9801-dd4203cfd3e2" }
        @{ ModuleName = "Semperis.SI.RC4EnabledOnDC"; RequiredVersion="1.300.0"; GUID="f8af8921-8901-466e-ba91-df970a56cc21" }
        @{ ModuleName = "Semperis.SI.RecentSIDHistoryChanges"; RequiredVersion="1.300.0"; GUID="7f12a52e-87a4-40c3-8e80-431934743207" }
        @{ ModuleName = "Semperis.SI.ReplicationPermissions"; RequiredVersion="1.300.0"; GUID="bcb85336-3507-4565-91a2-9c1360c5a5f1" }
        @{ ModuleName = "Semperis.SI.RiskyRODCCreds"; RequiredVersion="1.300.0"; GUID="f84225d1-4f05-4cb1-bf3f-f87413006214" }
        @{ ModuleName = "Semperis.SI.RODCPrivilegedCreds"; RequiredVersion="1.291.0"; GUID="5442096e-aee4-4fea-ab7d-a121ea528742" }
        @{ ModuleName = "Semperis.SI.ShadowCredentials"; RequiredVersion="1.322.0"; GUID="d6456fa7-456b-4cde-a8ef-9de5903d0419" }
        @{ ModuleName = "Semperis.SI.SIDHistoryPrivilegedSID"; RequiredVersion="1.300.0"; GUID="78a9064a-f3a0-4420-ab9d-2db003d6f4b4" }
        @{ ModuleName = "Semperis.SI.SmartCardUserPasswordNotChange"; RequiredVersion="1.291.0"; GUID="baeb89cc-e32d-4f17-ad37-29a6a45ff724" }
        @{ ModuleName = "Semperis.SI.SmbSigningIsNotRequired"; RequiredVersion="1.310.0"; GUID="0d9236c4-98a1-4763-913b-783fdfe1de4c" }
        @{ ModuleName = "Semperis.SI.SMBv1EnabledOnDCs"; RequiredVersion="1.310.0"; GUID="66ee675e-4b5d-47a9-a364-a4477c1e73e5" }
        @{ ModuleName = "Semperis.SI.SYSVOLExecutableChanges"; RequiredVersion="1.240.0"; GUID="9e036f83-4eba-48e8-9a5c-a399377ee6a1" }
        @{ ModuleName = "Semperis.SI.TrustPwdLastSet"; RequiredVersion="1.300.0"; GUID="4eab7c02-aae3-4b4c-ba3b-d08977ce7c18" }
        @{ ModuleName = "Semperis.SI.UnprivilegedDNSAdmin"; RequiredVersion="1.300.0"; GUID="e79191aa-b68f-4983-8420-b2ca25bca6ea" }
        @{ ModuleName = "Semperis.SI.UnprivilegedOwner"; RequiredVersion="1.300.0"; GUID="40499bf5-9087-4d55-9db3-2cb641a47ac8" }
        @{ ModuleName = "Semperis.SI.UserPasswordAttributeIsSet"; RequiredVersion="1.291.0"; GUID="dfa45647-c2b5-4066-b7db-3a8890868cef" }
        @{ ModuleName = "Semperis.SI.UsersCanAddComputers"; RequiredVersion="1.300.0"; GUID="6317479a-c7df-49ca-bbf1-47ecdf199792" }
        @{ ModuleName = "Semperis.SI.UsersDESPWD"; RequiredVersion="1.300.0"; GUID="ca67406b-a063-4aba-ba61-261be7f9ee96" }
        @{ ModuleName = "Semperis.SI.UsersPwdNeverExpires"; RequiredVersion="1.300.0"; GUID="3653043f-2790-4255-a625-3359e6dc8ef6" }
        @{ ModuleName = "Semperis.SI.UsersPwdNeverExpiresAdmin"; RequiredVersion="1.300.0"; GUID="755d0eba-b8dc-4216-a9d4-44ab43bfb7b5" }
        @{ ModuleName = "Semperis.SI.UsersPWDNotReq"; RequiredVersion="1.291.0"; GUID="32c2a92b-fe99-4e5c-bfbb-7497b759946d" }
        @{ ModuleName = "Semperis.SI.UsersReversiblePWD"; RequiredVersion="1.300.0"; GUID="2c62cbf1-ebdb-4ac4-9c5c-6507a15fd9e2" }
        @{ ModuleName = "Semperis.SI.UsersWithPreAuth"; RequiredVersion="1.300.0"; GUID="ad0f14a9-580c-4709-b8d2-c1be16b22a3e" }
        @{ ModuleName = "Semperis.SI.WeakCertificateCipher"; RequiredVersion="1.300.0"; GUID="966491f1-e550-48ae-aae5-2fc1b0ae4a60" }
        @{ ModuleName = "Semperis.SI.WeakGPOLinkingADSite"; RequiredVersion="1.300.0"; GUID="eab117be-3114-494c-b3d8-dbdecaf9a050" }
        @{ ModuleName = "Semperis.SI.WeakGPOLinkingOnDCOU"; RequiredVersion="1.300.0"; GUID="154c93b1-02fc-435b-88b4-a5e3b0467f85" }
        @{ ModuleName = "Semperis.SI.WeakGPOLinkingOnDomain"; RequiredVersion="1.300.0"; GUID="2cfda02d-2ac4-4d4d-bc9c-bff9c51024d0" }
    )
    Description = 'Aggregates a group of security indicators for PK'

    Author = 'Semperis'
    CompanyName = 'Semperis Inc.'
    Copyright = '© 2022 Semperis Inc.'

    FunctionsToExport = @(
        'Get-SecurityIndicator'
        'Invoke-SecurityIndicator'
    )
    AliasesToExport = @(
        'List-SecurityIndicator'
        'lsi'
    )
}

# SIG # Begin signature block
# MIIuIwYJKoZIhvcNAQcCoIIuFDCCLhACAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDLgoHlWfYp3q/7
# +93k4RfP3Nzgo6D5FJaL0MVJPGVWrqCCE6MwggVyMIIDWqADAgECAhB2U/6sdUZI
# k/Xl10pIOk74MA0GCSqGSIb3DQEBDAUAMFMxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSkwJwYDVQQDEyBHbG9iYWxTaWduIENvZGUgU2ln
# bmluZyBSb290IFI0NTAeFw0yMDAzMTgwMDAwMDBaFw00NTAzMTgwMDAwMDBaMFMx
# CzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMSkwJwYDVQQD
# EyBHbG9iYWxTaWduIENvZGUgU2lnbmluZyBSb290IFI0NTCCAiIwDQYJKoZIhvcN
# AQEBBQADggIPADCCAgoCggIBALYtxTDdeuirkD0DcrA6S5kWYbLl/6VnHTcc5X7s
# k4OqhPWjQ5uYRYq4Y1ddmwCIBCXp+GiSS4LYS8lKA/Oof2qPimEnvaFE0P31PyLC
# o0+RjbMFsiiCkV37WYgFC5cGwpj4LKczJO5QOkHM8KCwex1N0qhYOJbp3/kbkbuL
# ECzSx0Mdogl0oYCve+YzCgxZa4689Ktal3t/rlX7hPCA/oRM1+K6vcR1oW+9YRB0
# RLKYB+J0q/9o3GwmPukf5eAEh60w0wyNA3xVuBZwXCR4ICXrZ2eIq7pONJhrcBHe
# OMrUvqHAnOHfHgIB2DvhZ0OEts/8dLcvhKO/ugk3PWdssUVcGWGrQYP1rB3rdw1G
# R3POv72Vle2dK4gQ/vpY6KdX4bPPqFrpByWbEsSegHI9k9yMlN87ROYmgPzSwwPw
# jAzSRdYu54+YnuYE7kJuZ35CFnFi5wT5YMZkobacgSFOK8ZtaJSGxpl0c2cxepHy
# 1Ix5bnymu35Gb03FhRIrz5oiRAiohTfOB2FXBhcSJMDEMXOhmDVXR34QOkXZLaRR
# kJipoAc3xGUaqhxrFnf3p5fsPxkwmW8x++pAsufSxPrJ0PBQdnRZ+o1tFzK++Ol+
# A/Tnh3Wa1EqRLIUDEwIrQoDyiWo2z8hMoM6e+MuNrRan097VmxinxpI68YJj8S4O
# JGTfAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB0G
# A1UdDgQWBBQfAL9GgAr8eDm3pbRD2VZQu86WOzANBgkqhkiG9w0BAQwFAAOCAgEA
# Xiu6dJc0RF92SChAhJPuAW7pobPWgCXme+S8CZE9D/x2rdfUMCC7j2DQkdYc8pzv
# eBorlDICwSSWUlIC0PPR/PKbOW6Z4R+OQ0F9mh5byV2ahPwm5ofzdHImraQb2T07
# alKgPAkeLx57szO0Rcf3rLGvk2Ctdq64shV464Nq6//bRqsk5e4C+pAfWcAvXda3
# XaRcELdyU/hBTsz6eBolSsr+hWJDYcO0N6qB0vTWOg+9jVl+MEfeK2vnIVAzX9Rn
# m9S4Z588J5kD/4VDjnMSyiDN6GHVsWbcF9Y5bQ/bzyM3oYKJThxrP9agzaoHnT5C
# JqrXDO76R78aUn7RdYHTyYpiF21PiKAhoCY+r23ZYjAf6Zgorm6N1Y5McmaTgI0q
# 41XHYGeQQlZcIlEPs9xOOe5N3dkdeBBUO27Ql28DtR6yI3PGErKaZND8lYUkqP/f
# obDckUCu3wkzq7ndkrfxzJF0O2nrZ5cbkL/nx6BvcbtXv7ePWu16QGoWzYCELS/h
# AtQklEOzFfwMKxv9cW/8y7x1Fzpeg9LJsy8b1ZyNf1T+fn7kVqOHp53hWVKUQY9t
# W76GlZr/GnbdQNJRSnC0HzNjI3c/7CceWeQIh+00gkoPP/6gHcH1Z3NFhnj0qinp
# J4fGGdvGExTDOUmHTaCX4GUT9Z13Vunas1jHOvLAzYIwggbmMIIEzqADAgECAhB3
# vQ4DobcI+FSrBnIQ2QRHMA0GCSqGSIb3DQEBCwUAMFMxCzAJBgNVBAYTAkJFMRkw
# FwYDVQQKExBHbG9iYWxTaWduIG52LXNhMSkwJwYDVQQDEyBHbG9iYWxTaWduIENv
# ZGUgU2lnbmluZyBSb290IFI0NTAeFw0yMDA3MjgwMDAwMDBaFw0zMDA3MjgwMDAw
# MDBaMFkxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMS8w
# LQYDVQQDEyZHbG9iYWxTaWduIEdDQyBSNDUgQ29kZVNpZ25pbmcgQ0EgMjAyMDCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBANZCTfnjT8Yj9GwdgaYw90g9
# z9DljeUgIpYHRDVdBs8PHXBg5iZU+lMjYAKoXwIC947Jbj2peAW9jvVPGSSZfM8R
# Fpsfe2vSo3toZXer2LEsP9NyBjJcW6xQZywlTVYGNvzBYkx9fYYWlZpdVLpQ0LB/
# okQZ6dZubD4Twp8R1F80W1FoMWMK+FvQ3rpZXzGviWg4QD4I6FNnTmO2IY7v3Y2F
# QVWeHLw33JWgxHGnHxulSW4KIFl+iaNYFZcAJWnf3sJqUGVOU/troZ8YHooOX1Re
# veBbz/IMBNLeCKEQJvey83ouwo6WwT/Opdr0WSiMN2WhMZYLjqR2dxVJhGaCJedD
# CndSsZlRQv+hst2c0twY2cGGqUAdQZdihryo/6LHYxcG/WZ6NpQBIIl4H5D0e6lS
# TmpPVAYqgK+ex1BC+mUK4wH0sW6sDqjjgRmoOMieAyiGpHSnR5V+cloqexVqHMRp
# 5rC+QBmZy9J9VU4inBDgoVvDsy56i8Te8UsfjCh5MEV/bBO2PSz/LUqKKuwoDy3K
# 1JyYikptWjYsL9+6y+JBSgh3GIitNWGUEvOkcuvuNp6nUSeRPPeiGsz8h+WX4VGH
# aekizIPAtw9FbAfhQ0/UjErOz2OxtaQQevkNDCiwazT+IWgnb+z4+iaEW3VCzYkm
# eVmda6tjcWKQJQ0IIPH/AgMBAAGjggGuMIIBqjAOBgNVHQ8BAf8EBAMCAYYwEwYD
# VR0lBAwwCgYIKwYBBQUHAwMwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQU
# 2rONwCSQo2t30wygWd0hZ2R2C3gwHwYDVR0jBBgwFoAUHwC/RoAK/Hg5t6W0Q9lW
# ULvOljswgZMGCCsGAQUFBwEBBIGGMIGDMDkGCCsGAQUFBzABhi1odHRwOi8vb2Nz
# cC5nbG9iYWxzaWduLmNvbS9jb2Rlc2lnbmluZ3Jvb3RyNDUwRgYIKwYBBQUHMAKG
# Omh0dHA6Ly9zZWN1cmUuZ2xvYmFsc2lnbi5jb20vY2FjZXJ0L2NvZGVzaWduaW5n
# cm9vdHI0NS5jcnQwQQYDVR0fBDowODA2oDSgMoYwaHR0cDovL2NybC5nbG9iYWxz
# aWduLmNvbS9jb2Rlc2lnbmluZ3Jvb3RyNDUuY3JsMFYGA1UdIARPME0wQQYJKwYB
# BAGgMgEyMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29t
# L3JlcG9zaXRvcnkvMAgGBmeBDAEEATANBgkqhkiG9w0BAQsFAAOCAgEACIhyJsav
# +qxfBsCqjJDa0LLAopf/bhMyFlT9PvQwEZ+PmPmbUt3yohbu2XiVppp8YbgEtfjr
# y/RhETP2ZSW3EUKL2Glux/+VtIFDqX6uv4LWTcwRo4NxahBeGQWn52x/VvSoXMNO
# Ca1Za7j5fqUuuPzeDsKg+7AE1BMbxyepuaotMTvPRkyd60zsvC6c8YejfzhpX0FA
# Z/ZTfepB7449+6nUEThG3zzr9s0ivRPN8OHm5TOgvjzkeNUbzCDyMHOwIhz2hNab
# XAAC4ShSS/8SS0Dq7rAaBgaehObn8NuERvtz2StCtslXNMcWwKbrIbmqDvf+28rr
# vBfLuGfr4z5P26mUhmRVyQkKwNkEcUoRS1pkw7x4eK1MRyZlB5nVzTZgoTNTs/Z7
# KtWJQDxxpav4mVn945uSS90FvQsMeAYrz1PYvRKaWyeGhT+RvuB4gHNU36cdZytq
# tq5NiYAkCFJwUPMB/0SuL5rg4UkI4eFb1zjRngqKnZQnm8qjudviNmrjb7lYYuA2
# eDYB+sGniXomU6Ncu9Ky64rLYwgv/h7zViniNZvY/+mlvW1LWSyJLC9Su7UpkNpD
# R7xy3bzZv4DB3LCrtEsdWDY3ZOub4YUXmimi/eYI0pL/oPh84emn0TCOXyZQK8ei
# 4pd3iu/YTT4m65lAYPM8Zwy2CHIpNVOBNNwwggc/MIIFJ6ADAgECAgxsjPy20SAh
# 5jGEkUUwDQYJKoZIhvcNAQELBQAwWTELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEds
# b2JhbFNpZ24gbnYtc2ExLzAtBgNVBAMTJkdsb2JhbFNpZ24gR0NDIFI0NSBDb2Rl
# U2lnbmluZyBDQSAyMDIwMB4XDTI0MDYwNDEzMDU0NVoXDTI3MDcxNTE0MzA0NFow
# gYoxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpOZXcgSmVyc2V5MRAwDgYDVQQHEwdI
# b2Jva2VuMRYwFAYDVQQKEw1TRU1QRVJJUyBJTkMuMRYwFAYDVQQDEw1TRU1QRVJJ
# UyBJTkMuMSQwIgYJKoZIhvcNAQkBFhVjb2Rlc2lnbkBzZW1wZXJpcy5jb20wggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCNYiocFDfmQmq3ngxGCT305SbM
# YRrXTVpotaqQbcpoesQbYwj/Wq94RNeh7cAXSLaMaQt5YlyhAO/aND5VxLBiWi9+
# Y2v8cGziq1XGTGSFV6Rwc0Go777qQP0lc76Q8qGijZNWqIWWSaE3cS57dIFwNAWn
# pWVtUhtfz3LJZ1ok7vP+UQT8zC5qfbM7pAxJ8T6vrsInAG5iClrwuspeuUmAaLbW
# MKHFn2yeLOXAbEqVSwn8R8gNUBVVSMkXKooXDU35fr5xGRBuSVtdnguHL7jAPuDu
# 5btcOggLcCgD9fegjXQeKphZVdpdRchpXe3idFYHAVx21552cFfshEHL4M4I3YcO
# C/5JJcyLMIHP63MXPzQbbZ3IZQ9++sIZora75v7Bynx04xl/2mO5Y2LGiu4DHs6r
# xgBYU8AnA5ncM/mcrEoG/Ce03z7nt7Mnl7KC3GjYBnx5XCwYc0sLr6sHLKJdsd3b
# jwL/watiUxV60+lW+t5Z1JYQGlBjHwMEfQYliZHMix2Pe+9KsMbkvLeHMGo31pUZ
# qeBl7hEPCD0x5KqP4VrBNPySHDhJMk582TvJdoHCKZYfJHdkChHzADIbvUcAE69b
# TFsTOp/ypC/yOTFrZFuBr6w30+x+9UVy4+jsx1MUoNBOLv6on1MmYaTH5sp4/MoA
# 6LkPG0h7ZJUq2qlNXwIDAQABo4IB0zCCAc8wDgYDVR0PAQH/BAQDAgeAMIGbBggr
# BgEFBQcBAQSBjjCBizBKBggrBgEFBQcwAoY+aHR0cDovL3NlY3VyZS5nbG9iYWxz
# aWduLmNvbS9jYWNlcnQvZ3NnY2NyNDVjb2Rlc2lnbmNhMjAyMC5jcnQwPQYIKwYB
# BQUHMAGGMWh0dHA6Ly9vY3NwLmdsb2JhbHNpZ24uY29tL2dzZ2NjcjQ1Y29kZXNp
# Z25jYTIwMjAwVgYDVR0gBE8wTTBBBgkrBgEEAaAyATIwNDAyBggrBgEFBQcCARYm
# aHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCAYGZ4EMAQQB
# MAkGA1UdEwQCMAAwRQYDVR0fBD4wPDA6oDigNoY0aHR0cDovL2NybC5nbG9iYWxz
# aWduLmNvbS9nc2djY3I0NWNvZGVzaWduY2EyMDIwLmNybDAgBgNVHREEGTAXgRVj
# b2Rlc2lnbkBzZW1wZXJpcy5jb20wEwYDVR0lBAwwCgYIKwYBBQUHAwMwHwYDVR0j
# BBgwFoAU2rONwCSQo2t30wygWd0hZ2R2C3gwHQYDVR0OBBYEFD9AijmjNjU3CNw8
# Unvu8bt4SgXDMA0GCSqGSIb3DQEBCwUAA4ICAQAQD+KrgTxd7wyLivnLriAHzIjT
# tvC5k8ov1rWGJgajZsA3MWQJ91mRkZzpDGYdrXgoX0f8D3qxpujkPOOsq8z8+AlM
# 957IzpDoq6oqLapaw25ADPTsPhlSxzY49Y9/B6pLOMVwCCTjGXDlDwtHiJHEyUkV
# 0icoXCxmSGSzT4fA8HHSDRf5xd1FTFtZ2CZFf40VN9ZjNXeNs602dI9t4LtsXY8Y
# 6g+wxEKc9Iwhuitp+gdXnDQ312nKo3p8Hsx5TGwRTkPJNCNq+BYtba7Z7fu9m3lo
# wjm3SaRfxgkZhW4//V8licRnrsMA3U2X4SkuXCMlC9t3NITiSPq5uEyhqhueu7wZ
# bOo6hr3+2j7Y5sDrHQ0g6GpvillfX+aiDuMwx1Oo+CmJezn7UIE8kFC934D8QEH/
# veD9GtVY1YOa4pXnn6d1Kd1tPPG4R5OXrjiRmwIU9c1UVR84t86meuqt+dOJo7L2
# i1RaNdcPLOExrzHZGZEUSZaizZxBN+XKWXDHWShq0zA+llH59l/RIbVZRUqt6c1M
# D/egPtsm0XGJABzhioGtjSmALmJiv4XWXg77pyhuy1SXELjOAW9WgLLv4xQaO4Fi
# XHO/yqLwh+XawyLk+iKLx3Gch3nGR8MepeRfqTg85PthgPQklS5FVN+q9Y6t3yR/
# sUxkJCMAt0B9E7sFVDGCGdYwghnSAgEBMGkwWTELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoTEEdsb2JhbFNpZ24gbnYtc2ExLzAtBgNVBAMTJkdsb2JhbFNpZ24gR0NDIFI0
# NSBDb2RlU2lnbmluZyBDQSAyMDIwAgxsjPy20SAh5jGEkUUwDQYJYIZIAWUDBAIB
# BQCggYQwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYK
# KwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG
# 9w0BCQQxIgQghWmzAesW49v8k8ASHS7u2JTwrqLjCW+XgY2LHj5UhfUwDQYJKoZI
# hvcNAQEBBQAEggIAeX3nFYPL2DDCmEb4t5+r5Tx2f3zo7Qs4JAz9A+MViP3NWQDR
# QB8y9b//mSV8epsDotrTqQkw4ZNzCD+umYavQehbQ5jBP4kymgnXeU/qAxMHIKvs
# xfZ+MpQxYDtVISqJOxhtCP38NChxpEz7GmQ5z61Nj7yZ/UPbFq4/hgbS4m+z0Cdg
# 9jeF4AL+Y5IycDQaDEbAKbEGJMYIA0OOJzK98TqbMcerRhjXpp4DOFEDY3UPnEkl
# 5HzR+t/t4nq3dBrf2ZVkLHPRNvbRZ9m1g+UQNfvyREjH8SZ02dNuKuY8suleokMg
# 9zRqPKDyX6SQswIlPkAjrGoZAYL1vRW37NSgBllOhqrs0kfZ0bCWS3SQDfmiafM6
# XcK004BpNUyeIlrSscfNPFfrBWAQoQzcAwe3IvliH8DACD1kdAXdZbLs6GE2nRzI
# LA2tAGo7S2p2w631mLVkY6pPJtdhW7ZJMRlt00MtiokHJ6K4qJ6Y3ujz+xi7ZKih
# UwSp1dsa/+paVt4EYv+sK2HcRYEZQ7Ptgly6lQnAsP1bBCUskngeahiJ8mHiO2Ai
# J3iV0n8RqfaNWpyGL/RwmF7NEzjOmhWRzk9N0DWWvfhFPetqTzt8V30DiC2WgLFI
# dyz+hmQ8fZPwKUWfGVzSDyIgc3crP8T5Y/JbcarApFqpJY+ct0n9AnOGjGKhgha3
# MIIWswYKKwYBBAGCNwMDATGCFqMwghafBgkqhkiG9w0BBwKgghaQMIIWjAIBAzEN
# MAsGCWCGSAFlAwQCATCB3AYLKoZIhvcNAQkQAQSggcwEgckwgcYCAQEGCSsGAQQB
# oDICAzAxMA0GCWCGSAFlAwQCAQUABCBgKjuWfynF5WhkSPGp6+1+7ujNpDMTlI/V
# 1KHIbgzOPAIUUz69+N7y2ny9LCkL3uMkLMMUxSgYDzIwMjUwNjEwMDc1MjIwWjAD
# AgEBoFekVTBTMQswCQYDVQQGEwJCRTEZMBcGA1UECgwQR2xvYmFsU2lnbiBudi1z
# YTEpMCcGA1UEAwwgR2xvYmFsc2lnbiBUU0EgZm9yIEFkdmFuY2VkIC0gRzSgghJK
# MIIGYjCCBEqgAwIBAgIQAQMy4WW/m3hD4Jl1lGN3CzANBgkqhkiG9w0BAQwFADBb
# MQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTExMC8GA1UE
# AxMoR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBTSEEzODQgLSBHNDAeFw0y
# NTA0MTExNDQ3MDFaFw0zNDEyMTAwMDAwMDBaMFMxCzAJBgNVBAYTAkJFMRkwFwYD
# VQQKDBBHbG9iYWxTaWduIG52LXNhMSkwJwYDVQQDDCBHbG9iYWxzaWduIFRTQSBm
# b3IgQWR2YW5jZWQgLSBHNDCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGB
# AL4lejlDGK511tWzocib1iaenoAWN1mu9Ocng7gqw8zEOq8sty7ryNq/wwWveWzX
# NhLatjNeMQ0n8+E9A4EbszvuRGgmnjPkyPUmJS/gkNkDR/QmZV1BxLysCQEhPewZ
# IEYvQB9sZb3VM2W94iCkRMVacCMtRKq2RsqAeeo8vjtsyGm4MgpXSOIJBHM6r4Fz
# KBZy+RsTtzj0Rjg36eklI/nsMLaCIKD+E7dgCl77Yvhvhbx8Gzevdk/vY1H8EQCX
# BZa6JNtfR6DaLDwsh8gxTczI5sRdI3ymYpNov8ymVwBzun3KW4Msk0BMIn25fcxv
# b501hIIfKpnXAZEKzaPQGDDxlkx7PNdUzXw+eF6eVzJYeToLRXOamOHYrSX++ML0
# COvPq2sg/GeXlHL1eMb/UhjKKU0rxtig1sjDMHswGoQYSfS2zNzW1NoeHRFCgS/O
# sJ6VgWLclzFIFpGTzArZiKlu8Zabb+XIO8lAPx9dQU/6AC0MTpVxG9VJrDCQy0oY
# TwIDAQABo4IBqDCCAaQwDgYDVR0PAQH/BAQDAgeAMBYGA1UdJQEB/wQMMAoGCCsG
# AQUFBwMIMB0GA1UdDgQWBBTZN7YzRW6PNQfO96mzCv2gqcj5gjBWBgNVHSAETzBN
# MAgGBmeBDAEEAjBBBgkrBgEEAaAyAR4wNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93
# d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wDAYDVR0TAQH/BAIwADCBkAYI
# KwYBBQUHAQEEgYMwgYAwOQYIKwYBBQUHMAGGLWh0dHA6Ly9vY3NwLmdsb2JhbHNp
# Z24uY29tL2NhL2dzdHNhY2FzaGEzODRnNDBDBggrBgEFBQcwAoY3aHR0cDovL3Nl
# Y3VyZS5nbG9iYWxzaWduLmNvbS9jYWNlcnQvZ3N0c2FjYXNoYTM4NGc0LmNydDAf
# BgNVHSMEGDAWgBTqFsZp5+PLV0U5M6TwQL7Qw71lljBBBgNVHR8EOjA4MDagNKAy
# hjBodHRwOi8vY3JsLmdsb2JhbHNpZ24uY29tL2NhL2dzdHNhY2FzaGEzODRnNC5j
# cmwwDQYJKoZIhvcNAQEMBQADggIBAGYfzwRhxCcMMGOdFylYezH0PcaS6ABq/E3x
# efhnLFLxh09UMeb2gE/XPDuBDaOR1ArLelpswVILQvkpBswzfheaZ0j/w+cjq/E0
# 3In7HD88F9WRn72NxokSBVMOdpEGqyWdZyeIcv1Db2Eprmb2vIwiuMNes5/frxqD
# Rf2w724UX07LumLYVRNDtH4dIl7qlqyfd+cn3e6s/uWNJGOyF0Yk9U3w6ibkAVmo
# 9W2JqSMRycQ8cC7svE/kuq3GgzscSOZoqzn3MKakNLDjVpu9z7Gh36RrulCrqVFd
# vZDAghLPFiXGxVc+7JyslVqFybbCOkzUvME08bvdxwRjIMDBgPSSQGrhGsKRGdzn
# 9MP3VJ9QpHCuAr29v3n4tGSdo7N53HM+0WBYgmesiKzGajy79/4pROfkamQQzM+i
# ergtga0cNaq9hK8npbrChB0NSA+qBpTxggf0mczlUveZF+IF6IW4+NJxBb2/pUFf
# yfSqg3PR+G3D+gTSkAg/dcS0Dk5f0Jjq0uqkTjA4w0L3qd4FjZNd0sNtATCIIWT7
# FN6nsMSNBtWSPXXmR3U98AfG0/517/SBxiCgAvOWx0hmDTCdpUJfR3vak2OxBlZR
# QxfudAg80Gy8XJ2x5XlbTcBayAHhD2jtm91FdEglFFxSM05mS/AJeDEw29LVZTlR
# sGBMYx6QMIIGWTCCBEGgAwIBAgINAewckkDe/S5AXXxHdDANBgkqhkiG9w0BAQwF
# ADBMMSAwHgYDVQQLExdHbG9iYWxTaWduIFJvb3QgQ0EgLSBSNjETMBEGA1UEChMK
# R2xvYmFsU2lnbjETMBEGA1UEAxMKR2xvYmFsU2lnbjAeFw0xODA2MjAwMDAwMDBa
# Fw0zNDEyMTAwMDAwMDBaMFsxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxT
# aWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWduIFRpbWVzdGFtcGluZyBDQSAt
# IFNIQTM4NCAtIEc0MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA8ALi
# MCP64BvhmnSzr3WDX6lHUsdhOmN8OSN5bXT8MeR0EhmW+s4nYluuB4on7lejxDXt
# szTHrMMM64BmbdEoSsEsu7lw8nKujPeZWl12rr9EqHxBJI6PusVP/zZBq6ct/XhO
# Q4j+kxkX2e4xz7yKO25qxIjw7pf23PMYoEuZHA6HpybhiMmg5ZninvScTD9dW+y2
# 79Jlz0ULVD2xVFMHi5luuFSZiqgxkjvyen38DljfgWrhsGweZYIq1CHHlP5Cljvx
# C7F/f0aYDoc9emXr0VapLr37WD21hfpTmU1bdO1yS6INgjcZDNCr6lrB7w/Vmbk/
# 9E818ZwP0zcTUtklNO2W7/hn6gi+j0l6/5Cx1PcpFdf5DV3Wh0MedMRwKLSAe70q
# m7uE4Q6sbw25tfZtVv6KHQk+JA5nJsf8sg2glLCylMx75mf+pliy1NhBEsFV/W6R
# xbuxTAhLntRCBm8bGNU26mSuzv31BebiZtAOBSGssREGIxnk+wU0ROoIrp1JZxGL
# guWtWoanZv0zAwHemSX5cW7pnF0CTGA8zwKPAf1y7pLxpxLeQhJN7Kkm5XcCrA5X
# DAnRYZ4miPzIsk3bZPBFn7rBP1Sj2HYClWxqjcoiXPYMBOMp+kuwHNM3dITZHWar
# NHOPHn18XpbWPRmwl+qMUJFtr1eGfhA3HWsaFN8CAwEAAaOCASkwggElMA4GA1Ud
# DwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBTqFsZp5+PL
# V0U5M6TwQL7Qw71lljAfBgNVHSMEGDAWgBSubAWjkxPioufi1xzWx/B/yGdToDA+
# BggrBgEFBQcBAQQyMDAwLgYIKwYBBQUHMAGGImh0dHA6Ly9vY3NwMi5nbG9iYWxz
# aWduLmNvbS9yb290cjYwNgYDVR0fBC8wLTAroCmgJ4YlaHR0cDovL2NybC5nbG9i
# YWxzaWduLmNvbS9yb290LXI2LmNybDBHBgNVHSAEQDA+MDwGBFUdIAAwNDAyBggr
# BgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8w
# DQYJKoZIhvcNAQEMBQADggIBAH/iiNlXZytCX4GnCQu6xLsoGFbWTL/bGwdwxvsL
# Ca0AOmAzHznGFmsZQEklCB7km/fWpA2PHpbyhqIX3kG/T+G8q83uwCOMxoX+SxUk
# +RhE7B/CpKzQss/swlZlHb1/9t6CyLefYdO1RkiYlwJnehaVSttixtCzAsw0SEVV
# 3ezpSp9eFO1yEHF2cNIPlvPqN1eUkRiv3I2ZOBlYwqmhfqJuFSbqtPl/KufnSGRp
# L9KaoXL29yRLdFp9coY1swJXH4uc/LusTN763lNMg/0SsbZJVU91naxvSsguarnK
# iMMSME6yCHOfXqHWmc7pfUuWLMwWaxjN5Fk3hgks4kXWss1ugnWl2o0et1sviC49
# ffHykTAFnM57fKDFrK9RBvARxx0wxVFWYOh8lT0i49UKJFMnl4D6SIknLHniPOWb
# HuOqhIKJPsBK9SH+YhDtHTD89szqSCd8i3VCf2vL86VrlR8EWDQKie2CUOTRe6jJ
# 5r5IqitV2Y23JSAOG1Gg1GOqg+pscmFKyfpDxMZXxZ22PLCLsLkcMe+97xTYFEBs
# IB3CLegLxo1tjLZx7VIh/j72n585Gq6s0i96ILH0rKod4i0UnfqWah3GPMrz2Ry/
# U02kR1l8lcRDQfkl4iwQfoH5DZSnffK1CfXYYHJAUJUg1ENEvvqglecgWbZ4xqRq
# qiKbMIIFgzCCA2ugAwIBAgIORea7A4Mzw4VlSOb/RVEwDQYJKoZIhvcNAQEMBQAw
# TDEgMB4GA1UECxMXR2xvYmFsU2lnbiBSb290IENBIC0gUjYxEzARBgNVBAoTCkds
# b2JhbFNpZ24xEzARBgNVBAMTCkdsb2JhbFNpZ24wHhcNMTQxMjEwMDAwMDAwWhcN
# MzQxMjEwMDAwMDAwWjBMMSAwHgYDVQQLExdHbG9iYWxTaWduIFJvb3QgQ0EgLSBS
# NjETMBEGA1UEChMKR2xvYmFsU2lnbjETMBEGA1UEAxMKR2xvYmFsU2lnbjCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAJUH6HPKZvnsFMp7PPcNCPG0RQss
# grRIxutbPK6DuEGSMxSkb3/pKszGsIhrxbaJ0cay/xTOURQh7ErdG1rG1ofuTToV
# Bu1kZguSgMpE3nOUTvOniX9PeGMIyBJQbUJmL025eShNUhqKGoC3GYEOfsSKvGRM
# IRxDaNc9PIrFsmbVkJq3MQbFvuJtMgamHvm566qjuL++gmNQ0PAYid/kD3n16qIf
# KtJwLnvnvJO7bVPiSHyMEAc4/2ayd2F+4OqMPKq0pPbzlUoSB239jLKJz9CgYXfI
# WHSw1CM69106yqLbnQneXUQtkPGBzVeS+n68UARjNN9rkxi+azayOeSsJDa38O+2
# HBNXk7besvjihbdzorg1qkXy4J02oW9UivFyVm4uiMVRQkQVlO6jxTiWm05OWgtH
# 8wY2SXcwvHE35absIQh1/OZhFj931dmRl4QKbNQCTXTAFO39OfuD8l4UoQSwC+n+
# 7o/hbguyCLNhZglqsQY6ZZZZwPA1/cnaKI0aEYdwgQqomnUdnjqGBQCe24DWJfnc
# BZ4nWUx2OVvq+aWh2IMP0f/fMBH5hc8zSPXKbWQULHpYT9NLCEnFlWQaYw55PfWz
# jMpYrZxCRXluDocZXFSxZba/jJvcE+kNb7gu3GduyYsRtYQUigAZcIN5kZeR1Bon
# vzceMgfYFGM8KEyvAgMBAAGjYzBhMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8E
# BTADAQH/MB0GA1UdDgQWBBSubAWjkxPioufi1xzWx/B/yGdToDAfBgNVHSMEGDAW
# gBSubAWjkxPioufi1xzWx/B/yGdToDANBgkqhkiG9w0BAQwFAAOCAgEAgyXt6NH9
# lVLNnsAEoJFp5lzQhN7craJP6Ed41mWYqVuoPId8AorRbrcWc+ZfwFSY1XS+wc3i
# EZGtIxg93eFyRJa0lV7Ae46ZeBZDE1ZXs6KzO7V33EByrKPrmzU+sQghoefEQzd5
# Mr6155wsTLxDKZmOMNOsIeDjHfrYBzN2VAAiKrlNIC5waNrlU/yDXNOd8v9EDERm
# 8tLjvUYAGm0CuiVdjaExUd1URhxN25mW7xocBFymFe944Hn+Xds+qkxV/ZoVqW/h
# pvvfcDDpw+5CRu3CkwWJ+n1jez/QcYF8AOiYrg54NMMl+68KnyBr3TsTjxKM4kEa
# SHpzoHdpx7Zcf4LIHv5YGygrqGytXm3ABdJ7t+uA/iU3/gKbaKxCXcPu9czc8FB1
# 0jZpnOZ7BN9uBmm23goJSFmH63sUYHpkqmlD75HHTOwY3WzvUy2MmeFe8nI+z1TI
# vWfspA9MRf/TuTAjB0yPEL+GltmZWrSZVxykzLsViVO6LAUP5MSeGbEYNNVMnbrt
# 9x+vJJUEeKgDu+6B5dpffItKoZB0JaezPkvILFa9x8jvOOJckvB595yEunQtYQEg
# fn7R8k8HWV+LLUNS60YMlOH1Zkd5d9VUWx+tJDfLRVpOoERIyNiwmcUVhAn21klJ
# wGW45hpxbqCo8YLoRT5s1gLXCmeDBVrJpBAxggNJMIIDRQIBATBvMFsxCzAJBgNV
# BAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9i
# YWxTaWduIFRpbWVzdGFtcGluZyBDQSAtIFNIQTM4NCAtIEc0AhABAzLhZb+beEPg
# mXWUY3cLMAsGCWCGSAFlAwQCAaCCAS0wGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJ
# EAEEMCsGCSqGSIb3DQEJNDEeMBwwCwYJYIZIAWUDBAIBoQ0GCSqGSIb3DQEBCwUA
# MC8GCSqGSIb3DQEJBDEiBCC7TyIjLIJ1TXv6mrUtbTEN4/FSIrWvAnzXWVy7TAqp
# jzCBsAYLKoZIhvcNAQkQAi8xgaAwgZ0wgZowgZcEIJGSR5tiNbl2Jr+2AW14CJGD
# cgPYc5HAbBuOPXf/4sc3MHMwX6RdMFsxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBH
# bG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWduIFRpbWVzdGFtcGlu
# ZyBDQSAtIFNIQTM4NCAtIEc0AhABAzLhZb+beEPgmXWUY3cLMA0GCSqGSIb3DQEB
# CwUABIIBgHFlnbSOEkvmLnvddy+kpg3u/6P4lSjUI20VyoDs5+zN8j0091n7/hCP
# YL/ruuOYBw3gGhe7sv4L8fj7aCZCKKk1wHAkZTgZCQQ3pp2b5SHYcKFnmPdVLphW
# 61qp6ZOE/oM4kzphD5T4oIV5pA7u1qhJVd5umMpH7r0+kmdrFNftfZCd2dh6sXGf
# g2nu9AaxQ8l0PTYj63/fIsUQyKgu66BD67lQCgXS+dyVHzt49lZ5NqEcHRqX+5fp
# TxhH3AS7UFUBvnZ+T2pQgD/PEzKl19n8ZfX6xmi9G+telobHJGguibfPkvM8UC5r
# VZlyGUAz6Zg6eb8KOjXX+AwbZqYHO00E5/AAVFItx9+QUe5uFmv3mZoN/+5CiBSf
# 9gVsnYln5N/lbj1PHcxZQl5kp+YRhPOrKJ/zDy4ZzJ8WO1iZllRpqdZNOeZusClF
# Acy8bZqMVYbW/7TywiWMa6J3+63EYFCmuf1ukO6H3CZcUgJr5zb7+mBfymkKERq/
# 8w8ndl4tvA==
# SIG # End signature block
