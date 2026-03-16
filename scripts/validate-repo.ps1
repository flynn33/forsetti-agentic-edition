# Forsetti Agentic Edition — Repository Validation Script
# Analogous to verify-forsetti-guardrails.ps1 (Windows Forsetti Framework)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent $PSScriptRoot }
$Errors = 0
$Warnings = 0

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Forsetti Agentic Edition - Repo Validation" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# [1/6] File Existence Check
Write-Host "[1/6] Checking required files..." -ForegroundColor Yellow

$RequiredFiles = @(
    "README.md", "VISION.md", "FORSETTI_CONSTITUTION.md", "AGENTS.md",
    "COMPLIANCE_POLICY.md", "CHANGE_CONTROL_POLICY.md", "RELEASE_POLICY.md",
    "DOCUMENTATION_POLICY.md", "CONTRIBUTING.md", "CODE_OF_DELIVERY.md",
    ".github/CODEOWNERS", ".github/labels.json", ".github/pull_request_template.md",
    ".github/ISSUE_TEMPLATE/feature_request.md", ".github/ISSUE_TEMPLATE/bug_report.md",
    ".github/ISSUE_TEMPLATE/governance_change.md", ".github/ISSUE_TEMPLATE/agent_task.md",
    ".github/workflows/policy-check.yml", ".github/workflows/changelog-check.yml",
    ".github/workflows/docs-sync-check.yml", ".github/workflows/version-guard.yml",
    ".github/workflows/protected-path-check.yml",
    "agents/architect.md", "agents/builder.md", "agents/validator.md",
    "agents/release-manager.md", "agents/docs-manager.md",
    "contracts/task-contract-template.md", "contracts/bugfix-contract-template.md",
    "contracts/governance-change-template.md", "contracts/release-contract-template.md",
    "policies/agent-roles.json", "policies/compliance-rules.json",
    "policies/repo-boundaries.json", "policies/versioning-rules.json",
    "policies/changelog-rules.json", "policies/docs-sync-rules.json", "policies/labels.json",
    "standards/naming-standard.md", "standards/versioning-standard.md",
    "standards/changelog-standard.md", "standards/documentation-standard.md",
    "standards/review-standard.md",
    "changelog/CHANGELOG.md", "changelog/release-notes-template.md",
    "wiki/Home.md", "wiki/Constitution.md", "wiki/Agent-Roles.md",
    "wiki/Workflow.md", "wiki/Compliance.md", "wiki/Releases.md", "wiki/Glossary.md",
    "schemas/task-contract.schema.json", "schemas/release-entry.schema.json",
    "schemas/compliance-report.schema.json"
)

foreach ($f in $RequiredFiles) {
    $path = Join-Path $RepoRoot $f
    if (-not (Test-Path $path)) {
        Write-Host "  ERROR: Missing required file: $f" -ForegroundColor Red
        $Errors++
    }
}
if ($Errors -eq 0) {
    Write-Host "  All $($RequiredFiles.Count) required files present." -ForegroundColor Green
}
Write-Host ""

# [2/6] JSON Validation
Write-Host "[2/6] Validating JSON files..." -ForegroundColor Yellow
$JsonErrors = 0
$JsonFiles = Get-ChildItem -Path $RepoRoot -Filter "*.json" -Recurse | Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' }
foreach ($jf in $JsonFiles) {
    try {
        $null = Get-Content $jf.FullName -Raw | ConvertFrom-Json
    } catch {
        Write-Host "  ERROR: Invalid JSON: $($jf.FullName)" -ForegroundColor Red
        $JsonErrors++
        $Errors++
    }
}
if ($JsonErrors -eq 0) {
    Write-Host "  All JSON files parse cleanly." -ForegroundColor Green
}
Write-Host ""

# [3/6] YAML Validation (basic structure check)
Write-Host "[3/6] Validating YAML workflow files..." -ForegroundColor Yellow
$YamlDir = Join-Path $RepoRoot ".github/workflows"
if (Test-Path $YamlDir) {
    $YamlFiles = Get-ChildItem -Path $YamlDir -Filter "*.yml"
    foreach ($yf in $YamlFiles) {
        $content = Get-Content $yf.FullName -Raw
        if ([string]::IsNullOrWhiteSpace($content) -or $content.Length -lt 10) {
            Write-Host "  ERROR: YAML file appears empty: $($yf.Name)" -ForegroundColor Red
            $Errors++
        }
    }
    Write-Host "  YAML files checked (basic validation)." -ForegroundColor Green
}
Write-Host ""

# [4/6] Non-Trivial Content Check
Write-Host "[4/6] Checking files are non-trivial (>5 lines)..." -ForegroundColor Yellow
$Trivial = 0
foreach ($f in $RequiredFiles) {
    $path = Join-Path $RepoRoot $f
    if (Test-Path $path) {
        $lines = (Get-Content $path).Count
        if ($lines -lt 5) {
            Write-Host "  WARNING: File appears to be a stub ($lines lines): $f" -ForegroundColor DarkYellow
            $Warnings++
            $Trivial++
        }
    }
}
if ($Trivial -eq 0) {
    Write-Host "  All required files have substantive content." -ForegroundColor Green
}
Write-Host ""

# [5/6] Labels Sync Check
Write-Host "[5/6] Checking labels.json sync..." -ForegroundColor Yellow
$policyLabels = Join-Path $RepoRoot "policies/labels.json"
$githubLabels = Join-Path $RepoRoot ".github/labels.json"
if ((Test-Path $policyLabels) -and (Test-Path $githubLabels)) {
    $diff = Compare-Object (Get-Content $policyLabels) (Get-Content $githubLabels)
    if ($null -eq $diff) {
        Write-Host "  policies/labels.json and .github/labels.json are in sync." -ForegroundColor Green
    } else {
        Write-Host "  WARNING: policies/labels.json and .github/labels.json differ." -ForegroundColor DarkYellow
        $Warnings++
    }
} else {
    Write-Host "  ERROR: One or both labels.json files missing." -ForegroundColor Red
    $Errors++
}
Write-Host ""

# [6/6] Schema Non-Empty Check
Write-Host "[6/6] Checking JSON schemas have properties defined..." -ForegroundColor Yellow
$schemas = @("schemas/task-contract.schema.json", "schemas/release-entry.schema.json", "schemas/compliance-report.schema.json")
foreach ($s in $schemas) {
    $path = Join-Path $RepoRoot $s
    if (Test-Path $path) {
        $obj = Get-Content $path -Raw | ConvertFrom-Json
        if (-not $obj.properties) {
            Write-Host "  ERROR: Schema has no properties defined: $s" -ForegroundColor Red
            $Errors++
        }
    }
}
Write-Host "  Schema structure validated." -ForegroundColor Green
Write-Host ""

# Summary
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Validation Complete" -ForegroundColor Cyan
Write-Host "  Errors:   $Errors" -ForegroundColor $(if ($Errors -gt 0) { "Red" } else { "Green" })
Write-Host "  Warnings: $Warnings" -ForegroundColor $(if ($Warnings -gt 0) { "DarkYellow" } else { "Green" })
Write-Host "==========================================" -ForegroundColor Cyan

if ($Errors -gt 0) {
    Write-Host "FAILED - $Errors error(s) must be resolved." -ForegroundColor Red
    exit 1
} else {
    Write-Host "PASSED - Repository validation successful." -ForegroundColor Green
    exit 0
}
