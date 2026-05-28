
$AAD_PRIVILEGED_ROLES = @{
    "62e90394-69f5-4237-9190-012177145e10" = "Global administrator"
    "9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3" = "Application administrator"
    "c4e39bd9-1100-46d3-8c65-fb160da0071f" = "Authentication administrator"
    "b0f54661-2d74-4c50-afa3-1ec803f12efe" = "Billing administrator"
    "158c047a-c907-4556-b7ef-446551a6b5f7" = "Cloud application administrator"
    "b1be1c3e-b65d-4f19-8427-f6fa0d97feb9" = "Conditional Access administrator"
    "29232cdf-9323-42fd-ade2-1d097af3e4de" = "Exchange administrator"
    "729827e3-9c14-49f7-bb1b-9608f156bbb8" = "Helpdesk administrator"
    "966707d0-3269-4727-9be2-8c3a10f19b9d" = "Password administrator"
    "7be44c8a-adaf-4e2a-84d6-ab2649e08a13" = "Privileged authentication administrator"
    "194ae4cb-b126-40b2-bd5b-6091b380977d" = "Security administrator"
    "f28a1f50-f6e7-4571-818b-6a12f2af6b6c" = "SharePoint administrator"
    "fe930be7-5e62-47db-91af-98c3a49a38b1" = "User administrator"
    "0526716b-113d-4c15-b2c8-68e3c22b9f80" = "Authentication Policy Administrator"
    "be2f45a1-457d-42af-a067-6ec1fa63bc45" = "External Identity Provider Administrator"
    "e8611ab8-c189-46e8-94e1-60213ab1f814" = "Privileged Role Administrator"
    "cf1c38e5-3621-4004-a7cb-879624dced7c" = "Application Developer"
    "aaf43236-0c0d-4d5f-883a-6955382ac081" = "B2C IEF Keyset Administrator"
    "d29b2b05-8046-44ba-8758-1e26182fcf32" = "Directory Synchronization Accounts"
    "4ba39ca4-527c-499a-b93d-d9b492c50246" = "Partner Tier1 Support"
    "e00e864a-17c5-4a4b-9c06-f5b95a8d5bd8" = "Partner Tier2 Support"
    "f2ef992c-3afb-46b9-b7cf-a126ee74c451" = "Global Reader"
    "25a516ed-2fa0-40ea-a2d0-12923a21473a" = "Authentication Extensibility Administrator"
    "7698a772-787b-4ac8-901f-60d6b08affd2" = "Cloud Device Administrator"
    "9360feb5-f418-4baa-8175-e2a00bac4301" = "Directory Writers"
    "8329153b-31d0-4727-b945-745eb3bc5f31" = "Domain Name Administrator"
    "8ac3fc64-6eca-42ea-9e69-59f4c7b60eb2" = "Hybrid Identity Administrator"
    "3a2c62db-5318-420d-8d74-23affee5d9d5" = "Intune Administrator"
    "59d46f88-662b-457b-bceb-5c3809e5908f" = "Lifecycle Workflows Administrator"
    "5f2222b1-57c3-48ba-8ad5-d4759f1fde6f" = "Security Operator"
    "5d6b6bb7-de71-4623-b4af-96380a352509" = "Security Reader"
}

