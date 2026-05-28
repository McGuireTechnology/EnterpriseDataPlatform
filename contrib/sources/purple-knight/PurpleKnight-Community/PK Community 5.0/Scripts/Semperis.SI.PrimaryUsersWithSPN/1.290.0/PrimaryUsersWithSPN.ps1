# This script looks for users with SPN associated

[CmdletBinding()]
param(
    [Parameter(Mandatory,ParameterSetName='Execution')][string]$ForestName,
    [Parameter(Mandatory,ParameterSetName='Execution')][string[]]$DomainNames,
    [Parameter(ParameterSetName='Execution')]$StartAttackWindow,
    [Parameter(ParameterSetName='Execution')]$EndAttackWindow,
    [Parameter(ParameterSetName='Metadata',Mandatory)][switch]$Metadata
)

$Global:self = @{
    ID = 42
    UUID = '868c36af-b784-465b-a15c-291bd3c66d47'
    Version = '1.290.0'
    CategoryID = 5
    ShortName = 'SI000042'
    Name = 'Users with SPN defined'
    ScriptName = 'PrimaryUsersWithSPN'
    Description = 'This indicator provides a way to visually inventory all users accounts that have SPNs defined. Generally SPNs are only defined for "Kerberized" services, so if you see an account with an SPN that should not have one, this could be cause for concern.'
    Weight = 3
    Severity = 'Informational'
    Schedule = '1w'
    Impact = 3
    LikelihoodOfCompromise = '<p>SPNs are generally only defined for service accounts or other services that use Kerberos. If you see SPNs on other accounts, they are worth investigating to determine if they are just an administrative error.<p>
        <h3>References</h3>
        <p><a href="https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/audit-user-account-management" target="_blank">Audit User Account Management</a></p>'
    ResultMessage = 'Found {0} users with associated SPN.'
    Remediation = 'If possible use Group Managed Service Accounts instead of regular users or ensure that all users that have an SPN are not primary users and considered as service accounts.'
    Types = @('IoE')
    DataSources = @('AD.LDAP')
    OutputFields = @(
        @{ Name = 'DistinguishedName'; Type = 'String'; IsCollection = $false },
        @{ Name = 'SamAccountName'; Type = 'String'; IsCollection = $false },
        @{ Name = 'ServicePrincipalName'; Type = 'String'; IsCollection = $false },
        @{ Name = 'AESEnabled'; Type = 'Boolean'; IsCollection = $false }
    )
    Targets = @('AD')
    Permissions = @()
    SecurityFrameworks = @(
        @{ Name = 'MITRE ATT&CK'; Tags = @('Privilege Escalation') },
        @{ Name = 'MITRE D3FEND'; Tags = @('Detect - Domain Account Monitoring') }
    )
    Products = @(
        @{ Name = 'HYD'; MinVersion = '1.0'; MaxVersion = '3.0'; Licenses = @('Cloud') },
        @{ Name = 'DSP'; MinVersion = '3.5'; MaxVersion = '10'; Licenses = @('DSP-I') },
        @{ Name = 'PK'; MinVersion = '1.4'; MaxVersion = '10'; Licenses = @('Community', 'Post-Breach', 'BPIR') }
    )
    IgnoreListSupport = $true
    Selected = 1
}
if($Metadata){ return $self | ConvertTo-Json -Depth 8 -Compress }

Import-Module -Name 'Semperis-Lib'

