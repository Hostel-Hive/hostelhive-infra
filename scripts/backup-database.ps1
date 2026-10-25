[CmdletBinding()]
param(
    [string]$OutputDirectory = (Join-Path (Split-Path $PSScriptRoot -Parent) 'backups')
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'database-tools.ps1')
if ([string]::IsNullOrWhiteSpace($env:DATABASE_URL)) {
    throw 'Set DATABASE_URL in this terminal. This script does not load .env.'
}
$null = Get-DatabaseTarget -ConnectionUrl $env:DATABASE_URL
$null = Get-Command pg_dump -CommandType Application -ErrorAction Stop
$null = New-Item -ItemType Directory -Path $OutputDirectory -Force
$name = 'hostelhive-public-' + [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssZ') + '-' + [Guid]::NewGuid().ToString('N')
$destination = Join-Path $OutputDirectory ($name + '.dump')
$partial = $destination + '.partial'
try {
    $null = Invoke-DatabaseTool -Tool pg_dump -ConnectionUrl $env:DATABASE_URL -Arguments @(
        '--no-password', '--format=custom', '--schema=public', '--no-owner', '--no-acl', "--file=$partial"
    )
    if (-not (Test-Path -LiteralPath $partial) -or (Get-Item -LiteralPath $partial).Length -eq 0) {
        throw 'The database export did not produce an archive.'
    }
    Move-Item -LiteralPath $partial -Destination $destination
    Write-Output "Application public-schema backup saved to $destination"
} finally {
    if (Test-Path -LiteralPath $partial) { Remove-Item -LiteralPath $partial -Force }
}
