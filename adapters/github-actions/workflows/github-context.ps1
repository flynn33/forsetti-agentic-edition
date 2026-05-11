$ErrorActionPreference = "Stop"

function Get-ForsettiRepoRoot {
    $adapterRoot = Split-Path -Parent $PSScriptRoot
    $adaptersRoot = Split-Path -Parent $adapterRoot
    return [System.IO.Path]::GetFullPath((Join-Path $adaptersRoot ".."))
}

function Get-ForsettiGitHubEvent {
    $eventPath = $env:GITHUB_EVENT_PATH
    if ([string]::IsNullOrWhiteSpace($eventPath) -or -not (Test-Path -LiteralPath $eventPath)) {
        return $null
    }

    return Get-Content -LiteralPath $eventPath -Raw | ConvertFrom-Json -Depth 100
}

function Get-ForsettiEventName {
    param([AllowNull()]$Event)

    if (-not [string]::IsNullOrWhiteSpace($env:GITHUB_EVENT_NAME)) {
        return [string]$env:GITHUB_EVENT_NAME
    }
    if ($Event -and $Event.PSObject.Properties.Name -contains "event_name") {
        return [string]$Event.event_name
    }
    return ""
}

function Get-ForsettiEventInput {
    param(
        [AllowNull()]$Event,
        [string]$Name,
        [string]$Default = ""
    )

    if ($Event -and $Event.inputs -and ($Event.inputs.PSObject.Properties.Name -contains $Name)) {
        $value = $Event.inputs.$Name
        if ($null -ne $value) {
            return [string]$value
        }
    }
    return $Default
}

function Get-ForsettiPullRequestBody {
    param([AllowNull()]$Event)

    if ($Event -and $Event.pull_request -and $null -ne $Event.pull_request.body) {
        return [string]$Event.pull_request.body
    }
    if ($null -ne $env:PR_BODY) {
        return [string]$env:PR_BODY
    }
    return ""
}

function Get-ForsettiPullRequestTitle {
    param([AllowNull()]$Event)

    if ($Event -and $Event.pull_request -and $null -ne $Event.pull_request.title) {
        return [string]$Event.pull_request.title
    }
    if ($null -ne $env:PR_TITLE) {
        return [string]$env:PR_TITLE
    }
    return ""
}

function Get-ForsettiPullRequestNumber {
    param([AllowNull()]$Event)

    if ($Event -and $Event.pull_request -and $null -ne $Event.pull_request.number) {
        return [string]$Event.pull_request.number
    }
    if ($null -ne $env:PR_NUMBER) {
        return [string]$env:PR_NUMBER
    }
    return ""
}

function Get-ForsettiPullRequestLabels {
    param([AllowNull()]$Event)

    $labels = New-Object System.Collections.Generic.List[string]
    if ($Event -and $Event.pull_request -and $Event.pull_request.labels) {
        foreach ($label in @($Event.pull_request.labels)) {
            if ($label.name) {
                $labels.Add([string]$label.name)
            }
        }
    }

    if ($labels.Count -eq 0 -and -not [string]::IsNullOrWhiteSpace($env:PR_LABELS)) {
        try {
            $parsed = $env:PR_LABELS | ConvertFrom-Json -Depth 20
            foreach ($label in @($parsed)) {
                if ($label -is [string]) {
                    $labels.Add([string]$label)
                } elseif ($label.name) {
                    $labels.Add([string]$label.name)
                }
            }
        } catch {
            foreach ($label in ($env:PR_LABELS -split ",")) {
                $trimmed = $label.Trim()
                if (-not [string]::IsNullOrWhiteSpace($trimmed)) {
                    $labels.Add($trimmed)
                }
            }
        }
    }

    return @($labels.ToArray() | Select-Object -Unique)
}

