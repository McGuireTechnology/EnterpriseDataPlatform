# This script checks if privileged users have credentials cached on RODCs

[CmdletBinding()]
param(
    [Parameter(Mandatory,ParameterSetName='Execution')][string]$ForestName,
    [Parameter(Mandatory,ParameterSetName='Execution')][string[]]$DomainNames,
    [Parameter(ParameterSetName='Execution')]$StartAttackWindow,
    [Parameter(ParameterSetName='Execution')]$EndAttackWindow,
    [Parameter(ParameterSetName='Metadata',Mandatory)][switch]$Metadata
)

$Global:self = @{
    ID = 138
    UUID = '5442096e-aee4-4fea-ab7d-a121ea528742'
    Version = '1.291.0'
    CategoryID = 3
    ShortName = 'SI000138'
    Name = 'Privileged user credentials cached on RODC'
    ScriptName = 'RODCPrivilegedCreds'
    Description = '<p>This indicator checks for privileged user credentials that are cached to RODCs.</p>'
    Weight = 4
    Severity = 'Informational'
    Schedule = '1w'
    Impact = 4
    LikelihoodOfCompromise = '<p>In many instances, read-only domain controllers (RODCs) are deployed in area where there is a lower level of physical security to the servers.</p>
      <p>Attackers may try to target read-only domain controllers due to the lower level of security around these. While it is not a direct indicator of an attack, credentials for privileged users should not be cached on RODCs in the case the domain controller is compromised.</p>
      <h3>References</h3>
      <p><a href="https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-r2-and-2008/cc753223(v=ws.10)" target="_blank">RODC Features | Microsoft Learn</a></p>'
    ResultMessage = 'Found {0} privileged users with credentials cached to an RODC.'
    Remediation = '<p>It is recommended to adjust the password replication policy on the RODC to deny replication of credentials for the identified privileged users.</p>
      <p>You can review the current settings by opening <b>Active Directory Users and Computers</b>, locate the identified <b>RODC</b>, and then right-click and select <b>Properties</b>.</p>
      <p>In the <b>Properties</b> of the RODC, select the <b>Password Replication Policy</b> tab.</p>
      <p>Review the replication policies, identify the policy that is permitting replication of credentials, and adjust to ensure there is a deny policy for the privileged users.</p>'
    Types = @('IoE')
    DataSources = @('AD.LDAP')
    OutputFields = @(
        @{ Name = 'DistinguishedName'; Type = 'String'; IsCollection = $false },
        @{ Name = 'RODCName'; Type = 'String'; IsCollection = $false }
    )
    Targets = @('AD')
    Permissions = @()
    SecurityFrameworks = @(
        @{ Name = 'MITRE ATT&CK'; Tags = @('Lateral Movement', 'Privilege Escalation') }
    )
    Products = @(
        @{ Name = 'HYD'; MinVersion = '1.0'; MaxVersion = '3.0'; Licenses = @('Cloud') },
        @{ Name = 'DSP'; MinVersion = '3.5'; MaxVersion = '10'; Licenses = @('DSP-I') },
        @{ Name = 'PK'; MinVersion = '2.0'; MaxVersion = '10'; Licenses = @('Community', 'Post-Breach', 'BPIR') }
    )
    IgnoreListSupport = $true
    Selected = 1
}
if($Metadata){ return $self | ConvertTo-Json -Depth 8 -Compress }

Import-Module -Name 'Semperis-Lib'

$outputObjects = [System.Collections.ArrayList]@()
$failedObject = [System.Collections.ArrayList]@()
$largeGroups = [System.Collections.ArrayList]@()
if ($PSBoundParameters['ForestName'] -and $PSBoundParameters['DomainNames']) {
    $ForestName = $ForestName.ToLower()
    $DomainNames = ConvertTo-Lowercase -DomainNames $DomainNames
}
$forestNetBIOS = Get-NetBIOSName -dnsDomain $forestName -DomainNames $DomainNames -ForestName $ForestName

$script:rodcMatches = @()