$DefinedPermissions = @{
    "Read Administrative Units" = @{
        "appRoleIds" = @(
            "134fd756-38ce-4afd-ba33-e9623dbe66c2",
            "7ab1d382-f21e-4acd-a863-ba3e13f7da61",
            "5eb59dd3-1da2-4329-8733-9dabdc435916",
            "19dbc75e-c2e2-444c-a770-ec69d8559fc7"
        );
        "LeastPrivilege" = "AdministrativeUnit.Read.All"
    }

    "Read Authorization Policy" = @{
        "appRoleIds" = @(
            "246dd0d5-5bd0-4def-940b-0421030a5b68",
            "fb221be6-99f2-473f-bd32-01c6a0e9ca3b"
        );
        "LeastPrivilege" = "Policy.Read.All"
    }

    "Read Policy" = @{
        "appRoleIds" = @(
            "246dd0d5-5bd0-4def-940b-0421030a5b68"
        );
        "LeastPrivilege" = "Policy.Read.All"
    }

    "Read Audit Logs" = @{
        "appRoleIds" = @(
            "b0afded3-3588-46d8-8b3d-9842eff778da"
        );
        "LeastPrivilege" = "AuditLog.Read.All"
    }

    "Read Risky Users" = @{
        "appRoleIds" = @(
            "dc5007c0-2d7d-4c42-879c-2dab87571379"
        );
        "LeastPrivilege" = "IdentityRiskyUser.Read.All"
    }

    "Read Directory Roles" = @{
        "appRoleIds" = @(
            "483bed4a-2ad3-4361-a73b-c83ccdbdc53c",
            "7ab1d382-f21e-4acd-a863-ba3e13f7da61",
            "9e3f62cf-ca93-4989-b6ce-bf83c28f9fe8",
            "19dbc75e-c2e2-444c-a770-ec69d8559fc7"
        );
        "LeastPrivilege" = "RoleManagement.Read.Directory"
    }

    "Read Role Schedule Instances" = @{
        "appRoleIds" = @(
            "ff278e11-4a33-4d0c-83d2-d01dc58929a5",
            "483bed4a-2ad3-4361-a73b-c83ccdbdc53c",
            "c7fbd983-d9aa-4fa7-84b8-17382c103bc4",
            "fee28b28-e1f3-4841-818e-2704dc62245f",
            "9e3f62cf-ca93-4989-b6ce-bf83c28f9fe8"
        );
        "LeastPrivilege" = "RoleEligibilitySchedule.Read.Directory"
    }

    "Read Directory Objects" = @{
        "appRoleIds" = @(
            "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
        );
        "LeastPrivilege" = "Directory.Read.All"
    }

    "Read Users" = @{
        "appRoleIds" = @(
            "df021288-bdef-4463-88db-98f22de89214",
            "741f803b-c850-494e-b5df-cde7c675a1ca",
            "7ab1d382-f21e-4acd-a863-ba3e13f7da61",
            "19dbc75e-c2e2-444c-a770-ec69d8559fc7"
        );
        "LeastPrivilege" = "User.Read.All"
    }

    "Read Devices" = @{
        "appRoleIds" = @(
            "7438b122-aefc-4978-80ed-43db9fcc7715",
            "1138cb37-bd11-4084-a2b7-9f71582aeddb",
            "7ab1d382-f21e-4acd-a863-ba3e13f7da61",
            "19dbc75e-c2e2-444c-a770-ec69d8559fc7"
        );
        "LeastPrivilege" = "Device.Read.All"
    }

    "Read Reports" = @{
        "appRoleIds" = @(
            "230c1aed-a721-4c5d-9cb4-a90514e508ef"
        );
        "LeastPrivilege" = "Reports.Read.All"
    }

    "Read Applications" = @{
        "appRoleIds" = @(
            "d8e4ec18-f6c0-4620-8122-c8b1f2bf400e",
            "1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9",
            "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
        );
        "LeastPrivilege" = "Application.Read.All"
    }

    "Read Groups" = @{
        "appRoleIds" = @(
            "98830695-27a2-44f7-8c18-0c3ebc9698f6",
            "5b567255-7703-4780-807c-7be8301ae99b",
            "7ab1d382-f21e-4acd-a863-ba3e13f7da61",
            "62a82d76-70ea-41e2-9197-370581804d09",
            "19dbc75e-c2e2-444c-a770-ec69d8559fc7"
        );
        "LeastPrivilege" = "GroupMember.Read.All"
    }

    "Read User Authentication Method" = @{
        "appRoleIds" = @(
            "38d9df27-64da-44fd-b7c5-a6fbac20248f",
            "50483e42-d915-4231-9639-7fdb7fd190e5"
        );
        "LeastPrivilege" = "UserAuthenticationMethod.Read.All"
    }

    "Read Sync" = @{
        "appRoleIds" = @(
            "bb70e231-92dc-4729-aff5-697b3f04be95"
        );
        "LeastPrivilege" = "OnPremDirectorySynchronization.Read.All"
    }

    "Role Eligibility Schedule Instances" = @{
        "appRoleIds" = @(
            "c7fbd983-d9aa-4fa7-84b8-17382c103bc4",
            "483bed4a-2ad3-4361-a73b-c83ccdbdc53c",
            "9e3f62cf-ca93-4989-b6ce-bf83c28f9fe8"
        );
        "LeastPrivilege" = "RoleManagement.Read.All"
    }

    "Read Role Assignment Schedules" = @{
        "appRoleIds" = @(
            "d5fe8ce8-684c-4c83-a52c-46e882ce4be1",
            "dd199f4a-f148-40a4-a2ec-f0069cc799ec",
            "c7fbd983-d9aa-4fa7-84b8-17382c103bc4",
            "483bed4a-2ad3-4361-a73b-c83ccdbdc53c",
            "9e3f62cf-ca93-4989-b6ce-bf83c28f9fe8"
        );
        "LeastPrivilege" = "RoleAssignmentSchedule.Read.Directory"
    }

    "Read Privileged Eligibility Schedule" = @{
        "appRoleIds" = @(
            "edb419d6-7edc-42a3-9345-509bfdf5d87c"
        );
        "LeastPrivilege" = "PrivilegedEligibilitySchedule.Read.AzureADGroup"
    }

    "Read Organizations" = @{
        "appRoleIds" = @(
            "498476ce-e0fe-48b0-b801-37ba7e2685c6",
            "7ab1d382-f21e-4acd-a863-ba3e13f7da61",
            "292d869f-3427-49a8-9dab-8c70152b74e9",
            "19dbc75e-c2e2-444c-a770-ec69d8559fc7"
        );
        "LeastPrivilege" = "Organization.Read.All"
    }

    "Read Privileged Access" = @{
        "appRoleIds" = @(
            "01e37dc9-c035-40bd-b438-b2879c4870a6"
        );
        "LeastPrivilege" = "PrivilegedAccess.Read.AzureADGroup"
    }

    "Read Role Management Policies" = @{
        "appRoleIds" = @(
            "fdc4c997-9942-4479-bfcb-75a36d1138df"
        );
        "LeastPrivilege" = "RoleManagementPolicy.Read.Directory"
    }

    "Read Mailbox Settings" = @{
        "appRoleIds" = @(
            "40f97065-369a-49f4-947c-6a255697ae91"
        );
        "LeastPrivilege" = "MailboxSettings.Read"
    }
}


$Script:RefreshTokens = @{}

function Get-GraphApiToken {
    <#
    .SYNOPSIS
        Returns access token for specified tenant using security credentials
    .NOTES
        Global variables IOE_ENTRAID_ACCESS_TOKEN and IOE_ENTRAID_REFRESH_TOKEN can be used to override token retrieval
    #>
    [CmdletBinding()]
    param(
        [string] $Scope = 'https://graph.microsoft.com/.default',

        # Explicitly provided credentials
        [string] $TenantId,
        [string] $TenantAppId,
        [string] $TenantAppSecret,

        # Automatic token aquisition
        [string] $RefreshToken
    )

    $accessToken = $Global:IOE_ENTRAID_ACCESS_TOKEN
    if ($null -ne $accessToken) {
        Write-Verbose 'Using assigned Global IOE_ENTRAID_ACCESS_TOKEN'

        $Script:RefreshTokens[$accessToken] = @{
            Scope = $Scope
            RefreshToken = $Global:IOE_ENTRAID_REFRESH_TOKEN
        }
        return $accessToken
    }

    $getToken = @{
        Method = 'POST'
        ContentType = 'application/x-www-form-urlencoded'
    }

    if ($RefreshToken) {
        $getToken += @{
            Uri = "https://login.microsoftonline.com/common/oauth2/v2.0/token"
            Body = @{
                scope = $Scope
                grant_type = 'refresh_token'
                refresh_token = $RefreshToken
            }
        }
    }
    elseif ($TenantId -and $TenantAppId -and $TenantAppSecret) {
        $getToken += @{
            Uri = "https://login.microsoftonline.com/$($TenantId)/oauth2/v2.0/token"
            Body = @{
                scope = $Scope
                grant_type = 'client_credentials'
                client_id = $TenantAppId
                client_secret = $TenantAppSecret
            }
        }
    }
    else {
        throw 'NoEntraIdCredentialsProvided'
    }

    $tokenResult = Invoke-RestMethod @getToken
    $accessToken = $tokenResult.access_token

    # Store credentials, used to get this particular token
    $Script:RefreshTokens[$accessToken] = $PSBoundParameters
    return $accessToken
}