function Get-ForsettiChangedFiles {
    param(
        [string]$RepoRoot,
        [AllowNull()]$Event
    )

    $files = New-Object System.Collections.Generic.List[string]
    $baseSha = ""
    $headSha = ""

    if ($Event -and $Event.pull_request) {
        $baseSha = [string]$Event.pull_request.base.sha
        $headSha = [string]$Event.pull_request.head.sha
    } elseif ($Event -and $Event.before -and $Event.after) {
        $baseSha = [string]$Event.before
        $headSha = [string]$Event.after
    }

    if ([string]::IsNullOrWhiteSpace($baseSha) -and -not [string]::IsNullOrWhiteSpace($env:BASE_SHA)) {
        $baseSha = [string]$env:BASE_SHA
    }
    if ([string]::IsNullOrWhiteSpace($headSha) -and -not [string]::IsNullOrWhiteSpace($env:HEAD_SHA)) {
        $headSha = [string]$env:HEAD_SHA
    }
    if ([string]::IsNullOrWhiteSpace($baseSha) -and -not [string]::IsNullOrWhiteSpace($env:BEFORE_SHA)) {
        $baseSha = [string]$env:BEFORE_SHA
    }
    if ([string]::IsNullOrWhiteSpace($headSha) -and -not [string]::IsNullOrWhiteSpace($env:AFTER_SHA)) {
        $headSha = [string]$env:AFTER_SHA
    }

    $diff = @()
    if (-not [string]::IsNullOrWhiteSpace($baseSha) -and
        -not [string]::IsNullOrWhiteSpace($headSha) -and
        $baseSha -notmatch '^0+$') {
        $diff = @(& git -C $RepoRoot diff --name-only $baseSha $headSha)
    } else {
        $mergeBase = (& git -C $RepoRoot merge-base HEAD origin/main 2>$null)
        if (-not [string]::IsNullOrWhiteSpace($mergeBase)) {
            $diff = @(& git -C $RepoRoot diff --name-only $mergeBase HEAD)
        } else {
            $diff = @(& git -C $RepoRoot diff --name-only HEAD~1 HEAD 2>$null)
        }
    }

    foreach ($path in @($diff)) {
        if (-not [string]::IsNullOrWhiteSpace($path)) {
            $files.Add($path.Replace('\', '/'))
        }
    }

    return @($files.ToArray() | Select-Object -Unique)
}

function Write-ForsettiChangedFiles {
    param(
        [string[]]$ChangedFiles
    )

    $baseDir = $env:RUNNER_TEMP
    if ([string]::IsNullOrWhiteSpace($baseDir)) {
        $baseDir = [System.IO.Path]::GetTempPath()
    }

    $outDir = Join-Path $baseDir "forsetti-github-actions"
    if (-not (Test-Path -LiteralPath $outDir)) {
        New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    }

    $outPath = Join-Path $outDir "changed-files.txt"
    $lines = @()
    foreach ($file in @($ChangedFiles)) {
        if (-not [string]::IsNullOrWhiteSpace($file)) {
            $lines += [string]$file
        }
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding -ArgumentList $false
    [System.IO.File]::WriteAllLines($outPath, [string[]]$lines, $utf8NoBom)
    return $outPath
}

function Get-ForsettiMarkdownField {
    param(
        [string]$Text,
        [string]$Label
    )

    $escaped = [regex]::Escape($Label)
    $pattern = "(?im)^\s*(?:-\s*)?\*\*$escaped\*\*:\s*(?<value>.*)$"
    $match = [regex]::Match($Text, $pattern)
    if (-not $match.Success) {
        return ""
    }

    $value = $match.Groups["value"].Value
    $value = [regex]::Replace($value, '<!--.*?-->', '')
    return $value.Trim().Trim([char]0x60)
}

function Get-ForsettiMarkdownSection {
    param(
        [string]$Text,
        [string]$Header
    )

    $escaped = [regex]::Escape($Header)
    $match = [regex]::Match($Text, "(?ims)^#+\s*$escaped\s*\r?\n(?<content>.*?)(?=^#+\s|\z)")
    if ($match.Success) {
        return $match.Groups["content"].Value.Trim()
    }
    return ""
}

function ConvertTo-ForsettiGlobRegex {
    param([string]$Pattern)

    $normalized = $Pattern.Replace('\', '/').Trim()
    while ($normalized.StartsWith("./", [System.StringComparison]::Ordinal)) {
        $normalized = $normalized.Substring(2)
    }
    if ($normalized.EndsWith("/", [System.StringComparison]::Ordinal)) {
        $normalized = $normalized + "**"
    }

    $builder = New-Object System.Text.StringBuilder
    [void]$builder.Append("^")
    for ($i = 0; $i -lt $normalized.Length; $i++) {
        $ch = [string]$normalized[$i]
        if ($ch -eq "*") {
            if (($i + 1) -lt $normalized.Length -and [string]$normalized[$i + 1] -eq "*") {
                [void]$builder.Append(".*")
                $i++
            } else {
                [void]$builder.Append("[^/]*")
            }
        } elseif ($ch -eq "?") {
            [void]$builder.Append("[^/]")
        } else {
            [void]$builder.Append([regex]::Escape($ch))
        }
    }
    [void]$builder.Append("$")
    return $builder.ToString()
}

function Test-ForsettiPathPattern {
    param(
        [string]$Path,
        [string]$Pattern
    )

    if ([string]::IsNullOrWhiteSpace($Path) -or [string]::IsNullOrWhiteSpace($Pattern)) {
        return $false
    }

    $pathValue = $Path.Replace('\', '/').TrimStart('/')
    $patternValue = $Pattern.Replace('\', '/').Trim()
    while ($patternValue.StartsWith("./", [System.StringComparison]::Ordinal)) {
        $patternValue = $patternValue.Substring(2)
    }

    if ($patternValue.IndexOfAny(@([char]'*', [char]'?')) -lt 0 -and -not $patternValue.EndsWith("/", [System.StringComparison]::Ordinal)) {
        return $pathValue.Equals($patternValue.TrimStart('/'), [System.StringComparison]::OrdinalIgnoreCase)
    }

    $regex = ConvertTo-ForsettiGlobRegex -Pattern $patternValue
    return [regex]::IsMatch($pathValue, $regex, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
}

function Get-ForsettiApprovalRank {
    param([AllowNull()][string]$ApprovalClass)

    $value = ""
    if (-not [string]::IsNullOrWhiteSpace($ApprovalClass)) {
        $value = $ApprovalClass.Trim().ToLowerInvariant()
    }

    switch ($value) {
        "standard" { return 1 }
        "sensitive" { return 2 }
        "emergency" { return 2 }
        "release-critical" { return 2 }
        "governance-class" { return 3 }
        default { return 0 }
    }
}

function Test-ForsettiApprovalSufficient {
    param(
        [AllowNull()][string]$Actual,
        [string]$Required
    )

    return ((Get-ForsettiApprovalRank -ApprovalClass $Actual) -ge (Get-ForsettiApprovalRank -ApprovalClass $Required))
}

function Set-ForsettiGitIdentity {
    param([string]$RepoRoot)

    & git -C $RepoRoot config user.name "github-actions[bot]"
    & git -C $RepoRoot config user.email "41898282+github-actions[bot]@users.noreply.github.com"
}

function Save-ForsettiUtf8File {
    param(
        [string]$Path,
        [string]$Content
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory) -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding -ArgumentList $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Invoke-ForsettiCommitIfChanged {
    param(
        [string]$RepoRoot,
        [string[]]$Paths,
        [string]$Message
    )

    & git -C $RepoRoot diff --quiet -- $Paths
    if ($LASTEXITCODE -eq 0) {
        return $false
    }

    Set-ForsettiGitIdentity -RepoRoot $RepoRoot
    & git -C $RepoRoot add -- $Paths
    & git -C $RepoRoot commit -m $Message
    & git -C $RepoRoot push
    return $true
}

function Get-ForsettiAffectedArea {
    param([string[]]$ChangedFiles)

    $areas = New-Object System.Collections.Generic.List[string]
    $rules = [ordered]@{
        "agents" = "^agents/"
        "policies" = "^policies/"
        "schemas" = "^schemas/"
        "contracts" = "^contracts/"
        "standards" = "^standards/"
        "scripts" = "^scripts/"
        "wiki" = "^wiki/"
        "workflows" = "^\.github/"
        "adapters" = "^adapters/"
        "changelog" = "^changelog/"
        "governance docs" = "^(README|AGENTS|.*POLICY|FORSETTI|VISION|CONTRIBUTING|CODE_OF_DELIVERY|LICENSE)\.md$"
    }

    foreach ($name in $rules.Keys) {
        if (@($ChangedFiles | Where-Object { $_ -match $rules[$name] }).Count -gt 0) {
            $areas.Add($name)
        }
    }

    if ($areas.Count -eq 0) {
        return "general"
    }
    return ($areas.ToArray() -join ", ")
}
