

$Global:Parsers = @{}


function Search-AD{
    <#
    .SYNOPSIS
    Searches LDAP server with given filter

    .DESCRIPTION
    Searches LDAP server identified by given domain name with given parameters using System.DirectoryServices.Protocols

    .PARAMETER dnsDomain
    DNS name of the domain that will be searched against

    .PARAMETER attributes
    Attributes to return from the search, should be lowercase as convention

    .PARAMETER baseDN
    Root distinguished name for the search

    .PARAMETER scope
    Scope of the search

    .PARAMETER includeDeleted
    Determine if we search for deleted items

    .PARAMETER filter
    Filter to be applied to the search

    .PARAMETER pageSize
    Page size for the search
    Default = 1000

    .PARAMETER ASQ
    Attribute name for Attribute Scope Query

    .PARAMETER scriptblockFilter
    Scriptblock that gets an entry as parameter, analyze the entry and returns whether the indicator needs this entry or not
    This parameter is used to do analysis of the ldap results before building a list of object to reduce memory usage

    .EXAMPLE
    Get all users with their SamAccountName and UserAccountControl
    $DN = Get-DN test.lab
    Search-AD -dnsDomain test.lab -attributes "samaccountname", "useraccountcontrol" -baseDN $DN -scope "Subtree" -filter "(&(objectCategory=person)(objectClass=user))"
    #>
    param(
        [parameter(Mandatory = $true)]
        [string]$dnsDomain,

        [parameter(Mandatory = $false)]
        [string[]]$attributes = "",

        [parameter(Mandatory = $false)]
        [string]$baseDN,

        [parameter(Mandatory = $false)]
        [string]$scope = "subtree",

        [parameter(Mandatory = $false)]
        [switch]$includeDeleted,

        [parameter(Mandatory = $true)]
        [string]$filter,

        [parameter(Mandatory = $false)]
        [int]$pageSize = 1000,

        [parameter(Mandatory = $false)]
        [string]$ASQ,

        [parameter(Mandatory = $false)]
        [scriptblock[]]$scriptblockFilter
    )
    Out-Log -Operation $MyInvocation.MyCommand.Name -Data $PSBoundParameters

    Add-Type -AssemblyName 'System.DirectoryServices.Protocols'

    # Update filter to support a LDAP filter for a distinguished name which contains an asterisk
    if ($filter -match "distinguishedName=") {
        $filter = $filter.Replace("*","\2A")
    }

    # We don't want the client to timeout in large environments
    $Timeout = [System.TimeSpan]::FromDays(10000)
    $results = New-Object "System.Collections.Generic.List[System.DirectoryServices.Protocols.SearchResultEntry]"

    # If we're querying an attribute that is not normally replicated to a RODC, we will connect to RWDC
    $checkAttributes = @("lmpwdhistory","supplementalcredentials","ntpwdhistory","unicodepwd","dbcspwd","pwdlastset")

    $domainIP = Resolve-DomainName -Domain $dnsDomain
    if($domainIP -eq $dnsDomain){
        $directoryContext = New-DirectoryContext -Domain $dnsDomain
        $domainLocator = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($directoryContext)
        $locateWritable = [System.DirectoryServices.ActiveDirectory.LocatorOptions]::WriteableRequired
        try {
            $computerSiteName = [System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite().Name.ToString()
            if (Compare-Object -IncludeEqual -ExcludeDifferent $attributes $checkAttributes) {
                $controllerName = ($domainLocator.FindDomainController($computerSiteName, $locateWritable)).Name
            }
            else {
                $controllerName = ($domainLocator.FindDomainController($computerSiteName)).Name
            }
        }
        catch {
            if (Compare-Object -IncludeEqual -ExcludeDifferent $attributes $checkAttributes) {
                $controllerName = ($domainLocator.FindDomainController($locateWritable)).Name
            }
            else {
                $controllerName = ($domainLocator.FindDomainController()).Name
            }
        }
        $server = Resolve-DomainName -Domain $controllerName
        $connection = [System.DirectoryServices.Protocols.LdapConnection]::new($server)
    }
    else {
        $connection = [System.DirectoryServices.Protocols.LdapConnection]::new($domainIP)
    }

    $credential = Resolve-DomainCredential -Domain $dnsDomain
    if($null -ne $credential){
        $connection.Bind($credential)
    }

    $search = [System.DirectoryServices.Protocols.SearchRequest]::new($baseDN, $filter, $scope, $attributes)
    $search.TimeLimit = $Timeout
    $pageRequest = [System.DirectoryServices.Protocols.PageResultRequestControl]::new($pageSize)
    [void]$search.Controls.Add($pageRequest)

    $searchOptions = [System.DirectoryServices.Protocols.SearchOptionsControl]::new([System.DirectoryServices.Protocols.SearchOption]::DomainScope)
    [void]$search.Controls.Add($searchOptions)

    # Those flags let us query nTSecurityDescriptor when we don't have access to the SACL
    $searchSecurityFlags = [System.DirectoryServices.Protocols.SecurityDescriptorFlagControl]::new(7)
    [void]$search.Controls.Add($searchSecurityFlags)

    if ($includeDeleted) {
        $showDeletedControl = [System.DirectoryServices.Protocols.ShowDeletedControl]::new()
        [void]$search.Controls.Add($showDeletedControl)
    }

    # Attribute Scope Query
    if ($ASQ) {
        $asqControl = [System.DirectoryServices.Protocols.AsqRequestControl]::new($ASQ)
        [void]$search.Controls.Add($asqControl)
    }

    [int] $pageCount = 0

    if ($attributes) {
        $rangeRetrievalNeeded = Test-RangeRetrievalNeed -Attributes $attributes
    }
    while ($true) {
        $pageCount++
        $response = [System.DirectoryServices.Protocols.SearchResponse]$connection.SendRequest($search, $Timeout)
        [System.DirectoryServices.Protocols.PageResultResponseControl] $pageResponse = $response.Controls | Where-Object {$_.Type -eq "1.2.840.113556.1.4.319"}
        if ($response.Entries.Count -gt 0) {
            foreach ($entry in $response.Entries) {
                if ($rangeRetrievalNeeded) {
                    $entry = RangeQueryHelper -Attributes $Attributes -Entries $entry
                }
                if ($attributes) {
                    $entry = Bandage -Attributes $Attributes -Entries $entry
                }
                if ($scriptblockFilter) {
                    foreach ($scriptBlock in $scriptblockFilter) {
                        if ($entry) {
                            $entry = & $scriptblock $entry
                        }
                    }
                    if ($entry) {
                        $results.Add($entry)
                    }
                }
                else {
                    $results.Add($entry)
                }
            }
        }
        if ($pageResponse.Cookie.Length -eq 0) {
            break
        }
        $pageRequest.Cookie = $pageResponse.Cookie
    }
    return $results
}


function Get-DN {
    <#
    .SYNOPSIS
    Gets the distinguished name of a given domain

    .PARAMETER dnsDomain
    DNS name of the domain whose distinguished name we want

    .EXAMPLE
    Get-DN "test.lab"
    #>
    param(
        [parameter(Mandatory = $true)]
        [string]$dnsDomain
    )
    Out-Log -Operation $MyInvocation.MyCommand.Name -Data $PSBoundParameters

    return "DC=$($dnsDomain -replace '\.',',DC=')"
}


function Get-DomainSID{
    <#
    .SYNOPSIS
    Gets the SID of a given domain

    .DESCRIPTION
    Queries a given domain for his SID

    .PARAMETER dnsDomain
    DNS name of the domain whose SID we want

    .EXAMPLE
    Get-DomainSID "test.lab"
    #>
    param(
        [parameter(Mandatory = $true)]
        [string]$dnsDomain
    )
    Out-Log -Operation $MyInvocation.MyCommand.Name -Data $PSBoundParameters

    try {
        $domainContext = New-DirectoryContext -Domain $dnsDomain
        $selectedDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($domainContext)
        $sid = $selectedDomain.GetDirectoryEntry().Properties["objectSID"][0]
    }
    catch {
        $domainDN = Get-DN $dnsDomain
        $results = Search-AD -dnsDomain $dnsDomain -attributes "objectSID" -baseDN $domainDN -scope "base" -filter "(objectClass=domainDNS)"
        $sid = $results.Attributes.'objectsid'.GetValues("byte[]")[0]
    }

    return (New-Object System.Security.Principal.SecurityIdentifier @($sid,0)).Value
}


function Get-ForestSID{
    <#
    .SYNOPSIS
    Gets the SID of a given forest

    .DESCRIPTION
    Queries a given domain for the forest SID

    .PARAMETER forestName
    DNS name of the forest whose SID we want

    .PARAMETER domainNames
    List of domain names within forest

    .EXAMPLE
    Get-ForestSID -forestName "test.lab" -domainNames "test.lab","child.test.lab"
    #>
    param(
        [parameter(Mandatory = $true)]
        [string]$forestName,

        [parameter(Mandatory = $true)]
        [string[]]$DomainNames
    )

    Out-Log -Operation $MyInvocation.MyCommand.Name -Data $PSBoundParameters

    if ($DomainNames.Contains($forestName.ToLower()) -and (Confirm-DomainAvailability $forestName)) {

        return Get-DomainSID -dnsDomain $forestName
    }
    else {
        foreach ($domain in $DomainNames) {
            if (!$domain.ToLower().Equals($forestName.ToLower()) -and (Confirm-DomainAvailability $domain)) {
                $DN = Get-DN $domain

                $results = Search-AD -dnsDomain $domain -attributes "ntsecuritydescriptor" -baseDN $DN -scope "base" `
                    -filter "(DistinguishedName=$DN)"

                if ($results.count -gt 0) {
                    $bytes = $results.Attributes.'ntsecuritydescriptor'.GetValues([Byte[]])[0]
                    $securityDescriptor = New-Object System.DirectoryServices.ActiveDirectorySecurity
                    $securityDescriptor.SetSecurityDescriptorBinaryForm($bytes)

                    foreach ($access in $securityDescriptor.Access) {
                        try {
                            $identityAccount = new-object System.Security.Principal.NTAccount($access.IdentityReference.Value)
                            $identitySID = $identityAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value
                        }
                        catch {
                            $identitySID = $access.IdentityReference.Value
                        }

                        if ($identitySID.EndsWith("-519")) {
                            return $identitySID.Substring(0, $identitySID.LastIndexOf("-"))
                        }
                    }
                }
            }
        }
    }
}

# Lists indictators that need to implement custom dns/credentials
# or report that domain is not available on execution
$Script:CustomCredentialSupport = @{
    ChannelBindingIsNotRequired = $false
    ZeroLogonPK = $false
    ZeroLogonDSP = $false
    SMBv1EnabledOnDCs = $false
    SmbSigningIsNotRequired = $false
    LdapSigningIsNotRequired = $false
    DPAPIKeysPermissions = $false
    DomainObsoleteFunctionalLevel = $false
    NonStandardSchemaPermissions = $false
    DCPrintSpooler = $false
    GPOWeakLMHashStorageEnabled = $false
    GPOLogonScripts = $false
    GPOScheduledTasks = $false
    GPOBadShortcut = $false
    GPOUserRights = $false
}

function CheckLdapConnectivity {
    <#
    .SYNOPSIS
    Checks if a given domain is responding to LDAP

    .DESCRIPTION
    Queries a given domain for it's LDAP port

    .PARAMETER dnsDomain
    DNS name of the domain whose LDAP port we want

    .EXAMPLE
    CheckLdapConnectivity "test.lab"
    #>
    param(
        [parameter(Mandatory = $true)]
        [string]$dnsDomain
    )
    Out-Log -Operation $MyInvocation.MyCommand.Name -Data $PSBoundParameters

    $domainIP = Resolve-DomainName -Domain $dnsDomain

    try
    {
        if (-not ([System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GetName().Name -eq 'System.DirectoryServices.Protocols' }))
        {
            Add-Type -AssemblyName 'System.DirectoryServices.Protocols'
        }

        $ldapConnection = New-Object System.DirectoryServices.Protocols.LdapConnection($domainIP)
        $ldapConnection.SessionOptions.ProtocolVersion = 3
        $ldapConnection.AuthType = [System.DirectoryServices.Protocols.AuthType]::Anonymous
        $ldapConnection.Bind()

        return $true
    }
    catch
    {
        return $false
    }
    finally
    {
        if ($null -ne $ldapConnection)
        {
            try
                {
                    $ldapConnection.Dispose()
                }
            catch {}
        }
    }
}

function Confirm-DomainAvailability{
    <#
    .SYNOPSIS
    Gets the availability of a given domain

    .DESCRIPTION
    Queries a given domain for it's availability

    .PARAMETER dnsDomain
    DNS name of the domain whose availability we want

    .EXAMPLE
    Confirm-DomainAvailability "test.lab"
    #>
    param(
        [parameter(Mandatory = $true)]
        [string]$dnsDomain
    )
    Out-Log -Operation $MyInvocation.MyCommand.Name -Data $PSBoundParameters

    $indicatorName = $Global:Self.ScriptName
    if($indicatorName -and $Script:CustomCredentialSupport.ContainsKey($indicatorName)){
        if(Resolve-DomainCredential -Domain $dnsDomain){
            Write-Warning "[$indicatorName]: Custom domain credentials are not supported"
            return $false
        }
    }

    try {
        $domainContext = New-DirectoryContext -Domain $dnsDomain
        [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($domainContext)
        return $true
    } catch {
        return CheckLdapConnectivity -dnsDomain $dnsDomain
    }
}


function Get-UACSet{
    <#
    .SYNOPSIS
    Translate User Account Control value into string

    .DESCRIPTION
    Translate each of the active flags in a User Account Control value and returns a string of all of them

    .PARAMETER uac
    User Account Control value to be translated

    .EXAMPLE
    Get-UACSet 514
    #>
    param(
        [parameter(Mandatory = $true)]
        [int]$uac
    )
    Out-Log -Operation $MyInvocation.MyCommand.Name -Data $PSBoundParameters

    $uacvalues = @{
        1 = "Script"
        2 = "AccountDisabled"
        8 = "HomeDirectoryRequired"
        16 = "AccountLockedOut"
        32 = "PasswordNotRequired"
        64 = "PasswordCannotChange"
        128 = "EncryptedTextPasswordAllowed"
        256 = "TempDuplicateAccount"
        512 = "NormalAccount"
        2048 = "InterDomainTrustAccount"
        4096 = "WorkstationTrustAccount"
        8192 = "ServerTrustAccount"
        65536 = "PasswordDoesNotExpire"
        131072 = "MnsLogonAccount"
        262144 = "SmartCardRequired"
        524288 = "TrustedForDelegation"
        1048576 = "AccountNotDelegated"
        2097152 = "UseDesKeyOnly"
        4194304 = "DontRequirePreauth"
        8388608 = "PasswordExpired"
        16777216 = "TrustedToAuthenticateForDelegation"
        33554432 = "NoAuthDataRequired"
        67108864 = "PartialSecretsAccount"
    }

    $uaclist = [System.Collections.ArrayList]@()
    foreach($k in $uacvalues.Keys){
        if($uac -band $k){
            $uaclist.Add($uacvalues[$k]) | out-null
        }
    }
    $uaclist
}


function RangeQueryHelper {
    <#
    .SYNOPSIS
    Performs range retrieval when needed

    .DESCRIPTION
    Checks if the results of Search-AD has partial results for some attributes that need a ranged retrieval

    .PARAMETER Attributes
    Array of the attributes requested from Search-AD

    .PARAMETER Entries
    Array of results returned from Search-AD that will be checked to valid full attribute result

    .EXAMPLE
    RangeQueryHelper -Attributes "SamAccountName" -Entries $Entries

    .NOTES
    This function is internal and not exported

    #>
    param(
        [parameter(Mandatory = $true)]
        [string[]]$Attributes,

        [parameter(Mandatory = $true)]
        [System.DirectoryServices.Protocols.SearchResultEntry[]]$Entries
    )

    foreach ($entry in $Entries){
        $resRangeResults = $entry.Attributes.AttributeNames.Where({$PSItem -match "^[\w-]+;range=0-\d+$"})
        foreach ($attribute in $resRangeResults){
            $attribute -match "^([\w-]+);range=0-\d+$" | Out-Null
            $attrName = $Matches[1]
            $attrData =  $entry.Attributes[$attribute]
            $inc = $attrData.count # default is 1500
            $start = 0
            $doneSearching = $false
            while (!($doneSearching)) {
                $start += $inc
                $end = ($start + $inc -1)
                $search.Filter = "distinguishedName=$($entry.DistinguishedName)"
                $search.Scope = "base"
                $search.DistinguishedName = $entry.DistinguishedName
                $attr = "$attrName;range=$start-$end"
                $search.Attributes.Clear()
                $search.Attributes.Insert(0,"$attr")
                $response = [System.DirectoryServices.Protocols.SearchResponse]$connection.SendRequest($search)

                # Number of entries should be 1 or something unexpected happened
                foreach ($resEntry in $response.Entries) {
                    if ($resEntry.Attributes[$attr]) {
                        $attrData += $resEntry.Attributes[$attr]
                        continue
                    }

                    # In case we reached the last chunk or we are stuck in the while loop
                    elseif ($resEntry.Attributes["$attrName;range=$start-*"]) {
                        $attr = "$attrName;range=$start-*"
                        $attrData += $resEntry.Attributes[$attr]
                    }
                    $doneSearching = $true
                }
            }

            # Done going through the range, now fill the original attribute
            $directoryAttribute = New-Object System.DirectoryServices.Protocols.DirectoryAttribute($attrName,$attrData)
            $entry.Attributes[$attrName] = $directoryAttribute

            # Remove the partial attribute
            $entry.Attributes.Remove($attribute)
        }
    }
    return $Entries
}

# THIS FUNCTION IS TEMPORARY
# This is a temporary work around for cases that the results is missing some attributes
function Bandage {
    param(
        [parameter(Mandatory = $true)]
        [string[]]$Attributes,

        [parameter(Mandatory = $true)]
        [System.DirectoryServices.Protocols.SearchResultEntry[]]$Entries
    )
    $attributesCount = $Attributes.Count
    foreach ($entry in $Entries) {
        if ($attributesCount -ne ($entry.Attributes.AttributeNames | Where-Object {!($_ -match ";range=")}).Count) {
            foreach ($attribute in $Attributes) {
                if (!($entry.Attributes.contains($attribute))) {
                    $entry.Attributes.Add($attribute,"")
                }
            }
        }
    }
    return $Entries
}


function Get-ADSearchFlag {
    <#
    .SYNOPSIS
    Translate SearchFlag value into string

    .DESCRIPTION
    Translate each of the active flags in a SearchFlag value and returns a string of all of them

    .PARAMETER searchFlags
    SearchFlag value to be translated

    .EXAMPLE
    Get-ADSearchFlag 904
    #>
    param(
        [parameter(Mandatory = $true)]
        [int]$searchFlags
    )
    Out-Log -Operation $MyInvocation.MyCommand.Name -Data $PSBoundParameters

    $searchflagvalues = @{
        1 = "Index"
        2 = "ContainerIndex"
        4 = "ANR"
        8 = "PreserveOnDelete"
        16 = "Copy"
        32 = "TupleIndex"
        64 = "SubtreeIndex"
        128 = "Confidential"
        256 = "NeverValueAudit"
        512 = "RODCFiltered"
        1024 = "ExtendedLinkTracking"
        2048 ="BaseOnly"
        4096 ="PartitionSecret"

    }

    $searchflagslist = [System.Collections.ArrayList]@()
    foreach($k in $searchflagvalues.Keys){
        if($searchFlags -band $k){
            $searchflagslist.Add($searchflagvalues[$k]) | out-null
        }
    }
    $searchflagslist
}


function Convert-StringToXml {
    <#
    .SYNOPSIS
    Trim and replace special characters from a string and convert it to xml

    .DESCRIPTION
    Trim and replace special characters from a string and convert it to xml

    .PARAMETER Xml
    Xml in a string format to be converted to xml format

    .EXAMPLE
    Convert-StringToXml "<pszAttributeName>member</pszAttributeName>"
    #>
    param (
        [parameter(Mandatory = $true)]
        [string]$Xml
    )

    $Xml = $Xml -replace "`0$" -replace "&", "&amp;" -replace "`"", "&quot;" -replace "'", "&apos;" -replace "\\<", "&lt;" -replace "\\>", "&gt;"
    $parsedXML = [xml]$Xml
    return $parsedXML
}


function Get-TrustAttributesSet {
    <#
    .SYNOPSIS
    Translate TrustAttributes value into string

    .DESCRIPTION
    Translate each of the active flags in a TrustAttributes value and returns a string of all of them

    .PARAMETER TrustAttributes
    TrustAttributes value to be translated

    .EXAMPLE
    Get-TrustAttributesSet 64
    #>
    param (
        [parameter(Mandatory = $true)]
        [int]$TrustAttributes
    )
    Out-Log -Operation $MyInvocation.MyCommand.Name -Data $PSBoundParameters

    $trustAttributesValues = @{
        1 = "TRUST_ATTRIBUTE_NON_TRANSITIVE"
        2 = "TRUST_ATTRIBUTE_UPLEVEL_ONLY"
        4 = "TRUST_ATTRIBUTE_QUARANTINED_DOMAIN"
        8 = "TRUST_ATTRIBUTE_FOREST_TRANSITIVE"
        16 = "TRUST_ATTRIBUTE_CROSS_ORGANIZATION"
        32 = "TRUST_ATTRIBUTE_WITHIN_FOREST"
        64 = "TRUST_ATTRIBUTE_TREAT_AS_EXTERNAL"
        128 = "TRUST_ATTRIBUTE_USES_RC4_ENCRYPTION"
        512 = "TRUST_ATTRIBUTE_CROSS_ORGANIZATION_NO_TGT_DELEGATION"
        1024 = "TRUST_ATTRIBUTE_PIM_TRUST"
        2048 = "TRUST_ATTRIBUTE_CROSS_ORGANIZATION_ENABLE_TGT_DELEGATION"
    }

    $attrList = [System.Collections.ArrayList]@()
    foreach($k in $trustAttributesValues.Keys){
        if($TrustAttributes -band $k){
            $attrList.Add($trustAttributesValues[$k]) | out-null
        }
    }
    $attrList
}


function Update-AttributeMetadata {
    <#
    .SYNOPSIS
    Gets an entry with msds-ReplAttributeMetadata, filter just for the relevant attribute and returns it in a new attribute called attributemetadata

    .DESCRIPTION
    Gets an entry with msds-ReplAttributeMetadata, filter just for the relevant attribute and returns it in a new attribute called attributemetadata

    .PARAMETER Entry
    Entry with a msds-ReplAttributeMetadata that needs filter and map

    .PARAMETER PropertyFilter
    The attribute to filter for.

    .PARAMETER StartOriginatingChangeThreshold
    Starting time for time filter

    .PARAMETER EndOriginatingChangeThreshold
    End time for time filter

    .PARAMETER MinimumVersionThreshold
    Minimum version number that should be retrieved

    .PARAMETER MaximumVersionThreshold
    Maximum version number that should be retrieved

    .EXAMPLE
    Update-AttributeMetadata -Entry $entry -PropertyFilter "sidHistory" -MinimumVersion 2 -StartOriginatingChangeThreshold $startOriginatingChangeThreshold
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification="False negative")]
    param (
        [parameter(Mandatory = $true)]
        [System.DirectoryServices.Protocols.SearchResultEntry] $Entry,

        [parameter(Mandatory = $true)]
        [string] $PropertyFilter,

        [parameter(Mandatory = $false)]
        [string] $StartOriginatingChangeThreshold = "1000-01-01T00:00:00Z",

        [parameter(Mandatory = $false)]
        [string] $EndOriginatingChangeThreshold = "9999-01-01T00:00:00Z",

        [parameter(Mandatory = $false)]
        [string] $MinimumVersionThreshold = "0",

        [parameter(Mandatory = $false)]
        [string] $MaximumVersionThreshold = "99999"
    )
    $attributesObject = [System.Collections.ArrayList]@()
    if($PSCmdlet.ShouldProcess($Entry)){
        if(-not $Parsers[$PropertyFilter]) { $Parsers[$PropertyFilter] = [System.Text.RegularExpressions.Regex]::new(".*<pszattributename>$($PropertyFilter.ToLower())<\/pszattributename>.*", 'Compiled') }
        if ($Entry.Attributes.'msds-replattributemetadata') {
            $xml = $Entry.Attributes.'msds-replattributemetadata'.GetValues("string")
            if ($parsers[$PropertyFilter].IsMatch($xml.ToLower()))
            {
                foreach ($attr in $xml) {
                    $attrMetaData = ([xml]($attr -replace '\x00','')).DS_REPL_ATTR_META_DATA
                    if ($attrMetaData) {
                        if ($attrMetaData.pszAttributeName.ToLower() -match $propertyFilter.ToLower()) {
                            if ($attrMetaData.ftimeLastOriginatingChange -lt $EndOriginatingChangeThreshold `
                                    -and $attrMetaData.ftimeLastOriginatingChange -gt $StartOriginatingChangeThreshold )
                            {
                                $attributeMetadata = [PSCustomObject][Ordered] @{
                                    LastOriginatingChange = $attrMetaData.ftimeLastOriginatingChange
                                    AttributeName = $attrMetaData.pszAttributeName
                                    Version = $attrMetaData.dwVersion
                                    LastOriginatingDsaInvocationID = $attrMetadata.uuidLastOriginatingDsaInvocationID
                                    USNOriginatingChange = $attrMetadata.usnOriginatingChange
                                    USNLocalChange = $attrMetadata.usnLocalChange
                                    LastOriginatingDsaDN = $attrMetadata.pszLastOriginatingDsaDN
                                }
                                [void]$attributesObject.add($attributeMetadata)
                            }
                        }
                    }
                }
            }
            if ($attributesObject.Count -gt 0) {
                $Entry.Attributes["attributemetadata"] = $attributesObject
                $Entry.Attributes.Remove("msds-replattributemetadata")
                return $Entry
            }
            else {
                return $null
            }
        }
    }
}


