<#
.SYNOPSIS
Exports Active Directory schema object classes and properties.

.DESCRIPTION
Queries the Active Directory schema naming context and exports:
- object class definitions from classSchema objects
- property/attribute definitions from attributeSchema objects
- expanded class-to-property mappings for mandatory and optional attributes

The script requires the ActiveDirectory PowerShell module and a user account that
can read the directory schema. By default, domain users can read schema metadata.

.PARAMETER OutputPath
Directory where export files will be written.

.PARAMETER Server
Optional domain controller or AD LDS server to query.

.PARAMETER Credential
Optional credential used for the schema query.

.PARAMETER IncludeDefunct
Include schema objects marked as defunct.

.PARAMETER Json
Also export JSON files in addition to CSV files.

.EXAMPLE
.\scripts\Get-ActiveDirectorySchemaInventory.ps1

.EXAMPLE
.\scripts\Get-ActiveDirectorySchemaInventory.ps1 -OutputPath .\ad-schema -Server dc01.contoso.com -Json
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$OutputPath = ".\ad-schema-inventory",

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Server,

    [Parameter()]
    [System.Management.Automation.PSCredential]$Credential,

    [Parameter()]
    [switch]$IncludeDefunct,

    [Parameter()]
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function ConvertTo-JoinedString {
    param(
        [Parameter(ValueFromPipeline = $true)]
        [AllowNull()]
        [object]$Value
    )

    process {
        if ($null -eq $Value) {
            return ""
        }

        if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
            return ($Value | Where-Object { $null -ne $_ } | Sort-Object) -join ";"
        }

        return [string]$Value
    }
}

function ConvertTo-GuidString {
    param(
        [Parameter()]
        [AllowNull()]
        [object]$Value
    )

    if ($null -eq $Value) {
        return ""
    }

    if ($Value -is [guid]) {
        return $Value.ToString()
    }

    if ($Value -is [byte[]]) {
        return ([guid]$Value).ToString()
    }

    return [string]$Value
}

function New-AdCommandParameters {
    param(
        [Parameter()]
        [string]$ServerName,

        [Parameter()]
        [System.Management.Automation.PSCredential]$AdCredential
    )

    $parameters = @{}

    if (-not [string]::IsNullOrWhiteSpace($ServerName)) {
        $parameters["Server"] = $ServerName
    }

    if ($null -ne $AdCredential) {
        $parameters["Credential"] = $AdCredential
    }

    return $parameters
}

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    throw "The ActiveDirectory PowerShell module is required. Install RSAT: Active Directory Domain Services and Lightweight Directory Tools."
}

Import-Module ActiveDirectory

$adParameters = New-AdCommandParameters -ServerName $Server -AdCredential $Credential
$rootDse = Get-ADRootDSE @adParameters
$schemaNamingContext = $rootDse.SchemaNamingContext

if ([string]::IsNullOrWhiteSpace($schemaNamingContext)) {
    throw "Could not determine the AD schema naming context from RootDSE."
}

New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

$classProperties = @(
    "adminDescription",
    "adminDisplayName",
    "auxiliaryClass",
    "cn",
    "defaultHidingValue",
    "defaultObjectCategory",
    "description",
    "distinguishedName",
    "governsID",
    "isDefunct",
    "lDAPDisplayName",
    "mayContain",
    "mustContain",
    "name",
    "objectClassCategory",
    "objectGUID",
    "possSuperiors",
    "rDNAttID",
    "schemaIDGUID",
    "subClassOf",
    "systemAuxiliaryClass",
    "systemMayContain",
    "systemMustContain",
    "systemOnly"
)

$attributeProperties = @(
    "adminDescription",
    "adminDisplayName",
    "attributeID",
    "attributeSecurityGUID",
    "attributeSyntax",
    "cn",
    "description",
    "distinguishedName",
    "isDefunct",
    "isMemberOfPartialAttributeSet",
    "isSingleValued",
    "lDAPDisplayName",
    "linkID",
    "name",
    "oMSyntax",
    "rangeLower",
    "rangeUpper",
    "schemaIDGUID",
    "searchFlags",
    "systemFlags",
    "systemOnly"
)

Write-Verbose "Reading classSchema objects from $schemaNamingContext"
$classes = Get-ADObject `
    -SearchBase $schemaNamingContext `
    -LDAPFilter "(objectClass=classSchema)" `
    -Properties $classProperties `
    -ResultSetSize $null `
    @adParameters |
    Where-Object {
        $IncludeDefunct -or ($null -eq $_.isDefunct -or $_.isDefunct -eq $false)
    } |
    Sort-Object lDAPDisplayName

Write-Verbose "Reading attributeSchema objects from $schemaNamingContext"
$attributes = Get-ADObject `
    -SearchBase $schemaNamingContext `
    -LDAPFilter "(objectClass=attributeSchema)" `
    -Properties $attributeProperties `
    -ResultSetSize $null `
    @adParameters |
    Where-Object {
        $IncludeDefunct -or ($null -eq $_.isDefunct -or $_.isDefunct -eq $false)
    } |
    Sort-Object lDAPDisplayName