function Search-PrivilegedGroup {
    param(
        [string]$targetDomain,
        [string]$targetGroupDN
    )

    try {
        $searchParams = @{
            dnsDomain = $targetDomain
            attributes = @("msds-membertransitive","samAccountName")
            baseDN = $targetGroupDN
            scope = "base"
            filter = "distinguishedname=$targetGroupDN"
        }

        $groupMembers = Search-AD @searchParams

        if ($groupMembers.Attributes."msds-membertransitive;range=0-4499") {
            $groupSAM = $groupMembers.Attributes.samaccountname[0]
            [void]$largeGroups.Add("$forestNetBIOS\$groupSAM")

            $memberAttribute = "msds-membertransitive;range=0-4499"
        }
        else {
            $memberAttribute = "msds-membertransitive"
        }

        if (!($groupMembers.Attributes."msds-membertransitive"[0]) -and !($memberAttribute -match "range")) {
            continue
        }

        foreach ($adminDN in $groupMembers.Attributes.$memberAttribute.GetValues("string")) {
            if ($revealed_users -match $adminDN) {
                $matchedRODC = ($revealed_users -match $adminDN).split(";")[0].replace("$","")
                $matchedPAIR = "$matchedRODC;$adminDN"

                if ($script:rodcMatches.Contains("$matchedPAIR")) {
                    continue
                }

                $script:rodcMatches += $matchedPAIR

                $thisOutput = [PSCustomObject][Ordered] @{
                    DistinguishedName = $adminDN
                    RODCName = $matchedRODC
                }
                [void]$outputObjects.Add($thisOutput)
            }
        }
    }
    catch {
        [void]$failedObject.Add($targetGroupDN)
    }
}