function Update-ValueMetadata {
    <#
    .SYNOPSIS
    Gets an entry with msds-ReplValueMetadata, filter just for the relevant Value and returns it in a new attribute called valuemetadata

    .DESCRIPTION
    Gets an entry with msds-ReplValueMetadata, filter just for the relevant attribute and returns it in a new attribute called valuemetadata

    .PARAMETER Entry
    Entry with a msds-ReplValueMetadata that needs filter and map

    .PARAMETER PropertyFilter
    The attribute to filter for.

    .PARAMETER StartOriginatingChangeThreshold
    Starting time for time filter

    .PARAMETER EndOriginatingChangeThreshold
    End time for time filter

    .PARAMETER MinimumVersionThreshold
    Minimum version number that should be retrieved

    .PARAMETER MaximumVersionThreshold
    Maximum version number that should be retrieved

    .EXAMPLE
    Update-ValueMetadata -Entry $entry -PropertyFilter "member" -MinimumVersion 2 -StartOriginatingChangeThreshold $startOriginatingChangeThreshold
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification="False negative")]
    param (
        [parameter(Mandatory = $true)]
        [System.DirectoryServices.Protocols.SearchResultEntry] $Entry,

        [parameter(Mandatory = $true)]
        [string] $PropertyFilter,

        [parameter(Mandatory = $false)]
        [string] $StartOriginatingChangeThreshold = "1000-01-01T00:00:00Z",

        [parameter(Mandatory = $false)]
        [string] $EndOriginatingChangeThreshold = "9999-01-01T00:00:00Z",

        [parameter(Mandatory = $false)]
        [string] $MinimumVersionThreshold = "0",

        [parameter(Mandatory = $false)]
        [string] $MaximumVersionThreshold = "99999"
    )
    if($PSCmdlet.ShouldProcess($Entry)){
        if ($Entry.Attributes.'msds-replvaluemetadata') {
            $valuesObject = [System.Collections.ArrayList]@()
            foreach ($attr in $Entry.Attributes.'msds-replvaluemetadata'.GetValues("string")) {
                $attrMetaData = Convert-StringToXml $attr | Select-Object -ExpandProperty 'DS_REPL_VALUE_META_DATA' -ErrorAction SilentlyContinue
                if ($attrMetaData) {
                    if ($attrMetaData.pszAttributeName.ToLower() -match $propertyFilter.ToLower()) {
                        if ($attrMetaData.ftimeLastOriginatingChange -lt $EndOriginatingChangeThreshold `
                                -and $attrMetaData.ftimeLastOriginatingChange -gt $StartOriginatingChangeThreshold `
                                -and $attrMetaData.dwVersion -ge $MinimumVersionThreshold `
                                -and $attrMetaData.dwVersion -le $MaximumVersionThreshold) {
                            $attributeMetadata = [PSCustomObject][Ordered] @{
                                LastOriginatingChange = $attrMetaData.ftimeLastOriginatingChange
                                AttributeName = $attrMetaData.pszAttributeName
                                TimeDeleted = $attrMetaData.ftimeDeleted
                                TimeCreated = $attrMetaData.ftimeCreated
                                Version = $attrMetaData.dwVersion
                                LastOriginatingDsaInvocationID = $attrMetadata.uuidLastOriginatingDsaInvocationID
                                USNOriginatingChange = $attrMetadata.usnOriginatingChange
                                USNLocalChange = $attrMetadata.usnLocalChange
                                LastOriginatingDsaDN = $attrMetadata.pszLastOriginatingDsaDN
                                ParentDN = $Entry.DistinguishedName
                                ValueDN = $attrMetaData.pszObjectDn
                            }
                            [void]$valuesObject.add($attributeMetadata)
                        }
                    }
                }
            }
            if ($valuesObject.Count -gt 0) {
                $Entry.Attributes["valuemetadata"] = $valuesObject
                $Entry.Attributes.Remove("msds-replvaluemetadata")
                return $Entry
            }
            else {
                return $null
            }
        }
    }
}

<#
.SYNOPSIS
Gets an entry with ntSecurityDescriptor, filter just the relevant ACEs and returns it in a new attribute

.DESCRIPTION
Gets an entry with ntSecurityDescriptor, filter just the relevant ACEs and returns it in a new attribute

.PARAMETER Entry
Entry with a ntSecurityDescriptor that needs filter and map

.PARAMETER GuidHTFilter
Hashtable of Guids to filter for. Use just if only specific object types are needed.

.PARAMETER PropagationFlagsFilter
Wanted propagation flags as string, divided by '|', to be filtered by

.PARAMETER AccessControlTypeFilter
Wanted Access control type (e.g. Allow)

.PARAMETER ExcludedSIDs
List of SIDs that are allowed and should be excluded

.PARAMETER RightsFilter
Access rights that we care about, divided by "|"
For example - "GenericAll|GenericWrite"

.EXAMPLE
Update-NTSecurityDescriptor -Entry $entry -RightsFilter "GenericAll|GenericWrite" -PropagationFlagsFilter "None|NoPropagateInherit"

#>
$codeUpdateNtSecurityDescriptor = @"
using System.DirectoryServices.Protocols;
using System.DirectoryServices;
using System.Collections.Generic;
using System.Collections;
using System;
using System.Security.Principal;
using System.Security.AccessControl;
using System.Text.RegularExpressions;
namespace UpdateNtSecurityDescriptor
{
    public class NtSecurityDescriptor
    {
        static public List<ActiveDirectoryAccessRule> Update(SearchResultEntry entry, Hashtable guidHTFilter, string propagationFlagsFilter, string accessControlTypeFilter, string []excludedSIDs, string rightsFilter, string inheritanceTypeFilter)
        {
            string identitySID = "";
            List<ActiveDirectoryAccessRule> relevantACEs = new List<ActiveDirectoryAccessRule>();
            byte[][] descriptorBytes= (byte[][])entry.Attributes["ntsecuritydescriptor"].GetValues(typeof(byte[]));
            ActiveDirectorySecurity securityDescriptor = new ActiveDirectorySecurity();
            securityDescriptor.SetSecurityDescriptorBinaryForm(descriptorBytes[0]);
            foreach (AuthorizationRule rule in securityDescriptor.GetAccessRules(true, true, typeof(NTAccount)))

            {
                ActiveDirectoryAccessRule oar = rule as ActiveDirectoryAccessRule;
                if (guidHTFilter.Keys.Count == 0 || guidHTFilter.Contains(oar.ObjectType.ToString()))

                {
                    if (!Regex.IsMatch(oar.PropagationFlags.ToString(),propagationFlagsFilter))
                    {
                        continue;
                    }
                    if (!Regex.IsMatch(oar.InheritanceType.ToString(),inheritanceTypeFilter))
                    {
                        continue;
                    }
                    try
                    {
                        NTAccount identityAccount = new NTAccount(oar.IdentityReference.Value);
                        identitySID = identityAccount.Translate(typeof(SecurityIdentifier)).Value;
                    }
                    catch
                    {
                        identitySID = oar.IdentityReference.Value;
                    }
                    bool containsSID = false;
                    foreach (string sid in excludedSIDs)
                    {
                        if (sid == identitySID)
                        {
                            containsSID = true;
                            break;
                        }
                    }
                    if (!(containsSID))
                    {
                        if (oar.AccessControlType.ToString() == accessControlTypeFilter)
                        {
                            if (Regex.IsMatch(oar.ActiveDirectoryRights.ToString(),rightsFilter))
                            {
                                relevantACEs.Add(oar);
                            }
                      }
                    }
                }
            }
            return relevantACEs;
        }
    }
}
"@
if ($PSVersionTable.PSEdition -eq "Core"){
    $referencingassembliesNtSD = ("System.DirectoryServices.Protocols","System.Collections","System.Security","System.DirectoryServices","System.Security.AccessControl","System.Text.RegularExpressions","System.Collections.NonGeneric","System.IO.FileSystem.AccessControl","System.Security.Principal.Windows")
}
else{
    $referencingassembliesNtSD = ("System.DirectoryServices.Protocols","System.Collections","System.Security","System.DirectoryServices")
}

if (-not ('UpdateNtSecurityDescriptor.NtSecurityDescriptor' -as [Type])) {
    Add-Type -TypeDefinition $codeUpdateNtSecurityDescriptor -Language CSharp -ReferencedAssemblies $referencingassembliesNtSD
}
function Update-NTSecurityDescriptor {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [parameter(Mandatory = $true)]
        [System.DirectoryServices.Protocols.SearchResultEntry] $Entry,

        [parameter(Mandatory = $false)]
        [Hashtable] $GuidHTFilter = @{},

        [parameter(Mandatory = $false)]
        [string] $PropagationFlagsFilter,

        [parameter(Mandatory = $false)]
        [string] $InheritanceTypeFilter = "None|All|Descendents|Children|SelfAndChildren",

        [parameter(Mandatory = $false)]
        [string] $AccessControlTypeFilter = "Allow",

        [parameter(Mandatory = $false)]
        [string[]] $ExcludedSIDs = @(),

        [parameter(Mandatory = $false)]
        [string] $RightsFilter
    )

    $relevantACEs = [UpdateNtSecurityDescriptor.NtSecurityDescriptor]::Update($Entry,$GuidHTFilter,$PropagationFlagsFilter,$AccessControlTypeFilter,$ExcludedSIDs,$RightsFilter,$InheritanceTypeFilter)
    if ($relevantACEs) {
        $Entry.Attributes["aces"] = $relevantACEs

        # Remove the full ntSecurityDescriptor attribute
        $Entry.Attributes.Remove("ntsecuritydescriptor")
        return $Entry
    }
    else {
        return $null
    }
}


function Test-RangeRetrievalNeed {
    <#
    .SYNOPSIS
    Check whether a multi valued attribute was requested

    .DESCRIPTION
    Checking for a need for range retrieval query will require iterating over every entry in the results,
    this function should prevent doing this check when no multi valued attributed was requested and therefore no chance for range retrieval need

    .PARAMETER Attributes
    Array of the attributes requested from Search-AD

    .EXAMPLE
    Test-RangeRetrievalNeed -Attributes "SamAccountName"

    .NOTES
    This function is internal and not exported
    #>
    param (
        [parameter(Mandatory = $true)]
        [string[]]$Attributes
    )

    # Determine if ranged search might be needed, trying to reduce cost of the check for ranged results
    $rangedSearch = $false
    $rangedAttributes = @("member","memberof","serviceprincipalname", "*", "msds-replattributemetadata", "msds-replvaluemetadata", "serviceprincipalname", "msds-revealedlist") # Attributes that are multi valued and might have more then 1500 entries
    foreach ($attribute in $Attributes) {
        if($rangedAttributes -contains $attribute.ToLower()) {
            $rangedSearch = $true
            break
        }
    }
    return $rangedSearch
}


function Get-AdminsInDomain {
    <#
    .DESCRIPTION
    Returns SIDs or DNs for privileged group membesrs in requested domains
    .PARAMETER DomainNames
    Array of existing domains
    .PARAMETER ReturnSIDs
    Only specify if SIDs are needed
    .EXAMPLE
    Get-AdminsInDomain -DomainNames $DomainNames
    Get-AdminsInDomain -DomainNames $DomainNames -ReturnSIDs
    #>
    param (
        [parameter(Mandatory = $true)]
        [string]$forestName,

        [parameter(Mandatory = $true)]
        [string[]]$DomainNames,

        [parameter(Mandatory = $false)]
        [switch]$ReturnSIDs
    )
    Out-Log -Operation $MyInvocation.MyCommand.Name -Data $PSBoundParameters

    $forestDN = Get-DN $forestName
    $privilegedGroupsDN = [System.Collections.ArrayList]@()
    $admins = [System.Collections.ArrayList]@()
    $failedToEnumerate = [System.Collections.ArrayList]@()
    $largeGroups = [System.Collections.ArrayList]@()
    $EnumeratedDN = [System.Collections.ArrayList]@()
    $unavailableDomains = [System.Collections.ArrayList]@()

    # Build filter for primary group ID search
    $privilegedRIDs = [System.Collections.ArrayList]@()
    [void]$privilegedRIDs.AddRange(@("551","552","548","549","550","544","512","516","518","519","521"))

    $primaryGroupFilter = "(|"
    foreach($privilegedRID in $privilegedRIDs) {
        $primaryGroupFilter += "(primaryGroupID=$privilegedRID)"
    }
    $primaryGroupFilter += ")"

    foreach ($domain in $DomainNames) {
        if ($unavailableDomains.Contains($domain)) {
            continue
        }
        else {
            if (-not (Confirm-DomainAvailability $domain)) {
                [void]$unavailableDomains.Add($domain)
                continue
            }
        }

        $DN = Get-DN $domain
        $domainSID = Get-DomainSID $domain

        if ($domain -eq $ForestName) {
            # Get a list of the forest groups DN
            $forestSID = Get-DomainSID $ForestName
            $forestPrivilegedGroups = @("519","518")

            foreach ($groupRID in $forestPrivilegedGroups) {
                $forestGroupObject = Search-AD -dnsDomain $ForestName -baseDN $forestDN -scope "subtree" `
                    -filter "(&(objectSid=$forestSID-$groupRID)(objectCategory=group))"
                if ($forestGroupObject) {
                    [void]$privilegedGroupsDN.add($forestGroupObject.DistinguishedName)
                }
            }
        }

        $privilegedGroups = @("S-1-5-32-551","S-1-5-32-552","S-1-5-32-548","S-1-5-32-549","S-1-5-32-550","S-1-5-32-544",
            "$domainSID-512","$domainSID-516","$domainSID-521")

        # Get a list of the groups DN
        foreach ($sid in $privilegedGroups) {
            $groupObjectSearchParams = @{
                dnsDomain = $domain
                baseDN = $DN
                scope = "subtree"
                filter = "(&(objectSid=$sid)(objectCategory=group))"
            }

            $groupObject = Search-AD @groupObjectSearchParams

            if ($groupObject) {
                [void]$privilegedGroupsDN.add($groupObject.DistinguishedName)
            }
        }

        # Get users who are admins via primaryGroupID
        $primarySearchParams = @{
            dnsDomain = $domain
            attributes = "objectsid"
            baseDN = $DN
            scope = "subtree"
            filter = $primaryGroupFilter
        }

        $primaryResults = Search-AD @primarySearchParams

        foreach ($primaryResult in $primaryResults) {
            if($primaryResult.DistinguishedName){
                if (!($EnumeratedDN.Contains($primaryResult.DistinguishedName))) {
                    [void]$EnumeratedDN.Add($primaryResult.DistinguishedName)
                }

                if ($ReturnSIDs) {
                    $adminSID = (New-Object System.Security.Principal.SecurityIdentifier @($primaryResult.Attributes."objectsid".GetValues("byte[]")[0],0)).Value
                    if (!($admins.Contains($adminSID))) {
                        [void]$admins.Add($adminSID)
                    }
                }
            }
        }
    }

    # The above creation of $privilegedGroupsDN will result in only groups existing in one of the domains provided within $DomainNames
    foreach($groupDN in $privilegedGroupsDN) {
        try {
            $groupDomain = $groupDN.Substring($groupDN.IndexOf("DC=")).replace("DC=","").replace(",",".")
            $groupDomainNETBios = Get-NetBIOSName -dnsDomain $groupDomain -DomainNames $DomainNames -forestName $forestName

            $groupMemberSearchParam = @{
                dnsDomain = $groupDomain
                attributes = @("msds-membertransitive", "objectsid", "samAccountName")
                baseDN = $groupDN
                scope = "base"
                filter = "distinguishedName=$groupDN"
            }

            $groupMembers = Search-AD @groupMemberSearchParam

            if ($ReturnSIDs) {
                $groupSID = (New-Object System.Security.Principal.SecurityIdentifier @($groupMembers.Attributes."objectsid".GetValues("byte[]")[0],0)).Value
                if ($admins.Contains($groupSID)) {
                    continue
                }
                [void]$admins.Add($groupSID)
            }
            if (!$EnumeratedDN.Contains($groupDN)) {
                [void]$EnumeratedDN.Add($groupDN)
            }

            if ($groupMembers.Attributes."msds-membertransitive;range=0-4499") {
                $groupSAM = $groupMembers.Attributes.samaccountname[0]
                [void]$largeGroups.Add("$groupDomainNETBios\$groupSAM")
                $memberAttribute = "msds-membertransitive;range=0-4499"
            }
            else {
                $memberAttribute = "msds-membertransitive"
            }

            if (!($groupMembers.Attributes."msds-membertransitive"[0]) -and !($memberAttribute -match "range")) {
                continue
            }

            foreach ($adminDN in $groupMembers.Attributes.$memberAttribute.GetValues("string")) {
                $memberDomain = $adminDN.Substring($adminDN.IndexOf("DC=")).replace("DC=","").replace(",",".").tolower()

                if ($unavailableDomains.Contains($memberDomain) -or !($DomainNames.Contains($memberDomain))) {
                    continue
                }
                else {
                    if (-not (Confirm-DomainAvailability $memberDomain)) {
                        [void]$unavailableDomains.Add($memberDomain)
                        continue
                    }
                }

                if ($EnumeratedDN.Contains($adminDN)) {
                    continue
                }
                [void]$EnumeratedDN.Add($adminDN)

                if (!$ReturnSIDs) {
                    continue
                }
                try {
                    if ($adminDN -match "CN=ForeignSecurityPrincipals") {
                        if (!($admins.Contains($adminDN))) {
                            [void]$admins.Add($adminDN)
                        }

                        if (!($failedToEnumerate.Contains($adminDN))) {
                            [void]$failedToEnumerate.Add($adminDN)
                        }

                        continue
                    }

                    $adminSearchParam = @{
                        dnsDomain = $memberDomain
                        attributes = "objectsid"
                        baseDN = $adminDN
                        scope = "base"
                        filter = "distinguishedName=$adminDN"
                    }

                    $adminObject = Search-AD @adminSearchParam

                    $adminSID = (New-Object System.Security.Principal.SecurityIdentifier @($adminObject.Attributes."objectsid".GetValues("byte[]")[0],0)).Value
                    if ($admins.Contains($adminSID)) {
                        continue
                    }
                    [void]$admins.Add($adminSID)
                }
                catch {
                    if (!($failedToEnumerate.Contains($adminDN))) {
                        [void]$failedToEnumerate.Add($adminDN)
                    }
                }
            }
        }
        catch {
            if (!($failedToEnumerate.Contains($adminDN))) {
                [void]$failedToEnumerate.Add($adminDN)
            }
        }
    }
    if (!$ReturnSIDs) {
        $admins = $EnumeratedDN
    }
    return $admins, $failedToEnumerate, $largeGroups, $unavailableDomains
}

function Update-IndicatorOutputAttackWindow {
    <#
    .SYNOPSIS
    Update output ArrayList to include additional fields
    .DESCRIPTION
    Returns an updated version of the indicator's output ArrayList if more processing is needed
    .PARAMETER OutputObjects
    ArrayList of objects to be returned by the indicator
    .PARAMETER StartAttackWindow
    DateTime specifying the start of the attack
    .PARAMETER EndAttackWindow
    DateTime specifying the end of the attack
    .EXAMPLE
    Update-IndicatorOutputAttackWindow -OutputObjects $outputObjects -StartAttackWindow $StartAttackWindow -EndAttackWindow $EndAttackWindow
    #>
    [OutputType([System.Collections.ArrayList])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        $ThisOutput,

        $StartAttackWindow,

        $EndAttackWindow,

        $Metadata,

        [switch]$ValueMetadata,

        [switch]$ExcludeTimestamp
    )
    if($PSCmdlet.ShouldProcess($Metadata.ValueDN)) {
        if(!($ThisOutput)) {
            return $null
        }

        if ($StartAttackWindow -and $EndAttackWindow) {
            if(!($ThisOutput.psobject.Properties.name -contains "EventTimestamp")) {
                if (!($Metadata)) {
                    return $null
                }
                $timestamp = [DateTime]::Parse($Metadata.LastOriginatingChange).ToUniversalTime()
                $ThisOutput | Add-Member -Type NoteProperty -Name "EventTimestamp" -Value $timestamp
            }
            if ($ThisOutput."EventTimestamp" -gt $StartAttackWindow -and $ThisOutput."EventTimestamp" -lt $EndAttackWindow) {
                $ThisOutput | Add-Member -Type NoteProperty -Name "InAttackWindow" -Value "True"
            }
            else {
                $ThisOutput | Add-Member -Type NoteProperty -Name "InAttackWindow" -Value "False"
            }
        }
        else {
            if(!($ThisOutput.psobject.Properties.name -contains "EventTimestamp") -and (!($ExcludeTimestamp))) {
                if (!($Metadata)) {
                    return $null
                }
                $timestamp = [DateTime]::Parse($Metadata.LastOriginatingChange).ToUniversalTime()
                $ThisOutput | Add-Member -Type NoteProperty -Name "EventTimestamp" -Value $timestamp
            }
        }
    }
}


function Search-ADHelper{
    <#
    .SYNOPSIS
    Proxy to the Search-AD function

    .DESCRIPTION
    Utilize Search-AD to send ldap queries but applies some logic before calling search-ad to split into several calls

    .PARAMETER dnsDomain
    DNS name of the domain that will be searched against

    .PARAMETER attributes
    Attributes to return from the search, should be lowercase as convention

    .PARAMETER baseDN
    Root distinguished name for the search

    .PARAMETER scope
    Scope of the search

    .PARAMETER filter
    Filter to be applied to the search

    .PARAMETER pageSize
    Page size for the search
    Default = 1000

    .PARAMETER ASQ
    Attribute name for Attribute Scope Query

    .PARAMETER scriptblockFilter
    Scriptblock that gets an entry as parameter, analyze the entry and returns whether the indicator needs this entry or not
    This parameter is used to do analysis of the ldap results before building a list of object to reduce memory usage

    .PARAMETER MetaType
    For PK-PRE indicators, chose whether we should search on msds-replattributemetadata or msds-replvaluemetadata

    .PARAMETER StartAttackWindow
    Start time of the time window supplied by PK-PRE

    .PARAMETER EndAttackWindow
    End time of the time window supplied by PK-PRE

    .PARAMETER PropertyFilter
    Attribute name of the attribute we are looking for in the metadata (for PK-PRE indicators)

    .PARAMETER StartMetaFilter
    Start time of the time window supplied by the indicator in his normal case (for indicators that utilized metadata before PK-PRE)

    .PARAMETER EndMetaFilter
    End time of the time window supplied by the indicator in his normal case (for indicators that utilized metadata before PK-PRE)

    .PARAMETER MinimumVersionThreshold
    Minimum dwVersion to filter by in the metadata (for indicators that utilized metadata before PK-PRE)

    .PARAMETER MaximumVersionThreshold
    Maximum dwVersion to filter by in the metadata (for indicators that utilized metadata before PK-PRE)

    .EXAMPLE
    Get all users with their SamAccountName and UserAccountControl
    $DN = Get-DN test.lab
    Search-ADHelper -dnsDomain test.lab -attributes "samaccountname", "useraccountcontrol" -baseDN $DN -scope "Subtree" -filter "(&(objectCategory=person)(objectClass=user))"
    #>
    param(
        [parameter(Mandatory)]
        [string] $dnsDomain,

        [string[]] $attributes = "",

        [string] $baseDN,

        [string] $scope = "subtree",

        [parameter(Mandatory)]
        [string] $filter,

        [int] $pageSize = 1000,

        [string] $ASQ,

        [scriptblock[]] $scriptblockFilter = @(),

        [string] $MetaType = "Attribute",

        $StartAttackWindow,

        $EndAttackWindow,

        [string] $PropertyFilter,

        [DateTime] $StartMetaFilter = "Monday, 1 January 0001 0:00:00",

        [DateTime] $EndMetaFilter = "Friday, 31 December 9999 23:59:59",

        [string] $MinimumVersionThreshold = "0",

        [string] $MaximumVersionThreshold = "99999",

        [switch] $ExcludeScriptblock
    )
    Out-Log -Operation $MyInvocation.MyCommand.Name -Data $PSBoundParameters

    $attributes = $attributes | ForEach-Object {$_.ToLower()}
    $searchADParameters = @{
        dnsDomain = $dnsDomain
        attributes = $attributes
        baseDN = $baseDN
        scope = $scope
        filter = $filter
        pageSize = $pageSize
        ASQ = $ASQ
        scriptblockFilter = $scriptblockFilter
    }

    $metaDateFormat = "yyyy-MM-ddTHH:mm:ssZ"

    if ($PropertyFilter) {
        if (!($ExcludeScriptblock) -or ($StartAttackWindow -and $EndAttackWindow)) {
            # Check which is earlier, the indicator default start date or the start of the attack window
            if ($StartAttackWindow -and $StartAttackWindow -lt $StartMetaFilter) {
                $StartMetaFilter = $StartAttackWindow
            }

            # updateMetadataArguments will be used when using $updateMetadata.GetNewClosure() although we are not passing it anywhere
            $updateMetadataArguments = @{
                PropertyFilter = $PropertyFilter
                MinimumVersionThreshold = $MinimumVersionThreshold
                MaximumVersionThreshold = $MaximumVersionThreshold
                StartOriginatingChangeThreshold = get-date $StartMetaFilter -Format $metaDateFormat
                EndOriginatingChangeThreshold = get-date $EndMetaFilter -Format $metaDateFormat
            }

            # This line doesn't really do anything, it is just to bypass the powershell script analyzer saying this variable is assigned but not used
            $updateMetadataArguments.MinimumVersionThreshold = $MinimumVersionThreshold

            # We need to make sure we are getting the metadata
            if ($MetaType -eq "attribute") {
                if(!($attributes.Contains("msds-replattributemetadata"))) {
                    $attributes += "msds-replattributemetadata"
                }
            }
            elseif($MetaType -eq "value") {
                if(!($attributes.Contains("msds-replvaluemetadata"))) {
                    $attributes += "msds-replvaluemetadata"
                }
            }
            $searchADParameters.attributes = $attributes
            $updateMetadata = UpdateMetaHelper -MetaType $MetaType

            $searchADParameters.scriptblockFilter += $updateMetadata.GetNewClosure()
            return Search-AD @searchADParameters
        }
    }
    # We hit this code if we don't have PropertyFilter or we were provided $excludeScriptblockFitler AND were not provided with an attack window
    return Search-AD @searchADParameters
}


function Search-ADConfig {
    <#
    .SYNOPSIS
    Check domain availability before passing to Search-ADHelper when querying the Configuration partition

    .DESCRIPTION
    Determine if a domain is available before running Search-ADHelper for querying the Configuration partition

    .PARAMETER forestName
    DNS name of the forest whose SID we want

    .PARAMETER domainNames
    List of domain names within forest

    .PARAMETER searchADParameters
    Hashtable. Parameters to pass to Search-ADHelper

    .EXAMPLE
    Search-ADConfig -forestName "test.lab" -domainNames "test.lab","child.test.lab" -searchADParameters $searchParams
    #>
    param(
        [parameter(Mandatory)]
        [string] $forestName,

        [parameter(Mandatory)]
        [string[]] $DomainNames,

        [parameter(Mandatory)]
        [hashtable] $searchADParameters
    )
    Out-Log -Operation $MyInvocation.MyCommand.Name -Data $PSBoundParameters

    $unavailableDomains = [System.Collections.ArrayList]@()

    if ($DomainNames.Contains($forestName.ToLower()) -and (Confirm-DomainAvailability $forestName)) {
        $searchADParameters.dnsDomain = $forestName
    }
    else {
        if ($DomainNames.Contains($forestName)) {
            [void]$unavailableDomains.Add($forestName.ToLower())
        }

        foreach ($domain in $DomainNames) {
            if (-not $domain.ToLower().Equals($forestName.ToLower()) -and (Confirm-DomainAvailability $domain)) {
                $searchADParameters.dnsDomain = $domain
                break
            }
            elseif (-not $domain.ToLower().Equals($forestName.ToLower())) {
                [void]$unavailableDomains.Add($domain)
            }
        }
    }

    if ($unavailableDomains.Count -eq $DomainNames.Count) {
        return [System.Collections.ArrayList]@(), $unavailableDomains
    }

    return (Search-ADHelper @searchADParameters), $unavailableDomains
}

function Resolve-DomainName {
    <#
    .SYNOPSIS
        Replaces domain name with its IP address if custom Dns server is specified for this domain
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $Domain
    )

    if(-not $env:IOE_FOREST_DNS_SERVER ){ return $Domain }

    $dnsQuery = @{
        Name = $Domain
        Server = $env:IOE_FOREST_DNS_SERVER
    }
    $ipAddress = Resolve-DnsName @dnsQuery | Select-Object -First 1 -ExpandProperty 'IP4Address'
    if(-not $ipAddress){
        Write-Error "[$($Domain)]: Cannot resolve IP address using DNS server [$($dnsQuery.Server)]"
        return $Domain
    }

    return $ipAddress
}

$Script:ForestCredentials = $null
function Resolve-DomainCredential {
    <#
    .SYNOPSIS
        Returns network credentials for the specified domain or $null if no custom credentials are specified
    #>
    [CmdletBinding()]
    [OutputType([System.Net.NetworkCredential])]
    param(
        [Parameter(Mandatory)]
        [string] $Domain
    )

    if($null -eq $Script:ForestCredentials){
        if($env:IOE_FOREST_CREDENTIALS){
            $Script:ForestCredentials = $env:IOE_FOREST_CREDENTIALS | ConvertFrom-Json
        }
        else {
            $Script:ForestCredentials = $false
        }
    }
    if(-not $Script:ForestCredentials){ return $null }

    $credentials = $Script:ForestCredentials."$Domain"
    if(-not $credentials){ return $null }

    return [System.Net.NetworkCredential]::new(
        $credentials.UserName,
        $credentials.Password
    )
}

function New-DirectoryContext {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Domain
    )

    $context = @{
        TypeName = 'System.DirectoryServices.ActiveDirectory.DirectoryContext'
        ArgumentList = @(
            'Domain' # ContextType
            $Domain # Name
        )
    }

    $domainIP = Resolve-DomainName -Domain $Domain
    if($domainIP -ne $Domain){
        $context.ArgumentList[0] = [System.DirectoryServices.ActiveDirectory.DirectoryContextType]::DirectoryServer
        $context.ArgumentList[1] = $domainIP
    }

    $credentials = Resolve-DomainCredential -Domain $Domain
    if($credentials){
        $context.ArgumentList += @(
            $credentials.UserName
            $credentials.Password
        )
    }

    return New-Object @context
}


