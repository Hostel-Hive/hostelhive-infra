[CmdletBinding()]
param(
    [string]$BackendUrl = 'https://hostelhive-backend-dev.onrender.com',
    [string]$FrontendUrl = 'https://web-kohl-delta-90.vercel.app',
    [ValidateRange(1, 10)][int]$Attempts = 3,
    [ValidateRange(1, 120)][int]$TimeoutSeconds = 30
)
$ErrorActionPreference = 'Stop'
foreach ($address in @($BackendUrl, $FrontendUrl)) {
    $uri = $null
    if (-not [Uri]::TryCreate($address, [UriKind]::Absolute, [ref]$uri) -or
        $uri.Scheme -notin @('http', 'https') -or $uri.UserInfo -ne '' -or
        $uri.Query -ne '' -or $uri.Fragment -ne '' -or $uri.AbsolutePath -ne '/') {
        throw 'Supply an HTTP(S) origin without credentials, paths, query strings or fragments.'
    }
}
$BackendUrl = $BackendUrl.TrimEnd('/')
$FrontendUrl = $FrontendUrl.TrimEnd('/')
$checks = @(
    @{ Name = 'Backend health'; Url = "$BackendUrl/health"; Json = $true },
    @{ Name = 'Database readiness'; Url = "$BackendUrl/ready"; Json = $true },
    @{ Name = 'Student login route'; Url = "$FrontendUrl/login"; Json = $false },
    @{ Name = 'Staff login route'; Url = "$FrontendUrl/staff/login"; Json = $false }
)
foreach ($check in $checks) {
    $passed = $false
    for ($attempt = 1; $attempt -le $Attempts; $attempt++) {
        try {
            $response = Invoke-WebRequest -Uri $check.Url -UseBasicParsing -TimeoutSec $TimeoutSeconds
            if ($response.StatusCode -ne 200) { throw 'Unexpected HTTP status.' }
            if ($check.Json) {
                $null = $response.Content | ConvertFrom-Json
            } elseif ($response.Content -notmatch '(?i)<html') {
                throw 'Expected an HTML document.'
            }
            $passed = $true
            break
        } catch {
            if ($attempt -lt $Attempts) { Start-Sleep -Seconds 3 }
        }
    }
    if (-not $passed) { throw "$($check.Name) failed after $Attempts attempts." }
    Write-Output "PASS $($check.Name)"
}
try {
    $response = Invoke-WebRequest -Uri "$BackendUrl/health" -UseBasicParsing -TimeoutSec $TimeoutSeconds -Headers @{ Origin = $FrontendUrl }
    $allowedOrigin = ($response.Headers['Access-Control-Allow-Origin'] -join ',')
    if ($allowedOrigin -cne $FrontendUrl) { throw 'Origin mismatch.' }
} catch {
    throw 'CORS verification failed. Check CORS_ALLOWED_ORIGINS on the backend.'
}
Write-Output 'PASS frontend origin allowed by backend CORS'
Write-Output 'Public deployment checks passed. Complete the authenticated smoke tests in docs/deployment.md.'