function Update-GraphApiToken {
    <#
    .SYNOPSIS
        Retrieves new token using previously used credentials

    .PARAMETER AccessToken
        Previously used and expired token
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string] $AccessToken
    )
    process {
        # Make sure that if global token was set it is no longer used
        Remove-Variable -Name 'IOE_ENTRAID_ACCESS_TOKEN' -Scope 'Global' -ErrorAction 'SilentlyContinue'

        Write-Warning 'Updating Azure Graph API Token'
        $credentials = $Script:RefreshTokens[$AccessToken]
        if ($credentials) {
            $newToken = Get-GraphApiToken @credentials
            Write-Verbose "New Graph API token received: $($newToken.Substring(0, 8))..."
            return $newToken
        }
        Write-Error 'Cannot update Graph API Token'
    }
}

function Get-RetryInterval {
    [CmdletBinding()]
    [OutputType([timespan])]
    param(
        $Attempts = 0,
        $Exception
    )

    if ([int]$Exception.Exception.Response.StatusCode -eq 429) {
        if ($Exception.Exception.Response.Headers) {
            if ($Exception.Exception.Response.Headers["Retry-After"]) {
                $delay = $Exception.Exception.Response.Headers["Retry-After"]
                return $delay
            }
        }
    }

    $delay = (Get-Random -Minimum 1 -Maximum (24 - $Attempts * 2))
    [timespan]::FromSeconds($delay)
}

function Invoke-GraphApiRequest {
    <#
    .SYNOPSIS
        Invokes REST call to Graph API
    .NOTES
        Automatically handles token expiration and @odata.next page iteration
    .NOTES
        Calls to /$batch API combine all results into single array of objects
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Uri] $Uri,

        [ValidateNotNullOrEmpty()]
        [string] $Method = 'GET',

        $Body,

        [ValidateNotNullOrEmpty()]
        [string] $ContentType = 'application/json',

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $AccessToken,

        [int] $Attempts = 7,
        [switch] $NoPaginate
    )
    $request = @{
        Uri = $Uri
        Method = $Method
        ContentType = $ContentType
        Headers = @{
            Authorization = "Bearer $AccessToken"
        }
    }

    if ($Body) {
        $request.Body = $Body
    }

    try {
        $response = Invoke-RestMethod @request

        $isBatch = $Uri -like '*/$batch'
        if ($isBatch) {
            $requests = $Body | ConvertFrom-Json | Select-Object -ExpandProperty 'requests'
            $results = @()
            foreach ($result in $response.responses) {
                if ($result.status -eq 403) {
                    throw New-Object 'Exception' | Add-Member -PassThru -NotePropertyMembers @{
                        Response = @{ StatusCode = 403 }
                    }
                }

                $batchResult = $result.body.value
                $batchError = $result.body.error

                if ($batchError) {
                    Write-Warning "Batch error occured: $($batchError.message)"
                    $failedRequest = $requests | Where-Object -Property 'id' -Value $result.id

                    $batchRetry = @{
                        Uri = [Uri]::new($Uri, $failedRequest.Uri)
                        Method = $failedRequest.Method
                        AccessToken = $AccessToken
                        ContentType = $ContentType
                        Body = (if ($failedRequest.Body) { ConvertTo-Json $failedRequest.Body -Compress })
                    }
                    $retried = Invoke-GraphApiRequest @batchRetry
                    $batchResult = $retried.value
                }

                if ($batchResult) {
                    $results += $batchResult
                }
            }
            $response = $results
        }
        elseif (-not $NoPaginate) {
            $nextPage = $response.'@odata.nextLink'
            while ($null -ne $nextPage) {
                $innerRequest = @{
                    NoPaginate = $true
                    Uri = $nextPage
                    Method = 'GET'
                    ContentType = $ContentType
                    AccessToken = $AccessToken
                    Attempts = $Attempts
                }
                $innerResponse = Invoke-GraphApiRequest @innerRequest
                $response.value += $innerResponse.value

                $nextPage = $innerResponse.'@odata.nextLink'
            }
        }
        return $response
    }
    catch {
        $httpStatus = [int]$_.Exception.Response.StatusCode
        $shouldRetry = $false

        if ($httpStatus -eq 429 <#Too Many Requests#>) {
            Write-Warning "The request has failed due to Azure Graph API throttling"
            $shouldRetry = $true
        }
        elseif ($httpStatus -eq 401 <#Unauthorized#>) {
            Write-Warning 'The request has failed because of expired Graph Access Token'
            $AccessToken = Update-GraphApiToken $AccessToken
            $shouldRetry = $true
        }
        elseif ($httpStatus -eq 400 <#Bad Request#>) {
            if ($request.Uri.OriginalString -match "roleEligibilityScheduleInstances") {
                return [PSCustomObject] @{ value = @() }
            }
        }

        if ($shouldRetry -and $Attempts -gt 0) {
            Get-RetryInterval -Attempts $Attempts -Exception $_ | Start-Sleep
            $retry = @{
                Uri = $Uri
                Method = $Method
                AccessToken = $AccessToken
                Body = $Body
                Attempts = ($Attempts - 1)
                NoPaginate = $NoPaginate
            }
            return Invoke-GraphApiRequest @retry
        }

        throw
    }
}

function ConvertTo-GraphApiErrorResult {
    <#
    .SYNOPSIS
        Provides unified global exception handling for Graph API errors
    #>
    #[CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $ErrorObject,

        [string] $AccessToken,
        [string] $TenantAppId,
        [string[]] $RequiredPrivileges
    )
    process {
        if ($_.Exception.Response.StatusCode -eq 403) {
            $result = New-Result
            $result.Status = 'Error'

            $context = @{
                TenantAppId = $TenantAppId
                AccessToken = $AccessToken
                RequiredPrivileges = $RequiredPrivileges
            }
            $permissions = Get-GraphApiRequiredPermission @context

            if ($permissions.Message -match "P1") {
                $result.Status = 'NotRelevant'
                $result.ResultMessage = 'This indicator is relevant only when a P1 or P2 license is in place'
            }
            else {
                $result.ResultMessage = $permissions.Message
                $result.Remediation = $permissions.Remediation
            }

            return $result

        }
        ConvertTo-ErrorResult $ErrorObject
    }
}