function UpdateMetaHelper {
    <#
    .SYNOPSIS
    Build scriptblock to be passed by Search-ADHelper to Search-AD base on $MetaType parameter

    .DESCRIPTION
    Build scriptblock to be passed by Search-ADHelper to Search-AD base on $MetaType parameter

    .PARAMETER MetaType
    For PK-PRE indicators, chose whether we should search on msds-replattributemetadata or msds-replvaluemetadata

    .Example
    $updateMetadata = UpdateMetaHelper -MetaType $MetaType
    #>
    param (
        [string]$MetaType
    )
    if ($MetaType -eq "Attribute") {
        $updateMetaSB = {
            param ([System.DirectoryServices.Protocols.SearchResultEntry] $Entry)
            Update-AttributeMetadata @updateMetadataArguments -entry $Entry
        }
    }
    elseif ($MetaType -eq "Value") {
        $updateMetaSB = {
            param ([System.DirectoryServices.Protocols.SearchResultEntry] $Entry)
            Update-ValueMetadata @updateMetadataArguments -entry $Entry
        }
    }
    return $updateMetaSB
}


function Get-SupportedEncryptionTypesSet {
    <#
    .SYNOPSIS
    Get a string representation of MsDS-SupportedEncryptionTypes from its decimal value

    .DESCRIPTION
    Get a string representation of MsDS-SupportedEncryptionTypes from its decimal value

    .PARAMETER SupportedEncryptionTypesValue
    The decimal value of MsDS-SupportedEncryptionTypes.
    Can also handle an empty MsDS-SupportedEncryptionTypes value as input, as [int]$null becomes 0

    .EXAMPLE
    Get-SupportedEncryptionTypesSet $supportedEncryptionType
    #>
    param(
        [parameter(Mandatory = $true)]
        [int]$SupportedEncryptionTypesValue
    )
    Out-Log -Operation $MyInvocation.MyCommand.Name -Data $PSBoundParameters

    $SupportedEncryptionTypesKeys = @{
        0 = "RC4_HMAC_MD5"
        1 = "DES_DES_CBC_CRC"
        2 = "DES_CBC_MD5"
        4 = "RC4_HMAC_MD5"
        8 = "AES 128"
        16 = "AES 256"
    }

    $supportedEncryptionTypeList = [System.Collections.ArrayList]@()

    if ($SupportedEncryptionTypesValue -eq 0){ # handle 0 value (-band 0 will always return false)
        [void]$supportedEncryptionTypeList.Add($SupportedEncryptionTypesKeys[0])
    }
    else {
        foreach($k in $SupportedEncryptionTypesKeys.Keys){
            if($SupportedEncryptionTypesValue -band $k){
                [void]$supportedEncryptionTypeList.Add($SupportedEncryptionTypesKeys[$k])
            }
        }
    }
    $supportedEncryptionTypeList
}


