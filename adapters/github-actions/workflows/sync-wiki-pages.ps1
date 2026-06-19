$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "github-context.ps1")

function Get-ForsettiWikiPages {
    param([string]$RepoRoot)

    $wikiRoot = Join-Path $RepoRoot "wiki"
    if (-not (Test-Path -LiteralPath $wikiRoot)) {
        throw "Wiki mirror directory not found: $wikiRoot"
    }

    $pages = @(Get-ChildItem -LiteralPath $wikiRoot -Filter "*.md" -File | Sort-Object Name)
    if ($pages.Count -eq 0) {
        throw "Wiki mirror directory contains no markdown pages: $wikiRoot"
    }

    return $pages
}

function Copy-ForsettiWikiPages {
    param(
        [System.IO.FileInfo[]]$Pages,
        [string]$DestinationRoot
    )

    if (-not (Test-Path -LiteralPath $DestinationRoot)) {
        New-Item -ItemType Directory -Path $DestinationRoot -Force | Out-Null
    }

    $sourceNames = @{}
    foreach ($page in @($Pages)) {
        $sourceNames[$page.Name] = $true
        Copy-Item -LiteralPath $page.FullName -Destination (Join-Path $DestinationRoot $page.Name) -Force
    }

    foreach ($existing in @(Get-ChildItem -LiteralPath $DestinationRoot -Filter "*.md" -File)) {
        if (-not $sourceNames.ContainsKey($existing.Name)) {
            Remove-Item -LiteralPath $existing.FullName -Force
        }
    }
}

$repoRoot = Get-ForsettiRepoRoot
$repo = if ($env:GITHUB_REPOSITORY) { $env:GITHUB_REPOSITORY } else { "flynn33/forsetti-agentic-edition" }
$pages = @(Get-ForsettiWikiPages -RepoRoot $repoRoot)

Write-Host "Wiki mirror contains $($pages.Count) page(s)."

if ([string]::IsNullOrWhiteSpace($env:GITHUB_TOKEN)) {
    Write-Host "GITHUB_TOKEN is not available. Repository wiki publish skipped."
    exit 0
}

$wikiUrl = "https://github.com/${repo}.wiki.git"
$publishRoot = Join-Path ([System.IO.Path]::GetTempPath()) "forsetti-wiki-publish"
if (Test-Path -LiteralPath $publishRoot) {
    Remove-Item -LiteralPath $publishRoot -Recurse -Force
}

$extraHeader = "AUTHORIZATION: bearer $env:GITHUB_TOKEN"
& git -c "http.https://github.com/.extraheader=$extraHeader" clone $wikiUrl $publishRoot 2>$null
if ($LASTEXITCODE -ne 0) {
    New-Item -ItemType Directory -Path $publishRoot -Force | Out-Null
    & git -C $publishRoot init
    & git -C $publishRoot remote add origin $wikiUrl
}

Copy-ForsettiWikiPages -Pages $pages -DestinationRoot $publishRoot
Set-ForsettiGitIdentity -RepoRoot $publishRoot

& git -C $publishRoot add -A
& git -C $publishRoot diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "No changes to publish to GitHub Wiki."
    exit 0
}

& git -C $publishRoot commit -m "docs(wiki): sync from repository"
& git -C $publishRoot -c "http.https://github.com/.extraheader=$extraHeader" push origin HEAD:master
if ($LASTEXITCODE -ne 0) {
    throw "Failed to publish wiki pages to $wikiUrl."
}

Write-Host "Wiki published to GitHub Wiki successfully."
