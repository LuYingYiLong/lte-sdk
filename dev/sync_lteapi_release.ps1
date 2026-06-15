param(
    [string]$Source = "D:\GodotProjects\LTEAPI"
)

$ErrorActionPreference = "Stop"
$SdkRoot = Split-Path -Parent $PSScriptRoot
$SourceAddon = Join-Path $Source "addons/lteapi"
$SourceTools = Join-Path $Source "tools"
$TargetAddon = Join-Path $SdkRoot "addons/lteapi"

if (!(Test-Path -LiteralPath $SourceAddon)) {
    throw "LTEAPI release addon not found: $SourceAddon"
}

if (Test-Path -LiteralPath $TargetAddon) {
    Remove-Item -LiteralPath $TargetAddon -Recurse -Force
}
New-Item -ItemType Directory -Path $TargetAddon | Out-Null
Copy-Item -LiteralPath (Join-Path $SourceAddon "plugin.cfg") -Destination $TargetAddon -Force

$TargetBin = Join-Path $TargetAddon "bin"
New-Item -ItemType Directory -Path $TargetBin | Out-Null
$SourceBin = Join-Path $SourceAddon "bin"
foreach ($Pattern in @("*.gdextension", "*.uid", "*.dll")) {
    Copy-Item -Path (Join-Path $SourceBin $Pattern) -Destination $TargetBin -Force
}

if (Test-Path -LiteralPath $SourceTools) {
    $TargetTools = Join-Path $TargetAddon "tools"
    New-Item -ItemType Directory -Path $TargetTools | Out-Null
    Copy-Item -Path (Join-Path $SourceTools "lteplugin_*") -Destination $TargetTools -Force
}

Write-Host "Synced LTEAPI release artifact to $TargetAddon"