function Get-HostSPNMapping {
    <#
    .SYNOPSIS
    Get the services that map to the HOST SPN

    .DESCRIPTION
    Get the services that map to the HOST SPN from the Configuration partition

    .PARAMETER DomainNames
    The DNS name of the domain

    .PARAMETER ForestName
    The DNS name of the forest root

    .EXAMPLE
    Get-HostSPNMapping -dnsDomain $domain -forestName $forestName
    #>
    param(
        [parameter(Mandatory = $true)]
        [string[]]$DomainNames,

        [parameter(Mandatory = $true)]
        [string]$ForestName
    )

    $spnMappings = [System.Collections.ArrayList]@()

    $forestDN = Get-DN -dnsDomain $forestName
    $dsDN = "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,$forestDN"
    $filter = "(sPNMappings=*)"

    $searchParams = @{
        attributes = "sPNMappings"
        baseDN = $dsDN
        scope = "base"
        filter = $filter
    }

    $spnMappingObject = (Search-ADConfig -forestName $forestName -domainNames $DomainNames -searchADParameters $searchParams)[0]
    foreach ($mapping in $spnMappingObject.Attributes.'spnmappings'.GetValues("string")) {
        if ($mapping.ToLower().StartsWith("host=")) {
            foreach ($hostMapping in $mapping.Substring(5).Split(',')) {
                [void]$spnMappings.Add($hostMapping.ToLower())
            }
        }
    }

    return $spnMappings
}


