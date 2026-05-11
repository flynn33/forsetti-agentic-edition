$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "github-context.ps1")

function New-RepositoryTree {
    param([string]$RepoRoot)

    $entries = Get-ChildItem -LiteralPath $RepoRoot -Force |
        Where-Object { $_.Name -notin @(".git", "node_modules", "__pycache__") } |
        Sort-Object Name

    $lines = New-Object System.Collections.Generic.List[string]
    foreach ($entry in $entries) {
        $suffix = if ($entry.PSIsContainer) { "/" } else { "" }
        $lines.Add("├── $($entry.Name)$suffix")
        if ($entry.PSIsContainer -and $entry.Name -notin @(".forsetti", ".github")) {
            $children = Get-ChildItem -LiteralPath $entry.FullName -Force |
                Where-Object { $_.Name -notin @(".git", "node_modules", "__pycache__") } |
                Sort-Object Name
            foreach ($child in $children) {
                $childSuffix = if ($child.PSIsContainer) { "/" } else { "" }
                $lines.Add("  ├── $($child.Name)$childSuffix")
            }
        }
    }

    return ($lines.ToArray() -join "`n")
}

function Update-ReadmeStructure {
    param([string]$RepoRoot)

    $readmePath = Join-Path $RepoRoot "README.md"
    if (-not (Test-Path -LiteralPath $readmePath)) {
        return
    }

    $content = Get-Content -LiteralPath $readmePath -Raw
    if ($content -notmatch '(?m)^## Repository Structure\s*$') {
        return
    }

    $tree = New-RepositoryTree -RepoRoot $RepoRoot
    $pattern = '(?ms)(^## Repository Structure\s*\r?\n\s*```.*?\r?\n).*?(\r?\n```)'
    $newContent = [regex]::Replace($content, $pattern, ('$1' + $tree + '$2'), 1)
    if ($newContent -ne $content) {
        Save-ForsettiUtf8File -Path $readmePath -Content $newContent
        Write-Host "README repository structure updated."
    }
}

function Update-ReadmeVersionBadge {
    param(
        [string]$RepoRoot,
        [string]$Version
    )

    $readmePath = Join-Path $RepoRoot "README.md"
    if (-not (Test-Path -LiteralPath $readmePath)) {
        return
    }

    $content = Get-Content -LiteralPath $readmePath -Raw
    $newContent = $content -replace 'img\.shields\.io/badge/version-[^)]+', "img.shields.io/badge/version-v$Version-blue"
    if ($newContent -ne $content) {
        Save-ForsettiUtf8File -Path $readmePath -Content $newContent
        Write-Host "README version badge updated."
    }
}

function Test-WikiCanonicalConsistency {
    param([string]$RepoRoot)

    $wikiMap = @{
        "FORSETTI_CONSTITUTION.md" = "wiki/Constitution.md"
        "COMPLIANCE_POLICY.md" = "wiki/Compliance.md"
        "RELEASE_POLICY.md" = "wiki/Releases.md"
    }

    $driftFound = $false
    foreach ($canonical in $wikiMap.Keys) {
        $canonicalPath = Join-Path $RepoRoot $canonical
        $wikiPath = Join-Path $RepoRoot $wikiMap[$canonical]
        if (-not (Test-Path -LiteralPath $canonicalPath) -or -not (Test-Path -LiteralPath $wikiPath)) {
            continue
        }

        $firstLine = @(Get-Content -LiteralPath $canonicalPath |
            Where-Object { $_ -notmatch '^#' -and -not [string]::IsNullOrWhiteSpace($_) } |
            Select-Object -First 1)
        if ($firstLine.Count -gt 0) {
            $probe = $firstLine[0]
            if ($probe.Length -gt 60) {
                $probe = $probe.Substring(0, 60)
            }
            $wikiContent = Get-Content -LiteralPath $wikiPath -Raw
            if ($wikiContent -notlike "*$probe*") {
                Write-Warning "Wiki drift detected: $($wikiMap[$canonical]) may be out of sync with $canonical."
                $driftFound = $true
            }
        }
    }

    if (-not $driftFound) {
        Write-Host "All checked wiki pages are consistent with canonical sources."
    }
}

$repoRoot = Get-ForsettiRepoRoot
$versionPath = Join-Path $repoRoot "VERSION"
$version = "unreleased"
if (Test-Path -LiteralPath $versionPath) {
    $version = (Get-Content -LiteralPath $versionPath -Raw).Trim()
}

Update-ReadmeVersionBadge -RepoRoot $repoRoot -Version $version
Update-ReadmeStructure -RepoRoot $repoRoot
Test-WikiCanonicalConsistency -RepoRoot $repoRoot

[void](Invoke-ForsettiCommitIfChanged -RepoRoot $repoRoot -Paths @("README.md") -Message "docs(readme): sync README sections")
