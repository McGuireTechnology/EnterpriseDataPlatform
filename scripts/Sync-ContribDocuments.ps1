param(
    [string]$SourceRoot = $env:EDP_CONTRIB_SOURCE_ROOT,
    [string]$DestinationRoot = (Join-Path $PSScriptRoot "..\contrib\sources"),
    [string[]]$Collections = @("CIS Controls"),
    [switch]$Clean
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($SourceRoot)) {
    throw "Set EDP_CONTRIB_SOURCE_ROOT or pass -SourceRoot with the folder that contains approved contrib collections."
}

$resolvedSourceRoot = (Resolve-Path -LiteralPath $SourceRoot).Path
$resolvedDestinationRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($DestinationRoot)

New-Item -ItemType Directory -Path $resolvedDestinationRoot -Force | Out-Null

$workspaceRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
if (-not $resolvedDestinationRoot.StartsWith($workspaceRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "DestinationRoot must stay inside the workspace: $workspaceRoot"
}

$copiedCollections = @()

foreach ($collection in $Collections) {
    $source = Join-Path $resolvedSourceRoot $collection
    if (-not (Test-Path -LiteralPath $source)) {
        Write-Warning "Skipping missing contrib collection: $source"
        continue
    }

    $destination = Join-Path $resolvedDestinationRoot $collection

    if ($Clean -and (Test-Path -LiteralPath $destination)) {
        $resolvedDestination = (Resolve-Path -LiteralPath $destination).Path
        if (-not $resolvedDestination.StartsWith($resolvedDestinationRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to clean outside contrib destination: $resolvedDestination"
        }
        Remove-Item -LiteralPath $resolvedDestination -Recurse -Force
    }

    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    Copy-Item -Path (Join-Path $source "*") -Destination $destination -Recurse -Force
    $copiedCollections += $collection
}

$manifest = [ordered]@{
    generated_at = (Get-Date).ToUniversalTime().ToString("o")
    source_root = $resolvedSourceRoot
    destination_root = $resolvedDestinationRoot
    collections = $copiedCollections
}

$manifest | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $resolvedDestinationRoot "manifest.json") -Encoding UTF8

Write-Host "Copied $($copiedCollections.Count) contrib collection(s) to $resolvedDestinationRoot"
