$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "github-context.ps1")

function Get-SemVerParts {
    param([string]$Version)

    if ($Version -notmatch '^(\d+)\.(\d+)\.(\d+)$') {
        throw "Current version '$Version' is not valid SemVer (X.Y.Z)."
    }

    return [pscustomobject]@{
        Major = [int]$Matches[1]
        Minor = [int]$Matches[2]
        Patch = [int]$Matches[3]
    }
}

function Get-NewVersion {
    param(
        [string]$CurrentVersion,
        [string]$BumpType
    )

    $parts = Get-SemVerParts -Version $CurrentVersion
    switch ($BumpType) {
        "patch" { return ("{0}.{1}.{2}" -f $parts.Major, $parts.Minor, ($parts.Patch + 1)) }
        "minor" { return ("{0}.{1}.0" -f $parts.Major, ($parts.Minor + 1)) }
        "major" { return ("{0}.0.0" -f ($parts.Major + 1)) }
        default { throw "Unknown bump type: '$BumpType'." }
    }
}

$repoRoot = Get-ForsettiRepoRoot
$event = Get-ForsettiGitHubEvent
$manualBump = Get-ForsettiEventInput -Event $event -Name "bump_type"
$changelogPath = Join-Path $repoRoot "changelog/CHANGELOG.md"

if (-not [string]::IsNullOrWhiteSpace($manualBump)) {
    $bumpType = $manualBump
    Write-Host "Manual bump requested: $bumpType"
} elseif (Test-Path -LiteralPath $changelogPath) {
    $changelog = Get-Content -LiteralPath $changelogPath -Raw
    $entryMatch = [regex]::Match($changelog, "(?ms)^## \[.*?(?=^## \[|\z)")
    $versionImpact = ""
    if ($entryMatch.Success) {
        $versionImpact = Get-ForsettiMarkdownField -Text $entryMatch.Value -Label "Version Impact"
    }

    switch ($versionImpact) {
        "none" {
            Write-Host "No version bump needed for impact 'none'."
            exit 0
        }
        "governance-only" {
            Write-Host "No version bump needed for impact 'governance-only'."
            exit 0
        }
        "patch" { $bumpType = "patch" }
        "minor" { $bumpType = "minor" }
        "major" { $bumpType = "major" }
        default {
            Write-Host "No Version Impact found in newest changelog entry. Checking recent commit messages."
            $bumpType = "patch"
            $commits = @(& git -C $repoRoot log --format="%s" HEAD~5..HEAD 2>$null)
            if ($LASTEXITCODE -ne 0 -or $commits.Count -eq 0) {
                $commits = @(& git -C $repoRoot log --format="%s" -5)
            }
            foreach ($message in $commits) {
                if ($message -match '(?i)BREAKING CHANGE|^.*!:') {
                    $bumpType = "major"
                    break
                } elseif ($message -match '(?i)^feat(\(.*\))?:') {
                    $bumpType = "minor"
                }
            }
        }
    }
} else {
    Write-Host "No changelog found. Skipping."
    exit 0
}

$versionPath = Join-Path $repoRoot "VERSION"
if (Test-Path -LiteralPath $versionPath) {
    $currentVersion = (Get-Content -LiteralPath $versionPath -Raw).Trim()
} elseif (Test-Path -LiteralPath $changelogPath) {
    $content = Get-Content -LiteralPath $changelogPath -Raw
    if ($content -match '## \[(\d+\.\d+\.\d+)\]') {
        $currentVersion = $Matches[1]
    } else {
        $currentVersion = "0.0.0"
    }
} else {
    $currentVersion = "0.0.0"
}

$newVersion = Get-NewVersion -CurrentVersion $currentVersion -BumpType $bumpType
Write-Host "Previous version: $currentVersion"
Write-Host "Bump type:        $bumpType"
Write-Host "New version:      $newVersion"

if ((Test-Path -LiteralPath $versionPath) -and ((Get-Content -LiteralPath $versionPath -Raw).Trim() -eq $newVersion)) {
    Write-Host "VERSION file already at $newVersion. Skipping write."
} else {
    Save-ForsettiUtf8File -Path $versionPath -Content ($newVersion + "`n")
    [void](Invoke-ForsettiCommitIfChanged -RepoRoot $repoRoot -Paths @("VERSION") -Message "chore(version): bump to v$newVersion")
}

$tag = "v$newVersion"
& git -C $repoRoot rev-parse $tag 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Tag $tag already exists. Skipping tag creation."
} else {
    Set-ForsettiGitIdentity -RepoRoot $repoRoot
    & git -C $repoRoot tag -a $tag -m "Release $tag"
    & git -C $repoRoot push origin $tag
    Write-Host "Created and pushed tag: $tag"
}

$gh = Get-Command gh -ErrorAction SilentlyContinue
if ($gh) {
    & gh release view $tag 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Release $tag already exists. Skipping release creation."
    } else {
        $notes = "Release $tag"
        if (Test-Path -LiteralPath $changelogPath) {
            $content = Get-Content -LiteralPath $changelogPath -Raw
            $entryMatch = [regex]::Match($content, "(?ms)^## \[(?:$([regex]::Escape($newVersion))|Unreleased)\].*?(?=^## \[|\z)")
            if ($entryMatch.Success) {
                $notes = $entryMatch.Value
            }
        }
        $notesPath = Join-Path ([System.IO.Path]::GetTempPath()) "forsetti-release-notes.md"
        Save-ForsettiUtf8File -Path $notesPath -Content $notes
        & gh release create $tag --title $tag --notes-file $notesPath
        Write-Host "Created GitHub Release: $tag"
    }
} else {
    Write-Warning "GitHub CLI was not available. Release creation skipped after tag handling."
}
