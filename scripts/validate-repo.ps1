# Forsetti Agentic Edition repository validation wrapper

[CmdletBinding()]
param(
    [ValidateSet("all", "files", "structure", "json", "policies", "policy", "docs", "schemas", "schema", "scripts")]
    [string]$Mode = "all",
    [string]$OutputJson,
    [switch]$Strict
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

if (-not [string]::IsNullOrWhiteSpace($OutputJson)) {
    if ($Strict) {
        & $Validator -RepoRoot $RepoRoot -Mode $Mode -Strict -OutputJson $OutputJson
    } else {
        & $Validator -RepoRoot $RepoRoot -Mode $Mode -OutputJson $OutputJson
    }
} else {
    if ($Strict) {
        & $Validator -RepoRoot $RepoRoot -Mode $Mode -Strict
    } else {
        & $Validator -RepoRoot $RepoRoot -Mode $Mode
    }
}
exit $LASTEXITCODE
