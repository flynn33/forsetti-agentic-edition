$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "github-context.ps1")

$repoRoot = Get-ForsettiRepoRoot
$event = Get-ForsettiGitHubEvent
$dryRun = Get-ForsettiEventInput -Event $event -Name "dry_run" -Default "true"

$statuses = [ordered]@{
    Changelog = "passed"
    Json = "passed"
    Yaml = "passed"
    Validator = "passed"
}
$failed = $false

$changelogPath = Join-Path $repoRoot "changelog/CHANGELOG.md"
if (-not (Test-Path -LiteralPath $changelogPath)) {
    Write-Error "Changelog file not found at changelog/CHANGELOG.md."
    $statuses.Changelog = "failed"
    $failed = $true
} else {
    $changelogLines = @(Get-Content -LiteralPath $changelogPath)
    $entryCount = @($changelogLines | Where-Object { $_ -match '^\s*##\s' }).Count
    if ($changelogLines.Count -lt 5) {
        Write-Error "Changelog appears to be empty or has no meaningful entries."
        $statuses.Changelog = "failed"
        $failed = $true
    } else {
        Write-Host "Changelog validation passed. Found $entryCount version sections in $($changelogLines.Count) lines."
    }
}

$jsonFiles = @(Get-ChildItem -LiteralPath $repoRoot -Recurse -Filter "*.json" -File |
    Where-Object { $_.FullName -notmatch '\\\.git\\|\\node_modules\\' })
$jsonErrors = 0
foreach ($file in $jsonFiles) {
    try {
        $null = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
        Write-Host "Valid JSON: $($file.FullName.Substring($repoRoot.Length).TrimStart('\'))"
    } catch {
        Write-Error "Invalid JSON: $($file.FullName)"
        $jsonErrors++
    }
}
if ($jsonErrors -gt 0) {
    $statuses.Json = "failed"
    $failed = $true
}

$workflowRoot = Join-Path $repoRoot ".github/workflows"
$yamlFiles = @(Get-ChildItem -LiteralPath $workflowRoot -Include "*.yml", "*.yaml" -File -Recurse)
$ruby = Get-Command ruby -ErrorAction SilentlyContinue
if ($yamlFiles.Count -eq 0) {
    Write-Warning "No YAML workflow files found."
} elseif ($ruby) {
    $paths = @($yamlFiles | ForEach-Object { $_.FullName })
    & ruby -e "require 'yaml'; ARGV.each { |path| YAML.load_file(path); puts ""Valid YAML: #{path}"" }" @paths
    if ($LASTEXITCODE -ne 0) {
        $statuses.Yaml = "failed"
        $failed = $true
    }
} else {
    foreach ($file in $yamlFiles) {
        $content = Get-Content -LiteralPath $file.FullName -Raw
        if ([string]::IsNullOrWhiteSpace($content)) {
            Write-Error "Invalid YAML candidate: $($file.FullName) is empty."
            $statuses.Yaml = "failed"
            $failed = $true
        } else {
            Write-Host "YAML file is present and non-empty: $($file.FullName.Substring($repoRoot.Length).TrimStart('\'))"
        }
    }
}

$validator = Join-Path $PSScriptRoot "invoke-local-validation.ps1"
& $validator -Mode all -Strict
if ($LASTEXITCODE -ne 0) {
    $statuses.Validator = "failed"
    $failed = $true
}

Write-Host "====================================="
Write-Host "  Release Readiness Report"
Write-Host "====================================="
Write-Host "  Changelog:    $($statuses.Changelog)"
Write-Host "  JSON files:   $($statuses.Json)"
Write-Host "  YAML files:   $($statuses.Yaml)"
Write-Host "  Validator:    $($statuses.Validator)"
Write-Host "  Dry run:      $dryRun"
Write-Host "====================================="

if ($failed) {
    exit 1
}

Write-Host "STATUS: READY FOR RELEASE"