function Get-GraphApiRequiredPermission {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        $TenantAppId,
        [string[]] $RequiredPrivileges,
        $AccessToken
    )

    if (-not $TenantAppId) {
        $TenantAppId = $AccessToken | Get-TokenPayload | Select-Object -ExpandProperty 'appid'
    }

    $getPrincipal = @{
        Uri = "https://graph.microsoft.com/v1.0/servicePrincipals/?`$filter=appid eq '$TenantAppId'"
        AccessToken = $AccessToken
    }
    $appIDResult = Invoke-GraphApiRequest @getPrincipal
    $principalId = $appIDResult.value.id

    $getRoleAssignments = @{
        Uri = "https://graph.microsoft.com/v1.0/servicePrincipals/$principalId/appRoleAssignments"
        AccessToken = $AccessToken
    }

    $appIDAssignments = @()
    $appAssignmentResult = Invoke-GraphApiRequest @getRoleAssignments
    $appIDAssignments += $appAssignmentResult.value | Where-Object { $_.resourceDisplayName -eq "Microsoft Graph" }

    $appIDAssignmentRoleIds = @()
    $appIDAssignmentRoleIds += $appIDAssignments.appRoleId

    $neededPrivs = [System.Collections.ArrayList]$RequiredPrivileges
    foreach ($privilege in $RequiredPrivileges) {
        foreach ($roleId in $appIDAssignmentRoleIds) {
            if ($DefinedPermissions[$privilege].appRoleIds -contains $roleId) {
                [void]$neededPrivs.Remove($privilege)
            }
        }
    }

    $missingPrivs = @()
    foreach ($neededPriv in $neededPrivs) {
        $missingPrivs += $DefinedPermissions[$neededPriv].LeastPrivilege
    }

    if ($missingPrivs.Count -gt 0) {
        return @{
            Message = "Insufficient permissions"
            Remediation = "Please ensure your Entra ID app registration has the following Graph API permission(s): $($missingPrivs -join ", ")"
        }
    }
    else {
        return @{
            Message = "This indicator requires a P1 or P2 license"
        }
    }
}

function Get-TokenPayload {
    <#
    .SYNOPSIS
        Returns the deserialized payload object of a JWT token
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string] $AccessToken
    )
    process {
        $tokenPayload = ($AccessToken -split '\.')[1]

        $padding = $tokenPayload.Length % 4
        if ($padding -eq 2) {
            $tokenPayload += '=='
        }
        elseif ($padding -eq 3) {
            $tokenPayload += '='
        }
        $tokenPayload = [System.Convert]::FromBase64String($tokenPayload)
        $decodedPayload = [System.Text.Encoding]::UTF8.GetString($tokenPayload)

        $decodedPayload | ConvertFrom-Json

    }
}

Function Get-AADAuditLog {
    <#
    .SYNOPSIS
    Gets Azure audit logs for a given filter

    .DESCRIPTION
    Queries Azure audit logs for entries matching filter

    .PARAMETER auditFilter
    Filter to use while searching audit logs

    .EXAMPLE
    Get-AADAuditLog -auditFilter $filter
    #>
    param(
        [parameter(Mandatory = $true)]
        [string]$AuditFilter,

        [parameter(Mandatory = $true)]
        [string]$Token,

        [parameter(Mandatory = $false)]
        [switch]$Regex = $false,

        [parameter(Mandatory = $false)]
        [string[]]$NewValues
    )

    Out-Log -Operation $MyInvocation.MyCommand.Name -Data $PSBoundParameters

    $getAuditLogs = @{
        Uri = "https://graph.microsoft.com/v1.0/auditLogs/directoryAudits?`$filter=$AuditFilter"
        AccessToken = $Token
    }

    try {
        $auditLogResults = Invoke-GraphApiRequest @getAuditLogs
    }
    catch {
        return $_ | ConvertTo-GraphApiErrorResult -RequiredPrivileges 'Read Audit Logs' -TenantAppId $TenantAppId -AccessToken $Token
    }

    $auditLogs = [System.Collections.ArrayList]@()
    $filteredResults = @()

    if ($newValues) {
        foreach ($newValue in $newValues) {
            if ($Regex) {
                $filteredResults += $auditLogResults.value | Where-Object { $_.targetResources.modifiedProperties.newValue -match "`"$newValue`"" }
            }
            else {
                $filteredResults += $auditLogResults.value | Where-Object { $_.targetResources.modifiedProperties.newValue -eq "`"$newValue`"" }
            }
        }
        $auditLogs.AddRange($filteredResults)
    }
    else {
        $auditLogs.AddRange($auditLogResults.value)
    }

    return $auditLogs
}

function Search-PrivilegedCollection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$Identity,
        [Parameter(Mandatory)]
        [string]$RoleGuid,
        [Parameter(Mandatory)]
        [ValidateSet('Active', 'Eligible')]
        [string]$State,
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [System.Collections.ArrayList]$adminCollection,
        [System.Collections.ArrayList]$unresolvedCollection,
        [switch] $AddUnresolved
    )

    $entityObject = [PSCustomObject] @{
        ID = $Identity.id
        Role = $AAD_PRIVILEGED_ROLES[$RoleGuid]
        State = $State
    }

    $existingIdentity = $adminCollection | Where-Object { $_.ID -eq $entityObject.id -and $_.Role -eq $entityObject.Role -and $_.State -eq $entityObject.State }
    if (!($existingIdentity)) {
        [void]$adminCollection.Add($entityObject)
    }

    if ($AddUnresolved) {
        $existingUnresolved = $unresolvedCollection | Where-Object { $_.ID -eq $entityObject.id -and $_.Role -eq $entityObject.Role -and $_.State -eq $entityObject.State }
        if (!($existingUnresolved)) {
            [void]$unresolvedCollection.Add($entityObject)
        }
    }
}

