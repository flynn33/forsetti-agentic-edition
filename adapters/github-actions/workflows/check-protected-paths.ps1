$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "github-context.ps1")

$repoRoot = Get-ForsettiRepoRoot
$event = Get-ForsettiGitHubEvent
$changedFiles = Get-ForsettiChangedFiles -RepoRoot $repoRoot -Event $event
$changedFilesPath = Write-ForsettiChangedFiles -ChangedFiles $changedFiles
$labels = Get-ForsettiPullRequestLabels -Event $event

Write-Host "Changed files written to $changedFilesPath"
foreach ($file in $changedFiles) {
    Write-Host "Changed: $file"
}

$policyPath = Join-Path $repoRoot "core/policies/repo-boundaries.json"
$policy = Get-Content -LiteralPath $policyPath -Raw | ConvertFrom-Json
$approvalLabels = @{}
foreach ($entry in @($policy.approval_labels.hierarchy)) {
    $approvalLabels[[string]$entry.label] = [string]$entry.approval_class
}
foreach ($entry in @($policy.approval_labels.non_hierarchical)) {
    $approvalLabels[[string]$entry.label] = [string]$entry.approval_class
}

$actualApproval = ""
foreach ($label in $labels) {
    if ($approvalLabels.ContainsKey($label)) {
        $candidate = $approvalLabels[$label]
        if ((Get-ForsettiApprovalRank -ApprovalClass $candidate) -gt (Get-ForsettiApprovalRank -ApprovalClass $actualApproval)) {
            $actualApproval = $candidate
        }
    }
}

$failures = New-Object System.Collections.Generic.List[string]
foreach ($file in $changedFiles) {
    $required = $null
    foreach ($mapping in @($policy.approval_required_paths.mappings)) {
        if (Test-ForsettiPathPattern -Path $file -Pattern ([string]$mapping.path_pattern)) {
            if ($null -eq $required -or
                (Get-ForsettiApprovalRank -ApprovalClass $mapping.minimum_approval_class) -gt
                (Get-ForsettiApprovalRank -ApprovalClass $required.minimum_approval_class)) {
                $required = $mapping
            }
        }
    }

    if ($null -eq $required) {
        continue
    }

    Write-Host ("Protected path: {0}; required={1}; actual={2}" -f $file, $required.minimum_approval_class, $actualApproval)
    if (-not (Test-ForsettiApprovalSufficient -Actual $actualApproval -Required ([string]$required.minimum_approval_class))) {
        $failures.Add(("{0} requires {1}; labels={2}" -f $file, $required.minimum_approval_class, ($labels -join ",")))
    }
}

if ($failures.Count -gt 0) {
    foreach ($failure in $failures) {
        Write-Error $failure
    }
    exit 1
}

Write-Host "All protected path approvals verified. Check passed."