try {
    $res = New-Result


    # In each domain, get revealed credentials for every RODC
    $revealed_users = [System.Collections.ArrayList]@()
    $unavailableDomains = [System.Collections.ArrayList]@()
    foreach ($domain in $DomainNames) {
        if (-not (Confirm-DomainAvailability $domain)) {
            [void]$unavailableDomains.Add($domain)
            continue
        }
        $DN = "DC=$($domain -replace '\.',',DC=')"
        $domainNetBIOS = Get-NetBIOSName -dnsDomain $domain -forestName $forestName -DomainNames $DomainNames

        $searchParams = @{
            dnsDomain = $domain
            attributes = @("msds-revealedlist","samAccountName")
            baseDN = $DN
            scope = "subtree"
            filter = "(primaryGroupId=521)"
        }

        $domainRODCs = Search-AD @searchParams

        foreach ($domainRODC in $domainRODCs) {
            if ($domainRODC.Attributes.'msds-revealedlist') {
                $rodcSAM = $domainRODC.Attributes.samaccountname[0].Replace("$","")
                $rodc_item = "$domainNetBIOS\$rodcSAM"

                $revealed_values = $domainRODC.Attributes.'msds-revealedlist'.GetValues("string")

                foreach ($revealed_value in $revealed_values) {
                    $revealed_user = $revealed_value.split(":")[-1]
                    $revealed_item = "$rodc_item;$revealed_user"
                    if (!$revealed_users.Contains($($revealed_item))) {
                        [void]$revealed_users.Add("$revealed_item")
                    }
                }
            }
        }
    }

    $forestPrivilegedGroups = @("519","518")
    $forestDN = Get-DN $ForestName
    $forestSID = Get-DomainSID $ForestName

    foreach ($groupRID in $forestPrivilegedGroups) {
        $searchParams = @{
            dnsDomain = $ForestName
            attributes = @("")
            baseDN = $forestDN
            scope = "subtree"
            filter = "(&(objectSid=$forestSID-$groupRID)(objectCategory=group))"
        }

        $forestGroupObject = Search-AD @searchParams

        if ($forestGroupObject) {
            $groupDN = $($forestGroupObject.DistinguishedName)
            Search-PrivilegedGroup -targetDomain $ForestName -targetGroupDN $groupDN
        }
    }

    $builtinPrivilegedGroups = @("S-1-5-32-551","S-1-5-32-552","S-1-5-32-548","S-1-5-32-549","S-1-5-32-550","S-1-5-32-544")
    $domainPrivilegedRIDs = @("512","516")

    $privilegedRIDs = @("512","516","518","519")
    $primaryGroupFilter = "(|"
    foreach($privilegedRID in $privilegedRIDs) {
        $primaryGroupFilter += "(primaryGroupID=$privilegedRID)"
    }
    $primaryGroupFilter += ")"

    foreach ($domain in $DomainNames) {
        if ($unavailableDomains.Contains($domain)) {
            continue
        }
        elseif (-not (Confirm-DomainAvailability $domain)) {
            [void]$unavailableDomains.Add($domain)
            continue
        }
        $domainSID = Get-DomainSID $domain
        $DN = Get-DN -dnsDomain $domain

        $domainGroups = [System.Collections.ArrayList]@()

        $searchParams = @{
            dnsDomain = $domain
            attributes = @("")
            baseDN = $DN
            scope = "subtree"
            filter = $primaryGroupFilter
        }

        $primaryResults = Search-AD @searchParams

        foreach ($primaryResult in $primaryResults) {
            $primaryDN = $primaryResult.DistinguishedName

            if ($revealed_users -match $primaryDN) {
                $matchedRODC = ($revealed_users -match $primaryDN).split(";")[0].replace("$","")
                $matchedPAIR = "$matchedRODC;$primaryDN"

                if ($script:rodcMatches.Contains("$matchedPAIR")) {
                    continue
                }

                $script:rodcMatches += $matchedPAIR

                $thisOutput = [PSCustomObject][Ordered] @{
                    DistinguishedName = $primaryDN
                    RODCName = $matchedRODC
                }
                [void]$outputObjects.Add($thisOutput)
            }
        }

        foreach ($domainPrivilegedRID in $domainPrivilegedRIDs) {
            $searchParams = @{
                dnsDomain = $domain
                attributes = @("")
                baseDN = $DN
                scope = "subtree"
                filter = "(&(objectSid=$domainSID-$domainPrivilegedRID)(objectCategory=group))"
            }

            $groupObject = Search-AD @searchParams

            if ($groupObject) {
                [void]$domainGroups.add("$($groupObject.DistinguishedName)")
            }
        }

        # Get a list of the groups DN
        foreach ($sid in $builtinPrivilegedGroups) {
            $searchParams = @{
                dnsDomain = $domain
                attributes = @("")
                baseDN = $DN
                scope = "subtree"
                filter = "(&(objectSid=$sid)(objectCategory=group))"
            }

            $groupObject = Search-AD @searchParams

            if ($groupObject) {
                [void]$domainGroups.add("$($groupObject.DistinguishedName)")
            }
        }

        foreach($groupDN in $domainGroups) {
            Search-PrivilegedGroup -targetDomain $domain -targetGroupDN $groupDN
        }
    }

    # Calculate score
    if ($outputObjects){
        $configArgs = @{
            ScriptName = $self.ScriptName
            Path = $MyInvocation.MyCommand.ScriptBlock.File
            Fields = $outputObjects[0]
        }
        $config = Resolve-Configuration @configArgs
        $outputObjects | Set-IgnoredFlag -Configuration $config
        $scoreOutput = $outputObjects | Get-Score -Impact $self.Impact
        if($scoreOutput.Score -lt 100)
        {
            $res.ResultObjects = $outputObjects
            $res.ResultMessage = $self.ResultMessage -f $($outputObjects.Count)
            $res.Remediation = $self.Remediation
            $res.Status = 'Failed'
            if ($largeGroups) {
                $res.ResultMessage += " While processing group membership, group(s) were discovered to have more than 4500 transitive members. Only the first 4500 members were processed by this indicator. A secure environment should not have such a high number of privileged group members. Please review membership for the following group(s) to ensure only necessary objects are contained:  $($largeGroups -join '; ')."
            }
            if ($failedObject) {
                $res.ResultMessage += " The following objects were identified in the group enumeration but could not be read due to ACL restrictions on the object or OU. It is suggested to check why these objects are hidden.  $($failedObject -join '; ')."
            }
            $res.Score = $scoreOutput.Score
        }
        if ($scoreOutput.Ignoredcount -gt 0)
        {
            $res.ResultMessage += " ($($scoreOutput.Ignoredcount) Objects ignored)."
            $res.ResultObjects = $outputObjects
        }
    }
    else {
        if ($largeGroups) {
            $res.ResultMessage += " While processing group membership, group(s) were discovered to have more than 4500 transitive members. Only the first 4500 members were processed by this indicator. A secure environment should not have such a high number of privileged group members. Please review membership for the following group(s) to ensure only necessary objects are contained:  $($largeGroups -join '; ')."
            $res.Status = 'Error'
        }
        if ($failedObject) {
            $res.ResultMessage += " The following objects were identified in the group enumeration but could not be read due to ACL restrictions on the object or OU. It is suggested to check why these objects are hidden.  $($failedObject -join '; ')."
            $res.Status = 'Error'
        }
    }

    # deal with unavailable domains
    if ($unavailableDomains.Count -gt 0) {
        if ($unavailableDomains.Count -eq $DomainNames.Count) {
            $res.Score = 0
            $res.Status = 'Error'
            $res.ResultMessage = "The following domains were unavailable: $($unavailableDomains -join ', ')."
            $res.Remediation = "None"
        }
        else {
            $res.ResultMessage += " The following domains were unavailable: $($unavailableDomains -join ', ')."
        }
    }
}
catch {
    return ConvertTo-ErrorResult $_
}
return $res