$outputObjects = [System.Collections.ArrayList]@()
$failedDomainCount = 0
try {
    if ($PSBoundParameters['ForestName'] -and $PSBoundParameters['DomainNames']) {
        $ForestName = $ForestName.ToLower()
        $DomainNames = ConvertTo-Lowercase -DomainNames $DomainNames
    }
    $res = New-Result

    $attributes = @("serviceprincipalname","samaccountname", "msds-supportedencryptiontypes")
    $unavailableDomains = [System.Collections.ArrayList]@()
    foreach ($domain in $DomainNames) {
        if (-not (Confirm-DomainAvailability $domain)) {
            [void]$unavailableDomains.Add($domain)
            continue
        }
        $results = @()
        $DN = Get-DN $domain

        # Get a list of all users that has SPN associated
        $searchParams = @{
            dnsDomain = $domain
            attributes = $attributes
            baseDN = $DN
            scope = "subtree"
            filter = "(&(objectCategory=person)(objectClass=user)(servicePrincipalName=*)(!(servicePrincipalName=kadmin/changepw)))"
            PropertyFilter = "servicePrincipalName"
            StartAttackWindow = $StartAttackWindow
            EndAttackWindow = $EndAttackWindow
        }

        $results = Search-ADHelper @searchParams -ExcludeScriptblock

        if ($results.Count) {
            $failedDomainCount++
            foreach($result in $results) {
                $aes = $false
                $SET = $result.attributes."msds-supportedencryptiontypes"[0]
                if ($SET -in (8,16,24)) {
                    $aes = $True
                }
                if ($result.Attributes."serviceprincipalname") {
                    $spn = $result.Attributes."serviceprincipalname".GetValues("string") -join "; "
                }
                else {
                    $spn = $null
                }
                $thisOutput = [PSCustomObject][Ordered] @{
                    DistinguishedName = $result.DistinguishedName
                    SamAccountName = $result.Attributes."samaccountname"[0]
                    ServicePrincipalName = $spn
                    AESEnabled = $aes
                }
                $attrMetaData = $result.Attributes.'attributemetadata'
                Update-IndicatorOutputAttackWindow -ThisOutput $thisOutput -Metadata $attrMetaData `
                    -StartAttackWindow $StartAttackWindow -EndAttackWindow $EndAttackWindow -ExcludeTimestamp
                [void]$outputObjects.Add($thisOutput)
            }
        }
    }

    # Count is the number of domains that failed the test
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
            $res.ResultMessage = "Found $($outputObjects.Count) users with associated SPN."
            $res.Remediation = "If possible use Group Managed Service Accounts instead of regular users or ensure that all users that have an SPN are not primary users and considered as service accounts."
            $res.Status = 'Failed'
            $res.Score = $scoreOutput.Score
        }
        if ($scoreOutput.Ignoredcount -gt 0)
        {
            $res.ResultMessage += " ($($scoreOutput.Ignoredcount) Objects ignored)."
            $res.ResultObjects = $outputObjects
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
# MIIuIgYJKoZIhvcNAQcCoIIuEzCCLg8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBTuMfK+jtfqTxV
# Vf9rgTWoL8mS1L41/LtBG2uXEJeUbKCCE6MwggVyMIIDWqADAgECAhB2U/6sdUZI
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
# sUxkJCMAt0B9E7sFVDGCGdUwghnRAgEBMGkwWTELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoTEEdsb2JhbFNpZ24gbnYtc2ExLzAtBgNVBAMTJkdsb2JhbFNpZ24gR0NDIFI0
# NSBDb2RlU2lnbmluZyBDQSAyMDIwAgxsjPy20SAh5jGEkUUwDQYJYIZIAWUDBAIB
# BQCggYQwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYK
# KwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG
# 9w0BCQQxIgQgkQ6vGKzBAsSownfAgOVtxi1YttbAYHAOfLGueL/khWQwDQYJKoZI
# hvcNAQEBBQAEggIAKNYeF6qRDt69CEdnygFaeN6hpVTtTeTN7WHRjnl8MV1Wm1p/
# Wg0QnaM6a7OvVrAuKQPllbMdGcFUwheFt3ti5Ee1OApqyUkWvc1jvXkdAQIgriUZ
# uX4qZLq9io0yIi93sn0CRN9TT5D4Dbll5P6c83v8iLigF7xmKA4n+Ew3FSTe7lhY
# scw2WHBb3Gk6Qq48eDaUdymJq/ucTk2dTJ+GxXgCtKcKjDQ8eBm94eB9wdo6JDWC
# JVx2h1vvG3tVmBU/+TUOLMElyorgBog8gk4N6A+DxSac4menK8n2nzC/YHv4LAVp
# GyhUPQJdRDlABp0rPXy1g9UNjWcu/CHm00OBgZ0Faz6dhd9GDj6FgNiL+EECDcZe
# Wpiqeutkl3/35T4DrnhHcSBWTEz2IGXXVxIT3NbrJMQXPbBKl0+5kUTPVwBz2QrJ
# z29ej4Ui4QvI0tAsGeWkExGhJuEAdU+w4x6CDMuaCz/0hJK+Id5LrHHMrdk73W/p
# M+6Mgjvylg1HWx1DFifZHSO1FXeHGtaBz4WUnjgmlzqEI9Z/P5fb1lg47h0AfAX+
# sRLDERTNZSDDYkjHjKmdqNj1UVvCQmag1eMeabzQ/yLR03vUIjRY9Bx6d6kmVpMy
# yaMP3psU9ROWrTtkaGgL2MFYf1TAvTJo5yb+xhoXdMSbpJfApYRMgVlaEYChgha2
# MIIWsgYKKwYBBAGCNwMDATGCFqIwghaeBgkqhkiG9w0BBwKgghaPMIIWiwIBAzEN
# MAsGCWCGSAFlAwQCATCB2wYLKoZIhvcNAQkQAQSggcsEgcgwgcUCAQEGCSsGAQQB
# oDICAzAxMA0GCWCGSAFlAwQCAQUABCDmOY4s+V25SiI9twePOUGM23iUY5pyyHnI
# QRVLhCx8fwITMH7WjcCyC3R9qTkKoXa5K2/e2xgPMjAyNTA1MTMxODUyMDRaMAMC
# AQGgV6RVMFMxCzAJBgNVBAYTAkJFMRkwFwYDVQQKDBBHbG9iYWxTaWduIG52LXNh
# MSkwJwYDVQQDDCBHbG9iYWxzaWduIFRTQSBmb3IgQWR2YW5jZWQgLSBHNKCCEkow
# ggZiMIIESqADAgECAhABAzLhZb+beEPgmXWUY3cLMA0GCSqGSIb3DQEBDAUAMFsx
# CzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMTEwLwYDVQQD
# EyhHbG9iYWxTaWduIFRpbWVzdGFtcGluZyBDQSAtIFNIQTM4NCAtIEc0MB4XDTI1
# MDQxMTE0NDcwMVoXDTM0MTIxMDAwMDAwMFowUzELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoMEEdsb2JhbFNpZ24gbnYtc2ExKTAnBgNVBAMMIEdsb2JhbHNpZ24gVFNBIGZv
# ciBBZHZhbmNlZCAtIEc0MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEA
# viV6OUMYrnXW1bOhyJvWJp6egBY3Wa705yeDuCrDzMQ6ryy3LuvI2r/DBa95bNc2
# Etq2M14xDSfz4T0DgRuzO+5EaCaeM+TI9SYlL+CQ2QNH9CZlXUHEvKwJASE97Bkg
# Ri9AH2xlvdUzZb3iIKRExVpwIy1EqrZGyoB56jy+O2zIabgyCldI4gkEczqvgXMo
# FnL5GxO3OPRGODfp6SUj+ewwtoIgoP4Tt2AKXvti+G+FvHwbN692T+9jUfwRAJcF
# lrok219HoNosPCyHyDFNzMjmxF0jfKZik2i/zKZXAHO6fcpbgyyTQEwifbl9zG9v
# nTWEgh8qmdcBkQrNo9AYMPGWTHs811TNfD54Xp5XMlh5OgtFc5qY4ditJf74wvQI
# 68+rayD8Z5eUcvV4xv9SGMopTSvG2KDWyMMwezAahBhJ9LbM3NbU2h4dEUKBL86w
# npWBYtyXMUgWkZPMCtmIqW7xlptv5cg7yUA/H11BT/oALQxOlXEb1UmsMJDLShhP
# AgMBAAGjggGoMIIBpDAOBgNVHQ8BAf8EBAMCB4AwFgYDVR0lAQH/BAwwCgYIKwYB
# BQUHAwgwHQYDVR0OBBYEFNk3tjNFbo81B873qbMK/aCpyPmCMFYGA1UdIARPME0w
# CAYGZ4EMAQQCMEEGCSsGAQQBoDIBHjA0MDIGCCsGAQUFBwIBFiZodHRwczovL3d3
# dy5nbG9iYWxzaWduLmNvbS9yZXBvc2l0b3J5LzAMBgNVHRMBAf8EAjAAMIGQBggr
# BgEFBQcBAQSBgzCBgDA5BggrBgEFBQcwAYYtaHR0cDovL29jc3AuZ2xvYmFsc2ln
# bi5jb20vY2EvZ3N0c2FjYXNoYTM4NGc0MEMGCCsGAQUFBzAChjdodHRwOi8vc2Vj
# dXJlLmdsb2JhbHNpZ24uY29tL2NhY2VydC9nc3RzYWNhc2hhMzg0ZzQuY3J0MB8G
# A1UdIwQYMBaAFOoWxmnn48tXRTkzpPBAvtDDvWWWMEEGA1UdHwQ6MDgwNqA0oDKG
# MGh0dHA6Ly9jcmwuZ2xvYmFsc2lnbi5jb20vY2EvZ3N0c2FjYXNoYTM4NGc0LmNy
# bDANBgkqhkiG9w0BAQwFAAOCAgEAZh/PBGHEJwwwY50XKVh7MfQ9xpLoAGr8TfF5
# +GcsUvGHT1Qx5vaAT9c8O4ENo5HUCst6WmzBUgtC+SkGzDN+F5pnSP/D5yOr8TTc
# ifscPzwX1ZGfvY3GiRIFUw52kQarJZ1nJ4hy/UNvYSmuZva8jCK4w16zn9+vGoNF
# /bDvbhRfTsu6YthVE0O0fh0iXuqWrJ935yfd7qz+5Y0kY7IXRiT1TfDqJuQBWaj1
# bYmpIxHJxDxwLuy8T+S6rcaDOxxI5mirOfcwpqQ0sONWm73PsaHfpGu6UKupUV29
# kMCCEs8WJcbFVz7snKyVWoXJtsI6TNS8wTTxu93HBGMgwMGA9JJAauEawpEZ3Of0
# w/dUn1CkcK4Cvb2/efi0ZJ2js3nccz7RYFiCZ6yIrMZqPLv3/ilE5+RqZBDMz6J6
# uC2BrRw1qr2EryelusKEHQ1ID6oGlPGCB/SZzOVS95kX4gXohbj40nEFvb+lQV/J
# 9KqDc9H4bcP6BNKQCD91xLQOTl/QmOrS6qROMDjDQvep3gWNk13Sw20BMIghZPsU
# 3qewxI0G1ZI9deZHdT3wB8bT/nXv9IHGIKAC85bHSGYNMJ2lQl9He9qTY7EGVlFD
# F+50CDzQbLxcnbHleVtNwFrIAeEPaO2b3UV0SCUUXFIzTmZL8Al4MTDb0tVlOVGw
# YExjHpAwggZZMIIEQaADAgECAg0B7BySQN79LkBdfEd0MA0GCSqGSIb3DQEBDAUA
# MEwxIDAeBgNVBAsTF0dsb2JhbFNpZ24gUm9vdCBDQSAtIFI2MRMwEQYDVQQKEwpH
# bG9iYWxTaWduMRMwEQYDVQQDEwpHbG9iYWxTaWduMB4XDTE4MDYyMDAwMDAwMFoX
# DTM0MTIxMDAwMDAwMFowWzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNp
# Z24gbnYtc2ExMTAvBgNVBAMTKEdsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0g
# U0hBMzg0IC0gRzQwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDwAuIw
# I/rgG+GadLOvdYNfqUdSx2E6Y3w5I3ltdPwx5HQSGZb6zidiW64HiifuV6PENe2z
# NMeswwzrgGZt0ShKwSy7uXDycq6M95laXXauv0SofEEkjo+6xU//NkGrpy39eE5D
# iP6TGRfZ7jHPvIo7bmrEiPDul/bc8xigS5kcDoenJuGIyaDlmeKe9JxMP11b7Lbv
# 0mXPRQtUPbFUUweLmW64VJmKqDGSO/J6ffwOWN+BauGwbB5lgirUIceU/kKWO/EL
# sX9/RpgOhz16ZevRVqkuvftYPbWF+lOZTVt07XJLog2CNxkM0KvqWsHvD9WZuT/0
# TzXxnA/TNxNS2SU07Zbv+GfqCL6PSXr/kLHU9ykV1/kNXdaHQx50xHAotIB7vSqb
# u4ThDqxvDbm19m1W/oodCT4kDmcmx/yyDaCUsLKUzHvmZ/6mWLLU2EESwVX9bpHF
# u7FMCEue1EIGbxsY1TbqZK7O/fUF5uJm0A4FIayxEQYjGeT7BTRE6giunUlnEYuC
# 5a1ahqdm/TMDAd6ZJflxbumcXQJMYDzPAo8B/XLukvGnEt5CEk3sqSbldwKsDlcM
# CdFhniaI/MiyTdtk8EWfusE/VKPYdgKVbGqNyiJc9gwE4yn6S7Ac0zd0hNkdZqs0
# c48efXxeltY9GbCX6oxQkW2vV4Z+EDcdaxoU3wIDAQABo4IBKTCCASUwDgYDVR0P
# AQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFOoWxmnn48tX
# RTkzpPBAvtDDvWWWMB8GA1UdIwQYMBaAFK5sBaOTE+Ki5+LXHNbH8H/IZ1OgMD4G
# CCsGAQUFBwEBBDIwMDAuBggrBgEFBQcwAYYiaHR0cDovL29jc3AyLmdsb2JhbHNp
# Z24uY29tL3Jvb3RyNjA2BgNVHR8ELzAtMCugKaAnhiVodHRwOi8vY3JsLmdsb2Jh
# bHNpZ24uY29tL3Jvb3QtcjYuY3JsMEcGA1UdIARAMD4wPAYEVR0gADA0MDIGCCsG
# AQUFBwIBFiZodHRwczovL3d3dy5nbG9iYWxzaWduLmNvbS9yZXBvc2l0b3J5LzAN
# BgkqhkiG9w0BAQwFAAOCAgEAf+KI2VdnK0JfgacJC7rEuygYVtZMv9sbB3DG+wsJ
# rQA6YDMfOcYWaxlASSUIHuSb99akDY8elvKGohfeQb9P4byrze7AI4zGhf5LFST5
# GETsH8KkrNCyz+zCVmUdvX/23oLIt59h07VGSJiXAmd6FpVK22LG0LMCzDRIRVXd
# 7OlKn14U7XIQcXZw0g+W8+o3V5SRGK/cjZk4GVjCqaF+om4VJuq0+X8q5+dIZGkv
# 0pqhcvb3JEt0Wn1yhjWzAlcfi5z8u6xM3vreU0yD/RKxtklVT3WdrG9KyC5qucqI
# wxIwTrIIc59eodaZzul9S5YszBZrGM3kWTeGCSziRdayzW6CdaXajR63Wy+ILj19
# 8fKRMAWcznt8oMWsr1EG8BHHHTDFUVZg6HyVPSLj1QokUyeXgPpIiScseeI85Zse
# 46qEgok+wEr1If5iEO0dMPz2zOpIJ3yLdUJ/a8vzpWuVHwRYNAqJ7YJQ5NF7qMnm
# vkiqK1XZjbclIA4bUaDUY6qD6mxyYUrJ+kPExlfFnbY8sIuwuRwx773vFNgUQGwg
# HcIt6AvGjW2MtnHtUiH+PvafnzkarqzSL3ogsfSsqh3iLRSd+pZqHcY8yvPZHL9T
# TaRHWXyVxENB+SXiLBB+gfkNlKd98rUJ9dhgckBQlSDUQ0S++qCV5yBZtnjGpGqq
# IpswggWDMIIDa6ADAgECAg5F5rsDgzPDhWVI5v9FUTANBgkqhkiG9w0BAQwFADBM
# MSAwHgYDVQQLExdHbG9iYWxTaWduIFJvb3QgQ0EgLSBSNjETMBEGA1UEChMKR2xv
# YmFsU2lnbjETMBEGA1UEAxMKR2xvYmFsU2lnbjAeFw0xNDEyMTAwMDAwMDBaFw0z
# NDEyMTAwMDAwMDBaMEwxIDAeBgNVBAsTF0dsb2JhbFNpZ24gUm9vdCBDQSAtIFI2
# MRMwEQYDVQQKEwpHbG9iYWxTaWduMRMwEQYDVQQDEwpHbG9iYWxTaWduMIICIjAN
# BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAlQfoc8pm+ewUyns89w0I8bRFCyyC
# tEjG61s8roO4QZIzFKRvf+kqzMawiGvFtonRxrL/FM5RFCHsSt0bWsbWh+5NOhUG
# 7WRmC5KAykTec5RO86eJf094YwjIElBtQmYvTbl5KE1SGooagLcZgQ5+xIq8ZEwh
# HENo1z08isWyZtWQmrcxBsW+4m0yBqYe+bnrqqO4v76CY1DQ8BiJ3+QPefXqoh8q
# 0nAue+e8k7ttU+JIfIwQBzj/ZrJ3YX7g6ow8qrSk9vOVShIHbf2MsonP0KBhd8hY
# dLDUIzr3XTrKotudCd5dRC2Q8YHNV5L6frxQBGM032uTGL5rNrI55KwkNrfw77Yc
# E1eTtt6y+OKFt3OiuDWqRfLgnTahb1SK8XJWbi6IxVFCRBWU7qPFOJabTk5aC0fz
# BjZJdzC8cTflpuwhCHX85mEWP3fV2ZGXhAps1AJNdMAU7f05+4PyXhShBLAL6f7u
# j+FuC7IIs2FmCWqxBjplllnA8DX9ydoojRoRh3CBCqiadR2eOoYFAJ7bgNYl+dwF
# nidZTHY5W+r5paHYgw/R/98wEfmFzzNI9cptZBQselhP00sIScWVZBpjDnk99bOM
# ylitnEJFeW4OhxlcVLFltr+Mm9wT6Q1vuC7cZ27JixG1hBSKABlwg3mRl5HUGie/
# Nx4yB9gUYzwoTK8CAwEAAaNjMGEwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQF
# MAMBAf8wHQYDVR0OBBYEFK5sBaOTE+Ki5+LXHNbH8H/IZ1OgMB8GA1UdIwQYMBaA
# FK5sBaOTE+Ki5+LXHNbH8H/IZ1OgMA0GCSqGSIb3DQEBDAUAA4ICAQCDJe3o0f2V
# Us2ewASgkWnmXNCE3tytok/oR3jWZZipW6g8h3wCitFutxZz5l/AVJjVdL7BzeIR
# ka0jGD3d4XJElrSVXsB7jpl4FkMTVlezorM7tXfcQHKso+ubNT6xCCGh58RDN3ky
# vrXnnCxMvEMpmY4w06wh4OMd+tgHM3ZUACIquU0gLnBo2uVT/INc053y/0QMRGby
# 0uO9RgAabQK6JV2NoTFR3VRGHE3bmZbvGhwEXKYV73jgef5d2z6qTFX9mhWpb+Gm
# +99wMOnD7kJG7cKTBYn6fWN7P9BxgXwA6JiuDng0wyX7rwqfIGvdOxOPEoziQRpI
# enOgd2nHtlx/gsge/lgbKCuobK1ebcAF0nu364D+JTf+AptorEJdw+71zNzwUHXS
# Nmmc5nsE324GabbeCglIWYfrexRgemSqaUPvkcdM7BjdbO9TLYyZ4V7ycj7PVMi9
# Z+ykD0xF/9O5MCMHTI8Qv4aW2ZlatJlXHKTMuxWJU7osBQ/kxJ4ZsRg01Uyduu33
# H68klQR4qAO77oHl2l98i0qhkHQlp7M+S8gsVr3HyO844lyS8Hn3nIS6dC1hASB+
# ftHyTwdZX4stQ1LrRgyU4fVmR3l31VRbH60kN8tFWk6gREjI2LCZxRWECfbWSUnA
# ZbjmGnFuoKjxguhFPmzWAtcKZ4MFWsmkEDGCA0kwggNFAgEBMG8wWzELMAkGA1UE
# BhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExMTAvBgNVBAMTKEdsb2Jh
# bFNpZ24gVGltZXN0YW1waW5nIENBIC0gU0hBMzg0IC0gRzQCEAEDMuFlv5t4Q+CZ
# dZRjdwswCwYJYIZIAWUDBAIBoIIBLTAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQ
# AQQwKwYJKoZIhvcNAQk0MR4wHDALBglghkgBZQMEAgGhDQYJKoZIhvcNAQELBQAw
# LwYJKoZIhvcNAQkEMSIEIJOvw8ngvfuUISOQcCAuSA1SWH8x5fo143t9+ytkjiRm
# MIGwBgsqhkiG9w0BCRACLzGBoDCBnTCBmjCBlwQgkZJHm2I1uXYmv7YBbXgIkYNy
# A9hzkcBsG449d//ixzcwczBfpF0wWzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEds
# b2JhbFNpZ24gbnYtc2ExMTAvBgNVBAMTKEdsb2JhbFNpZ24gVGltZXN0YW1waW5n
# IENBIC0gU0hBMzg0IC0gRzQCEAEDMuFlv5t4Q+CZdZRjdwswDQYJKoZIhvcNAQEL
# BQAEggGAEPNr/8zzUYqFgpw8UkShpVy9YZQuFG7hv9XpMmTTd7p8HiV+ub9FAIEt
# h9Gs62zUyLzn/M1sFkj+CKeRw7XSjDRWsBefYIwMwBR0v+0scCPOAuUGCH6hGarw
# N//skKJhzH0WbfSEF+ek/Ts75DBT/jRWGsjNYspgqntSGRYilmPlPW1dvB5lD8NM
# qscOwO3+9GnyO56qHfPw+oDa0ORDiaEc6I/PwM219KIVKrpx4HfUfy4WvQwhgCx8
# PSDYqETG5WO5hQSa3Pj415MG7jez8CPJp/NgY2TjiLHsif3Ryvpjn2wVWBdqkXpP
# h1KzknMfPiAM3IA3FIgEy8lnlLYX5LcCBG++rQu6ygPswbsH2R7Av3COUQxsfUDn
# JH5wlKa/5GU6eLAJeSJeoGcn0vZrLt7s5ZrFYa+RJnKq8KI4YPJGKDQ3S+1q/D0v
# 46OF4jG3JOeKbz5ReQluDdK0PpiR21U8fDuINP9+RetMHXwaf8Bi6gtUXJ4wGK/m
# Inxn95/B
# SIG # End signature block