function Get-NetBIOSName {
    <#
    .SYNOPSIS
    Gets the NetBIOS name of a given domain

    .DESCRIPTION
    Queries a given domain for its NetBIOS name

    .PARAMETER DomainNames
    Array of existing domains

    .PARAMETER ForestName
    DNS name of the forest root

    .PARAMETER dnsDomain
    DNS name of the domain whose NetBIOS name we want

    .EXAMPLE
    Get-NetBIOSName -dnsDomain "child.test.lab" -forestName "test.lab"
    #>
    param(
        [parameter(Mandatory = $true)]
        [string[]]$DomainNames,

        [parameter(Mandatory = $true)]
        [string]$ForestName,

        [parameter(Mandatory = $true)]
        [string]$dnsDomain
    )

    $forestDN = Get-DN -dnsDomain $forestName
    $configDN = "CN=Configuration,$forestDN"
    $netbiosFilter = "(&(netbiosname=*)(dnsroot=$dnsDomain))"

    $searchParams = @{
        attributes = "netbiosname"
        baseDN = $configDN
        scope = "subtree"
        filter = $netbiosFilter
    }

    $netBIOSObject = Search-ADConfig -forestName $forestName -domainNames $DomainNames -searchADParameters $searchParams
    return $netBIOSObject.Attributes.netbiosname.GetValues("string")[0]
}