function Get-PrivilegedAdmins {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $AccessToken,
        [string[]] $RoleID,
        [string[]] $RoleName,
        [switch] $ReturnUnresolved
    )

    $AADAdmins = [System.Collections.ArrayList]@()
    $AADAdminsUnresolved = [System.Collections.ArrayList]@()

    # Determine the roles to retrieve based on the provided parameters
    $selectedRoles = @()
    if ($RoleID) {
        foreach ($rID in $RoleID) {
            if ($AAD_PRIVILEGED_ROLES.ContainsKey($rID)) {
                $selectedRoles += $rID
            }
        }
    }
    if ($RoleName) {
        foreach ($rName in $RoleName) {
            $roleGUID = $AAD_PRIVILEGED_ROLES.GetEnumerator() | Where-Object { $_.Value -eq $rName } | Select-Object -ExpandProperty Key
            if ($roleGUID) {
                $selectedRoles += $roleGUID
            }
        }
    }
    if ((-not $RoleID) -and (-not $RoleName)) {
        $selectedRoles = $AAD_PRIVILEGED_ROLES.Keys
    }

    foreach ($AadPrivilegedGUID in $selectedRoles) {
        # Get Active Assignments
        $getActiveAADAdministrators = @{
            Uri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments?`$filter=roleDefinitionId eq '$($AadPrivilegedGUID)'&`$select=principalId"
            AccessToken = $AccessToken
        }
        $assignedAdminsResponse = Invoke-GraphApiRequest @getActiveAADAdministrators

        $activeAdminsResponse = @($assignedAdminsResponse.value)
        if ($activeAdminsResponse) {
            foreach ($AdminResponse in $activeAdminsResponse) {
                $getRoleMember = @{
                    Uri = "https://graph.microsoft.com/v1.0/directoryObjects/$($AdminResponse.principalId)?`$select=id"
                    AccessToken = $AccessToken
                }

                try {
                    $roleMember = Invoke-GraphApiRequest @getRoleMember

                    if ($roleMember.'@odata.type' -eq '#microsoft.graph.group') {
                        # If it's a group, get its members
                        $getGroupMembers = @{
                            Uri = "https://graph.microsoft.com/v1.0/groups/$($AdminResponse.principalId)/members?`$select=id"
                            AccessToken = $AccessToken
                        }

                        $groupMembers = Invoke-GraphApiRequest @getGroupMembers

                        foreach ($groupMember in $groupMembers.value) {
                            # We only add users - Group nesting isn't supported
                            if ($groupMember.'@odata.type' -eq '#microsoft.graph.user') {
                                Search-PrivilegedCollection -Identity $groupMember -RoleGuid $AadPrivilegedGUID -State 'Active' -adminCollection $AADAdmins
                            }
                        }
                    }
                    else {
                        Search-PrivilegedCollection -Identity $roleMember -RoleGuid $AadPrivilegedGUID -State 'Active' -adminCollection $AADAdmins
                    }
                }
                catch {
                    if ($_.Exception.Response.StatusCode -eq 404) {
                        if ($ReturnUnresolved) {
                            $tempObject = @{
                                id = $AdminResponse.principalId
                            }
                            Search-PrivilegedCollection -Identity $tempObject -RoleGuid $AadPrivilegedGUID -State 'Active' -adminCollection $AADAdmins -AddUnresolved -unresolvedCollection $AADAdminsUnresolved
                        }
                        continue
                    }
                    throw
                }
            }
        }

        $getEligibleAssignments = @{
            Uri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleEligibilityScheduleInstances?`$filter=roleDefinitionId eq '$($AADPrivilegedGUID)'&`$select=principalId&`$expand=principal"
            AccessToken = $AccessToken
        }

        $eligibleResults = Invoke-GraphApiRequest @getEligibleAssignments
        $eligibleAdmins = @($eligibleResults.value)

        if ($eligibleAdmins) {
            foreach ($eligibleAdmin in $eligibleAdmins) {
                $getRoleMember = @{
                    Uri = "https://graph.microsoft.com/v1.0/directoryObjects/$($eligibleAdmin.principalId)?`$select=id"
                    AccessToken = $AccessToken
                }

                try {
                    $roleMember = Invoke-GraphApiRequest @getRoleMember

                    if ($roleMember.'@odata.type' -eq '#microsoft.graph.group') {
                        # If it's a group, get its members
                        $getGroupMembers = @{
                            Uri = "https://graph.microsoft.com/v1.0/groups/$($eligibleAdmin.principalId)/members?`$select=id"
                            AccessToken = $AccessToken
                        }

                        $groupMembers = Invoke-GraphApiRequest @getGroupMembers

                        foreach ($groupMember in $groupMembers.value) {
                            # We only add users - Group nesting isn't supported
                            if ($groupMember.'@odata.type' -eq '#microsoft.graph.user') {
                                Search-PrivilegedCollection -Identity $groupMember -RoleGuid $AadPrivilegedGUID -State 'Eligible' -adminCollection $AADAdmins
                            }
                        }
                    }
                    else {
                        Search-PrivilegedCollection -Identity $roleMember -RoleGuid $AadPrivilegedGUID -State 'Eligible' -adminCollection $AADAdmins
                    }
                }
                catch {
                    if ($_.Exception.Response.StatusCode -eq 404) {
                        if ($ReturnUnresolved) {
                            $tempObject = @{
                                id = $eligibleAdmin.principalId
                            }
                            Search-PrivilegedCollection -Identity $tempObject -RoleGuid $AadPrivilegedGUID -State 'Eligible' -adminCollection $AADAdmins -AddUnresolved -unresolvedCollection $AADAdminsUnresolved
                        }
                        continue
                    }
                    throw
                }
            }
        }
    }

    return $AADAdmins, $AADAdminsUnresolved
}