# SIG # Begin signature block
# MIIuIwYJKoZIhvcNAQcCoIIuFDCCLhACAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAqelJVT2cS4tZ2
# FPak7BMLsn39E+X0wbuv35IC8wBGwaCCE6MwggVyMIIDWqADAgECAhB2U/6sdUZI
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
# 9w0BCQQxIgQgLUSOPRLYTXfCA2COjiNUsEFigQu2vUVZw0TPvAeM/4swDQYJKoZI
# hvcNAQEBBQAEggIANban2oAXF7mwV4wwxJo9MX9yJF6i2U3ZGKUvwY6nOUXvdu8Q
# GeoZlI77DkzygRDDgICiPEdj2zTdfFgynzNFHuXwNEruQYIRhEmnw7ekBt7iscNN
# uDcC4kQ3VEr6nkNX3dWlAnC5FppmaOJAOjx6g6TF7jHza4V8Xq2doaByPnLHZ7tv
# /F2847SzWVaZV4ZyqF1N5N34S0Pn5oEcmFu1SZ6DL0mEp5kgnYRr4RKisnIdx9Ie
# b5YLF7XwLGImVpv1QEj2YZcBAxmXvjTikAbGBxYx2TN/UP1uQPk59Fsws9stMne3
# cmX4GRyQHifPiQz1qIpC3o3yb+NK30CKeYnwFlfuXJyBet69ZJnFixxtneF3PBRw
# 988XlwDo7X72h3rKzpAEe1YzVb5PSMCEP830ZUWDQb66zZrv7tCu/cCrK76o1pcq
# DK2Zn25m6TAF3YZVKHIqTilr9Iw7YPFkcrUdgXZMXkmwJ/BVLJGjNbYjtJb2B7uL
# QMsU39oGpkNWH+s+7iMDmaerpd3UrdXuqZAaV32g9Tnk6lEVjh9iCjk3ejlMm62K
# WElfpxk7vU1FbEPS33JlsM9yFmQfhMbE8EaOIaV6/xP5KUprsNeyKCFqmZTmmMAU
# 6GY8TiRqvVaD58TZry/QIkC8Jt9tnMsUkGf1KhSEph3epqanDQ/Zhq0hCaOhgha3
# MIIWswYKKwYBBAGCNwMDATGCFqMwghafBgkqhkiG9w0BBwKgghaQMIIWjAIBAzEN
# MAsGCWCGSAFlAwQCATCB3AYLKoZIhvcNAQkQAQSggcwEgckwgcYCAQEGCSsGAQQB
# oDICAzAxMA0GCWCGSAFlAwQCAQUABCDpKyJtcAlE9Ic4GwXNmZi9tm4sm7dWlQl4
# Q97r1r/VwgIUd9GD7caggVaoMdoxZyttYU8FbTcYDzIwMjUwNTE1MTIzODEwWjAD
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
# MC8GCSqGSIb3DQEJBDEiBCDakvrub58x3oX1tMUvb1OKDLHJWF/1VJXK4Hi1os3C
# RjCBsAYLKoZIhvcNAQkQAi8xgaAwgZ0wgZowgZcEIJGSR5tiNbl2Jr+2AW14CJGD
# cgPYc5HAbBuOPXf/4sc3MHMwX6RdMFsxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBH
# bG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWduIFRpbWVzdGFtcGlu
# ZyBDQSAtIFNIQTM4NCAtIEc0AhABAzLhZb+beEPgmXWUY3cLMA0GCSqGSIb3DQEB
# CwUABIIBgGfCuD32MWBV/cHE2nas/Ix2FjBbUdaVRj5EgrQxRMLKHVCbLEaONyr7
# dBmlz+MnWt1yH+A2UHsDpujFBGYugYLQv7XkiJ2wPIq5Y2lmYJoiz98oO6N6AQPP
# MuSpCWeCIU/zaUalMGeEquKy7p2nLbFvkZsXkzt7E7lc9UM/TKTxMvtwAh9zk1kp
# lWRrs0T7EUDxCMzZLofEjYzhTSoZiKJDP1AujlPniSK8N/U1hfF3j7OQQeYmIbDs
# 3bTtX2fsb1LbG7CkfMSnntNeijbW3CheV2QiCbd3TqsF0nIvk5sJKsLyiBj4Wph7
# NBfRAfrleT8Rpfn2PMe0TN4PAt7U8qRkYtJAWW/BQSyZUPxrvEywNRsx4c9FtpWd
# +FkrpqwofqtDIKiXZTpvi2Cfj8ytd4QRqctIb5xXQi5kq38Us9b7TrVDo10I77Q9
# jK4zx+2QDFN+KYctF8s87Lf7H9GDNzzDl19dBSrTALebYjd68IYDg9Mkb6pwd1r2
# y5RQKAtXfA==
# SIG # End signature block
