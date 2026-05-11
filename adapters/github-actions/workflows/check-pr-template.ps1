$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "github-context.ps1")

$event = Get-ForsettiGitHubEvent
$body = Get-ForsettiPullRequestBody -Event $event
$sections = @(
    "Task Reference",
    "Change Classification",
    "Scope Confirmation",
    "Documentation Impact",
    "Release and Changelog Status",
    "Validation Statement",
    "Known Risks or Issues",
    "Compliance Checklist"
)

if ([string]::IsNullOrWhiteSpace($body)) {
    Write-Error "PR body is empty. All required sections are missing."
    exit 1
}

$missing = New-Object System.Collections.Generic.List[string]
$empty = New-Object System.Collections.Generic.List[string]

foreach ($section in $sections) {
    $escaped = [regex]::Escape($section)
    $match = [regex]::Match($body, "(?ims)^#+\s*$escaped\s*\r?\n(?<content>.*?)(?=^#+\s|\z)")
    if (-not $match.Success) {
        $missing.Add($section)
        continue
    }

    $content = $match.Groups["content"].Value
    $stripped = [regex]::Replace($content, '<!--.*?-->', '')
    $stripped = (($stripped -split "\r?\n") | Where-Object {
        $line = $_.Trim()
        $line -ne "" -and $line -notmatch '^\s*-\s*\[ \]'
    }) -join "`n"

    if ($content -match '-\s*\[') {
        if ($content -notmatch '-\s*\[x\]' -and [string]::IsNullOrWhiteSpace($stripped)) {
            $empty.Add($section)
        }
    } elseif ([string]::IsNullOrWhiteSpace($stripped)) {
        $empty.Add($section)
    }
}

if ($missing.Count -gt 0) {
    Write-Error ("Missing required PR sections: " + ($missing.ToArray() -join ", "))
}
if ($empty.Count -gt 0) {
    Write-Error ("Required PR sections appear empty: " + ($empty.ToArray() -join ", "))
}
if ($missing.Count -gt 0 -or $empty.Count -gt 0) {
    exit 1
}

Write-Host "All required PR sections are present and populated."
