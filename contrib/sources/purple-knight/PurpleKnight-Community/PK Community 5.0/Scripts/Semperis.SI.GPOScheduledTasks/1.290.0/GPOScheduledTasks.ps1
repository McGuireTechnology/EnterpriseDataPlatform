[CmdletBinding()]
param(
    [Parameter(Mandatory,ParameterSetName='Execution')][string]$ForestName,
    [Parameter(Mandatory,ParameterSetName='Execution')][string[]]$DomainNames,
    [Parameter(ParameterSetName='Execution')]$StartAttackWindow,
    [Parameter(ParameterSetName='Execution')]$EndAttackWindow,
    [Parameter(ParameterSetName='Metadata',Mandatory)][switch]$Metadata
)

$Global:self = @{
    ID = 316
    UUID = '20cacac3-f001-41ca-8a96-3dd02e429f37'
    Version = '1.290.0'
    CategoryID = 4
    ShortName = 'SI000316'
    Name = 'GPO with Scheduled Tasks configured'
    ScriptName = 'GPOScheduledTasks'
    Description = 'When a scheduled task launches an executable, it checks to see if low-privilege users have permissions to modify GPOs.'
    Weight = 2
    Severity = 'Informational'
    Schedule = '1w'
    Impact = 2
    LikelihoodOfCompromise = 'Scheduled tasks configured through group policies can be risky if not set up correctly.
      They can cause unintended problems and potential security vulnerabilities in the following situations:
      <ul>
      <li><b>Missing path specification for executable files launched by the Task Scheduler:</b> When setting up a scheduled task, it''s important to provide the complete path to the executable file. This helps reduce the risk of path manipulation attacks. Path manipulation involves manipulating the search path or taking advantage of vulnerabilities in the path resolution mechanism to execute a malicious program. By explicitly specifying the complete path, you minimize the reliance on potentially vulnerable search path resolution mechanisms and decrease the chances of path manipulation exploits.</li>
      <li><b>Executables located in unsecure locations:</b> If scheduled tasks are configured to launch executables from locations where standard users have write access, it poses a potential risk. Standard users having write access to these directories can replace the intended program with a malicious one. This can lead to privilege escalation, where the malicious program gains higher privileges than it should have, resulting in security breaches and compromising the system''s security.</li></ul>'
    ResultMessage = 'Found {0} GPO set with Scheduled Tasks'
    Remediation = 'It is crucial to properly configure group policies with scheduled tasks and grant appropriate levels of access to users and groups in order to inhibit misuse and abuse.'
    Types = @('IoE')
    DataSources = @('AD.LDAP')
    OutputFields = @(
        @{ Name = 'GpoName'; Type = 'String'; IsCollection = $false },
        @{ Name = 'GPOFilePath'; Type = 'String'; IsCollection = $false },
        @{ Name = 'ScheduledTaskName'; Type = 'String'; IsCollection = $false },
        @{ Name = 'UserContext'; Type = 'String'; IsCollection = $false },
        @{ Name = 'Executable'; Type = 'String'; IsCollection = $false },
        @{ Name = 'RunLevel'; Type = 'String'; IsCollection = $false },
        @{ Name = 'TaskType'; Type = 'String'; IsCollection = $false },
        @{ Name = 'UsersWithPrivOnFile'; Type = 'String'; IsCollection = $false },
        @{ Name = 'UsersWithPrivOnFolder'; Type = 'String'; IsCollection = $false },
        @{ Name = 'Result'; Type = 'String'; IsCollection = $false },
        @{ Name = 'LinkedOUs'; Type = 'String'; IsCollection = $false }
    )
    Targets = @('AD')
    Permissions = @()
    SecurityFrameworks = @(
        @{ Name = 'MITRE ATT&CK'; Tags = @('Privilege Escalation', 'Lateral Movement') },
        @{ Name = 'MITRE D3FEND'; Tags = @('Detect - Script Execution Analysis', 'Detect - File Creation Analysis') }
    )
    Products = @(
        @{ Name = 'HYD'; MinVersion = '1.0'; MaxVersion = '3.0'; Licenses = @('Cloud') },
        @{ Name = 'DSP'; MinVersion = '3.5'; MaxVersion = '10'; Licenses = @('DSP-I') },
        @{ Name = 'PK'; MinVersion = '2.5'; MaxVersion = '10'; Licenses = @('Community', 'Post-Breach', 'BPIR') }
    )
    IgnoreListSupport = $true
    Selected = 1
}
if($Metadata){ return $self | ConvertTo-Json -Depth 8 -Compress }