function Compare-DSPMultiValuedAttribute {
    <#
    .SYNOPSIS
    Convert and compare Old and New values from a DSP search

    .DESCRIPTION
    Convert string values from DSP to arrays and compare

    .PARAMETER dspResult
    The object returned from a DSP search

    .EXAMPLE
    Compare-DSPMultiValuedAttribute -dspResult $dsp_result
    #>
    param(
        [parameter(Mandatory = $true)]
        [object]$dspResult
    )
    $ret = @{}
    $fromValue = $dspResult.From_StringValue
    $toValue = $dspResult.To_StringValue

    if ($fromValue) { $ret["from"] = $fromValue.TrimStart('[').TrimEnd(']').Split(',') }
    if ($toValue) { $ret["to"] = $toValue.TrimStart('[').TrimEnd(']').Split(',') }

    $ret["removed"] = $ret["from"] | Where-Object {$ret["to"] -notcontains $_}
    $ret["added"] = $ret["to"] | Where-Object {$ret["from"] -notcontains $_}

    return $ret
}


function Update-GraphApiAADIndicatorOutputAttackWindow {
    <#
    .SYNOPSIS
    Update output to include additional fields
    .DESCRIPTION
    Returns an updated version of the indicator's output if more processing is needed
    .PARAMETER OutputObjects
    ArrayList of objects to be returned by the indicator
    .PARAMETER StartAttackWindow
    DateTime specifying the start of the attack
    .PARAMETER EndAttackWindow
    DateTime specifying the end of the attack
    .EXAMPLE
    Update-GraphApiAADIndicatorOutputAttackWindow -ThisOutput $thisOutput -StartAttackWindow $StartAttackWindow -EndAttackWindow $EndAttackWindow -DateToCheck <A Date>
    #>
    [OutputType([System.Collections.ArrayList])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        $ThisOutput,

        $StartAttackWindow,

        $EndAttackWindow,

        $DateToCheck


    )
    if($PSCmdlet.ShouldProcess($DateToCheck)) {
        if(!($ThisOutput)) {
            return $null
        }

        if ($StartAttackWindow -and $EndAttackWindow) {
            if(!($ThisOutput.psobject.Properties.name -contains "EventTimestamp")) {
                if (!($DateToCheck)) {
                    return $null
                }
                if ($DateToCheck){
                    if (-not ($DateToCheck.GetType().Name -eq "DateTime"))
                    {
                        $timestamp = [DateTime]::Parse($DateToCheck).ToUniversalTime()
                    }
                    else {
                        $timestamp = $DateToCheck.ToUniversalTime()
                    }
                }
                $ThisOutput | Add-Member -Type NoteProperty -Name "EventTimestamp" -Value $timestamp
            }
            if ($ThisOutput."EventTimestamp" -gt $StartAttackWindow -and $ThisOutput."EventTimestamp" -lt $EndAttackWindow) {
                $ThisOutput | Add-Member -Type NoteProperty -Name "InAttackWindow" -Value "True"
            }
            else {
                $ThisOutput | Add-Member -Type NoteProperty -Name "InAttackWindow" -Value "False"
            }
        }
    }
}

<#GPO Functions#>
$GPOValueCode = @"
using System;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
namespace GPPS
{
    public class Class1
    {
        [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
        public static extern uint GetPrivateProfileString(
        string lpAppName,
        string lpKeyName,
        string lpDefault,
        StringBuilder lpReturnedString,
        uint nSize,
        string lpFileName);
        public static string[] getValue(string fullPath, string app, string key)
        {
            StringBuilder sb2 = new StringBuilder(2000);
            uint res2 = GetPrivateProfileString(app, key, "", sb2, (uint)sb2.Capacity, fullPath);
            string[] resultsArray = new string[2];
            if(res2 > 0)
            {
                resultsArray[0] = fullPath;
                resultsArray[1] = sb2.ToString();
            }
            else
            {
                resultsArray[0] = fullPath;
                resultsArray[1] = "-1";
            }

            return resultsArray;
        }

        public static Task<string[]> Check(string fullPath, string app, string key)
        {
            return Task.Run(() => getValue(fullPath, app, key));
        }
    }
}
"@

if (-not ('GPPS.Class1' -as [Type])) {
    Add-Type $GPOValueCode
}

function Get-GPOValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Path,

