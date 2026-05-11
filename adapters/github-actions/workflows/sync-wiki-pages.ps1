$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "github-context.ps1")

function Get-ContentWithoutFirstHeading {
    param(
        [string]$RepoRoot,
        [string]$Path
    )

    $fullPath = Join-Path $RepoRoot $Path
    if (-not (Test-Path -LiteralPath $fullPath)) {
        return "*Source document not found: ``$Path``.*"
    }

    $lines = @(Get-Content -LiteralPath $fullPath)
    if ($lines.Count -gt 0 -and $lines[0] -match '^#\s+') {
        $lines = @($lines | Select-Object -Skip 1)
    }
    while ($lines.Count -gt 0 -and [string]::IsNullOrWhiteSpace($lines[0])) {
        $lines = @($lines | Select-Object -Skip 1)
    }
    return ($lines -join "`n").TrimEnd()
}

function New-WikiHeader {
    param(
        [string]$Title,
        [string]$Canonical,
        [string]$RepoUrl,
        [string]$Version,
        [string]$ShortSha,
        [string]$Today
    )

    return @"
# $Title

[![Version](https://img.shields.io/badge/version-v$Version-blue)]($RepoUrl) [![License](https://img.shields.io/badge/license-see%20repo-lightgrey)]($RepoUrl/blob/main/LICENSE.md)

> **Canonical source**: [``$Canonical``]($RepoUrl/blob/main/$Canonical)
> **Last synced**: v$Version `$ShortSha` - $Today

---
"@
}

function New-WikiFooter {
    return @"

---

<sub>

**Navigation**: [Home](Home) | [Overview](Overview) | [Constitution](Constitution) | [Agent Roles](Agent-Roles) | [Workflow](Workflow) | [Compliance](Compliance) | [Releases](Releases) | [Changelog](Changelog) | [Glossary](Glossary)

</sub>
"@
}

function Save-WikiPage {
    param(
        [string]$RepoRoot,
        [string]$Name,
        [string]$Content
    )

    $wikiRoot = Join-Path $RepoRoot "wiki"
    if (-not (Test-Path -LiteralPath $wikiRoot)) {
        New-Item -ItemType Directory -Path $wikiRoot -Force | Out-Null
    }
    Save-ForsettiUtf8File -Path (Join-Path $wikiRoot $Name) -Content ($Content.TrimEnd() + "`n")
}

$repoRoot = Get-ForsettiRepoRoot
$repo = if ($env:GITHUB_REPOSITORY) { $env:GITHUB_REPOSITORY } else { "flynn33/forsetti-agentic-edition" }
$repoUrl = "https://github.com/$repo"
$versionPath = Join-Path $repoRoot "VERSION"
$version = if (Test-Path -LiteralPath $versionPath) { (Get-Content -LiteralPath $versionPath -Raw).Trim() } else { "unreleased" }
$shortSha = (& git -C $repoRoot rev-parse --short HEAD).Trim()
$today = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd")
$footer = New-WikiFooter

$home = @"
# Forsetti Agentic Edition

[![Version](https://img.shields.io/badge/version-v$version-blue)]($repoUrl) [![License](https://img.shields.io/badge/license-see%20repo-lightgrey)]($repoUrl/blob/main/LICENSE.md)

> Constitutional governance for software delivery

---

## Welcome

This wiki provides navigational documentation for the Forsetti Agentic Edition governance framework. Repository markdown files are canonical. Wiki pages are derived orientation surfaces.

## Quick Navigation

| Page | Description | Source |
|:-----|:------------|:-------|
| [Overview](Overview) | Repository overview, structure, and portable architecture | `README.md` |
| [Constitution](Constitution) | Foundational principles, authority hierarchy, and governance doctrine | `FORSETTI_CONSTITUTION.md` |
| [Agent Roles](Agent-Roles) | Governed roles, authorities, and boundaries | `AGENTS.md`, `agents/*.md` |
| [Workflow](Workflow) | Change control lifecycle, approval classes, and documentation policy | `CHANGE_CONTROL_POLICY.md`, `DOCUMENTATION_POLICY.md` |
| [Compliance](Compliance) | Evidence-based compliance model and blocking violations | `COMPLIANCE_POLICY.md` |
| [Releases](Releases) | Versioning model, release readiness, and impact classification | `RELEASE_POLICY.md` |
| [Changelog](Changelog) | Version history and change records | `changelog/CHANGELOG.md` |
| [Glossary](Glossary) | Key terms and definitions | Various |

## Core Principles

1. **Contract Before Action** - No meaningful work begins without a governing contract.
2. **Scope Is Binding** - Work stays within defined boundaries.
3. **Truthfulness Is Mandatory** - Status claims must match evidence.
4. **Governance Overrides Convenience** - Required process is not optional.
5. **Documentation Is Part of Delivery** - Documentation drift is a compliance issue.
6. **Compliance Must Be Measurable** - Evidence determines compliance.
7. **Release Integrity Is Non-Negotiable** - Release claims require validation.
$footer
"@
Save-WikiPage -RepoRoot $repoRoot -Name "Home.md" -Content $home

$overviewHeader = New-WikiHeader -Title "Forsetti Agentic Edition Overview" -Canonical "README.md" -RepoUrl $repoUrl -Version $version -ShortSha $shortSha -Today $today
$overviewBody = Get-ContentWithoutFirstHeading -RepoRoot $repoRoot -Path "README.md"
Save-WikiPage -RepoRoot $repoRoot -Name "Overview.md" -Content ($overviewHeader + "`n`n" + $overviewBody + $footer)

$constitutionHeader = New-WikiHeader -Title "Constitution" -Canonical "FORSETTI_CONSTITUTION.md" -RepoUrl $repoUrl -Version $version -ShortSha $shortSha -Today $today
Save-WikiPage -RepoRoot $repoRoot -Name "Constitution.md" -Content ($constitutionHeader + "`n`n" + (Get-ContentWithoutFirstHeading -RepoRoot $repoRoot -Path "FORSETTI_CONSTITUTION.md") + $footer)

$agentHeader = New-WikiHeader -Title "Agent Roles" -Canonical "AGENTS.md" -RepoUrl $repoUrl -Version $version -ShortSha $shortSha -Today $today
$agentBody = "## General Agent Instructions`n`n" + (Get-ContentWithoutFirstHeading -RepoRoot $repoRoot -Path "AGENTS.md") + "`n`n---`n`n## Individual Role Definitions`n"
foreach ($agentFile in @(Get-ChildItem -LiteralPath (Join-Path $repoRoot "agents") -Filter "*.md" -File | Sort-Object Name)) {
    $roleName = (Get-Culture).TextInfo.ToTitleCase(($agentFile.BaseName -replace "-", " "))
    $relative = "agents/" + $agentFile.Name
    $agentBody += "`n### $roleName`n`n> Source: [``$relative``]($repoUrl/blob/main/$relative)`n`n"
    $agentBody += (Get-ContentWithoutFirstHeading -RepoRoot $repoRoot -Path $relative) + "`n"
}
Save-WikiPage -RepoRoot $repoRoot -Name "Agent-Roles.md" -Content ($agentHeader + "`n`n" + $agentBody + $footer)

$workflowHeader = New-WikiHeader -Title "Workflow" -Canonical "CHANGE_CONTROL_POLICY.md" -RepoUrl $repoUrl -Version $version -ShortSha $shortSha -Today $today
$workflowBody = "## Change Control Policy`n`n" + (Get-ContentWithoutFirstHeading -RepoRoot $repoRoot -Path "CHANGE_CONTROL_POLICY.md")
$workflowBody += "`n`n---`n`n## Documentation Policy`n`n" + (Get-ContentWithoutFirstHeading -RepoRoot $repoRoot -Path "DOCUMENTATION_POLICY.md")
Save-WikiPage -RepoRoot $repoRoot -Name "Workflow.md" -Content ($workflowHeader + "`n`n" + $workflowBody + $footer)

$complianceHeader = New-WikiHeader -Title "Compliance" -Canonical "COMPLIANCE_POLICY.md" -RepoUrl $repoUrl -Version $version -ShortSha $shortSha -Today $today
Save-WikiPage -RepoRoot $repoRoot -Name "Compliance.md" -Content ($complianceHeader + "`n`n" + (Get-ContentWithoutFirstHeading -RepoRoot $repoRoot -Path "COMPLIANCE_POLICY.md") + $footer)

$releaseHeader = New-WikiHeader -Title "Releases" -Canonical "RELEASE_POLICY.md" -RepoUrl $repoUrl -Version $version -ShortSha $shortSha -Today $today
$releaseBody = (Get-ContentWithoutFirstHeading -RepoRoot $repoRoot -Path "RELEASE_POLICY.md") + "`n`n---`n`n## Current Version`n`n**v$version** - See the [Changelog](Changelog) for details."
Save-WikiPage -RepoRoot $repoRoot -Name "Releases.md" -Content ($releaseHeader + "`n`n" + $releaseBody + $footer)

$changelogHeader = New-WikiHeader -Title "Changelog" -Canonical "changelog/CHANGELOG.md" -RepoUrl $repoUrl -Version $version -ShortSha $shortSha -Today $today
$changelogBody = Get-ContentWithoutFirstHeading -RepoRoot $repoRoot -Path "changelog/CHANGELOG.md"
Save-WikiPage -RepoRoot $repoRoot -Name "Changelog.md" -Content ($changelogHeader + "`n`n" + $changelogBody + $footer)

$glossaryPath = Join-Path $repoRoot "wiki/Glossary.md"
if (-not (Test-Path -LiteralPath $glossaryPath)) {
    $glossaryHeader = New-WikiHeader -Title "Glossary" -Canonical "Various" -RepoUrl $repoUrl -Version $version -ShortSha $shortSha -Today $today
    $glossary = @"
$glossaryHeader

## Key Terms

| Term | Definition |
|:-----|:-----------|
| **Agent** | A governed role operating under Forsetti governance. |
| **Contract** | A task-level governance document defining scope and deliverables. |
| **Canonical Source** | The authoritative repository file for a piece of content. |
| **Change Class** | Classification of a change. |
| **Compliance** | Adherence to governance rules, measured by evidence. |
| **Governance** | The system of rules, policies, and enforcement mechanisms. |
| **SemVer** | Semantic Versioning. |
| **Version Impact** | The effect of a change on version classification. |
$footer
"@
    Save-WikiPage -RepoRoot $repoRoot -Name "Glossary.md" -Content $glossary
}

$sidebar = @"
## Forsetti Agentic Edition

**v$version**

---

- [Home](Home)
- [Overview](Overview)
- [Constitution](Constitution)
- [Agent Roles](Agent-Roles)
- [Workflow](Workflow)
- [Compliance](Compliance)
- [Releases](Releases)
- [Changelog](Changelog)
- [Glossary](Glossary)
"@
Save-WikiPage -RepoRoot $repoRoot -Name "_Sidebar.md" -Content $sidebar

$wikiFooter = @"
---

<sub>

**Forsetti Agentic Edition** v$version | [Repository]($repoUrl) | [Issues]($repoUrl/issues)

Canonical repository sources are authoritative.

</sub>
"@
Save-WikiPage -RepoRoot $repoRoot -Name "_Footer.md" -Content $wikiFooter

Write-Host "Wiki pages prepared."
[void](Invoke-ForsettiCommitIfChanged -RepoRoot $repoRoot -Paths @("wiki") -Message "docs(wiki): sync wiki pages")

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

Copy-Item -Path (Join-Path $repoRoot "wiki/*.md") -Destination $publishRoot -Force
Set-ForsettiGitIdentity -RepoRoot $publishRoot
& git -C $publishRoot add -A
& git -C $publishRoot diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "No changes to publish to GitHub Wiki."
    exit 0
}

& git -C $publishRoot commit -m "docs(wiki): sync from repository"
& git -C $publishRoot -c "http.https://github.com/.extraheader=$extraHeader" push origin HEAD
if ($LASTEXITCODE -ne 0) {
    & git -C $publishRoot -c "http.https://github.com/.extraheader=$extraHeader" push --set-upstream origin master
}

Write-Host "Wiki published to GitHub Wiki successfully."