function Get-AADIdentityType {
    <#
    .SYNOPSIS
    Returns the object type of a given ID - 'user', 'servicePrincipal', 'group', 'application','NonExisting'
    #>
    param (
        [Parameter(Mandatory = $true)]
        [Alias("ID")]
        [string]$IdentityId,
        [Parameter(Mandatory = $true)]
        [string]$AccessToken
    )

    $getIdentityInfo = @{
        Uri = "https://graph.microsoft.com/v1.0/directoryObjects/$($IdentityId)`?`$select=odata.type"
        AccessToken = $AccessToken
    }

    try {
        $identityInfo = Invoke-GraphApiRequest @getIdentityInfo
        $identityType = $identityInfo.'@odata.type'
        $identityType = $identityType -replace '^#microsoft\.graph\.', ''
    }
    catch {
        $identityType = 'NonExisting'
    }
    return $identityType
}

function Search-AADIdentity {
    <#
    .SYNOPSIS
    Returns the requested properties for a given Azure AD identity (user, group, application object ID, service principal).
    Does not suppprt microsoft.graph.orgContact resource type.

    .PARAMETER Properties
    An optional array of properties to retrieve for the identity. If not specified, a default set of properties is returned based on the identity type.

    .EXAMPLE
    Search-AADIdentity -ID "7a851c0b-ded7-48b2-84d3-d3d0ee9c3a1c" -AccessToken $graphAccess

    $getUserInfo = @{
        ID = "7a851c0b-ded7-48b2-84d3-d3d0ee9c3a1c"
        AccessToken = $graphAccess
        Properties = "id", "displayName", "userPrincipalName", "onPremisesDomainName", "memberOf"
    }
    $userIdentityInfo = Search-AADIdentity @getUserInfo

    .NOTES
    Required App Role Access:
    - Read Directory Objects: Directory.Read.All
    - Read Applications: Application.Read.All
    - Read Groups: GroupMember.Read.All
    - Read Users: User.Read.All
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Alias("ID")]
        [string]$IdentityId,
        [Parameter(Mandatory = $true)]
        [string]$AccessToken,
        [string[]]$Properties,
        [string]$ObjectType
    )

    $defaultProperties = @{
        "User" = "id", "displayName", "userPrincipalName", "mail"
        "ServicePrincipal" = "id", "displayName", "appId", "accountEnabled"
        "Group" = "id", "displayName", "description", "mailEnabled", "securityEnabled"
        "Application" = "id", "displayName", "appId", "identifierUris", "signInAudience"
    }

    if ($ObjectType) {
        $identityType = $ObjectType
    }
    else {
        $identityType = Get-AADIdentityType -IdentityId $IdentityId -AccessToken $AccessToken
    }

    switch ($identityType) {
        'user' {
            $selectProperties = if ($Properties) { $Properties } else { $defaultProperties["User"] }
            $selectProperties = $selectProperties | Where-Object { $_ -ne "id" }
            $selectString = $selectProperties -join ","

            $getUserDetails = @{
                Uri = "https://graph.microsoft.com/v1.0/users/$($IdentityId)`?`$select=$selectString"
                AccessToken = $AccessToken
            }

            $userDetails = Invoke-GraphApiRequest @getUserDetails

            $identityDetails = [PSCustomObject]@{
                ID = $IdentityId
                Type = "User"
            }
            foreach ($property in $selectProperties) {
                $identityDetails | Add-Member -NotePropertyName $property -NotePropertyValue $userDetails.$property
            }
        }
        'servicePrincipal' {
            $selectProperties = if ($Properties) { $Properties } else { $defaultProperties["ServicePrincipal"] }
            $selectProperties = $selectProperties | Where-Object { $_ -ne "id" }
            $selectString = $selectProperties -join ","

            $getServicePrincipalDetails = @{
                Uri = "https://graph.microsoft.com/v1.0/servicePrincipals/$($IdentityId)`?`$select=$selectString"
                AccessToken = $AccessToken
            }

            $servicePrincipalDetails = Invoke-GraphApiRequest @getServicePrincipalDetails

            $identityDetails = [PSCustomObject]@{
                ID = $IdentityId
                Type = "ServicePrincipal"
            }
            foreach ($property in $selectProperties) {
                $identityDetails | Add-Member -NotePropertyName $property -NotePropertyValue $servicePrincipalDetails.$property
            }
        }
        'group' {
            $selectProperties = if ($Properties) { $Properties } else { $defaultProperties["Group"] }
            $selectProperties = $selectProperties | Where-Object { $_ -ne "id" }
            $selectString = $selectProperties -join ","

            $getGroupDetails = @{
                Uri = "https://graph.microsoft.com/v1.0/groups/$($IdentityId)`?`$select=$selectString"
                AccessToken = $AccessToken
            }

            $groupDetails = Invoke-GraphApiRequest @getGroupDetails

            $identityDetails = [PSCustomObject]@{
                ID = $IdentityId
                Type = "Group"
            }
            foreach ($property in $selectProperties) {
                $identityDetails | Add-Member -NotePropertyName $property -NotePropertyValue $groupDetails.$property
            }
        }
        'application' {
            $selectProperties = if ($Properties) { $Properties } else { $defaultProperties["Application"] }
            $selectProperties = $selectProperties | Where-Object { $_ -ne "id" }
            $selectString = $selectProperties -join ","

            $getApplicationDetails = @{
                Uri = "https://graph.microsoft.com/v1.0/applications/$($IdentityId)`?`$select=$selectString"
                AccessToken = $AccessToken
            }

            $applicationDetails = Invoke-GraphApiRequest @getApplicationDetails

            $identityDetails = [PSCustomObject]@{
                ID = $IdentityId
                Type = "Application"
            }
            foreach ($property in $selectProperties) {
                $identityDetails | Add-Member -NotePropertyName $property -NotePropertyValue $applicationDetails.$property
            }
        }
        Default {
            $identityDetails = [PSCustomObject]@{
                ID = "NonExisting ID or Type"
                Type = $identityType
            }
        }
    }
    return $identityDetails
}

