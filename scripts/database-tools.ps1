# Shared libpq runner. Connection values stay out of command-line arguments.
Set-StrictMode -Version Latest

function Get-DatabaseTarget {
    param([Parameter(Mandatory = $true)][string]$ConnectionUrl)
    $uri = $null
    if (-not [Uri]::TryCreate($ConnectionUrl, [UriKind]::Absolute, [ref]$uri) -or
        $uri.Scheme -notin @('postgres', 'postgresql') -or
        [string]::IsNullOrWhiteSpace($uri.Host) -or $uri.AbsolutePath -eq '/') {
        throw 'Use a PostgreSQL connection URL with an explicit host and database.'
    }
    $port = if ($uri.Port -lt 0) { 5432 } else { $uri.Port }
    return "$($uri.Host):$port/$([Uri]::UnescapeDataString($uri.AbsolutePath.TrimStart('/')))"
}

function Invoke-DatabaseTool {
    param(
        [Parameter(Mandatory = $true)][string]$Tool,
        [Parameter(Mandatory = $true)][string]$ConnectionUrl,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )
    $null = Get-DatabaseTarget -ConnectionUrl $ConnectionUrl
    $command = Get-Command $Tool -CommandType Application -ErrorAction Stop
    $previousDatabase = [Environment]::GetEnvironmentVariable('PGDATABASE', 'Process')
    $previousTimeout = [Environment]::GetEnvironmentVariable('PGCONNECT_TIMEOUT', 'Process')
    $errorFile = [IO.Path]::GetTempFileName()
    try {
        $env:PGDATABASE = $ConnectionUrl
        $env:PGCONNECT_TIMEOUT = '15'
        # Native stderr can contain credentials. Suppress it and report only the exit code.
        $nativePreference = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            $result = & $command.Source @Arguments 2> $errorFile
            $toolExitCode = $LASTEXITCODE
        } finally {
            $ErrorActionPreference = $nativePreference
        }
        if ($toolExitCode -ne 0) {
            throw "$Tool failed (exit $toolExitCode). Check connectivity, permissions and PostgreSQL client compatibility."
        }
        return $result
    } finally {
        [Environment]::SetEnvironmentVariable('PGDATABASE', $previousDatabase, 'Process')
        [Environment]::SetEnvironmentVariable('PGCONNECT_TIMEOUT', $previousTimeout, 'Process')
        Remove-Item -LiteralPath $errorFile -Force
    }
}
