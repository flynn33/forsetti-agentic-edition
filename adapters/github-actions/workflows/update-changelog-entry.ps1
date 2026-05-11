$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "github-context.ps1")

function Get-ChangeClassFromLabelsOrTitle {
    param(
        [string[]]$Labels,
        [string]$Title,
        [string]$Body
    )

    $result = [pscustomobject]@{
        ChangeClass = ""
        VersionImpact = ""
    }

    foreach ($label in $Labels) {
        $value = $label.Trim().ToLowerInvariant()
        switch ($value) {
            "feature" { $result.ChangeClass = "feature"; if (-not $result.VersionImpact) { $result.VersionImpact = "minor" } }
            "enhancement" { $result.ChangeClass = "feature"; if (-not $result.VersionImpact) { $result.VersionImpact = "minor" } }
            "bugfix" { $result.ChangeClass = "bugfix"; if (-not $result.VersionImpact) { $result.VersionImpact = "patch" } }
            "bug" { $result.ChangeClass = "bugfix"; if (-not $result.VersionImpact) { $result.VersionImpact = "patch" } }
            "fix" { $result.ChangeClass = "bugfix"; if (-not $result.VersionImpact) { $result.VersionImpact = "patch" } }
            "refactor" { $result.ChangeClass = "refactor"; if (-not $result.VersionImpact) { $result.VersionImpact = "patch" } }
            "refactoring" { $result.ChangeClass = "refactor"; if (-not $result.VersionImpact) { $result.VersionImpact = "patch" } }
            "docs" { $result.ChangeClass = "docs"; if (-not $result.VersionImpact) { $result.VersionImpact = "none" } }
            "documentation" { $result.ChangeClass = "docs"; if (-not $result.VersionImpact) { $result.VersionImpact = "none" } }
            "governance" { $result.ChangeClass = "governance"; if (-not $result.VersionImpact) { $result.VersionImpact = "governance-only" } }
            "metadata" { $result.ChangeClass = "metadata"; if (-not $result.VersionImpact) { $result.VersionImpact = "none" } }
            "breaking" { $result.ChangeClass = "breaking-change"; $result.VersionImpact = "major" }
            "breaking-change" { $result.ChangeClass = "breaking-change"; $result.VersionImpact = "major" }
            "patch" { $result.VersionImpact = "patch" }
            "minor" { $result.VersionImpact = "minor" }
            "major" { $result.VersionImpact = "major" }
        }
    }

    if (-not $result.ChangeClass) {
        $lower = $Title.ToLowerInvariant()
        if ($lower -match '^feat(\(|:|!)') {
            $result.ChangeClass = "feature"
            if (-not $result.VersionImpact) { $result.VersionImpact = "minor" }
        } elseif ($lower -match '^fix(\(|:)') {
            $result.ChangeClass = "bugfix"
            if (-not $result.VersionImpact) { $result.VersionImpact = "patch" }
        } elseif ($lower -match '^refactor(\(|:)') {
            $result.ChangeClass = "refactor"
            if (-not $result.VersionImpact) { $result.VersionImpact = "patch" }
        } elseif ($lower -match '^docs(\(|:)') {
            $result.ChangeClass = "docs"
            if (-not $result.VersionImpact) { $result.VersionImpact = "none" }
        } elseif ($lower -match '^chore(\(|:)') {
            $result.ChangeClass = "metadata"
            if (-not $result.VersionImpact) { $result.VersionImpact = "none" }
        } else {
            $result.ChangeClass = "feature"
            if (-not $result.VersionImpact) { $result.VersionImpact = "patch" }
        }
    }

    if ($Title -match '!:' -or $Body -match '(?i)BREAKING CHANGE') {
        $result.ChangeClass = "breaking-change"
        $result.VersionImpact = "major"
    }

    return $result
}

function ConvertTo-TitleCaseLabel {
    param([string]$Value)

    $words = $Value -replace "-", " "
    return (Get-Culture).TextInfo.ToTitleCase($words)
}

$repoRoot = Get-ForsettiRepoRoot
$event = Get-ForsettiGitHubEvent
$eventName = Get-ForsettiEventName -Event $event
$today = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd")

