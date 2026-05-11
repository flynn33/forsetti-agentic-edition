$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "github-context.ps1")

function Get-EntryContainingTask {
    param(
        [string]$UnreleasedText,
        [string]$TaskId
    )

    if ([string]::IsNullOrWhiteSpace($TaskId)) {
        return ""
    }

    $lines = $UnreleasedText -split "`r?`n"
    $taskIndex = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match [regex]::Escape($TaskId)) {
            $taskIndex = $i
            break
        }
    }

    if ($taskIndex -lt 0) {
        return ""
    }

    $start = $taskIndex
    while ($start -gt 0 -and $lines[$start] -notmatch '^\*\*Title\*\*:') {
        $start--
    }
    if ($lines[$start] -notmatch '^\*\*Title\*\*:') {
        $start = $taskIndex
    }

    $end = $start + 1
    while ($end -lt $lines.Count) {
        if ($end -gt $start -and ($lines[$end] -match '^\*\*Title\*\*:' -or $lines[$end] -match '^###\s+')) {
            break
        }
        $end++
    }

    return (($lines[$start..($end - 1)]) -join "`n").Trim()
}

function Get-FirstChangelogEntry {
    param([string]$UnreleasedText)

    $match = [regex]::Match($UnreleasedText, "(?ms)^\*\*Title\*\*:.*?(?=^\*\*Title\*\*:|^###\s+|\z)")
    if ($match.Success) {
        return $match.Value.Trim()
    }
    return $UnreleasedText.Trim()
}

$repoRoot = Get-ForsettiRepoRoot
$event = Get-ForsettiGitHubEvent
$body = Get-ForsettiPullRequestBody -Event $event
$changedFiles = Get-ForsettiChangedFiles -RepoRoot $repoRoot -Event $event
[void](Write-ForsettiChangedFiles -ChangedFiles $changedFiles)

if ($changedFiles -notcontains "changelog/CHANGELOG.md") {
    Write-Host "Changelog was not modified. Skipping format validation."
    exit 0
}

$changelogPath = Join-Path $repoRoot "changelog/CHANGELOG.md"
$changelog = Get-Content -LiteralPath $changelogPath -Raw
$unreleasedMatch = [regex]::Match($changelog, "(?ms)^## \[Unreleased\].*?(?=^## \[|\z)")
if (-not $unreleasedMatch.Success) {
    Write-Error "Could not extract the Unreleased changelog section from changelog/CHANGELOG.md."
    exit 1
}

$taskReference = Get-ForsettiMarkdownField -Text $body -Label "Task Reference"
$taskId = ""
if ($taskReference -match '(FAE-[A-Z]+-\d{4}-\d{2}-\d{2}-\d{3})') {
    $taskId = $Matches[1]
}

$entry = ""
if (-not [string]::IsNullOrWhiteSpace($taskId)) {
    $entry = Get-EntryContainingTask -UnreleasedText $unreleasedMatch.Value -TaskId $taskId
}
if ([string]::IsNullOrWhiteSpace($entry)) {
    $entry = Get-FirstChangelogEntry -UnreleasedText $unreleasedMatch.Value
}

$title = Get-ForsettiMarkdownField -Text $entry -Label "Title"
$changeClass = Get-ForsettiMarkdownField -Text $entry -Label "Change Class"
$versionImpact = Get-ForsettiMarkdownField -Text $entry -Label "Version Impact"
$summary = Get-ForsettiMarkdownField -Text $entry -Label "Summary"
$affectedArea = Get-ForsettiMarkdownField -Text $entry -Label "Affected Area"

$validChangeClasses = @("feature", "bugfix", "refactor", "docs", "governance", "release", "metadata", "breaking-change")
$validVersionImpacts = @("none", "patch", "minor", "major", "governance-only")
$failed = $false
$warnings = New-Object System.Collections.Generic.List[string]

if ([string]::IsNullOrWhiteSpace($title)) {
    Write-Error "Missing required field: **Title**."
    $failed = $true
} elseif ($title.Length -lt 10 -or $title.Length -gt 120) {
    Write-Error "Title length must be between 10 and 120 characters."
    $failed = $true
}

if ($changeClass -notin $validChangeClasses) {
    Write-Error "Invalid or missing Change Class: '$changeClass'."
    $failed = $true
}

if ($versionImpact -notin $validVersionImpacts) {
    Write-Error "Invalid or missing Version Impact: '$versionImpact'."
    $failed = $true
}

if ([string]::IsNullOrWhiteSpace($summary) -or $summary.Length -lt 30) {
    Write-Error "Missing or too-short Summary."
    $failed = $true
}

if ([string]::IsNullOrWhiteSpace($affectedArea)) {
    Write-Error "Missing required field: **Affected Area**."
    $failed = $true
}

if ($changeClass -eq "breaking-change") {
    if ($versionImpact -ne "major") {
        Write-Error "Breaking change entries must use Version Impact 'major'."
        $failed = $true
    }
    if ($entry -notmatch '(?im)^\*\*(migration_note|Migration Note|Migration Guidance)\*\*:') {
        Write-Error "Breaking change entries require migration guidance."
        $failed = $true
    }
}

$prChangeClass = Get-ForsettiMarkdownField -Text $body -Label "Change Class"
if (-not [string]::IsNullOrWhiteSpace($prChangeClass) -and
    -not [string]::IsNullOrWhiteSpace($changeClass) -and
    $prChangeClass -ne $changeClass) {
    $warnings.Add("Changelog Change Class '$changeClass' differs from PR body Change Class '$prChangeClass'.")
}

foreach ($warning in $warnings) {
    Write-Warning $warning
}

$displayTitle = if ([string]::IsNullOrWhiteSpace($title)) { "MISSING" } else { $title }
$displayClass = if ([string]::IsNullOrWhiteSpace($changeClass)) { "MISSING" } else { $changeClass }
$displayImpact = if ([string]::IsNullOrWhiteSpace($versionImpact)) { "MISSING" } else { $versionImpact }
$displayArea = if ([string]::IsNullOrWhiteSpace($affectedArea)) { "MISSING" } else { $affectedArea }

Write-Host "========================================"
Write-Host "  Changelog Validation Summary"
Write-Host "========================================"
Write-Host "  Title:          $displayTitle"
Write-Host "  Change Class:   $displayClass"
Write-Host "  Version Impact: $displayImpact"
Write-Host "  Affected Area:  $displayArea"

if ($failed) {
    Write-Host "  Status:         FAIL"
    exit 1
}

Write-Host "  Status:         PASS"
