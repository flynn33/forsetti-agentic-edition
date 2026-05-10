# Forsetti Agentic Edition local validator

[CmdletBinding()]
param(
    [string]$RepoRoot = (Get-Location).Path,
    [ValidateSet("all", "files", "structure", "json", "policies", "policy", "docs", "schemas", "schema", "scripts", "contract", "contracts")]
    [string]$Mode = "all",
    [switch]$Strict,
    [string]$OutputJson,
    [string]$ContractPath,
    [Alias("ChangedFiles")]
    [string[]]$ChangedFile,
    [string]$ChangedFilesPath
)

$ErrorActionPreference = "Stop"
$script:Findings = New-Object System.Collections.Generic.List[object]
$script:StartTime = Get-Date

function Resolve-ForsettiRepoRoot {
    param([string]$Path)

    $resolved = [System.IO.Path]::GetFullPath($Path)
    if (-not (Test-Path -LiteralPath (Join-Path $resolved "FORSETTI_CONSTITUTION.md"))) {
        throw "Unable to resolve Forsetti repository root from path: $Path"
    }
    return $resolved
}

function Get-RepoPath {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    $fullPath = $Path
    if (-not [System.IO.Path]::IsPathRooted($Path)) {
        $fullPath = Join-Path $script:RepoRoot $Path
    }

    try {
        $fullPath = [System.IO.Path]::GetFullPath($fullPath)
        $root = $script:RepoRoot.TrimEnd('\', '/')
        if ($fullPath.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $fullPath.Substring($root.Length).TrimStart('\', '/').Replace('\', '/')
        }
    } catch {
        return $Path.Replace('\', '/')
    }

    return $Path.Replace('\', '/')
}

function Add-Finding {
    param(
        [string]$FindingId,
        [ValidateSet("info", "warning", "error")]
        [string]$Severity,
        [ValidateSet("pass", "warn", "fail")]
        [string]$Status,
        [string]$Category,
        [AllowNull()]$Path,
        [string]$Message,
        [AllowNull()]$Evidence,
        [AllowNull()]$RemediationHint,
        [AllowNull()]$RuleId
    )

    $pathValue = if ([string]::IsNullOrWhiteSpace([string]$Path)) { $null } else { [string]$Path }
    $evidenceValue = if ([string]::IsNullOrWhiteSpace([string]$Evidence)) { $null } else { [string]$Evidence }
    $remediationHintValue = if ([string]::IsNullOrWhiteSpace([string]$RemediationHint)) { $null } else { [string]$RemediationHint }
    $ruleIdValue = if ([string]::IsNullOrWhiteSpace([string]$RuleId)) { $null } else { [string]$RuleId }

    $script:Findings.Add([pscustomobject][ordered]@{
        finding_id       = $FindingId
        rule_id          = $ruleIdValue
        severity         = $Severity
        status           = $Status
        category         = $Category
        path             = $pathValue
        message          = $Message
        evidence         = $evidenceValue
        remediation_hint = $remediationHintValue
    })
}

function Add-ExceptionFinding {
    param(
        [string]$Category,
        [string]$Message
    )

    Add-Finding `
        -FindingId ("FFAE-" + $Category.ToUpperInvariant() + "-EXCEPTION") `
        -Severity "error" `
        -Status "fail" `
        -Category $Category `
        -Path $null `
        -Message $Message `
        -Evidence $null `
        -RemediationHint "Fix the validator check or the repository data that caused the exception." `
        -RuleId "FAE-C011"
}

function Get-FileSha256 {
    param([string]$Path)

    $stream = [System.IO.File]::OpenRead($Path)
    try {
        $sha = [System.Security.Cryptography.SHA256]::Create()
        try {
            $hashBytes = $sha.ComputeHash($stream)
            return ([System.BitConverter]::ToString($hashBytes) -replace "-", "")
        } finally {
            $sha.Dispose()
        }
    } finally {
        $stream.Dispose()
    }
}

function Test-RequiredPaths {
    $required = @(
        ".github/CODEOWNERS",
        ".github/ISSUE_TEMPLATE/agent_task.md",
        ".github/ISSUE_TEMPLATE/bug_report.md",
        ".github/ISSUE_TEMPLATE/feature_request.md",
        ".github/ISSUE_TEMPLATE/governance_change.md",
        ".github/labels.json",
        ".github/pull_request_template.md",
        ".github/workflows/changelog-validation.yml",
        ".github/workflows/docs-sync-agent.yml",
        ".github/workflows/policy-check.yml",
        ".github/workflows/protected-path-check.yml",
        ".github/workflows/version-guard.yml",
        "AGENTS.md",
        "CHANGE_CONTROL_POLICY.md",
        "CODE_OF_DELIVERY.md",
        "COMPLIANCE_POLICY.md",
        "CONTRIBUTING.md",
        "DOCUMENTATION_POLICY.md",
        "FORSETTI_CONSTITUTION.md",
        "RELEASE_POLICY.md",
        "README.md",
        "VISION.md",
        "agents/architect.md",
        "agents/builder.md",
        "agents/docs-manager.md",
        "agents/release-manager.md",
        "agents/validator.md",
        "changelog/CHANGELOG.md",
        "changelog/release-notes-template.md",
        "contracts/bugfix-contract-template.md",
        "contracts/governance-change-template.md",
        "contracts/release-contract-template.md",
        "contracts/task-contract-template.md",
        "core/README.md",
        "core/policies/compliance-rules.json",
        "core/policies/repo-boundaries.json",
        "core/policies/docs-sync-rules.json",
        "core/policies/versioning-rules.json",
        "core/policies/changelog-rules.json",
        "core/contracts/task-contract-template.json",
        "core/schemas/task-contract.schema.json",
        "core/schemas/validator-result.schema.json",
        "core/validator/contract_rules.ps1",
        "core/validator/forsetti_validate.ps1",
        "core/validator/README.md",
        "policies/agent-roles.json",
        "policies/compliance-rules.json",
        "policies/repo-boundaries.json",
        "policies/docs-sync-rules.json",
        "policies/versioning-rules.json",
        "policies/changelog-rules.json",
        "policies/labels.json",
        "schemas/compliance-report.schema.json",
        "schemas/release-entry.schema.json",
        "schemas/task-contract.schema.json",
        "scripts/validate-repo.ps1",
        "scripts/validate-repo.sh",
        "standards/changelog-standard.md",
        "standards/documentation-standard.md",
        "standards/naming-standard.md",
        "standards/review-standard.md",
        "standards/versioning-standard.md",
        "wiki/Agent-Roles.md",
        "wiki/Compliance.md",
        "wiki/Constitution.md",
        "wiki/Documentation.md",
        "wiki/Glossary.md",
        "wiki/Home.md",
        "wiki/Overview.md",
        "wiki/Releases.md",
        "wiki/Workflow.md"
    )

    $missing = @()
    foreach ($path in $required) {
        if (-not (Test-Path -LiteralPath (Join-Path $script:RepoRoot $path))) {
            $missing += $path
            Add-Finding `
                -FindingId "FFAE-STRUCTURE-001" `
                -Severity "error" `
                -Status "fail" `
                -Category "structure" `
                -Path $path `
                -Message "Required repository path is missing." `
                -Evidence $path `
                -RemediationHint "Restore or create the required path." `
                -RuleId "FAE-C011"
        }
    }

    if ($missing.Count -eq 0) {
        Add-Finding `
            -FindingId "FFAE-STRUCTURE-001" `
            -Severity "info" `
            -Status "pass" `
            -Category "structure" `
            -Path $null `
            -Message "Required Phase 03 repository paths are present." `
            -Evidence ("Checked " + $required.Count + " paths.") `
            -RemediationHint $null `
            -RuleId $null
    }
}

function Get-RequiredRepositoryFiles {
    return @(
        ".github/CODEOWNERS",
        ".github/ISSUE_TEMPLATE/agent_task.md",
        ".github/ISSUE_TEMPLATE/bug_report.md",
        ".github/ISSUE_TEMPLATE/feature_request.md",
        ".github/ISSUE_TEMPLATE/governance_change.md",
        ".github/labels.json",
        ".github/pull_request_template.md",
        ".github/workflows/changelog-validation.yml",
        ".github/workflows/docs-sync-agent.yml",
        ".github/workflows/policy-check.yml",
        ".github/workflows/protected-path-check.yml",
        ".github/workflows/version-guard.yml",
        "AGENTS.md",
        "CHANGE_CONTROL_POLICY.md",
        "CODE_OF_DELIVERY.md",
        "COMPLIANCE_POLICY.md",
        "CONTRIBUTING.md",
        "DOCUMENTATION_POLICY.md",
        "FORSETTI_CONSTITUTION.md",
        "README.md",
        "RELEASE_POLICY.md",
        "VISION.md",
        "agents/architect.md",
        "agents/builder.md",
        "agents/docs-manager.md",
        "agents/release-manager.md",
        "agents/validator.md",
        "changelog/CHANGELOG.md",
        "changelog/release-notes-template.md",
        "contracts/bugfix-contract-template.md",
        "contracts/governance-change-template.md",
        "contracts/release-contract-template.md",
        "contracts/task-contract-template.md",
        "core/README.md",
        "core/policies/changelog-rules.json",
        "core/policies/compliance-rules.json",
        "core/policies/docs-sync-rules.json",
        "core/policies/repo-boundaries.json",
        "core/policies/versioning-rules.json",
        "core/contracts/task-contract-template.json",
        "core/schemas/task-contract.schema.json",
        "core/schemas/validator-result.schema.json",
        "core/validator/contract_rules.ps1",
        "core/validator/README.md",
        "core/validator/forsetti_validate.ps1",
        "policies/agent-roles.json",
        "policies/changelog-rules.json",
        "policies/compliance-rules.json",
        "policies/docs-sync-rules.json",
        "policies/labels.json",
        "policies/repo-boundaries.json",
        "policies/versioning-rules.json",
        "schemas/compliance-report.schema.json",
        "schemas/release-entry.schema.json",
        "schemas/task-contract.schema.json",
        "scripts/validate-repo.ps1",
        "scripts/validate-repo.sh",
        "standards/changelog-standard.md",
        "standards/documentation-standard.md",
        "standards/naming-standard.md",
        "standards/review-standard.md",
        "standards/versioning-standard.md",
        "wiki/Agent-Roles.md",
        "wiki/Compliance.md",
        "wiki/Constitution.md",
        "wiki/Documentation.md",
        "wiki/Glossary.md",
        "wiki/Home.md",
        "wiki/Overview.md",
        "wiki/Releases.md",
        "wiki/Workflow.md"
    )
}

function Test-NonTrivialRequiredFiles {
    $warnings = 0
    foreach ($path in (Get-RequiredRepositoryFiles)) {
        $fullPath = Join-Path $script:RepoRoot $path
        if (-not (Test-Path -LiteralPath $fullPath)) {
            continue
        }
        $lineCount = @(Get-Content -LiteralPath $fullPath).Count
        if ($lineCount -lt 5) {
            $warnings++
            Add-Finding `
                -FindingId "FFAE-CONTENT-001" `
                -Severity "warning" `
                -Status "warn" `
                -Category "structure" `
                -Path $path `
                -Message "Required file appears to be a stub." `
                -Evidence ($lineCount.ToString() + " lines.") `
                -RemediationHint "Add substantive content or remove the file from required-path policy." `
                -RuleId "FAE-C011"
        }
    }

    if ($warnings -eq 0) {
        Add-Finding `
            -FindingId "FFAE-CONTENT-001" `
            -Severity "info" `
            -Status "pass" `
            -Category "structure" `
            -Path $null `
            -Message "Required files have substantive content." `
            -Evidence ("Checked " + (Get-RequiredRepositoryFiles).Count + " required files.") `
            -RemediationHint $null `
            -RuleId $null
    }
}

function Test-YamlWorkflowFiles {
    $workflowRoot = Join-Path $script:RepoRoot ".github/workflows"
    if (-not (Test-Path -LiteralPath $workflowRoot)) {
        Add-Finding `
            -FindingId "FFAE-YAML-001" `
            -Severity "error" `
            -Status "fail" `
            -Category "structure" `
            -Path ".github/workflows" `
            -Message "Workflow directory is missing." `
            -Evidence ".github/workflows" `
            -RemediationHint "Restore the workflow directory or update required-path policy." `
            -RuleId "FAE-C011"
        return
    }

    $errors = 0
    $yamlFiles = Get-ChildItem -LiteralPath $workflowRoot -Filter "*.yml" -File
    foreach ($file in $yamlFiles) {
        $content = Get-Content -LiteralPath $file.FullName -Raw
        if ([string]::IsNullOrWhiteSpace($content) -or $content.Length -lt 10) {
            $errors++
            Add-Finding `
                -FindingId "FFAE-YAML-001" `
                -Severity "error" `
                -Status "fail" `
                -Category "structure" `
                -Path (Get-RepoPath $file.FullName) `
                -Message "YAML workflow file appears empty or too small." `
                -Evidence ($content.Length.ToString() + " characters.") `
                -RemediationHint "Restore substantive workflow content." `
                -RuleId "FAE-C011"
        }
    }

    if ($errors -eq 0) {
        Add-Finding `
            -FindingId "FFAE-YAML-001" `
            -Severity "info" `
            -Status "pass" `
            -Category "structure" `
            -Path ".github/workflows" `
            -Message "YAML workflow files are present and non-empty." `
            -Evidence ("Checked " + $yamlFiles.Count + " workflow files.") `
            -RemediationHint $null `
            -RuleId $null
    }
}

function Test-LabelMirrors {
    $policyLabels = Join-Path $script:RepoRoot "policies/labels.json"
    $githubLabels = Join-Path $script:RepoRoot ".github/labels.json"
    if (-not (Test-Path -LiteralPath $policyLabels) -or -not (Test-Path -LiteralPath $githubLabels)) {
        Add-Finding `
            -FindingId "FFAE-LABELS-001" `
            -Severity "error" `
            -Status "fail" `
            -Category "policy" `
            -Path "policies/labels.json" `
            -Message "One or both label registry files are missing." `
            -Evidence "policies/labels.json <-> .github/labels.json" `
            -RemediationHint "Restore both label registry files." `
            -RuleId "FAE-C011"
        return
    }

    $policyHash = Get-FileSha256 -Path $policyLabels
    $githubHash = Get-FileSha256 -Path $githubLabels
    if ($policyHash -ne $githubHash) {
        Add-Finding `
            -FindingId "FFAE-LABELS-001" `
            -Severity "warning" `
            -Status "warn" `
            -Category "policy" `
            -Path "policies/labels.json" `
            -Message "Label registry files differ." `
            -Evidence ("policies/labels.json=" + $policyHash + "; .github/labels.json=" + $githubHash) `
            -RemediationHint "Synchronize label registry mirrors." `
            -RuleId "FAE-C011"
    } else {
        Add-Finding `
            -FindingId "FFAE-LABELS-001" `
            -Severity "info" `
            -Status "pass" `
            -Category "policy" `
            -Path "policies/labels.json" `
            -Message "Label registry mirrors are byte-identical." `
            -Evidence ("SHA-256 " + $policyHash) `
            -RemediationHint $null `
            -RuleId $null
    }
}

function Test-JsonFiles {
    $jsonFiles = @(Get-RepositoryJsonFiles)

    $jsonErrors = 0
    foreach ($file in $jsonFiles) {
        try {
            $null = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
        } catch {
            $jsonErrors++
            Add-Finding `
                -FindingId "FFAE-JSON-001" `
                -Severity "error" `
                -Status "fail" `
                -Category "json" `
                -Path (Get-RepoPath $file.FullName) `
                -Message "Invalid JSON file." `
                -Evidence $_.Exception.Message `
                -RemediationHint "Fix the JSON syntax so the file parses with ConvertFrom-Json." `
                -RuleId "FAE-C011"
        }
    }

    if ($jsonErrors -eq 0) {
        Add-Finding `
            -FindingId "FFAE-JSON-001" `
            -Severity "info" `
            -Status "pass" `
            -Category "json" `
            -Path $null `
            -Message "All repository JSON files parse cleanly." `
            -Evidence ("Parsed " + $jsonFiles.Count + " JSON files.") `
            -RemediationHint $null `
            -RuleId $null
    }
}

function Get-RepositoryJsonFiles {
    $excludedDirectoryNames = @(".git", "node_modules")
    $pendingDirectories = New-Object System.Collections.Generic.Stack[string]
    $pendingDirectories.Push($script:RepoRoot)

    while ($pendingDirectories.Count -gt 0) {
        $currentDirectory = $pendingDirectories.Pop()

        foreach ($file in Get-ChildItem -LiteralPath $currentDirectory -Filter "*.json" -File -ErrorAction SilentlyContinue) {
            $file
        }

        foreach ($directory in Get-ChildItem -LiteralPath $currentDirectory -Directory -ErrorAction SilentlyContinue) {
            if ($excludedDirectoryNames -notcontains $directory.Name) {
                $pendingDirectories.Push($directory.FullName)
            }
        }
    }
}

function Get-JsonObject {
    param([string]$Path)

    return Get-Content -LiteralPath (Join-Path $script:RepoRoot $Path) -Raw | ConvertFrom-Json
}

function Assert-ByteIdentical {
    param(
        [string]$Left,
        [string]$Right,
        [string]$FindingId,
        [string]$Message
    )

    $leftPath = Join-Path $script:RepoRoot $Left
    $rightPath = Join-Path $script:RepoRoot $Right
    if (-not (Test-Path -LiteralPath $leftPath) -or -not (Test-Path -LiteralPath $rightPath)) {
        Add-Finding `
            -FindingId $FindingId `
            -Severity "error" `
            -Status "fail" `
            -Category "policy" `
            -Path $Left `
            -Message "Cannot compare mirror files because one or both paths are missing." `
            -Evidence ($Left + " <-> " + $Right) `
            -RemediationHint "Restore both mirror paths." `
            -RuleId "FAE-C011"
        return
    }

    $leftHash = Get-FileSha256 -Path $leftPath
    $rightHash = Get-FileSha256 -Path $rightPath
    if ($leftHash -ne $rightHash) {
        Add-Finding `
            -FindingId $FindingId `
            -Severity "error" `
            -Status "fail" `
            -Category "policy" `
            -Path $Left `
            -Message $Message `
            -Evidence ($Left + "=" + $leftHash + "; " + $Right + "=" + $rightHash) `
            -RemediationHint "Update the root mirror or canonical file so the files are byte-identical." `
            -RuleId "FAE-C011"
    } else {
        Add-Finding `
            -FindingId $FindingId `
            -Severity "info" `
            -Status "pass" `
            -Category "policy" `
            -Path $Left `
            -Message $Message `
            -Evidence ("SHA-256 " + $leftHash) `
            -RemediationHint $null `
            -RuleId $null
    }
}

function Test-PolicyRegistries {
    Assert-ByteIdentical `
        -Left "core/policies/compliance-rules.json" `
        -Right "policies/compliance-rules.json" `
        -FindingId "FFAE-POLICY-001" `
        -Message "Core and root compliance registries are byte-identical."

    Assert-ByteIdentical `
        -Left "core/policies/repo-boundaries.json" `
        -Right "policies/repo-boundaries.json" `
        -FindingId "FFAE-POLICY-002" `
        -Message "Core and root repository boundary registries are byte-identical."

    Assert-ByteIdentical `
        -Left "core/policies/docs-sync-rules.json" `
        -Right "policies/docs-sync-rules.json" `
        -FindingId "FFAE-POLICY-003" `
        -Message "Core and root documentation sync registries are byte-identical."

    Assert-ByteIdentical `
        -Left "core/policies/versioning-rules.json" `
        -Right "policies/versioning-rules.json" `
        -FindingId "FFAE-POLICY-006" `
        -Message "Core and root versioning registries are byte-identical."

    Assert-ByteIdentical `
        -Left "core/policies/changelog-rules.json" `
        -Right "policies/changelog-rules.json" `
        -FindingId "FFAE-POLICY-007" `
        -Message "Core and root changelog registries are byte-identical."

    Test-LabelMirrors

    $registry = Get-JsonObject "core/policies/compliance-rules.json"
    $ids = @($registry.rules | ForEach-Object { $_.rule_id })
    $expected = 1..12 | ForEach-Object { "FAE-C{0:D3}" -f $_ }
    $duplicates = @($ids | Group-Object | Where-Object { $_.Count -gt 1 })
    $missing = @($expected | Where-Object { $ids -notcontains $_ })
    $extra = @($ids | Where-Object { $expected -notcontains $_ })

    if ($duplicates.Count -gt 0 -or $missing.Count -gt 0 -or $extra.Count -gt 0) {
        Add-Finding `
            -FindingId "FFAE-POLICY-004" `
            -Severity "error" `
            -Status "fail" `
            -Category "policy" `
            -Path "core/policies/compliance-rules.json" `
            -Message "Canonical compliance IDs must be exactly FAE-C001 through FAE-C012 with no duplicates." `
            -Evidence ("ids=" + ($ids -join ",") + "; missing=" + ($missing -join ",") + "; extra=" + ($extra -join ",")) `
            -RemediationHint "Correct the canonical compliance registry rule IDs." `
            -RuleId "FAE-C011"
    } else {
        Add-Finding `
            -FindingId "FFAE-POLICY-004" `
            -Severity "info" `
            -Status "pass" `
            -Category "policy" `
            -Path "core/policies/compliance-rules.json" `
            -Message "Canonical compliance IDs are complete and ordered." `
            -Evidence ($ids -join ", ") `
            -RemediationHint $null `
            -RuleId $null
    }

    $stalePattern = '(?<!FORSETTI_)CONSTITUTION\.md|docs/wiki|RELEASE_NOTES\.md|(?<!changelog/)CHANGELOG\.md'
    $policyFiles = Get-ChildItem -LiteralPath (Join-Path $script:RepoRoot "policies") -Filter "*.json" -File
    $corePolicyFiles = Get-ChildItem -LiteralPath (Join-Path $script:RepoRoot "core/policies") -Filter "*.json" -File
    $staleHits = @()
    foreach ($file in @($policyFiles + $corePolicyFiles)) {
        $content = Get-Content -LiteralPath $file.FullName -Raw
        if ($content -cmatch $stalePattern) {
            $staleHits += (Get-RepoPath $file.FullName)
        }
    }

    if ($staleHits.Count -gt 0) {
        Add-Finding `
            -FindingId "FFAE-POLICY-005" `
            -Severity "error" `
            -Status "fail" `
            -Category "policy" `
            -Path $null `
            -Message "Policy registries contain stale repository paths." `
            -Evidence ($staleHits -join ", ") `
            -RemediationHint "Replace stale paths with current repository paths." `
            -RuleId "FAE-C011"
    } else {
        Add-Finding `
            -FindingId "FFAE-POLICY-005" `
            -Severity "info" `
            -Status "pass" `
            -Category "policy" `
            -Path $null `
            -Message "Policy registries do not contain known stale repository paths." `
            -Evidence "Scanned policies/*.json and core/policies/*.json." `
            -RemediationHint $null `
            -RuleId $null
    }
}

function Test-DocsSync {
    $sync = Get-JsonObject "core/policies/docs-sync-rules.json"
    $missing = 0
    foreach ($pair in $sync.sync_pairs) {
        $canonicalPath = [string]$pair.canonical
        $derivedPath = [string]$pair.derived
        if (-not (Test-Path -LiteralPath (Join-Path $script:RepoRoot $canonicalPath))) {
            $missing++
            Add-Finding `
                -FindingId "FFAE-DOCS-001" `
                -Severity "error" `
                -Status "fail" `
                -Category "docs" `
                -Path $canonicalPath `
                -Message "Documentation sync canonical source is missing." `
                -Evidence ($canonicalPath + " -> " + $derivedPath) `
                -RemediationHint "Update docs-sync rules or restore the canonical source." `
                -RuleId "FAE-C008"
        }
        if (-not (Test-Path -LiteralPath (Join-Path $script:RepoRoot $derivedPath))) {
            $missing++
            Add-Finding `
                -FindingId "FFAE-DOCS-002" `
                -Severity "error" `
                -Status "fail" `
                -Category "docs" `
                -Path $derivedPath `
                -Message "Documentation sync derived surface is missing." `
                -Evidence ($canonicalPath + " -> " + $derivedPath) `
                -RemediationHint "Update or restore the derived documentation surface." `
                -RuleId "FAE-C008"
        }
    }

    if ($missing -eq 0) {
        Add-Finding `
            -FindingId "FFAE-DOCS-001" `
            -Severity "info" `
            -Status "pass" `
            -Category "docs" `
            -Path "core/policies/docs-sync-rules.json" `
            -Message "Documentation sync pairs reference existing repository paths." `
            -Evidence ("Checked " + @($sync.sync_pairs).Count + " sync pairs.") `
            -RemediationHint $null `
            -RuleId $null
    }
}

function Test-Schemas {
    $schemaPaths = @(
        "schemas/task-contract.schema.json",
        "core/schemas/task-contract.schema.json",
        "schemas/release-entry.schema.json",
        "schemas/compliance-report.schema.json",
        "core/schemas/validator-result.schema.json"
    )

    $schemaErrors = 0
    foreach ($schema in $schemaPaths) {
        $path = Join-Path $script:RepoRoot $schema
        if (-not (Test-Path -LiteralPath $path)) {
            $schemaErrors++
            Add-Finding `
                -FindingId "FFAE-SCHEMA-001" `
                -Severity "error" `
                -Status "fail" `
                -Category "schema" `
                -Path $schema `
                -Message "Schema file is missing." `
                -Evidence $schema `
                -RemediationHint "Restore or create the schema file." `
                -RuleId "FAE-C011"
            continue
        }

        $schemaObj = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
        if (-not $schemaObj.properties) {
            $schemaErrors++
            Add-Finding `
                -FindingId "FFAE-SCHEMA-002" `
                -Severity "error" `
                -Status "fail" `
                -Category "schema" `
                -Path $schema `
                -Message "Schema has no properties object." `
                -Evidence $schema `
                -RemediationHint "Define the schema properties object." `
                -RuleId "FAE-C011"
        }
    }

    if ($schemaErrors -eq 0) {
        Add-Finding `
            -FindingId "FFAE-SCHEMA-001" `
            -Severity "info" `
            -Status "pass" `
            -Category "schema" `
            -Path $null `
            -Message "Required schemas exist and define properties." `
            -Evidence ("Checked " + $schemaPaths.Count + " schemas.") `
            -RemediationHint $null `
            -RuleId $null
    }
}

function Test-ScriptWrappers {
    $wrappers = @(
        "scripts/validate-repo.ps1",
        "scripts/validate-repo.sh"
    )

    $errors = 0
    foreach ($wrapper in $wrappers) {
        $path = Join-Path $script:RepoRoot $wrapper
        if (-not (Test-Path -LiteralPath $path)) {
            $errors++
            Add-Finding `
                -FindingId "FFAE-SCRIPT-001" `
                -Severity "error" `
                -Status "fail" `
                -Category "scripts" `
                -Path $wrapper `
                -Message "Validation wrapper is missing." `
                -Evidence $wrapper `
                -RemediationHint "Restore the wrapper script." `
                -RuleId "FAE-C011"
            continue
        }

        $content = Get-Content -LiteralPath $path -Raw
        if ($content -notmatch 'core[\\/]+validator[\\/]+forsetti_validate\.ps1') {
            $errors++
            Add-Finding `
                -FindingId "FFAE-SCRIPT-002" `
                -Severity "error" `
                -Status "fail" `
                -Category "scripts" `
                -Path $wrapper `
                -Message "Validation wrapper does not delegate to the core validator." `
                -Evidence "Missing core/validator/forsetti_validate.ps1 reference." `
                -RemediationHint "Delegate wrapper execution to the core validator." `
                -RuleId "FAE-C011"
        }
    }

    if ($errors -eq 0) {
        Add-Finding `
            -FindingId "FFAE-SCRIPT-001" `
            -Severity "info" `
            -Status "pass" `
            -Category "scripts" `
            -Path $null `
            -Message "Validation wrappers delegate to the core validator." `
            -Evidence ($wrappers -join ", ") `
            -RemediationHint $null `
            -RuleId $null
    }
}

function Invoke-SelectedChecks {
    $checks = @()
    if ($Mode -eq "all" -or $Mode -eq "structure" -or $Mode -eq "files") {
        $checks += @{ Name = "structure"; Script = { Test-RequiredPaths; Test-NonTrivialRequiredFiles; Test-YamlWorkflowFiles } }
    }
    if ($Mode -eq "all" -or $Mode -eq "json") { $checks += @{ Name = "json"; Script = { Test-JsonFiles } } }
    if ($Mode -eq "all" -or $Mode -eq "policy" -or $Mode -eq "policies") { $checks += @{ Name = "policy"; Script = { Test-PolicyRegistries } } }
    if ($Mode -eq "all" -or $Mode -eq "docs") { $checks += @{ Name = "docs"; Script = { Test-DocsSync } } }
    if ($Mode -eq "all" -or $Mode -eq "schema" -or $Mode -eq "schemas") { $checks += @{ Name = "schema"; Script = { Test-Schemas } } }
    if ($Mode -eq "all" -or $Mode -eq "scripts") { $checks += @{ Name = "scripts"; Script = { Test-ScriptWrappers } } }
    if ($Mode -eq "all" -or $Mode -eq "contract" -or $Mode -eq "contracts") {
        $checks += @{
            Name = "contract"
            Script = {
                Test-ContractInfrastructure -RepoRoot $script:RepoRoot
                Test-TaskContractRules `
                    -RepoRoot $script:RepoRoot `
                    -ContractPath $ContractPath `
                    -ChangedFile $ChangedFile `
                    -ChangedFilesPath $ChangedFilesPath `
                    -PendingOutputPath $OutputJson `
                    -RequireContract:($Mode -eq "contract" -or $Mode -eq "contracts")
            }
        }
    }

    foreach ($check in $checks) {
        try {
            & $check.Script
        } catch {
            Add-ExceptionFinding -Category $check.Name -Message $_.Exception.Message
        }
    }
}

function New-ValidatorResult {
    $duration = [int]((Get-Date) - $script:StartTime).TotalMilliseconds
    $findingsArray = @($script:Findings.ToArray())

    $errorCount = @($findingsArray | Where-Object { $_.status -eq "fail" -or $_.severity -eq "error" }).Count
    $warningCount = @($findingsArray | Where-Object { $_.status -eq "warn" -or $_.severity -eq "warning" }).Count
    $passCount = @($findingsArray | Where-Object { $_.status -eq "pass" }).Count

    $status = "pass"
    if ($errorCount -gt 0) {
        $status = "block"
    } elseif ($Strict -and $warningCount -gt 0) {
        $status = "request_changes"
    }

    return [pscustomobject][ordered]@{
        schema_version = "1.0"
        validator      = [pscustomobject][ordered]@{
            name    = "forsetti_validate"
            version = "0.2.0"
        }
        invocation     = [pscustomobject][ordered]@{
            repo_root           = $script:RepoRoot
            mode                = $Mode
            strict              = [bool]$Strict
            contract_path       = if ([string]::IsNullOrWhiteSpace($ContractPath)) { $null } else { Get-RepoPath $ContractPath }
            changed_files_path  = if ([string]::IsNullOrWhiteSpace($ChangedFilesPath)) { $null } else { Get-RepoPath $ChangedFilesPath }
            changed_files_count = [int]$script:ContractChangedFilesCount
            timestamp_utc       = (Get-Date).ToUniversalTime().ToString("o")
            engine              = $PSVersionTable.PSEdition
            ps_version          = $PSVersionTable.PSVersion.ToString()
        }
        summary        = [pscustomobject][ordered]@{
            status      = $status
            total       = $script:Findings.Count
            passed      = $passCount
            warnings    = $warningCount
            errors      = $errorCount
            duration_ms = $duration
        }
        findings       = $findingsArray
    }
}

function Write-HumanResult {
    param([object]$Result)

    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "Forsetti Local Validator" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ("Repository: " + $Result.invocation.repo_root)
    Write-Host ("Mode:       " + $Result.invocation.mode)
    Write-Host ("Strict:     " + $Result.invocation.strict)
    Write-Host ""

    foreach ($finding in $Result.findings) {
        $color = "Green"
        if ($finding.status -eq "warn") { $color = "DarkYellow" }
        if ($finding.status -eq "fail") { $color = "Red" }
        $pathText = ""
        if ($finding.path) {
            $pathText = " [" + $finding.path + "]"
        }
        Write-Host ("  " + $finding.status.ToUpperInvariant() + " " + $finding.finding_id + $pathText + " - " + $finding.message) -ForegroundColor $color
    }

    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ("Status:   " + $Result.summary.status) -ForegroundColor $(if ($Result.summary.status -eq "pass") { "Green" } elseif ($Result.summary.status -eq "request_changes") { "DarkYellow" } else { "Red" })
    Write-Host ("Passed:   " + $Result.summary.passed)
    Write-Host ("Warnings: " + $Result.summary.warnings)
    Write-Host ("Errors:   " + $Result.summary.errors)
    Write-Host "==========================================" -ForegroundColor Cyan
}

$script:RepoRoot = Resolve-ForsettiRepoRoot -Path $RepoRoot
$script:ContractChangedFilesCount = 0
$contractRulesPath = Join-Path $script:RepoRoot "core/validator/contract_rules.ps1"
if (Test-Path -LiteralPath $contractRulesPath) {
    . $contractRulesPath
} else {
    Add-Finding `
        -FindingId "FFAE-CONTRACT-INFRA-001" `
        -Severity "error" `
        -Status "fail" `
        -Category "contract" `
        -Path "core/validator/contract_rules.ps1" `
        -Message "Contract rules file is missing." `
        -Evidence "core/validator/contract_rules.ps1" `
        -RemediationHint "Restore the contract rules file." `
        -RuleId "FAE-C011"
}
Invoke-SelectedChecks
$result = New-ValidatorResult

if (-not [string]::IsNullOrWhiteSpace($OutputJson)) {
    $jsonPath = $OutputJson
    if (-not [System.IO.Path]::IsPathRooted($jsonPath)) {
        $jsonPath = Join-Path $script:RepoRoot $jsonPath
    }
    $jsonDir = Split-Path -Parent $jsonPath
    if (-not [string]::IsNullOrWhiteSpace($jsonDir) -and -not (Test-Path -LiteralPath $jsonDir)) {
        New-Item -ItemType Directory -Path $jsonDir -Force | Out-Null
    }
    $jsonText = $result | ConvertTo-Json -Depth 20
    $utf8NoBom = New-Object System.Text.UTF8Encoding -ArgumentList $false
    [System.IO.File]::WriteAllText($jsonPath, $jsonText, $utf8NoBom)
}

Write-HumanResult -Result $result

if ($result.summary.status -eq "pass") {
    exit 0
}

if ($result.summary.status -eq "request_changes") {
    exit 1
}

exit 2
