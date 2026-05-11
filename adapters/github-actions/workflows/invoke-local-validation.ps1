param(
    [ValidateSet("all", "files", "structure", "json", "policies", "policy", "docs", "schemas", "schema", "scripts", "contract", "contracts")]
    [string]$Mode = "all",
    [switch]$Strict,
    [string]$ContractPath,
    [string]$ChangedFilesPath,
    [string]$OutputJson
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "github-context.ps1")

$repoRoot = Get-ForsettiRepoRoot
$validator = Join-Path $repoRoot "core/validator/forsetti_validate.ps1"
if (-not (Test-Path -LiteralPath $validator)) {
    Write-Error "Local validator was not found at core/validator/forsetti_validate.ps1."
    exit 1
}

$arguments = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-File", $validator,
    "-RepoRoot", $repoRoot,
    "-Mode", $Mode
)

if ($Strict) {
    $arguments += "-Strict"
}
if (-not [string]::IsNullOrWhiteSpace($ContractPath)) {
    $arguments += @("-ContractPath", $ContractPath)
}
if (-not [string]::IsNullOrWhiteSpace($ChangedFilesPath)) {
    $arguments += @("-ChangedFilesPath", $ChangedFilesPath)
}
if (-not [string]::IsNullOrWhiteSpace($OutputJson)) {
    $arguments += @("-OutputJson", $OutputJson)
}

Write-Host "Invoking Forsetti local validator in mode '$Mode'."
& pwsh @arguments
exit $LASTEXITCODE
