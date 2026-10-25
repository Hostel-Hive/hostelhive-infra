[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $true)][string]$BackupFile,
    [Parameter(Mandatory = $true)][string]$ConfirmTarget
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'database-tools.ps1')
if ([string]::IsNullOrWhiteSpace($env:RESTORE_DATABASE_URL)) {
    throw 'Set RESTORE_DATABASE_URL to a separate empty recovery database.'
}
$target = Get-DatabaseTarget -ConnectionUrl $env:RESTORE_DATABASE_URL
if ($ConfirmTarget -cne $target) {
    throw 'ConfirmTarget must match the recovery host:port/database exactly. The default PostgreSQL port is 5432.'
}
$archive = (Resolve-Path -LiteralPath $BackupFile -ErrorAction Stop).Path
$null = Get-Command pg_restore -CommandType Application -ErrorAction Stop
$null = Get-Command psql -CommandType Application -ErrorAction Stop
if (-not $PSCmdlet.ShouldProcess($target, 'Restore the application public schema from the selected archive')) {
    return
}
# Reject targets with existing application relations, types or functions.
$query = @'
SELECT
    (SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public') +
    (SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public') +
    (SELECT count(*) FROM pg_type t JOIN pg_namespace n ON n.oid=t.typnamespace WHERE n.nspname='public');
'@
$count = Invoke-DatabaseTool -Tool psql -ConnectionUrl $env:RESTORE_DATABASE_URL -Arguments @(
    '--no-password', '-X', '--tuples-only', '--no-align', '--set=ON_ERROR_STOP=1', "--command=$query"
)
if (("$count").Trim() -ne '0') {
    throw 'The recovery public schema must be empty. Create a separate empty database before restoring.'
}
$null = Invoke-DatabaseTool -Tool pg_restore -ConnectionUrl $env:RESTORE_DATABASE_URL -Arguments @(
    '--no-password', '--dbname=', '--single-transaction',
    '--exit-on-error', '--no-owner', '--no-acl', '--schema=public', $archive
)
Write-Output 'Restore completed. Verify migration version, record counts and application workflows before switching services.'