        [Parameter(Mandatory)]
        [string]
        $app,

        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $key
    )
    begin {
        $tasks = [System.Collections.Generic.List[System.Threading.Tasks.Task]]::new()

    }
    process{
        $out = [GPPS.Class1]::Check($path, $app, $key)
        [void]$tasks.Add($out)
    }
    end{
        [System.Threading.Tasks.Task]::WhenAll($tasks).Wait()
        $output= @()
        foreach($task in $tasks)
        {
            $tempObj = [PSCustomObject]@{
                Path = $task.Result[0]
                User = $task.Result[1]
                Priv = $key
            }
            $output += $tempObj
        }
        return $output
    }
}
$GPOPrivs = @(
    [PSCustomObject] @{
        PrivRightName = "SeTakeOwnershipPrivilege"
        GrantsRemoteAccess = $false
        RemoteAccessDesc = ""
        LocalPrivesc = $true
        LocalPrivescDesc = "Can be used to grant yourself ownership on any file, registry key, etc."
        MsDescription = "Take ownership of files or other objects"
    },
    [PSCustomObject] @{
        PrivRightName = "SeSyncAgentPrivilege"
        GrantsRemoteAccess = $true
        RemoteAccessDesc = ""
        LocalPrivesc = $true
        LocalPrivescDesc = ""
        MsDescription = "Synchronize directory service data"
    },
    [PSCustomObject] @{
        PrivRightName = "SeTcbPrivilege"
        GrantsRemoteAccess = $false
        RemoteAccessDesc = ""
        LocalPrivesc = $true
        LocalPrivescDesc = "Lets you impersonate any other user."
        MsDescription = "Act as part of the operating system"
    },
    [PSCustomObject] @{
        PrivRightName = "SeRestorePrivilege"
        GrantsRemoteAccess = $false
        RemoteAccessDesc = ""
        LocalPrivesc = $true
        LocalPrivescDesc = "Can be used to overwrite/modify any file."
        MsDescription = "Restore files and directories"
    },
    [PSCustomObject] @{
        PrivRightName = "SeAssignPrimaryTokenPrivilege"
        GrantsRemoteAccess = $false
        RemoteAccessDesc = ""
        LocalPrivesc = $true
        LocalPrivescDesc = "Lets you impersonate accounts (after some backflips) look at the various 'potato' attacks, i.e. Rotten, Juicy, etc."
        MsDescription = "Replace a process level token"
    },
    [PSCustomObject] @{
        PrivRightName = "SeBackupPrivilege"
        GrantsRemoteAccess = $false
        RemoteAccessDesc = ""
        LocalPrivesc = $true
        LocalPrivescDesc = "Lets you override file and directory permissions to read any file on the FS."
        MsDescription = "Back up files and directories"
    },
    [PSCustomObject] @{
        PrivRightName = "SeCreateTokenPrivilege"
        GrantsRemoteAccess = $false
        RemoteAccessDesc = ""
        LocalPrivesc = $true
        LocalPrivescDesc = "Lets you grant yourself any access you want. Locally."
        MsDescription = "Create a token object"
    },
    [PSCustomObject] @{
        PrivRightName = "SeDebugPrivilege"
        GrantsRemoteAccess = $false
        RemoteAccessDesc = ""
        LocalPrivesc = $true
        LocalPrivescDesc = "Lets you do the mimikatz thing, you know, dump lsass.exe, cool stuff like that."
        MsDescription = "Debug programs"
    },
    [PSCustomObject] @{
        PrivRightName = "SeImpersonatePrivilege"
        GrantsRemoteAccess = $false
        RemoteAccessDesc = ""
        LocalPrivesc = $true
        LocalPrivescDesc = "Lets you impersonate accounts (after some backflips) look at the various 'potato' attacks, i.e. Rotten, Juicy, etc."
        MsDescription = "Impersonate a client after authentication"
    },
    [PSCustomObject] @{
        PrivRightName = "SeLoadDriverPrivilege"
        GrantsRemoteAccess = $false
        RemoteAccessDesc = ""
        LocalPrivesc = $true
        LocalPrivescDesc = "Lets you load device drivers. Privesc in this case is usually going to mean loading a known-vulnerable driver and then exploiting the known vulnerability."
        MsDescription = "Load and unload device drivers"
    },
    [PSCustomObject] @{
        PrivRightName = "SeCreateSymbolicLinkPrivilege"
        GrantsRemoteAccess = $false
        RemoteAccessDesc = ""
        LocalPrivesc = $true
        LocalPrivescDesc = ""
        MsDescription = "Create symbolic links"
    },
    [PSCustomObject] @{
        PrivRightName = "SeServiceLogonRight"
        GrantsRemoteAccess = $false
        RemoteAccessDesc = ""
        LocalPrivesc = $false
        LocalPrivescDesc = ""
        MsDescription = "Log on as a service"
    }
)

function Get-LinkedOU {
    param(
        [parameter(Mandatory = $true)]
        [string]$ForestName
    )
    $policies  = [System.Collections.ArrayList]@()
    $forestDN = Get-DN $ForestName
    $searchParams =
    @{
        dnsDomain = $forestName
        attributes = @("gplink", "gpoptions", "name", "displayname")
        baseDN = $forestDN
        scope = "subtree"
        filter = "(&(|(objectClass=organizationalUnit)(objectClass=site)(objectClass=domain))(gplink=*))"
    }

    $results = Search-AD @searchParams
    foreach($result in $results)
    {
        $gplink = $result.Attributes.gplink[0]
        if($gplink -match "LDAP")
        {
            $gpList = $gplink.split("\[").split("\]")
            $priority = -1
            $pCount = 0
            foreach($link in $gpList)
            {
                $temp = $link  -match "LDAP://cn=({([A-Z0-9a-z]+-){4}[A-Za-z0-9]+}),"
                if($temp -and $Matches[1])
                {
                    $pCount = ($gpList.count -1)/2
                    $priority = $priority + 1
                    $policy = $Matches[1].ToUpper()
                    $state = $link.Split(";")[1]
                    $tempState = switch ($state)
                    {
                        "0" {"Enabled, Unenforced"}
                        "1" {"Disabled, Unenforced"}
                        "2" {"Disabled, Enforced"}
                        "3" {"Enabled, Enforced"}
                    }
                    $tempP = "OU: {0}; State: {1}, Priority: {2}" -f $result.DistinguishedName,$tempState,($pCount - $priority).ToString()

                    if($policies){
                        if($policies.Policy.Contains($policy))
                        {
                            $currPolicy = $policies | Where-Object policy -eq $policy
                            $pArr = $currPolicy.PolicyInfo
                            [void]$pArr.Add($tempP)
                        }
                        else
                        {
                            $newP = [PSCustomObject][Ordered] @{
                                Policy = $policy
                                PolicyInfo = [System.Collections.ArrayList]@()
                            }
                            [void]$newp.PolicyInfo.Add($tempP)
                            [void]$policies.Add($newP)
                        }
                    }
                    else
                    {
                        $newP = [PSCustomObject][Ordered] @{
                            Policy = $policy
                            PolicyInfo = [System.Collections.ArrayList]@()
                        }
                        [void]$newp.PolicyInfo.Add($tempP)
                        [void]$policies.Add($newP)
                    }
                }
            }
        }
    }
    return $policies
}

function Get-LinkedOUsFromGpoCn {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        $LinkedOUsHM,

        [Parameter(Mandatory = $True)]
        $gpoCN
    )

    $pState = ""

    if($LinkedOUsHM)
    {
        try{
            $tempP = $LinkedOUsHM | Where-Object Policy -eq $gpoCN
            $pStateArr = $tempP.PolicyInfo
            $pState = $pStateArr -join " ;"
        }
        catch{
            $pState = "Unknown"
        }
    }
    else
    {
        $pState = ""
    }

    return $pState
}

function Get-UsersFromACL {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    Param (
        [Parameter(Mandatory = $True)]
        $Path,
        [Parameter(Mandatory = $True)]
        $Trusted

    )

    $acls = @("CreateFiles", "AppendData", "DeleteSubdirectoriesAndFiles", "Delete", "ChangePermissions", "TakeOwnership", "FullControl", "Write", "Modify")

    $usersFolder = [System.Collections.ArrayList]@()
    $usersFile = [System.Collections.ArrayList]@()
    $outMessage = ""

    $testPath = Test-Path -Path $Path
    # This part of the script is checking the ACL on the parent folder
    try {
        $folderPath = Split-Path -Path $Path
        $pFolderACL = Get-ACL $folderPath
    }
    catch {
        continue
    }
    foreach ($acl in $pFolderACL.Access) {
        # Get the account SID
        $tempName = $acl.IdentityReference.ToString()
        $objUser = New-Object System.Security.Principal.NTAccount($tempName)
        try {
            $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
            $sid = $strSID.Value
        }
        catch {
            $sid = $tempName
        }
        if ($trusted.Contains($sid)) {
            continue
        }
        # If the account is not trusted
        else {
            $systemRights = $acl.FileSystemRights.toString()
            foreach ($right in $acls) {
                if ($systemRights -match $right -and (!$usersFolder.Contains($acl.IdentityReference))) {
                    [void]$usersFolder.add($acl.IdentityReference)
                    break
                }
            }
        }
    }
    #end here the check for the ACL of the parent folder
    # If the path exists - check also the ACL on the file itself
    if ($testPath) {
        # Message
        #This part of the script is checking the ACL on the file itself
        try {
            $fileACL = Get-Acl $Path -ErrorAction Stop
        }
        catch {
            continue
        }
        foreach ($acl in $fileACL.Access) {
            # Get the account SID
            $tempName = $acl.IdentityReference.ToString()
            $objUser = New-Object System.Security.Principal.NTAccount($tempName)
            try {
                $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
                $sid = $strSID.Value
            }
            catch {
                $sid = $tempName
            }
            # Check if the SID is trusted
            if ($trusted.Contains($sid)) {
                continue
            }
            # If the account is not trusted
            else {
                $systemRights = $acl.FileSystemRights.toString()
                foreach ($right in $acls) {
                    if ($systemRights -match $right -and (!$usersFile.Contains($acl.IdentityReference))) {
                        [void]$usersFile.add($acl.IdentityReference)
                        break
                    }
                }
            }
        }
        #end here the check for the ACL of the file itself
    }
    else {
        $outMessage =  "None"
    }

    # Create valid string for low privilege users that can modify the parent folder
    if ($usersFolder) {
        $outFolder = $usersFolder -join " ;"
    }
    else {
        $outFolder = "None"
    }
    # Create valid string for low privilege users that can modify the file itself
    if ($usersFile) {
        $outFile = $usersFile -join " ;"
        $outMessage =  "The file exists but some low privilege user(s) can modify it."
    }
    else {
        $outFile = "None"
    }

    if ($outFolder -eq "None" -and $outFile -eq "None") {
        $outMessage = "The GPO has a scheduled task."
    }
    return $outFile, $outFolder, $outMessage
}

function Get-IniContent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string[]]
        $Path,

        [Management.Automation.PSCredential]
        [Management.Automation.CredentialAttribute()]
        $Credential = [Management.Automation.PSCredential]::Empty,

        [Switch]
        $OutputObject
    )

    PROCESS {
        ForEach ($TargetPath in $Path) {
            if (Test-Path -Path $TargetPath) {
                if ($PSBoundParameters['OutputObject']) {
                    $IniObject = New-Object PSObject
                }
                else {
                    $IniObject = @{}
                }
                Switch -Regex -File $TargetPath {
                    "^\[(.+)\]" # Section
                    {
                        $Section = $matches[1].Trim()
                        if ($PSBoundParameters['OutputObject']) {
                            $Section = $Section.Replace(' ', '')
                            $SectionObject = New-Object PSObject
                            $IniObject | Add-Member Noteproperty $Section $SectionObject
                        }
                        else {
                            $IniObject[$Section] = @{}
                        }
                        $CommentCount = 0
                    }
                    "^(;.*)$" # Comment
                    {
                        $Value = $matches[1].Trim()
                        $CommentCount = $CommentCount + 1
                        $Name = 'Comment' + $CommentCount
                        if ($PSBoundParameters['OutputObject']) {
                            $Name = $Name.Replace(' ', '')
                            $IniObject.$Section | Add-Member Noteproperty $Name $Value
                        }
                        else {
                            $IniObject[$Section][$Name] = $Value
                        }
                    }
                    "(.+?)\s*=(.*)" # Key
                    {
                        $Name, $Value = $matches[1..2]
                        $Name = $Name.Trim()
                        $Values = $Value.split(',') | ForEach-Object { $_.Trim() }

                        # if ($Values -isnot [System.Array]) { $Values = @($Values) }

                        if ($PSBoundParameters['OutputObject']) {
                            $Name = $Name.Replace(' ', '')
                            $IniObject.$Section | Add-Member Noteproperty $Name $Values
                        }
                        else {
                            $IniObject[$Section][$Name] = $Values
                        }
                    }
                }
                $IniObject
            }
        }
    }
}