function Get-AADIdentityOwner {
    <#
    .SYNOPSIS
    Returns all the owners of a given object ID (group, application, or service principal).
    In the case of group object type - assigned & eligible owners are returned.

    .EXAMPLE
    $getOwners = @{
        IdentityId = "157842c5-b320-4304-951c-e16d74aba5bf"
        AccessToken = $graphAccess
    }
    Get-AADIdentityOwner @getOwners

    OwnerID                              OwnerType OwnerDisplayName
    -------                              --------- ----------------
    c7db4b8e-4553-4a46-8769-21a2bb2f0da1 Assigned  Abigail.Clark
    9025fb2d-8362-4dd0-8b05-d52dd7bb2482 Assigned  strong2 app
    058dd1e7-b8fb-4053-a1d1-b4f6c19df4c6 Assigned  DSP
    61d8dc2a-0500-4e78-a81a-38c6cfd91ed0 Assigned  Postman2
    d46f62f9-cee5-494c-8c08-ef2e88c405db Assigned  strong app
    c83d30a2-b601-4618-ad92-b8ec379f7af5 Assigned  Admin User
    9ec6402a-6e56-40ca-9e33-c90c49feb973 Eligible  AAD DC Administrators

    .NOTES
    Required App Role Access:
    READ GROUPS: GroupMember.Read.All
    READ APPLICATIONS: Application.Read.All
    READ PRIVILEGED ELIGIBILITY SCHEDULE: RoleManagement.Read.All
    READ ELIGIBILITY SCHEDULE FOR ACCESS TO AZURE AD GROUPS: PrivilegedEligibilitySchedule.Read.AzureADGroup
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$AccessToken,
        [Parameter(Mandatory = $true)]
        [string]$IdentityId,
        [string]$ObjectType
    )

    $identityOwners = @()

    if ($ObjectType) {
        $identityType = $ObjectType
    }
    else {
        $identityType = Get-AADIdentityType -IdentityId $IdentityId -AccessToken $AccessToken
    }

    switch ($identityType) {
        'group' {
            $getOwners = @{
                Uri = "https://graph.microsoft.com/beta/groups/$($IdentityId)/owners?`$select=id,displayName"
                AccessToken = $AccessToken
            }

            $ownersResponse = Invoke-GraphApiRequest @getOwners
            foreach ($owner in $ownersResponse.value) {
                $identityOwners += [PSCustomObject]@{
                    OwnerID = $owner.id
                    OwnerType = 'Assigned'
                    OwnerDisplayName = $owner.displayName
                }
            }

            $getEligibleOwners = @{
                Uri = "https://graph.microsoft.com/beta/identityGovernance/privilegedAccess/group/eligibilityScheduleInstances?`$filter=groupId eq '$($IdentityId)' and accessId eq 'owner'&`$select=principalId"
                AccessToken = $AccessToken
            }
            $eligibleOwnersID = Invoke-GraphApiRequest @getEligibleOwners

            foreach ($eligibleOwner in $eligibleOwnersID.value) {
                try {
                    # no display name is available at the PIM response
                    $ownerDetails = Search-AADIdentity -IdentityId $eligibleOwner.principalId -AccessToken $AccessToken -Properties "displayName"
                    $ownerDisplayName = $ownerDetails.displayName
                }
                catch {
                    $ownerDisplayName = $eligibleOwner.principalId
                }
                $identityOwners += [PSCustomObject]@{
                    OwnerID = $eligibleOwner.principalId
                    OwnerType = 'Eligible'
                    OwnerDisplayName = $ownerDisplayName
                }
            }
        }
        'application' {
            $getOwners = @{
                Uri = "https://graph.microsoft.com/v1.0/applications/$($IdentityId)/owners?`$select=id,displayName"
                AccessToken = $AccessToken
            }

            $ownersResponse = Invoke-GraphApiRequest @getOwners
            foreach ($owner in $ownersResponse.value) {
                $identityOwners += [PSCustomObject]@{
                    OwnerID = $owner.id
                    OwnerType = 'Assigned'
                    OwnerDisplayName = $owner.displayName
                }
            }
        }
        'servicePrincipal' {
            $getOwners = @{
                Uri = "https://graph.microsoft.com/v1.0/servicePrincipals/$($IdentityId)/owners?`$select=id,displayName"
                AccessToken = $AccessToken
            }

            $ownersResponse = Invoke-GraphApiRequest @getOwners
            foreach ($owner in $ownersResponse.value) {
                $identityOwners += [PSCustomObject]@{
                    OwnerID = $owner.id
                    OwnerType = 'Assigned'
                    OwnerDisplayName = $owner.displayName
                }
            }
        }
        Default {
            $identityOwners += [PSCustomObject]@{
                OwnerID = "NonExisting ID or Type"
                OwnerType = $identityType
                OwnerDisplayName = "NonExisting ID or Type"
            }
        }
    }
    return $identityOwners
}

function Test-ConditionalMFAStrength {
    <#
    .SYNOPSIS
        Tests if provided grantControls meet criteria for sufficient MFA strength.

    .DESCRIPTION
        Evaluates grantControls against predefined MFA strength criteria and returns true/false.
        Can optionally check for phishing-resistant MFA requirements.

    .PARAMETER grantControls
        The grantControls object to evaluate for MFA strength requirements.

    .PARAMETER PhishingResistant
        Switch parameter to enable checking for phishing-resistant MFA methods only.

    .EXAMPLE
        Test-ConditionalMFAStrength -grantControls $policyObject.grantControls

        Tests if the provided grantControls meet basic MFA strength criteria.

    .EXAMPLE
        Test-ConditionalMFAStrength -grantControls $policyObject.grantControls -PhishingResistant

        Tests if the provided grantControls meet phishing-resistant MFA criteria.

    .NOTES
        Required App Role Access:
        None - This function evaluates already retrieved properties without making Graph API calls.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $true)]
        $grantControls,
        [switch]$PhishingResistant
    )

    $allowedValues = @(
        "windowsHelloForBusiness",
        "fido2",
        "x509CertificateMultiFactor",
        "deviceBasedPush",
        "temporaryAccessPassOneTime",
        "temporaryAccessPassMultiUse",
        "password,microsoftAuthenticatorPush",
        "password,softwareOath",
        "password,hardwareOath",
        "password,sms",
        "password,voice",
        "federatedMultiFactor",
        "microsoftAuthenticatorPush,federatedSingleFactor",
        "softwareOath,federatedSingleFactor",
        "hardwareOath,federatedSingleFactor",
        "sms,federatedSingleFactor",
        "voice,federatedSingleFactor"
    )

    $phishingResistantValues = @(
        "windowsHelloForBusiness",
        "fido2",
        "x509CertificateMultiFactor"
    )

    $targetValues = $grantControls.authenticationStrength.allowedCombinations

    if ($PhishingResistant) {
        if (($targetValues | Where-Object { $phishingResistantValues -contains $_ }).Count -eq $targetValues.Count) {
            return $true
        }

        return $false
    }

    if ($grantControls.builtInControls -match "mfa" -or (($targetValues | Where-Object { $allowedValues -contains $_ }).Count -eq $targetValues.Count)) {
        return $true
    }

    return $false
}

