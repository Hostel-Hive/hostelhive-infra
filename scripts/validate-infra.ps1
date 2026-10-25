[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$files = @(Get-ChildItem -LiteralPath (Join-Path $root 'scripts') -Filter '*.ps1' -File)
foreach ($file in $files) {
    $tokens = $null
    $parseErrors = $null
    $null = [Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$parseErrors)
    if ($parseErrors.Count -gt 0) {
        throw "PowerShell syntax failed for $($file.Name): $($parseErrors.Message -join '; ')"
    }
}
$required = @(
    'README.md', '.gitignore', '.env.example', 'compose.yaml', 'render.yaml',
    'docs/architecture.md', 'docs/deployment.md', 'docs/environment-variables.md',
    'docs/backup-and-recovery.md', 'docs/troubleshooting.md'
)
foreach ($relative in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $relative) -PathType Leaf)) {
        throw "Missing infrastructure file: $relative"
    }
}
Write-Output "PASS PowerShell syntax for $($files.Count) scripts and required infrastructure files"
