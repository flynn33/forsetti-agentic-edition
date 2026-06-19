# Forsetti Agentic Edition repository validation wrapper

[CmdletBinding()]
param(
    [ValidateSet("all", "repo", "files", "structure", "json", "policies", "policy", "docs", "schemas", "schema", "scripts", "contract", "contracts", "project-context", "edition-profile", "manifest", "dependencies", "capabilities", "module-isolation", "evidence")]
    [string]$Mode = "all",
    [string]$OutputJson,
    [switch]$Strict,
    [string]$ContractPath,
    [string]$ProjectContextPath,
    [string]$EditionProfilePath,
    [string]$ManifestPath,
    [Alias("ChangedFiles")]
    [string[]]$ChangedFile,
    [string]$ChangedFilesPath
)

$ErrorActionPreference = "Stop"

$ScriptRoot = if ($PSScriptRoot) {
    $PSScriptRoot
} elseif ($MyInvocation.MyCommand.Path) {
    Split-Path -Parent $MyInvocation.MyCommand.Path
} else {
    (Get-Location).Path
}

$RepoRoot = [System.IO.Path]::GetFullPath((Join-Path $ScriptRoot ".."))
$Validator = Join-Path $RepoRoot "core\validator\forsetti_validate.ps1"

if (-not (Test-Path -LiteralPath $Validator)) {
    throw "Unable to locate Forsetti local validator: $Validator"
}

$validatorArgs = @{
    RepoRoot = $RepoRoot
    Mode     = $Mode
}
if ($Strict) {
    $validatorArgs.Strict = $true
}
if (-not [string]::IsNullOrWhiteSpace($OutputJson)) {
    $validatorArgs.OutputJson = $OutputJson
}
if (-not [string]::IsNullOrWhiteSpace($ContractPath)) {
    $validatorArgs.ContractPath = $ContractPath
}
if (-not [string]::IsNullOrWhiteSpace($ProjectContextPath)) {
    $validatorArgs.ProjectContextPath = $ProjectContextPath
}
if (-not [string]::IsNullOrWhiteSpace($EditionProfilePath)) {
    $validatorArgs.EditionProfilePath = $EditionProfilePath
}
if (-not [string]::IsNullOrWhiteSpace($ManifestPath)) {
    $validatorArgs.ManifestPath = $ManifestPath
}
if (@($ChangedFile).Count -gt 0) {
    $validatorArgs.ChangedFile = $ChangedFile
}
if (-not [string]::IsNullOrWhiteSpace($ChangedFilesPath)) {
    $validatorArgs.ChangedFilesPath = $ChangedFilesPath
}

& $Validator @validatorArgs
exit $LASTEXITCODE
