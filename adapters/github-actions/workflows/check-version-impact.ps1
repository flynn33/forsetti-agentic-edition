$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "github-context.ps1")

$repoRoot = Get-ForsettiRepoRoot
$event = Get-ForsettiGitHubEvent
$body = Get-ForsettiPullRequestBody -Event $event
$changedFiles = Get-ForsettiChangedFiles -RepoRoot $repoRoot -Event $event
[void](Write-ForsettiChangedFiles -ChangedFiles $changedFiles)

if ([string]::IsNullOrWhiteSpace($body)) {
    Write-Error "PR body is empty. Cannot determine version impact."
    exit 1
}

$releaseImpact = Get-ForsettiMarkdownField -Text $body -Label "Release Impact"
$changeClass = Get-ForsettiMarkdownField -Text $body -Label "Change Class"
Write-Host "Detected Release Impact: '$releaseImpact'"
Write-Host "Detected Change Class: '$changeClass'"

$policyPath = Join-Path $repoRoot "core/policies/repo-boundaries.json"
$policy = Get-Content -LiteralPath $policyPath -Raw | ConvertFrom-Json
$governanceTouched = $false
foreach ($file in $changedFiles) {
    foreach ($pattern in @($policy.governance_only_paths.paths)) {
        if (Test-ForsettiPathPattern -Path $file -Pattern ([string]$pattern)) {
            $governanceTouched = $true
            Write-Host "Governance path modified: $file"
            break
        }
    }
}

$failed = $false
$warnings = New-Object System.Collections.Generic.List[string]

if ($governanceTouched -and $releaseImpact -notin @("governance-only", "major")) {
    Write-Error "Governance-sensitive paths were modified but Release Impact is '$releaseImpact'."
    $failed = $true
}

switch ($changeClass) {
    "feature" {
        if ($releaseImpact -notin @("minor", "patch")) {
            $warnings.Add("Change Class is 'feature' but Release Impact is '$releaseImpact'. Expected 'minor' or 'patch'.")
        }
    }
    "refactor" {
        if ($releaseImpact -notin @("patch", "none")) {
            $warnings.Add("Change Class is 'refactor' but Release Impact is '$releaseImpact'. Expected 'patch' or 'none'.")
        }
    }
    "governance" {
        if ($releaseImpact -notin @("governance-only", "major")) {
            Write-Error "Change Class is 'governance' but Release Impact is '$releaseImpact'. Expected 'governance-only' or 'major'."
            $failed = $true
        }
    }
    "metadata" {
        if ($releaseImpact -ne "none") {
            $warnings.Add("Change Class is 'metadata' but Release Impact is '$releaseImpact'. Expected 'none'.")
        }
    }
    "bugfix" {
        if ($releaseImpact -notin @("patch", "minor", "none")) {
            $warnings.Add("Change Class is 'bugfix' but Release Impact is '$releaseImpact'. Expected 'patch', 'minor', or 'none'.")
        }
    }
    "breaking-change" {
        if ($releaseImpact -ne "major") {
            Write-Error "Change Class is 'breaking-change' but Release Impact is '$releaseImpact'. Expected 'major'."
            $failed = $true
        }
    }
    "docs" {
        if ($releaseImpact -notin @("none", "patch")) {
            $warnings.Add("Change Class is 'docs' but Release Impact is '$releaseImpact'. Expected 'none' or 'patch'.")
        }
    }
}

foreach ($warning in $warnings) {
    Write-Warning $warning
}
if ($failed) {
    exit 1
}

Write-Host "Version impact classification is consistent. Check passed."