function ConvertTo-Lowercase {
    <#
    .SYNOPSIS
    Convert $DomainNames variable elements to be all lowercase
    .DESCRIPTION
    Returns a $DomainNames variable with all the elements lowercased
    .PARAMETER DomainNames
    ArrayList of strings to be lowercased and returned by the indicator
    .EXAMPLE
    $DomainNames = ConvertTo-Lowercase -DomainNames $DomainNames
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string[]]
        $DomainNames
    )

    PROCESS {
        Out-Log -Operation $MyInvocation.MyCommand.Name -Data $PSBoundParameters

        $out = [string[]]@()
        foreach ($domain in $DomainNames) {
            $out += $domain.ToLower()
        }

        return $out
    }
}

function Get-OperatingSystem {
    <#
    .SYNOPSIS
    Returns the operating system based on regex

    .DESCRIPTION
    Returns the operating system based on regex, can also return the type: Server or User Workstation

    .PARAMETER OperatingSystem
    The input operating system as in the operatingSystem AD attribute

    .PARAMETER IncludeOSType
    Flag. If true return also the OS type: Server or User Workstation

    .EXAMPLE
    Get the OS and the type of "Windows Server 2022 Datacenter Azure Edition":
    Get-OperatingSystem -OperatingSystem "Windows Server 2022 Datacenter Azure Edition" -IncludeOSType
    #>
    param (
        [Parameter(Mandatory = $true)][string]$OperatingSystem,
        [Parameter(Mandatory = $false)][switch]$IncludeOSType
    )
    Out-Log -Operation $MyInvocation.MyCommand.Name -Data $PSBoundParameters

    if ([string]::IsNullOrWhiteSpace($OperatingSystem)) {
        if ($IncludeOSType) {
            return @{
                OperatingSystem = "Operating System not set"
                Type = "Unknown"
            }
        }
        return "Operating System not set"
    }

    # Replace non-breaking spaces with regular spaces
    $os = $OperatingSystem -replace '\u00A0', ' '

    switch -Regex ($os) {
        'windows\s*(server\s*)?2000.*'           { $result = [PSCustomObject]@{ Name = 'Windows Server 2000'; Type = 'Server' }; break }
        'windows\s*(server\s*)?2003.*'           { $result = [PSCustomObject]@{ Name = 'Windows Server 2003'; Type = 'Server' }; break }
        'windows\s*(server\s*)?2008.*'           { $result = [PSCustomObject]@{ Name = 'Windows Server 2008'; Type = 'Server' }; break }
        'windows\s*(server\s*)?2012.*'           { $result = [PSCustomObject]@{ Name = 'Windows Server 2012'; Type = 'Server' }; break }
        'windows\s*(server\s*)?2016.*'           { $result = [PSCustomObject]@{ Name = 'Windows Server 2016'; Type = 'Server' }; break }
        'windows\s*(server\s*)?2019.*'           { $result = [PSCustomObject]@{ Name = 'Windows Server 2019'; Type = 'Server' }; break }
        'windows\s*(server\s*)?2022.*'           { $result = [PSCustomObject]@{ Name = 'Windows Server 2022'; Type = 'Server' }; break }
        'windows\s*(server\s*)?2025.*'           { $result = [PSCustomObject]@{ Name = 'Windows Server 2025'; Type = 'Server' }; break }
        'windows\s*embedded.*'                   { $result = [PSCustomObject]@{ Name = 'Windows Embedded'; Type = 'User Workstation' }; break }
        'windows\s*xp.*'                         { $result = [PSCustomObject]@{ Name = 'Windows XP'; Type = 'User Workstation' }; break }
        'windows\s*vista.*'                      { $result = [PSCustomObject]@{ Name = 'Windows Vista'; Type = 'User Workstation' }; break }
        'windows\s*7.*'                          { $result = [PSCustomObject]@{ Name = 'Windows 7'; Type = 'User Workstation' }; break }
        'windows\s*8.*'                          { $result = [PSCustomObject]@{ Name = 'Windows 8'; Type = 'User Workstation' }; break }
        'windows\s*10.*'                         { $result = [PSCustomObject]@{ Name = 'Windows 10'; Type = 'User Workstation' }; break }
        'windows\s*11.*'                         { $result = [PSCustomObject]@{ Name = 'Windows 11'; Type = 'User Workstation' }; break }
        'windows\s*nt.*'                         { $result = [PSCustomObject]@{ Name = 'Windows NT'; Type = 'User Workstation' }; break }
        'mac\s*os|macos|os\s*x.*'                { $result = [PSCustomObject]@{ Name = 'macOS'; Type = 'mac' }; break }
        'linux|ubuntu|centos|debian|red\s*hat.*' { $result = [PSCustomObject]@{ Name = 'Linux'; Type = 'linux' }; break }
        default                                  { $result = $null }
    }

    if ($IncludeOSType) {
        return $result
    }
    return $result.Name
}

Export-ModuleMember -Function Out-Log
Export-ModuleMember -Function Search-AD
Export-ModuleMember -Function Get-DN
Export-ModuleMember -Function Get-DomainSID
Export-ModuleMember -Function Get-UACSet
Export-ModuleMember -Function Get-SupportedEncryptionTypesSet
Export-ModuleMember -Function Update-GraphApiAADIndicatorOutputAttackWindow
Export-ModuleMember -Function Get-ADSearchFlag
Export-ModuleMember -Function Convert-StringToXml
Export-ModuleMember -Function Get-TrustAttributesSet
Export-ModuleMember -Function Update-NTSecurityDescriptor
Export-ModuleMember -Function Update-AttributeMetadata
Export-ModuleMember -Function Update-ValueMetadata
Export-ModuleMember -Function Get-AdminsInDomain
Export-ModuleMember -Function Update-IndicatorOutputAttackWindow
Export-ModuleMember -Function Search-ADHelper
Export-ModuleMember -Function Get-NetBIOSName
Export-ModuleMember -Function Get-HostSPNMapping
Export-ModuleMember -Function Compare-DSPMultiValuedAttribute
Export-ModuleMember -Function Resolve-DomainName
Export-ModuleMember -Function Resolve-DomainCredential
Export-ModuleMember -Function Confirm-DomainAvailability
Export-ModuleMember -Function Get-ForestSID
Export-ModuleMember -Function Search-ADConfig
Export-ModuleMember -Function Get-LinkedOU
Export-ModuleMember -Function Get-LinkedOUsFromGpoCn
Export-ModuleMember -Function Get-UsersFromACL
Export-ModuleMember -Function Get-GPOValue
Export-ModuleMember -Function Get-IniContent
Export-ModuleMember -Function ConvertTo-Lowercase
Export-ModuleMember -Function Get-OperatingSystem
Export-ModuleMember -Variable GPOPrivs
# SIG # Begin signature block
# MIIuIwYJKoZIhvcNAQcCoIIuFDCCLhACAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCD3QridIpAruIPU
# LjqLU77mrmF373S4WAVrQ0cekPq6jqCCE6MwggVyMIIDWqADAgECAhB2U/6sdUZI
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
# 9w0BCQQxIgQg5bb0br9L2kOuVy3yjL9Ld/YBKp9uo9fMCizHYgngSYowDQYJKoZI
# hvcNAQEBBQAEggIAYi0Si5mlRljkxcy0ihbp6abOrSZioSovqrqMJJmiotEBKu1I
# M1SQ/yO7u1mEo4vmzCMiPhURLaisPlP0MzcJsVfgZOQ4+3N9XU/2PZJBtmPF6EPG
# WJKRTT9D6h82P15YDKMRO2cnuldUsCj7VbOsviOJLAVN/JpIm1glBrfeEnQGvd/4
# l6oYuAIINcgeIBMRmZQdcsZotp/WK37tLoVD+vLsWzIFsLUEa4FaQc+IxLyfhA/H
# IFl19c6MPkvbsQtGhChlVbj+ybJ8UPbvtoiHrqjg+0nZVLTgkpK1YlE+9IJbPc4R
# lZfddoz0h2y00RQYSKO8LKNb2bNW/hMgMdaj9TT7gNbCrDvS2KYUJlQ4kba/wYba
# Ye7RvpNFxlrNXSRSDIt7UpULHb8EpLagBw0DUERac6R72fLJ9fb//0A60fvUg/DT
# Ng5RdrlfUT4bsIQZRrLhWIADBVlCgYDzfYTFqxiueqhUjtx0Fl1d27OWWT1Lt1zB
# 9hF64ttz9cxYxSp2OQsYH8hYWTijlqm3MxEFv4ASm2n2pA6BmcvZOSONDQFj7xDi
# ZC6D3jmLfdG0bfLyf359lH4VwCOELX8mUMMzTmwB0hZ3IjJkRJxxy714SpYeFLgq
# feIetlobWWmR3aPCdOIOxFMvg6RHCkPb0zaiFqbCox1HrKiqHtQPvVxJqaqhgha3
# MIIWswYKKwYBBAGCNwMDATGCFqMwghafBgkqhkiG9w0BBwKgghaQMIIWjAIBAzEN
# MAsGCWCGSAFlAwQCATCB3AYLKoZIhvcNAQkQAQSggcwEgckwgcYCAQEGCSsGAQQB
# oDICAzAxMA0GCWCGSAFlAwQCAQUABCC3MlesCPyO4Q6k/+fxS02LmlF2r7+6ieBh
# fRQ+zldb0gIUVv1D94mQ8pbBCRHlY0tB/n1+ytMYDzIwMjUwNjEwMDc1MDE1WjAD
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
# MC8GCSqGSIb3DQEJBDEiBCAGj01cTANFaLTDb0DHUyvIluty5uozfQYIA48A7bfC
# KzCBsAYLKoZIhvcNAQkQAi8xgaAwgZ0wgZowgZcEIJGSR5tiNbl2Jr+2AW14CJGD
# cgPYc5HAbBuOPXf/4sc3MHMwX6RdMFsxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBH
# bG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWduIFRpbWVzdGFtcGlu
# ZyBDQSAtIFNIQTM4NCAtIEc0AhABAzLhZb+beEPgmXWUY3cLMA0GCSqGSIb3DQEB
# CwUABIIBgKlY5IDTXX+n8TX/NVFmUsCymq+N64QZZmEt9Dx+jnVt4DEZgN+seAn7
# bi+10U9cu0/59e80CLkz7C5+jP9+6ZCDIcqSohpu1x3xj97C4NKU/SH8i1g4kNga
# XpUMCnNVyxuLOtzigCqBD70voyxN9Vga/wbR7JFcA+XQtudjpaNLuqkOqW0rppL5
# zxoPGCcJk+KU5xZ/GmPNeis/v4/Rr/DNYsp9cet5CJL/230VEYkBJqtfv+OC9Z1f
# wqUiZQ8pw2VDHYzv5DgwrGT2472m/V3QfqxFICAvYH8s2/qPfCAswXLzBR1B7pqt
# e57N5PjZ3Zt/00bMwsb2vzNVElBN+bLhC+RPjDnFI1lgcJu0oM4jRYvNVCy5XoYn
# YR+cCKzDWzYLruKuJ8EYITN7S6d0X0Bv1KLMJHl1dlBoC0cJs7QEKsOcAVZZYFWg
# 8WQwTWlNd42VNusAyi9ARoq86ODgwHgdUcvBwlpIL8DZOI0HzNmok1EfHE++TZJh
# /5NjKncbug==
# SIG # End signature block
