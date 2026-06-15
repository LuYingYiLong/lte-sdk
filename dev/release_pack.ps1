param(
    [string]$Output = "release/lte-sdk.zip",
    [string]$Version = "",
    [switch]$AllowDirty
)

$ErrorActionPreference = "Stop"
$SdkRoot = Split-Path -Parent $PSScriptRoot
$OutputPath = Join-Path $SdkRoot $Output

# If version provided, embed it in output path
if ($Version) {
    $OutputDir = Join-Path $SdkRoot "release"
    $OutputPath = Join-Path $OutputDir "lte-sdk-v$Version.zip"
}

$OutputParent = Split-Path -Parent $OutputPath
if (!(Test-Path -LiteralPath $OutputParent)) {
    New-Item -ItemType Directory -Path $OutputParent -Force | Out-Null
}
if (Test-Path -LiteralPath $OutputPath) {
    Remove-Item -LiteralPath $OutputPath -Force
}

Push-Location $SdkRoot
try {
    # Check for uncommitted changes — git archive only includes committed content
    $dirty = git status --porcelain
    if ($dirty) {
        Write-Warning "Working tree has uncommitted changes — these will NOT be included in the archive:"
        Write-Host $dirty
        Write-Warning "Commit your changes first, or use -AllowDirty to override."
        if (!$AllowDirty) {
            throw "Release aborted: working tree is not clean."
        }
    }

    # Use git archive to respect .gitattributes export-ignore
    git archive --format zip --output $OutputPath HEAD
    Write-Host "Packed LTE-SDK release: $OutputPath"
} finally {
    Pop-Location
}