$manualTitle = Get-ForsettiEventInput -Event $event -Name "title"
$manualClass = Get-ForsettiEventInput -Event $event -Name "change_class"
$manualImpact = Get-ForsettiEventInput -Event $event -Name "version_impact"
$manualSummary = Get-ForsettiEventInput -Event $event -Name "summary"

if (-not [string]::IsNullOrWhiteSpace($manualTitle)) {
    $title = $manualTitle
    $changeClass = $manualClass
    $versionImpact = $manualImpact
    $summary = $manualSummary
    $affectedArea = "Manual entry"
    $prReference = ""
    $body = ""
} else {
    if (-not ($event -and $event.pull_request -and $event.pull_request.merged -eq $true)) {
        Write-Host "No merged pull request context was found. Nothing to update."
        exit 0
    }

    $title = Get-ForsettiPullRequestTitle -Event $event
    $body = Get-ForsettiPullRequestBody -Event $event
    $labels = Get-ForsettiPullRequestLabels -Event $event
    $classification = Get-ChangeClassFromLabelsOrTitle -Labels $labels -Title $title -Body $body
    $changeClass = $classification.ChangeClass
    $versionImpact = $classification.VersionImpact
    $prNumber = Get-ForsettiPullRequestNumber -Event $event
    $prReference = ""
    if (-not [string]::IsNullOrWhiteSpace($prNumber)) {
        $prReference = " (PR #$prNumber)"
    }

    $summary = Get-ForsettiMarkdownSection -Text $body -Header "Summary"
    if ([string]::IsNullOrWhiteSpace($summary) -or $summary.Length -lt 30) {
        $summary = $title
    }
    if ($summary.Length -gt 500) {
        $summary = $summary.Substring(0, 497) + "..."
    }

    $changedFiles = Get-ForsettiChangedFiles -RepoRoot $repoRoot -Event $event
    if (@($changedFiles).Count -eq 0) {
        $changedFiles = @(& git -C $repoRoot diff --name-only HEAD~1 HEAD 2>$null)
    }
    $affectedArea = Get-ForsettiAffectedArea -ChangedFiles $changedFiles
}

if ([string]::IsNullOrWhiteSpace($changeClass)) {
    $changeClass = "feature"
}
if ([string]::IsNullOrWhiteSpace($versionImpact)) {
    $versionImpact = "patch"
}

$categoryLabel = ConvertTo-TitleCaseLabel -Value $changeClass
$entry = @"
## [Unreleased] - $today

### $categoryLabel

**Title**: $title$prReference
**Change Class**: $changeClass
**Version Impact**: $versionImpact
**Summary**: $summary
**Affected Area**: $affectedArea
"@

if ($changeClass -eq "breaking-change") {
    $migration = Get-ForsettiMarkdownSection -Text $body -Header "Migration"
    if ([string]::IsNullOrWhiteSpace($migration)) {
        $migration = "Review the breaking changes and update dependent configurations accordingly."
    }
    $entry = $entry.TrimEnd() + "`n**Migration Note**: $migration`n"
}

$changelogPath = Join-Path $repoRoot "changelog/CHANGELOG.md"
if (-not (Test-Path -LiteralPath $changelogPath)) {
    $initial = @"
# Changelog

All notable changes to the Forsetti Agentic Edition governance framework are documented in this file.

The changelog is a governance record. Entries must be accurate, specific, and traceable.

$entry
"@
    Save-ForsettiUtf8File -Path $changelogPath -Content $initial
} else {
    $content = Get-Content -LiteralPath $changelogPath -Raw
    $match = [regex]::Match($content, "(?m)^## \[")
    if ($match.Success) {
        $prefix = $content.Substring(0, $match.Index).TrimEnd()
        $suffix = $content.Substring($match.Index).TrimStart()
        $newContent = $prefix + "`n`n" + $entry.TrimEnd() + "`n`n" + $suffix
    } else {
        $newContent = $content.TrimEnd() + "`n`n" + $entry.TrimEnd() + "`n"
    }
    Save-ForsettiUtf8File -Path $changelogPath -Content $newContent
}

Write-Host "Changelog entry prepared."
[void](Invoke-ForsettiCommitIfChanged -RepoRoot $repoRoot -Paths @("changelog/CHANGELOG.md") -Message "docs(changelog): update changelog entry")
