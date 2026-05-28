$Script:SecurityIndicators = @(
    [PSCustomObject]@{ Name = 'ChangesToAdminContextMenuPK' }
    [PSCustomObject]@{ Name = 'ChangesToDomainOrDCPolicies' }
    [PSCustomObject]@{ Name = 'ZeroLogonPK' }
    [PSCustomObject]@{ Name = 'AAD_AllowedInstancePropertyLock' }
    [PSCustomObject]@{ Name = 'AAD_AllowUserConsentForRiskyApps' }
    [PSCustomObject]@{ Name = 'AAD_ApplicationNameAndGeographicLocationMFA' }
    [PSCustomObject]@{ Name = 'AAD_CAEDisabled' }
    [PSCustomObject]@{ Name = 'AAD_CBAPersistence' }
    [PSCustomObject]@{ Name = 'AAD_CheckAdministrativeUnits' }
    [PSCustomObject]@{ Name = 'AAD_CheckConditionalPrivateAddress' }
    [PSCustomObject]@{ Name = 'AAD_CheckGuestInvitePermission' }
    [PSCustomObject]@{ Name = 'AAD_CheckInactivePrincipals' }
    [PSCustomObject]@{ Name = 'AAD_CheckLegacyAuthentication' }
    [PSCustomObject]@{ Name = 'AAD_CheckLegacyMFA' }
    [PSCustomObject]@{ Name = 'AAD_CheckPrivigedGuests' }
    [PSCustomObject]@{ Name = 'AAD_CheckPrivilegedMFA' }
    [PSCustomObject]@{ Name = 'AAD_CheckRiskyRoles' }
    [PSCustomObject]@{ Name = 'AAD_CheckSecureMFA' }
    [PSCustomObject]@{ Name = 'AAD_CheckSecurityDefaults' }
    [PSCustomObject]@{ Name = 'AAD_CheckSMTPMatch' }
    [PSCustomObject]@{ Name = 'AAD_CheckUserConsent' }
    [PSCustomObject]@{ Name = 'AAD_CustomBannedPasswordNotInUse' }
    [PSCustomObject]@{ Name = 'AAD_DisableAdminTokenPersistence' }
    [PSCustomObject]@{ Name = 'AAD_ExpiredSecretsAndCertificates' }
    [PSCustomObject]@{ Name = 'AAD_FIDO2EnforceAttestation' }
    [PSCustomObject]@{ Name = 'AAD_GetResetAADSyncUsers' }
    [PSCustomObject]@{ Name = 'AAD_GlobalAdministratorLastSignIn' }
    [PSCustomObject]@{ Name = 'AAD_GuestUsersAreNotRestricted' }
    [PSCustomObject]@{ Name = 'AAD_HiddenConsentGrant' }
    [PSCustomObject]@{ Name = 'AAD_InactiveGuests' }
    [PSCustomObject]@{ Name = 'AAD_LessThan2GAs' }
    [PSCustomObject]@{ Name = 'AAD_MFABombingOnPrivilegedAccounts' }
    [PSCustomObject]@{ Name = 'AAD_MFAGroupChange' }
    [PSCustomObject]@{ Name = 'AAD_MoreThan10PrivilegedRoles' }
    [PSCustomObject]@{ Name = 'AAD_MoreThan5GlobalAdministrators' }
    [PSCustomObject]@{ Name = 'AAD_PasswordHashSync' }
    [PSCustomObject]@{ Name = 'AAD_PermanentActivePrivilegedRoleAssignment' }
    [PSCustomObject]@{ Name = 'AAD_privilegedAssociatedMailbox' }
    [PSCustomObject]@{ Name = 'AAD_PrivilegedOnPremiseAndAAD' }
    [PSCustomObject]@{ Name = 'AAD_PrivilegedOnPremiseSyncedToAAD' }
    [PSCustomObject]@{ Name = 'AAD_ProhibitedPrivilegedRoles' }
    [PSCustomObject]@{ Name = 'AAD_RBCDOnSSOUser' }
    [PSCustomObject]@{ Name = 'AAD_ReportMFASuspiciousActivityIsEnabled' }
    [PSCustomObject]@{ Name = 'AAD_RequireMFAOnPrivilegedAccounts' }
    [PSCustomObject]@{ Name = 'AAD_RequireMFAOnRiskySignIns' }
    [PSCustomObject]@{ Name = 'AAD_RequirePasswordChangeHighRiskUser' }
    [PSCustomObject]@{ Name = 'AAD_RiskyCustomRolesPermissions' }
    [PSCustomObject]@{ Name = 'AAD_RiskyUsers' }
    [PSCustomObject]@{ Name = 'AAD_SecurityQuestionInUse' }
    [PSCustomObject]@{ Name = 'AAD_SSOConfiguredWithSAML' }
    [PSCustomObject]@{ Name = 'AAD_SSOOldPwdLastSet' }
    [PSCustomObject]@{ Name = 'AAD_SSPRForAdmins' }
    [PSCustomObject]@{ Name = 'AAD_StaleGuestsInvites' }
    [PSCustomObject]@{ Name = 'AAD_SuspiciousDirectorySynchronizationAccountRoleMember' }
    [PSCustomObject]@{ Name = 'AAD_UnprivilegedGroupOwner' }
    [PSCustomObject]@{ Name = 'AAD_UnusedEligibleRole' }
    [PSCustomObject]@{ Name = 'AAD_UsersCanCreateSecurityGroups' }
    [PSCustomObject]@{ Name = 'AAD_UsersCanCreateTenants' }
    [PSCustomObject]@{ Name = 'AAD_UsersCanRegisterApplications' }
    [PSCustomObject]@{ Name = 'AAD_UsersCapableMFA' }
    [PSCustomObject]@{ Name = 'AbnormalPasswordRefresh' }
    [PSCustomObject]@{ Name = 'AccountsInCertPublishers' }
    [PSCustomObject]@{ Name = 'AdminPWNotChanged' }
    [PSCustomObject]@{ Name = 'AdminSDHolderInheritance' }
    [PSCustomObject]@{ Name = 'AdminSDHolderPermissionChange' }
    [PSCustomObject]@{ Name = 'AdminUsedRecently' }
    [PSCustomObject]@{ Name = 'altSecurityIdentitiesConfigured' }
    [PSCustomObject]@{ Name = 'AnonAccessonAD' }
    [PSCustomObject]@{ Name = 'AnonNSPIAccess' }
    [PSCustomObject]@{ Name = 'CertificatesNTAuthPermissions' }
    [PSCustomObject]@{ Name = 'CertificateTemplatesAreVulnerable' }
    [PSCustomObject]@{ Name = 'CertificateTemplatesPermissions' }
    [PSCustomObject]@{ Name = 'CertificateTemplatesWithSANAllowed' }
    [PSCustomObject]@{ Name = 'ChangesToDefaultSD' }
    [PSCustomObject]@{ Name = 'CompObsoleteOS' }
    [PSCustomObject]@{ Name = 'CompOldPwdLastSet' }
    [PSCustomObject]@{ Name = 'CompOldPwdLastSetDC' }
    [PSCustomObject]@{ Name = 'ComputersInPrivilegedGroup' }
    [PSCustomObject]@{ Name = 'ComputerUserWithSPNUnconstrainedDelegation' }
    [PSCustomObject]@{ Name = 'ConstrainedDelegationToKRBTGT' }
    [PSCustomObject]@{ Name = 'DangerousTrustAttributeSet' }
    [PSCustomObject]@{ Name = 'DCPrintSpooler' }
    [PSCustomObject]@{ Name = 'DCShadowInUse' }
    [PSCustomObject]@{ Name = 'DelegateToGhostSPN' }
    [PSCustomObject]@{ Name = 'DisabledPrivilegedUsers' }
    [PSCustomObject]@{ Name = 'DMSABadSuccessor' }
    [PSCustomObject]@{ Name = 'DnsZonesWithUnsecureUpdate' }
    [PSCustomObject]@{ Name = 'DomainControllerInconsistent' }
    [PSCustomObject]@{ Name = 'DomainControllerOwnerPermissions' }
    [PSCustomObject]@{ Name = 'DomainObsoleteFunctionalLevel' }
    [PSCustomObject]@{ Name = 'DPAPIKeysPermissions' }
    [PSCustomObject]@{ Name = 'DwAdminSDExMaskSet' }
    [PSCustomObject]@{ Name = 'EID_SuspiciousMSSPCreds' }
    [PSCustomObject]@{ Name = 'EID_UnresolvedPrivilegedUsers' }
    [PSCustomObject]@{ Name = 'EnabledAdminsNotInUse' }
    [PSCustomObject]@{ Name = 'EnterpriseCAs' }
    [PSCustomObject]@{ Name = 'EnterpriseKeyAdminsFullControl' }
    [PSCustomObject]@{ Name = 'EphemeralAdmins' }
    [PSCustomObject]@{ Name = 'ExpirePasswordOnSmartCard' }
    [PSCustomObject]@{ Name = 'FGPPNotAppliedToAGroup' }
    [PSCustomObject]@{ Name = 'FSPInPrivilegedGroup' }
    [PSCustomObject]@{ Name = 'GMSANotInUse' }
    [PSCustomObject]@{ Name = 'GMSAOldPwdLastSet' }
    [PSCustomObject]@{ Name = 'GMSAPasswordPermissions' }
    [PSCustomObject]@{ Name = 'GPOBadShortcut' }
    [PSCustomObject]@{ Name = 'GPOLogonScripts' }
    [PSCustomObject]@{ Name = 'GPOScheduledTasks' }
    [PSCustomObject]@{ Name = 'GPOUserRights' }
    [PSCustomObject]@{ Name = 'GPOWeakLMHashStorageEnabled' }
    [PSCustomObject]@{ Name = 'GPPrefPasswords' }
    [PSCustomObject]@{ Name = 'GuestAccountEnabled' }
    [PSCustomObject]@{ Name = 'InactiveDCs' }
    [PSCustomObject]@{ Name = 'InstallReplicaPermissions' }
    [PSCustomObject]@{ Name = 'KerberosGoldenTicket' }
    [PSCustomObject]@{ Name = 'LapsSearchFlagsNonDefault' }
    [PSCustomObject]@{ Name = 'LdapDenyList' }
    [PSCustomObject]@{ Name = 'LdapSigningIsNotRequired' }
    [PSCustomObject]@{ Name = 'ManyAdministratorsInForest' }
    [PSCustomObject]@{ Name = 'NewObjects' }
    [PSCustomObject]@{ Name = 'NewPrivilegedUsers' }
    [PSCustomObject]@{ Name = 'NonEmptyDcomAndPerformanceLogGroups' }
    [PSCustomObject]@{ Name = 'NonPrivilegedObjectsWithAdminCount' }
    [PSCustomObject]@{ Name = 'NonStandardPGID' }
    [PSCustomObject]@{ Name = 'NonStandardSchemaPermissions' }
    [PSCustomObject]@{ Name = 'NoPGID' }
    [PSCustomObject]@{ Name = 'NTFRSSysvolReplication' }
    [PSCustomObject]@{ Name = 'ObjectsCanReanimateTombstones' }
    [PSCustomObject]@{ Name = 'ObjectsInPrivilegedGroupWithoutAdmincount' }
    [PSCustomObject]@{ Name = 'ObjectsWithConstrainedDelegation' }
    [PSCustomObject]@{ Name = 'ObjectsWithConstrainedDelegationDC' }
    [PSCustomObject]@{ Name = 'ObjectsWithLapsRead' }
    [PSCustomObject]@{ Name = 'ObjectsWithProtocolTranistion' }
    [PSCustomObject]@{ Name = 'ObjectsWithProtocolTransitionDC' }
    [PSCustomObject]@{ Name = 'Okta_CustomRolesCreds' }
    [PSCustomObject]@{ Name = 'OKTA_NewAdminGroup' }
    [PSCustomObject]@{ Name = 'OKTA_NewAdminUser' }
    [PSCustomObject]@{ Name = 'OKTA_NewAppAccessToken' }
    [PSCustomObject]@{ Name = 'OKTA_NewSuperadminGroup' }
    [PSCustomObject]@{ Name = 'OKTA_NewSuperadminUser' }
    [PSCustomObject]@{ Name = 'OKTA_PasswordPolicyBestPractice' }
    [PSCustomObject]@{ Name = 'OKTA_UserActivate' }
    [PSCustomObject]@{ Name = 'OKTA_UserDeactivate' }
    [PSCustomObject]@{ Name = 'OKTA_UsersWithoutMFA' }
    [PSCustomObject]@{ Name = 'OldPwdLastSet' }
    [PSCustomObject]@{ Name = 'OldPwdLastSetAdmin' }
    [PSCustomObject]@{ Name = 'OperatorsGroupsAreNotEmpty' }
    [PSCustomObject]@{ Name = 'OutboundForestTrustWithSIDHistory' }
    [PSCustomObject]@{ Name = 'OutboundTrustWithoutQuarantine' }
    [PSCustomObject]@{ Name = 'PreWin2KGroup' }
    [PSCustomObject]@{ Name = 'PrimaryUsersWithSPN' }
    [PSCustomObject]@{ Name = 'PrimaryUsersWithSPNNotSupportingAES' }
    [PSCustomObject]@{ Name = 'PrivilegedGroupChanges' }
    [PSCustomObject]@{ Name = 'PrivilegedSPN' }
    [PSCustomObject]@{ Name = 'PrivilegedUsersWeakPasswordPolicy' }
    [PSCustomObject]@{ Name = 'ProtectedUsersNotUsed' }
    [PSCustomObject]@{ Name = 'RBCD' }
    [PSCustomObject]@{ Name = 'RBCDOnDC' }
    [PSCustomObject]@{ Name = 'RBCDOnkrbtgt' }
    [PSCustomObject]@{ Name = 'RBCDWriteOnDC' }
    [PSCustomObject]@{ Name = 'RBCDWriteOnkrbtgt' }
    [PSCustomObject]@{ Name = 'RC4EnabledOnDC' }
    [PSCustomObject]@{ Name = 'RecentSIDHistoryChanges' }
    [PSCustomObject]@{ Name = 'ReplicationPermissions' }
    [PSCustomObject]@{ Name = 'RiskyRODCCreds' }
    [PSCustomObject]@{ Name = 'RODCPrivilegedCreds' }
    [PSCustomObject]@{ Name = 'ShadowCredentials' }
    [PSCustomObject]@{ Name = 'SIDHistoryPrivilegedSID' }
    [PSCustomObject]@{ Name = 'SmartCardUserPasswordNotChange' }
    [PSCustomObject]@{ Name = 'SmbSigningIsNotRequired' }
    [PSCustomObject]@{ Name = 'SMBv1EnabledOnDCs' }
    [PSCustomObject]@{ Name = 'SYSVOLExecutableChanges' }
    [PSCustomObject]@{ Name = 'TrustPwdLastSet' }
    [PSCustomObject]@{ Name = 'UnprivilegedDNSAdmin' }
    [PSCustomObject]@{ Name = 'UnprivilegedOwner' }
    [PSCustomObject]@{ Name = 'UserPasswordAttributeIsSet' }
    [PSCustomObject]@{ Name = 'UsersCanAddComputers' }
    [PSCustomObject]@{ Name = 'UsersDESPWD' }
    [PSCustomObject]@{ Name = 'UsersPwdNeverExpires' }
    [PSCustomObject]@{ Name = 'UsersPwdNeverExpiresAdmin' }
    [PSCustomObject]@{ Name = 'UsersPWDNotReq' }
    [PSCustomObject]@{ Name = 'UsersReversiblePWD' }
    [PSCustomObject]@{ Name = 'UsersWithPreAuth' }
    [PSCustomObject]@{ Name = 'WeakCertificateCipher' }
    [PSCustomObject]@{ Name = 'WeakGPOLinkingADSite' }
    [PSCustomObject]@{ Name = 'WeakGPOLinkingOnDCOU' }
    [PSCustomObject]@{ Name = 'WeakGPOLinkingOnDomain' }
)