$classExport = $classes | ForEach-Object {
    [pscustomobject]@{
        LdapDisplayName       = $_.lDAPDisplayName
        CommonName            = $_.cn
        Name                  = $_.name
        DistinguishedName     = $_.distinguishedName
        GovernsId             = $_.governsID
        ObjectClassCategory   = $_.objectClassCategory
        SubClassOf            = $_.subClassOf
        RdnAttribute          = $_.rDNAttID
        DefaultObjectCategory = $_.defaultObjectCategory
        DefaultHidingValue    = $_.defaultHidingValue
        SystemOnly            = $_.systemOnly
        IsDefunct             = $_.isDefunct
        MustContain           = ConvertTo-JoinedString $_.mustContain
        SystemMustContain     = ConvertTo-JoinedString $_.systemMustContain
        MayContain            = ConvertTo-JoinedString $_.mayContain
        SystemMayContain      = ConvertTo-JoinedString $_.systemMayContain
        AuxiliaryClass        = ConvertTo-JoinedString $_.auxiliaryClass
        SystemAuxiliaryClass  = ConvertTo-JoinedString $_.systemAuxiliaryClass
        PossibleSuperiors     = ConvertTo-JoinedString $_.possSuperiors
        Description           = ConvertTo-JoinedString $_.description
        AdminDisplayName      = $_.adminDisplayName
        AdminDescription      = ConvertTo-JoinedString $_.adminDescription
        SchemaIdGuid          = ConvertTo-GuidString $_.schemaIDGUID
        ObjectGuid            = $_.objectGUID
    }
}

$attributeExport = $attributes | ForEach-Object {
    [pscustomobject]@{
        LdapDisplayName                 = $_.lDAPDisplayName
        CommonName                      = $_.cn
        Name                            = $_.name
        DistinguishedName               = $_.distinguishedName
        AttributeId                     = $_.attributeID
        AttributeSyntax                 = $_.attributeSyntax
        OmSyntax                        = $_.oMSyntax
        IsSingleValued                  = $_.isSingleValued
        RangeLower                      = $_.rangeLower
        RangeUpper                      = $_.rangeUpper
        SearchFlags                     = $_.searchFlags
        SystemFlags                     = $_.systemFlags
        LinkId                          = $_.linkID
        SystemOnly                      = $_.systemOnly
        IsDefunct                       = $_.isDefunct
        IsMemberOfPartialAttributeSet   = $_.isMemberOfPartialAttributeSet
        AttributeSecurityGuid           = ConvertTo-GuidString $_.attributeSecurityGUID
        Description                     = ConvertTo-JoinedString $_.description
        AdminDisplayName                = $_.adminDisplayName
        AdminDescription                = ConvertTo-JoinedString $_.adminDescription
        SchemaIdGuid                    = ConvertTo-GuidString $_.schemaIDGUID
    }
}

$classPropertyMap = foreach ($class in $classes) {
    $propertyGroups = [ordered]@{
        MustContain       = $class.mustContain
        SystemMustContain = $class.systemMustContain
        MayContain        = $class.mayContain
        SystemMayContain  = $class.systemMayContain
    }

    foreach ($propertyGroup in $propertyGroups.GetEnumerator()) {
        foreach ($propertyName in @($propertyGroup.Value)) {
            if ([string]::IsNullOrWhiteSpace($propertyName)) {
                continue
            }

            [pscustomobject]@{
                ClassLdapDisplayName = $class.lDAPDisplayName
                ClassCommonName      = $class.cn
                PropertyName         = $propertyName
                PropertyRequirement  = $propertyGroup.Key
            }
        }
    }
}

$classCsvPath = Join-Path $OutputPath "ad-schema-classes.csv"
$attributeCsvPath = Join-Path $OutputPath "ad-schema-attributes.csv"
$classPropertyCsvPath = Join-Path $OutputPath "ad-schema-class-properties.csv"

$classExport | Export-Csv -Path $classCsvPath -NoTypeInformation -Encoding UTF8
$attributeExport | Export-Csv -Path $attributeCsvPath -NoTypeInformation -Encoding UTF8
$classPropertyMap | Sort-Object ClassLdapDisplayName, PropertyRequirement, PropertyName |
    Export-Csv -Path $classPropertyCsvPath -NoTypeInformation -Encoding UTF8

if ($Json) {
    $classExport | ConvertTo-Json -Depth 5 | Out-File -FilePath (Join-Path $OutputPath "ad-schema-classes.json") -Encoding UTF8
    $attributeExport | ConvertTo-Json -Depth 5 | Out-File -FilePath (Join-Path $OutputPath "ad-schema-attributes.json") -Encoding UTF8
    $classPropertyMap | Sort-Object ClassLdapDisplayName, PropertyRequirement, PropertyName |
        ConvertTo-Json -Depth 5 |
        Out-File -FilePath (Join-Path $OutputPath "ad-schema-class-properties.json") -Encoding UTF8
}

[pscustomobject]@{
    SchemaNamingContext = $schemaNamingContext
    ClassCount          = @($classExport).Count
    AttributeCount      = @($attributeExport).Count
    ClassPropertyCount  = @($classPropertyMap).Count
    OutputPath          = (Resolve-Path $OutputPath).Path
    ClassCsv            = (Resolve-Path $classCsvPath).Path
    AttributeCsv        = (Resolve-Path $attributeCsvPath).Path
    ClassPropertyCsv    = (Resolve-Path $classPropertyCsvPath).Path
}