Import-Module -Name 'Semperis-Lib'

try{

    $res = New-Result
    if ($PSBoundParameters['ForestName'] -and $PSBoundParameters['DomainNames']) {
        $ForestName = $ForestName.ToLower()
        $DomainNames = ConvertTo-Lowercase -DomainNames $DomainNames
    }
    $trustedForestSid = @()
    $trustedDomain = @()
    $unavailableDomains = [System.Collections.ArrayList]@()
    foreach ($domain in $DomainNames) {
        if (-not (Confirm-DomainAvailability $domain)) {
            [void]$unavailableDomains.Add($domain)
            continue
        }
        # Create trusted sids list
        $domainSID = Get-DomainSID $domain
        if($domainSID){
            $trustedDomain += @(
                "$domainSID-500", "$domainSID-512", "$domainSID-516", "$domainSID-517", "$domainSID-520", "$domainSID-526", "$domainSID-527",
                "$domainSID-498","$domainSID-521"
            )
        }
        if ($domain -eq $ForestName) {
            $trustedForestSid += "$domainSID-518", "$domainSID-519"
        }
    }

    $trustedSids = @(
        "S-1-3-0", "S-1-3-1","S-1-3-4","S-1-5-9","S-1-5-18","S-1-5-19","S-1-5-20",
        "S-1-5-32-544","S-1-5-32-548","S-1-5-32-549","S-1-5-32-550", "S-1-5-32-551", "S-1-5-32-552","S-1-16-12288","S-1-16-16384", "S-1-16-20480","S-1-16-28672",
        "S-1-5-32-557","S-1-5-32-562","S-1-5-32-577","S-1-5-32-578","S-1-5-32-580","NT Service\TrustedInstaller","S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464"
    )
    $trusted = $trustedDomain + $trustedSids + $trustedForestSid
    $outputObjects = [System.Collections.ArrayList]@()
    $filesToSearch = @("ScheduledTasks.xml")

    foreach ($domain in $DomainNames) {
        if ($unavailableDomains.Contains($domain)) {
            continue
        }
        elseif (-not (Confirm-DomainAvailability $domain)) {
            [void]$unavailableDomains.Add($domain)
            continue
        }

        try {
            $LinkedOUs = Get-LinkedOU -ForestName $domain
        }
        catch {
            $LinkedOUs = $null
        }
        $DN = Get-DN $domain

        $files = @()
        $searchParams = @{
            dnsDomain = $domain
            attributes = @("gpcfilesyspath", "flags","cn", "displayName")
            baseDN = $DN
            scope = "subtree"
            filter = "(&(objectClass=groupPolicyContainer))"
        }

        $results = Search-AD @searchParams
        foreach ($result in $results) {
            $policyFiles = Get-ChildItem -path $result.Attributes.gpcfilesyspath[0] -Recurse -Include $filesToSearch -Force
            foreach ($pFile in $policyFiles) {
                $files += $pFile.FullName
            }

            foreach ($file in $policyFiles) {
                $scheduledTaskXml = [xml](Get-Content $file)
                $scheduledTasks = $scheduledTaskXml.ScheduledTasks
                $gpoCN = $result.Attributes.cn[0]

                if ($scheduledTasks.Task) {
                    foreach ($task in $scheduledTasks.Task) {
                        $name = $task.name
                        $userContext = $task.userContext
                        $executables = $task.Properties.appName
                        if ($executables) {
                            foreach ($executable in $executables) {
                                $outFile, $outFolder, $outMessage = Get-UsersFromACL -Path $executable -Trusted $trusted
                                $thisOutput = [PSCustomObject][Ordered] @{
                                    GpoName =$result.Attributes.displayname[0]
                                    GPOFilePath = $result.Attributes.gpcfilesyspath[0]
                                    ScheduledTaskName = $name
                                    UserContext = $userContext
                                    Executable = $executable
                                    RunLevel = "N/A"
                                    TaskType = "Task"
                                    UsersWithPrivOnFile = $outFile
                                    UsersWithPrivOnFolder = $outFolder
                                    Result = $outMessage
                                    LinkedOUs = Get-LinkedOUsFromGpoCn -LinkedOUsHM $LinkedOUs -gpoCN $gpoCN
                                }
                                [void]$outputObjects.Add($thisOutput)
                            }
                        }
                        else {
                            $outFile = "N/A"
                            $outFolder = "N/A"
                            $outMessage = "N/A"
                            $thisOutput = [PSCustomObject][Ordered] @{
                                GpoName =$result.Attributes.displayname[0]
                                GPOFilePath = $result.Attributes.gpcfilesyspath[0]
                                ScheduledTaskName = $name
                                UserContext = $userContext
                                Executable = $executables
                                RunLevel = "N/A"
                                TaskType = "Task"
                                UsersWithPrivOnFile = $outFile
                                UsersWithPrivOnFolder = $outFolder
                                Result = $outMessage
                                LinkedOUs = Get-LinkedOUsFromGpoCn -LinkedOUsHM $LinkedOUs -gpoCN $gpoCN
                            }
                            [void]$outputObjects.Add($thisOutput)
                        }

                    }
                }
                if ($scheduledTasks.ImmediateTask) {
                    foreach ($task in $scheduledTasks.ImmediateTask) {
                        $name = $task.name
                        $executables = $task.appName
                        $userContext = $task.userContext
                        $gpoCN = $result.Attributes.cn[0]
                        if ($executables) {
                            foreach ($executable in $executables) {
                                $outFile, $outFolder, $outMessage = Get-UsersFromACL -Path $executable -Trusted $trusted
                                $thisOutput = [PSCustomObject][Ordered] @{
                                    GpoName =$result.Attributes.displayname[0]
                                    GPOFilePath = $result.Attributes.gpcfilesyspath[0]
                                    ScheduledTaskName = $name
                                    UserContext = $userContext
                                    Executable = $executable
                                    RunLevel = "N/A"
                                    TaskType = "ImmediateTask"
                                    UsersWithPrivOnFile = $outFile
                                    UsersWithPrivOnFolder = $outFolder
                                    Result = $outMessage
                                    LinkedOUs = Get-LinkedOUsFromGpoCn -LinkedOUsHM $LinkedOUs -gpoCN $gpoCN
                                }
                                [void]$outputObjects.Add($thisOutput)
                            }
                        }
                        else {
                            $outFile = "N/A"
                            $outFolder = "N/A"
                            $outMessage = "N/A"
                            $thisOutput = [PSCustomObject][Ordered] @{
                                GpoName =$result.Attributes.displayname[0]
                                GPOFilePath = $result.Attributes.gpcfilesyspath[0]
                                ScheduledTaskName = $name
                                UserContext = $userContext
                                Executable = $executables
                                RunLevel = "N/A"
                                TaskType = "ImmediateTask"
                                UsersWithPrivOnFile = $outFile
                                UsersWithPrivOnFolder = $outFolder
                                Result = $outMessage
                                LinkedOUs = Get-LinkedOUsFromGpoCn -LinkedOUsHM $LinkedOUs -gpoCN $gpoCN
                            }
                            [void]$outputObjects.Add($thisOutput)
                        }

                    }
                }
                if ($scheduledTasks.TaskV2) {
                    foreach ($task in $scheduledTasks.TaskV2) {
                        $name = $task.name
                        $executables = $task.Properties.Task.Actions.Exec.Command
                        $userContext = $task.Properties.runAs
                        $runLevel = $task.Properties.Task.Principals.Principal.RunLevel
                        $gpoCN = $result.Attributes.cn[0]
                        if ($executables) {
                            foreach ($executable in $executables) {
                                $outFile, $outFolder, $outMessage = Get-UsersFromACL -Path $executable -Trusted $trusted
                                $thisOutput = [PSCustomObject][Ordered] @{
                                    GPOName = $result.Attributes.displayname[0]
                                    GPOFilePath = $result.Attributes.gpcfilesyspath[0]
                                    ScheduledTaskName = $name
                                    UserContext = $userContext
                                    Executable = $executable
                                    RunLevel = $runLevel
                                    TaskType = "TaskV2"
                                    UsersWithPrivOnFile = $outFile
                                    UsersWithPrivOnFolder = $outFolder
                                    Result = $outMessage
                                    LinkedOUs = Get-LinkedOUsFromGpoCn -LinkedOUsHM $LinkedOUs -gpoCN $gpoCN
                                }
                                [void]$outputObjects.Add($thisOutput)
                            }
                        }
                        else {
                            $outFile = "N/A"
                            $outFolder = "N/A"
                            $outMessage = "N/A"
                            $thisOutput = [PSCustomObject][Ordered] @{
                                GPOName = $result.Attributes.displayname[0]
                                GPOFilePath = $result.Attributes.gpcfilesyspath[0]
                                ScheduledTaskName = $name
                                UserContext = $userContext
                                Executable = $executables
                                RunLevel = $runLevel
                                TaskType = "TaskV2"
                                UsersWithPrivOnFile = $outFile
                                UsersWithPrivOnFolder = $outFolder
                                Result = $outMessage
                                LinkedOUs = Get-LinkedOUsFromGpoCn -LinkedOUsHM $LinkedOUs -gpoCN $gpoCN
                            }
                            [void]$outputObjects.Add($thisOutput)
                        }
                    }
                }
                if ($scheduledTasks.ImmediateTaskV2) {
                    foreach ($task in $scheduledTasks.ImmediateTaskV2) {
                        $name = $task.name
                        $executables = $task.Properties.Task.Actions.Exec.Command
                        $userContext = $task.Properties.runAs
                        $runLevel = $task.Properties.Task.Principals.Principal.RunLevel
                        $gpoCN = $result.Attributes.cn[0]
                        if ($executables) {
                            foreach ($executable in $executables) {
                                $outFile, $outFolder, $outMessage = Get-UsersFromACL -Path $executable -Trusted $trusted
                                $thisOutput = [PSCustomObject][Ordered] @{
                                    GPOName = $result.Attributes.displayname[0]
                                    GPOFilePath = $result.Attributes.gpcfilesyspath[0]
                                    ScheduledTaskName = $name
                                    UserContext = $userContext
                                    Executable = $executable
                                    RunLevel = $runLevel
                                    TaskType = "ImmediateTaskV2"
                                    UsersWithPrivOnFile = $outFile
                                    UsersWithPrivOnFolder = $outFolder
                                    Result = $outMessage
                                    LinkedOUs = Get-LinkedOUsFromGpoCn -LinkedOUsHM $LinkedOUs -gpoCN $gpoCN
                                }
                                [void]$outputObjects.Add($thisOutput)
                            }
                        }
                        else {
                            $outFile = "N/A"
                            $outFolder = "N/A"
                            $outMessage = "N/A"
                            $thisOutput = [PSCustomObject][Ordered] @{
                                GPOName = $result.Attributes.displayname[0]
                                GPOFilePath = $result.Attributes.gpcfilesyspath[0]
                                ScheduledTaskName = $name
                                UserContext = $userContext
                                Executable = $executables
                                RunLevel = $runLevel
                                TaskType = "ImmediateTaskV2"
                                UsersWithPrivOnFile = $outFile
                                UsersWithPrivOnFolder = $outFolder
                                Result = $outMessage
                                LinkedOUs = Get-LinkedOUsFromGpoCn -LinkedOUsHM $LinkedOUs -gpoCN $gpoCN
                            }
                            [void]$outputObjects.Add($thisOutput)
                        }
                    }
                }
            }
        }
    }

    if ($outputObjects.Count -gt 0) {
        $configArgs = @{
            ScriptName = $self.ScriptName
            Path = $MyInvocation.MyCommand.ScriptBlock.File
            Fields = $outputObjects[0]
        }
        $config = Resolve-Configuration @configArgs
        $outputObjects | Set-IgnoredFlag -Configuration $config
        $scoreOutput = $outputObjects | Get-Score -Impact $self.Impact
        if ($scoreOutput.Score -lt 100) {
            $res.ResultObjects = $outputObjects
            $res.ResultMessage = $self.ResultMessage -f $outputObjects.Count
            $res.Remediation = $self.Remediation
            $res.Score = 0
            $res.Status = 'Failed'
        }
        if ($scoreOutput.Ignoredcount -gt 0) {
            $res.ResultMessage += " ($($scoreOutput.Ignoredcount) Objects ignored)."
            $res.ResultObjects = $outputObjects
        }
    }
    else {
        $res.ResultMessage = "No evidence of exposure."
        $res.Remediation = "None"
        $res.Score = 100
        $res.Status = 'Pass'
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
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBPa92MYGSm1adH
# N8h2UC7pDkLS1qpTkBlWqwPvO2pYaqCCE6MwggVyMIIDWqADAgECAhB2U/6sdUZI
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
# 9w0BCQQxIgQgq48Gkl5H9CUTxpbtBvVGobYdy8O3rYsDG8KHaSBzSZwwDQYJKoZI
# hvcNAQEBBQAEggIAVPI0HxellXW1GiqaybMy+3L930k3FTCc+PYBhQrHD9GOJaY1
# qgEsFfMhAf9azP5TrqWLjb5aWtKhT9PsVd/jA8Xpp62N+RbxDEDLom0y+J5Rz0mB
# pV2xyJqLNQwneZHIbiKd4ytgeGPcWGHZFRjeZOkRiD+5brtQJDOpW47SWRDkFzs6
# SMWgz/pHzTCy3rSUh6zBD9md7DFDF/mdgeLuCb3ojWo31wtljDNuJaI3jJ87XpWO
# 7m1jMumsdDwr2KvtSil2ijE2m07Byc2RiMIqaTShY4PXVeoF562bEYjZ+EOsD/8K
# KDpgLnB5l5mtiZtHaofRcKLO944RxCUHhebCwUhDv7ljb2Fvvyq4j3F1F3K7+ntb
# w81+88IosUqf8W4elr9P2Qp/Veul3A5UXRX7uI9CxYY/1q9EHq9SbaeyKy9mYVbl
# MoSwSaOAuu0/CiSNs69JSgNjlQ3tvBjKsMh0lkhQUfiE/R96LjcM29bSzm5sy+GU
# yQvaLzjsBh1PeIHUm29ZvAutW1lxoHzsYaDnVJbEn1/O3YZU9I5rtUkp7XwYRIHx
# bb4NJ9ktD3e+W+9eF3UgzlN+9GCI0kF5oN04V97ofYWz5glvUE3qG26dw9Grjomn
# 8oN9TRTmxkp+eriiI5c2thY6/KnQWSYNJ32b1uXcrsBCvv9JM/PwB3WdWyihgha3
# MIIWswYKKwYBBAGCNwMDATGCFqMwghafBgkqhkiG9w0BBwKgghaQMIIWjAIBAzEN
# MAsGCWCGSAFlAwQCATCB3AYLKoZIhvcNAQkQAQSggcwEgckwgcYCAQEGCSsGAQQB
# oDICAzAxMA0GCWCGSAFlAwQCAQUABCBCCrRV+4GnQXZt+eKmbNWMBdHK289gvPbU
# Hd0er6NJkgIUW1Oa9uChl1IzQ4yWexChRcXypG8YDzIwMjUwNTEzMTg1MDEyWjAD
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
# MC8GCSqGSIb3DQEJBDEiBCBDK83cNYw+Lm0qGaX98kKoHhO5cJhUICA+mB4bGlDy
# ezCBsAYLKoZIhvcNAQkQAi8xgaAwgZ0wgZowgZcEIJGSR5tiNbl2Jr+2AW14CJGD
# cgPYc5HAbBuOPXf/4sc3MHMwX6RdMFsxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBH
# bG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWduIFRpbWVzdGFtcGlu
# ZyBDQSAtIFNIQTM4NCAtIEc0AhABAzLhZb+beEPgmXWUY3cLMA0GCSqGSIb3DQEB
# CwUABIIBgFo4hyfVurlwtqPY4KltfoMPkwsMvlCGfmKAALeavaooPwNJpGrxthns
# ejzgPk+vddMdld49GbFqurpT90EmTXNpYprui3erebV4253ZfHdpjDGPU6xgahTp
# 9tDJNinPZHWAk1rnSDFCcxV3Tr+pPspvf0Guu7IaGJ6O08saFkxk9Zaplxf0JSmg
# 1k0BDlyt/prs96yZXsB+eJKW4lqQN4bglMPQYLd1jpbpyAXEKdMt+4V7jlQlvn+L
# ybvs1hU/UbArAyUpuFSBNUlbKOvK2cm+Tpbd7QjwQowLm3vyfjnCfh3bC+8370Su
# QUsdzQSre/4xDAmFqjO3GhgnFKIeYQqdXhpEDZgW+QpyjqBJdaRURpuJdMl2C3Oz
# C+vkVkK6pVH7zvwEa1dPaHDXtVXilYfmgdHuoEp8hQX0sDh8iEAoKqZ3Cmt5KBWh
# fu83/vd50s41RT2xN0SVPsDgiw/CYIc83JcjNhwrD379rDhT2vG7vphq1I9QDSBu
# 9qusxjd66A==
# SIG # End signature block