function Get-SecurityIndicator {
    <#
    .SYNOPSIS
        Returns collection of all security indicators for currently loaded product aggregator
    #>
    [CmdletBinding()]
    [Alias('List-SecurityIndicator')]
    [Alias('lsi')]
    param()

    $Script:SecurityIndicators | ForEach-Object {
        $indicator = $_ | Invoke-SecurityIndicator -Metadata | ConvertFrom-Json

        # Swap title and name
        $title = $indicator.Name
        $indicator.Name = $_.Name
        $indicator | Add-Member -NotePropertyName 'Title' -NotePropertyValue $title -PassThru
    }
}

function Invoke-SecurityIndicator {
    <#
    .SYNOPSIS
        Executes single security indicator, specified by name
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        # Common parameters
        [string] $ForestName,
        [string[]] $DomainNames,
        [string] $TenantId,
        [string] $TenantAppId,
        [string] $TenantAppSecret,
        [switch] $Metadata
    )
    process {
        $noun = $Name -replace '-', '_'
        $command = Get-Command "Test-$noun"
        Write-Verbose "Executing [$($command.Name)]"

        [void]$PSBoundParameters.Remove('Name')
        &$command @PSBoundParameters
    }
}

# SIG # Begin signature block
# MIIuIwYJKoZIhvcNAQcCoIIuFDCCLhACAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAOK7Zk4bH4Lfg2
# p1rHxU2n/tx7SRz05h8+n0Yu8WEUNKCCE6MwggVyMIIDWqADAgECAhB2U/6sdUZI
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
# 9w0BCQQxIgQg+Xyg5zWmukTkL4uF2ZVNqP+kE+40ZxrA1/niqmlDShIwDQYJKoZI
# hvcNAQEBBQAEggIAHPTtqerXR5RhNb8sBVWyaxv96PESa9AyfkieJRv22agByElL
# sdxcD2goLilufII4OeyOPnB4bioOspv7g7NUy2IAN+yJsZV6lNOR96wBSqjAHsyN
# RmlP+I7bRzYGa3gPHvocmeqD9QrqNBihg+cqmH5pr7Fkpgxbjji7Eh4r+7/0BLVm
# q3GTc0TY0q5Gh2+2E0npk8HLsefk9sgEkF5Z8xC0vIb64Run7M5B2Rzb4aGSarab
# AS88QISySzetV0tPrnWXlIi0F/f4ZJQqqsbelB9Rzx4K7AeY0bF5hgchN4jbD/k1
# JEyQwQCQL5rxUCKIPSYJ5tf0Mjy4ckYLR/az4jRetlVKYZQvZpUdGwQb8Ya1oRVB
# 3HVK/nkOrYs8egSmWdGGXJVZp7imaY1tTtghbM53hROVchnzRkSslrY/pcu36LMI
# mUGO1wFbCmMIvC/EzUnKXHpGY6CS9CKYEo5EvlKfZFMHXNEqFSo6R6lmZT/jG5OD
# Nly5/C1hedCJXraYDaaSkPKj8ZXR8hR16sOI0BXJlPEnpDAkvmprZFpyVQBsWgWC
# +a/6ZxjosMEtzdRf3lEHFw0uS8G006iJkSaZO5BJLJi1CqSacEItgNjyXx/SUsev
# 4DgfeYlH+Zc1xoE7k96PyaT2ho4Tftxf5voIoYc8t4POrYL3X+nsKs/9/ayhgha3
# MIIWswYKKwYBBAGCNwMDATGCFqMwghafBgkqhkiG9w0BBwKgghaQMIIWjAIBAzEN
# MAsGCWCGSAFlAwQCATCB3AYLKoZIhvcNAQkQAQSggcwEgckwgcYCAQEGCSsGAQQB
# oDICAzAxMA0GCWCGSAFlAwQCAQUABCBjLJLVilvEAa6U01nQkCAsG+4D+JrK25m1
# ZvTzndCbxAIUCWtdwD4Nm1oanlqPlcZsyGpIoh8YDzIwMjUwNjEwMDc1MjIyWjAD
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
# MC8GCSqGSIb3DQEJBDEiBCAR9JD9/+Ud6hhrQV+0XdKGtlspTusptgNeSMfYVELK
# pjCBsAYLKoZIhvcNAQkQAi8xgaAwgZ0wgZowgZcEIJGSR5tiNbl2Jr+2AW14CJGD
# cgPYc5HAbBuOPXf/4sc3MHMwX6RdMFsxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBH
# bG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWduIFRpbWVzdGFtcGlu
# ZyBDQSAtIFNIQTM4NCAtIEc0AhABAzLhZb+beEPgmXWUY3cLMA0GCSqGSIb3DQEB
# CwUABIIBgE/Q5UYQkUGgl7vglVWdgI4mT/yAkS6ejBNqL4jhiFQ/YxrZ+SuhyvNS
# caeDcNRa5DbQTe/+uyR2wR9Y54wzoM6BS3A4CxNJqy2pT3fPCr00sjLpZxn64rlO
# Tbn55PN3NCZ38SSGtSMd2d7ryv671jJ84gVl2KDfdENAYaDsVq+/eT0Mqlbq3DKG
# 0IVt3SmgeSB4yjUTkJBpr8iA6JBujMdF2jbOjA2gxluDo0Pb6JB9BkAREx1K+azI
# /ryE2p9cn+KvG1xncTWeYbJR00becl76ZzULOvqtCyNKsOe9hLxUFzW7MoUWpuXa
# Lf8/I6Hc6GA+MhDprtNRaZLYkfXNQ//vgMYkDv3Q4zpAFRFklMenKEa543/DEPIw
# VUw0KGK5N850YyVumJVK3f9+/Gdh/o/0F43GLcr7U466gtaWdA1UH3QoL0CM/5Wf
# /Oq6E9SOz/NdG6MMVbhQWab30UFtwvbcjqKIucmhjjPHTtaXww1mCAAp4mk1Vc4S
# /4HVVvKa4g==
# SIG # End signature block