Export-ModuleMember -Variable AAD_PRIVILEGED_ROLES
Export-ModuleMember -Function Get-GraphApiToken
Export-ModuleMember -Function Get-AADAuditLog
Export-ModuleMember -Function Invoke-GraphApiRequest
Export-ModuleMember -Function ConvertTo-GraphApiErrorResult
Export-ModuleMember -Function Get-GraphApiRequiredPermission
Export-ModuleMember -Function Get-PrivilegedAdmins
Export-ModuleMember -Function Search-PrivilegedCollection
Export-ModuleMember -Function Search-AADIdentity
Export-ModuleMember -Function Get-AADIdentityOwner
Export-ModuleMember -Function Get-AADIdentityType
Export-ModuleMember -Function Test-ConditionalMFAStrength
# SIG # Begin signature block
# MIIuIwYJKoZIhvcNAQcCoIIuFDCCLhACAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDjktMqDEe3LX3g
# JdjoPFZZ+ymgykmSu+JmEJRvc7elBqCCE6MwggVyMIIDWqADAgECAhB2U/6sdUZI
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
# 9w0BCQQxIgQg23wxyCvnki2lVBsl09Bcfv4LfCk8Eaetp6b8ztGQuFQwDQYJKoZI
# hvcNAQEBBQAEggIAG5AZWIvz+syjTAyeahhA95/9pYui7ijB/jlx7LMgXvJFeQyk
# tn3ZTqaJQS44i/s96p7BfNUqplDjWffh/dLpX0yAlnAKIfq3UuOhaBKUDBrso6eJ
# 8N6KYfckUxpGQkULZwgXMq05fyhdUQ/dAgwZ8pcMP74HOvMvf8zlyXJ3x8WzRl3W
# oa+x7GEc4CZfU4wESnUdSfcbReHL5GJsEDsuy6Wa7Yg0QLN4QNcpeOt7vPaceIbL
# 7DxfuRC2R4TTxKk7c34qyC6yPzHHFRoJZD+NHt5zo/Q05cqmxjexh/pzJ0cyEx6T
# S7OHJOrTf3Elk5PqB3XmvnZn1N+PZyvNeiXAeAheZtLITvr8V8/DbMxYaK6rgE/R
# spTvdwR17eRoDLUr0jHCBcLQuUrjF/xkqpiPZQNmw+vLhVG3ZkRTfgA8S2b7JnXl
# cfzxNbdMI7Gu05AQHz9GuwrN91Yhtow0UKHBEuHjC3gNXnrWbOG8KG10C+OKBMb0
# zkJcXMgGevLCKHxCU4ZZ0aF43fdiQyH2gzycNbg62e+andL+Q70htvGwtccI9lrD
# QaLLYpCmeVXUhoGTx11lkXlZAC7ZBvUUSx/V+1bDBrp/k+tY5eohBOgXOokTDA/u
# X3V5Kcm4IMTi3Ec4ChR/6oTueXeKv1MTYeXy4XIy4SMTuOTC3h9Qg/NT3qehgha3
# MIIWswYKKwYBBAGCNwMDATGCFqMwghafBgkqhkiG9w0BBwKgghaQMIIWjAIBAzEN
# MAsGCWCGSAFlAwQCATCB3AYLKoZIhvcNAQkQAQSggcwEgckwgcYCAQEGCSsGAQQB
# oDICAzAxMA0GCWCGSAFlAwQCAQUABCAc0smiwWJ+eOgX6sIwwcRaVW6KdTH/mA+h
# kfJuFnoG2QIUR1Xj+RUUyG3tfvEltbHTmB2oTigYDzIwMjUwNjEwMDc1MDE4WjAD
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
# MC8GCSqGSIb3DQEJBDEiBCC2iehXS+f7GejVOh2wZTtF8zIlIHME73Z+BrYVAY/h
# 6DCBsAYLKoZIhvcNAQkQAi8xgaAwgZ0wgZowgZcEIJGSR5tiNbl2Jr+2AW14CJGD
# cgPYc5HAbBuOPXf/4sc3MHMwX6RdMFsxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBH
# bG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWduIFRpbWVzdGFtcGlu
# ZyBDQSAtIFNIQTM4NCAtIEc0AhABAzLhZb+beEPgmXWUY3cLMA0GCSqGSIb3DQEB
# CwUABIIBgGa5ndGEDaxl8AtGA6jBwk3bFLD66BG89Nq5+0nUlpyycosGU/TYGA9l
# SH7VJ8uVQwyUC/fPG0qOa9HYJfYyt66CQG8TihNe9EQm0Ql6b8h9JJQc7/ooUURs
# wQWCr6xbu0womQXSJyDtqOrpq553qsQPqUCihX9ayhEgVlrOQC7WZiBBppiDpigv
# F07PTRgHLJYypZPOKEe2EeqFq+xg3WupqVIOXkoIG5rLAp82VSStWBlDctTDY6vK
# f/ItC1VLylVbmG2pKu/hYh0uQMiuuHgiUKR4DdmWVQie6gPvfn4hO6bZahnf6R9U
# ksl6P+7Dd5wzH3UY7g7Z1LEEvwiNTxC4jrikGLHuOFg653CU8ZelZfdX5FiPA0A0
# 7ozsqxMVsdnAilpEdQMtzt2p49Hjr0z+fzDSweWJlKUzfHYTZth3pmX27zQClUrN
# zCffwJF//u3vutffdeJaDrh/9SOQEB3XkiXuPF5UFeojcYrqHFO3VVUkjCdcnY0A
# Gk8ppyOrcg==
# SIG # End signature block
