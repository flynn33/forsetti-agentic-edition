# Forsetti Agentic Edition local validator

[CmdletBinding()]
param(
    [string]$RepoRoot = (Get-Location).Path,
    [ValidateSet("all", "repo", "files", "structure", "json", "policies", "policy", "docs", "schemas", "schema", "scripts", "contract", "contracts", "project-context", "edition-profile", "manifest", "dependencies", "capabilities", "module-isolation", "evidence")]
    [string]$Mode = "all",
    [string]$ContractPath,
    [string]$ProjectContextPath,
    [string]$EditionProfilePath,
    [Alias("ChangedFiles")]
    [string[]]$ChangedFile,
    [string]$ChangedFilesPath,
    [string]$ManifestPath,
    [string]$OutputJson,
    [switch]$Strict
)

$ErrorActionPreference = "Stop"
$script:StartTime = Get-Date
$script:Findings = New-Object System.Collections.Generic.List[object]

function Resolve-ValidationRoot {
    param([string]$Path)

    $resolved = [System.IO.Path]::GetFullPath($Path)
    if (-not (Test-Path -LiteralPath $resolved)) {
        throw "Validation root does not exist: $Path"
    }
    return $resolved
}

function Resolve-InputPath {
    param([AllowNull()][string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $script:RepoRoot $Path))
}

function Get-RepoPath {
    param([AllowNull()][string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }
    try {
        $full = [System.IO.Path]::GetFullPath($Path)
        $root = $script:RepoRoot.TrimEnd('\', '/')
        if ($full.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $full.Substring($root.Length).TrimStart('\', '/').Replace('\', '/')
        }
    } catch {
        return $Path.Replace('\', '/')
    }
    return $Path.Replace('\', '/')
}

function Add-Finding {
    param(
        [string]$RuleId,
        [ValidateSet("info", "low", "medium", "high", "critical")]
        [string]$Severity,
        [ValidateSet("pass", "request_changes", "block")]
        [string]$Decision,
        [string]$Message,
        [AllowNull()]$Evidence,
        [AllowNull()][string]$Remediation,
        [AllowNull()][string]$Category,
        [AllowNull()][string]$Path
    )

    $evidenceArray = @()
    if ($null -ne $Evidence) {
        foreach ($item in @($Evidence)) {
            if (-not [string]::IsNullOrWhiteSpace([string]$item)) {
                $evidenceArray += [string]$item
            }
        }
    }

    $legacyStatus = "pass"
    if ($Decision -eq "request_changes") {
        $legacyStatus = "warn"
    } elseif ($Decision -eq "block") {
        $legacyStatus = "fail"
    }

    $script:Findings.Add([pscustomobject][ordered]@{
        rule_id          = $RuleId
        severity         = $Severity
        decision         = $Decision
        status           = $legacyStatus
        message          = $Message
        evidence         = $evidenceArray
        remediation      = if ([string]::IsNullOrWhiteSpace($Remediation)) { $null } else { $Remediation }
        remediation_hint = if ([string]::IsNullOrWhiteSpace($Remediation)) { $null } else { $Remediation }
        category         = if ([string]::IsNullOrWhiteSpace($Category)) { $null } else { $Category }
        path             = if ([string]::IsNullOrWhiteSpace($Path)) { $null } else { $Path }
    })
}

function Read-JsonObject {
    param([string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Get-JsonFiles {
    $excluded = @(".git", "node_modules")
    $stack = New-Object System.Collections.Generic.Stack[string]
    $stack.Push($script:RepoRoot)
    while ($stack.Count -gt 0) {
        $current = $stack.Pop()
        foreach ($file in Get-ChildItem -LiteralPath $current -Filter "*.json" -File -ErrorAction SilentlyContinue) {
            $file
        }
        foreach ($directory in Get-ChildItem -LiteralPath $current -Directory -ErrorAction SilentlyContinue) {
            if ($excluded -notcontains $directory.Name) {
                $stack.Push($directory.FullName)
            }
        }
    }
}

function Test-JsonFiles {
    $errors = 0
    $count = 0
    foreach ($file in Get-JsonFiles) {
        $count++
        try {
            $null = Read-JsonObject -Path $file.FullName
        } catch {
            $errors++
            Add-Finding -RuleId "FAE-C011" -Severity "critical" -Decision "block" -Category "json" -Path (Get-RepoPath $file.FullName) -Message "Invalid JSON file." -Evidence $_.Exception.Message -Remediation "Fix JSON syntax before proceeding."
        }
    }
    if ($errors -eq 0) {
        Add-Finding -RuleId "FAE-C011" -Severity "info" -Decision "pass" -Category "json" -Message "Repository JSON files parse cleanly." -Evidence ("Parsed " + $count + " JSON files.") -Remediation $null
    }
}

function Assert-PathExists {
    param([string]$RelativePath, [string]$RuleId)
    if (-not (Test-Path -LiteralPath (Join-Path $script:RepoRoot $RelativePath))) {
        Add-Finding -RuleId $RuleId -Severity "critical" -Decision "block" -Category "repo" -Path $RelativePath -Message "Required repository path is missing." -Evidence $RelativePath -Remediation "Restore or create the required path."
        return $false
    }
    return $true
}

function Test-RequiredRepositorySurface {
    $required = @(
        "README.md",
        "FORSETTI_CONSTITUTION.md",
        "AGENTS.md",
        "COMPLIANCE_POLICY.md",
        "ACCOUNTABILITY_POLICY.md",
        "core/README.md",
        "core/AGENTS.md",
        "core/enforcement/authority-model.md",
        "core/contracts/forsetti-project-context-template.json",
        "core/contracts/task-contract-template.json",
        "core/schemas/forsetti-project-context.schema.json",
        "core/schemas/edition-profile.schema.json",
        "core/schemas/module-manifest-1.1.schema.json",
        "core/schemas/task-contract.schema.json",
        "core/schemas/validator-result.schema.json",
        "core/policies/forsetti-enforcement-rules.json",
        "core/policies/manifest-rules.json",
        "core/policies/runtime-requirement-rules.json",
        "core/policies/module-isolation-rules.json",
        "core/policies/dependency-boundary-rules.json",
        "core/policies/public-api-rules.json",
        "core/policies/capability-rules.json",
        "core/policies/ui-contribution-rules.json",
        "core/policies/service-access-rules.json",
        "core/policies/mcp-provider-policy.json",
        "core/policies/mcp-resolution-order.json",
        "core/policies/accountability-rules.json",
        "core/policies/agent-enforcement-actions.json",
        "core/validator/forsetti_validate.ps1",
        "core/validator/rules/forsetti_project_rules.ps1",
        "editions/shared/shared-forsetti-invariants.json",
        "editions/apple/forsetti-apple-0.1.3.profile.json",
        "editions/windows/forsetti-windows-0.2.0.profile.json",
        "editions/README.md",
        "overlays/generic/README.md",
        "overlays/forsetti-apple/README.md",
        "overlays/forsetti-windows/README.md",
        "standards/mcp-local-helper-standard.md",
        "scripts/validate-repo.ps1",
        "scripts/validate-repo.sh"
    )

    $missing = 0
    foreach ($path in $required) {
        if (-not (Assert-PathExists -RelativePath $path -RuleId "FAE-C011")) {
            $missing++
        }
    }
    if ($missing -eq 0) {
        Add-Finding -RuleId "FAE-C011" -Severity "info" -Decision "pass" -Category "repo" -Message "Required repository surface exists." -Evidence ("Checked " + $required.Count + " paths.") -Remediation $null
    }
}

function Test-PolicyMirrors {
    $pairs = @(
        "forsetti-enforcement-rules.json",
        "manifest-rules.json",
        "runtime-requirement-rules.json",
        "module-isolation-rules.json",
        "dependency-boundary-rules.json",
        "public-api-rules.json",
        "capability-rules.json",
        "ui-contribution-rules.json",
        "service-access-rules.json",
        "mcp-provider-policy.json",
        "mcp-resolution-order.json",
        "accountability-rules.json",
        "agent-enforcement-actions.json"
    )

    $errors = 0
    foreach ($file in $pairs) {
        $corePath = Join-Path $script:RepoRoot ("core/policies/" + $file)
        $rootPath = Join-Path $script:RepoRoot ("policies/" + $file)
        if (-not (Test-Path -LiteralPath $corePath) -or -not (Test-Path -LiteralPath $rootPath)) {
            $errors++
            Add-Finding -RuleId "FAE-C011" -Severity "critical" -Decision "block" -Category "policies" -Path $file -Message "Policy mirror pair is missing." -Evidence $file -Remediation "Create both core and root policy mirror files."
            continue
        }
        $coreText = Get-Content -LiteralPath $corePath -Raw
        $rootText = Get-Content -LiteralPath $rootPath -Raw
        if ($coreText -ne $rootText) {
            $errors++
            Add-Finding -RuleId "FAE-C011" -Severity "high" -Decision "request_changes" -Category "policies" -Path $file -Message "Core policy and root mirror differ." -Evidence $file -Remediation "Synchronize the root mirror with the canonical core policy."
        }
    }
    if ($errors -eq 0) {
        Add-Finding -RuleId "FAE-C011" -Severity "info" -Decision "pass" -Category "policies" -Message "Forsetti policy mirrors are synchronized." -Evidence ("Checked " + $pairs.Count + " policy mirrors.") -Remediation $null
    }
}

function Test-ForsettiRuleRegistry {
    $path = Join-Path $script:RepoRoot "core/policies/forsetti-enforcement-rules.json"
    if (-not (Test-Path -LiteralPath $path)) {
        Add-Finding -RuleId "FAE-F002" -Severity "critical" -Decision "block" -Category "policies" -Path "core/policies/forsetti-enforcement-rules.json" -Message "Forsetti enforcement rule registry is missing." -Evidence "core/policies/forsetti-enforcement-rules.json" -Remediation "Create FAE-F001 through FAE-F020 registry."
        return
    }

    $registry = Read-JsonObject -Path $path
    $ids = @($registry.rules | ForEach-Object { [string]$_.rule_id })
    $expected = 1..20 | ForEach-Object { "FAE-F{0:D3}" -f $_ }
    $missing = @($expected | Where-Object { $ids -notcontains $_ })
    $shapeErrors = 0
    foreach ($rule in @($registry.rules)) {
        foreach ($field in @("rule_id", "title", "severity", "decision", "applies_to_modes", "required_evidence", "validation", "remediation")) {
            if (-not $rule.PSObject.Properties[$field]) {
                $shapeErrors++
                Add-Finding -RuleId "FAE-F002" -Severity "critical" -Decision "block" -Category "policies" -Path "core/policies/forsetti-enforcement-rules.json" -Message "Forsetti rule is missing a required field." -Evidence (($rule.rule_id) + " missing " + $field) -Remediation "Add rule ID, title, severity, decision, applies-to modes, required evidence, validation, and remediation fields."
            }
        }
    }
    if ($missing.Count -gt 0) {
        Add-Finding -RuleId "FAE-F002" -Severity "critical" -Decision "block" -Category "policies" -Path "core/policies/forsetti-enforcement-rules.json" -Message "Forsetti enforcement registry is missing rule IDs." -Evidence ($missing -join ", ") -Remediation "Add the missing FAE-F rule IDs."
    } elseif ($shapeErrors -eq 0) {
        Add-Finding -RuleId "FAE-F002" -Severity "info" -Decision "pass" -Category "policies" -Message "FAE-F001 through FAE-F020 are present with required fields." -Evidence ($expected -join ", ") -Remediation $null
    }
}

function Test-CoreBoundary {
    $coreRoot = Join-Path $script:RepoRoot "core"
    if (-not (Test-Path -LiteralPath $coreRoot)) {
        return
    }
    $forbidden = "(Invoke-WebRequest|Invoke-RestMethod|\bgh\b|\bdocker\b|\bwsl\b|https?://github.com|adapters/github-actions/workflows)"
    $hits = @()
    foreach ($file in Get-ChildItem -LiteralPath $coreRoot -File -Recurse) {
        $text = Get-Content -LiteralPath $file.FullName -Raw
        if ($text -match $forbidden) {
            $hits += (Get-RepoPath $file.FullName)
        }
    }
    if ($hits.Count -gt 0) {
        Add-Finding -RuleId "FAE-C011" -Severity "high" -Decision "request_changes" -Category "repo" -Message "Core contains hosted or local-tool dependency language." -Evidence ($hits -join ", ") -Remediation "Keep core governance host-neutral and move hosted/tool logic to adapters or standards."
    } else {
        Add-Finding -RuleId "FAE-C011" -Severity "info" -Decision "pass" -Category "repo" -Message "Core remains free of hosted workflow and local-tool dependencies." -Evidence "Scanned core files." -Remediation $null
    }
}

function Test-Repo {
    if (-not (Test-Path -LiteralPath (Join-Path $script:RepoRoot "FORSETTI_CONSTITUTION.md"))) {
        Add-Finding -RuleId "FAE-C011" -Severity "medium" -Decision "request_changes" -Category "repo" -Message "Repo mode was requested for a target repository without FFAE constitution." -Evidence $script:RepoRoot -Remediation "Use project-context, manifest, dependencies, capabilities, module-isolation, or evidence modes for target repositories."
        return
    }
    Test-RequiredRepositorySurface
    Test-JsonFiles
    Test-PolicyMirrors
    Test-ForsettiRuleRegistry
    Test-CoreBoundary
}

function Get-DefaultProfilePath {
    param([object]$Context)
    if ($Context -and $Context.edition_profile) {
        return Resolve-InputPath -Path ([string]$Context.edition_profile)
    }
    if (-not [string]::IsNullOrWhiteSpace($EditionProfilePath)) {
        return Resolve-InputPath -Path $EditionProfilePath
    }
    return $null
}

function Test-ProjectContextObject {
    param([object]$Context, [string]$SourcePath)

    $required = @(
        "repository_mode",
        "forsetti_edition",
        "target_platform",
        "framework_version",
        "edition_profile",
        "manifest_schema_version",
        "manifest_template_version",
        "deployment_pattern",
        "module_type",
        "module_id",
        "capabilities_requested",
        "runtime_requirements_declared",
        "uses_public_api_only",
        "touches_framework_internals"
    )
    $missing = @()
    foreach ($field in $required) {
        if (-not $Context.PSObject.Properties[$field]) {
            $missing += $field
        } elseif ([string]::IsNullOrWhiteSpace([string]$Context.$field)) {
            if ($field -ne "capabilities_requested" -and $field -ne "module_id") {
                $missing += $field
            }
        }
    }
    if ($missing.Count -gt 0) {
        Add-Finding -RuleId "FAE-F001" -Severity "critical" -Decision "block" -Category "project-context" -Path (Get-RepoPath $SourcePath) -Message "Forsetti project context is missing required fields." -Evidence ($missing -join ", ") -Remediation "Complete every required Forsetti project context field before execution."
        return $false
    }

    if ($Context.forsetti_edition -notin @("apple", "windows")) {
        Add-Finding -RuleId "FAE-F002" -Severity "critical" -Decision "block" -Category "project-context" -Path (Get-RepoPath $SourcePath) -Message "Unsupported Forsetti edition." -Evidence ([string]$Context.forsetti_edition) -Remediation "Select the Apple or Windows edition profile."
        return $false
    }
    if ($Context.target_platform -notin @("iOS", "macOS", "Windows")) {
        Add-Finding -RuleId "FAE-F003" -Severity "critical" -Decision "block" -Category "project-context" -Path (Get-RepoPath $SourcePath) -Message "Unsupported target platform." -Evidence ([string]$Context.target_platform) -Remediation "Select a target platform supported by the edition profile."
        return $false
    }
    if ($Context.manifest_schema_version -ne "1.1" -or $Context.manifest_template_version -ne "1.1") {
        Add-Finding -RuleId "FAE-F004" -Severity "critical" -Decision "block" -Category "project-context" -Path (Get-RepoPath $SourcePath) -Message "Manifest schema/template version must be 1.1 for this remediation package." -Evidence (($Context.manifest_schema_version) + "/" + ($Context.manifest_template_version)) -Remediation "Set manifest schema and template versions to 1.1."
        return $false
    }
    if ($Context.module_type -notin @("app", "ui", "service", "not_applicable")) {
        Add-Finding -RuleId "FAE-F001" -Severity "critical" -Decision "block" -Category "project-context" -Path (Get-RepoPath $SourcePath) -Message "Unknown Forsetti module type." -Evidence ([string]$Context.module_type) -Remediation "Use app, ui, service, or not_applicable."
        return $false
    }
    if ($Context.module_type -ne "not_applicable" -and [string]::IsNullOrWhiteSpace([string]$Context.module_id)) {
        Add-Finding -RuleId "FAE-F001" -Severity "critical" -Decision "block" -Category "project-context" -Path (Get-RepoPath $SourcePath) -Message "Forsetti project context is missing module_id for a module-bearing task." -Evidence "module_id" -Remediation "Provide the Forsetti module identifier or set module_type to not_applicable for non-module governance work."
        return $false
    }
    if ($Context.touches_framework_internals -eq $true) {
        Add-Finding -RuleId "FAE-F012" -Severity "critical" -Decision "block" -Category "project-context" -Path (Get-RepoPath $SourcePath) -Message "Task context indicates framework internals are touched." -Evidence "touches_framework_internals=true" -Remediation "Re-scope the task to public APIs or obtain explicit governance-class authority."
        return $false
    }
    if ($Context.uses_public_api_only -ne $true) {
        Add-Finding -RuleId "FAE-F011" -Severity "critical" -Decision "block" -Category "project-context" -Path (Get-RepoPath $SourcePath) -Message "Task context does not confirm public API-only use." -Evidence "uses_public_api_only=false" -Remediation "Confirm and enforce public Forsetti API-only use."
        return $false
    }

    Add-Finding -RuleId "FAE-F001" -Severity "info" -Decision "pass" -Category "project-context" -Path (Get-RepoPath $SourcePath) -Message "Forsetti project context is complete." -Evidence (($Context.forsetti_edition) + " " + ($Context.framework_version) + " " + ($Context.target_platform)) -Remediation $null
    return $true
}

function Test-ProjectContext {
    if ([string]::IsNullOrWhiteSpace($ProjectContextPath)) {
        if ($Mode -eq "project-context") {
            Add-Finding -RuleId "FAE-F001" -Severity "critical" -Decision "block" -Category "project-context" -Message "Project context mode requires -ProjectContextPath." -Evidence "-ProjectContextPath" -Remediation "Provide a Forsetti project context JSON file."
        }
        return $null
    }
    $path = Resolve-InputPath -Path $ProjectContextPath
    if (-not (Test-Path -LiteralPath $path)) {
        Add-Finding -RuleId "FAE-F001" -Severity "critical" -Decision "block" -Category "project-context" -Path (Get-RepoPath $path) -Message "Project context file is missing." -Evidence $ProjectContextPath -Remediation "Create the project context file before execution."
        return $null
    }
    $context = Read-JsonObject -Path $path
    $null = Test-ProjectContextObject -Context $context -SourcePath $path
    return $context
}

function Test-EditionProfileObject {
    param([object]$Profile, [string]$SourcePath)

    $required = @("edition", "frameworkVersion", "supportedPlatforms", "nativeTools", "publicProducts", "manifest", "capabilities", "dependencyRules", "verificationCommands")
    $missing = @()
    foreach ($field in $required) {
        if (-not $Profile.PSObject.Properties[$field]) {
            $missing += $field
        }
    }
    if ($missing.Count -gt 0) {
        Add-Finding -RuleId "FAE-F002" -Severity "critical" -Decision "block" -Category "edition-profile" -Path (Get-RepoPath $SourcePath) -Message "Edition profile is missing required fields." -Evidence ($missing -join ", ") -Remediation "Complete the edition profile before using it."
        return $false
    }
    if ($Profile.manifest.currentSchemaVersion -ne "1.1" -or $Profile.manifest.currentTemplateVersion -ne "1.1") {
        Add-Finding -RuleId "FAE-F004" -Severity "critical" -Decision "block" -Category "edition-profile" -Path (Get-RepoPath $SourcePath) -Message "Edition profile does not select manifest 1.1." -Evidence (($Profile.manifest.currentSchemaVersion) + "/" + ($Profile.manifest.currentTemplateVersion)) -Remediation "Set current schema and template versions to 1.1."
        return $false
    }
    Add-Finding -RuleId "FAE-F002" -Severity "info" -Decision "pass" -Category "edition-profile" -Path (Get-RepoPath $SourcePath) -Message "Edition profile is complete." -Evidence (($Profile.edition) + " " + ($Profile.frameworkVersion)) -Remediation $null
    return $true
}

function Test-EditionProfile {
    if (-not [string]::IsNullOrWhiteSpace($EditionProfilePath)) {
        $path = Resolve-InputPath -Path $EditionProfilePath
        if (-not (Test-Path -LiteralPath $path)) {
            Add-Finding -RuleId "FAE-F002" -Severity "critical" -Decision "block" -Category "edition-profile" -Path (Get-RepoPath $path) -Message "Edition profile file is missing." -Evidence $EditionProfilePath -Remediation "Provide the selected edition profile."
            return $null
        }
        $profile = Read-JsonObject -Path $path
        $null = Test-EditionProfileObject -Profile $profile -SourcePath $path
        return $profile
    }

    if ($Mode -eq "edition-profile" -or $Mode -eq "all") {
        $profilePaths = @(
            "editions/apple/forsetti-apple-0.1.3.profile.json",
            "editions/windows/forsetti-windows-0.2.0.profile.json"
        )
        foreach ($relative in $profilePaths) {
            $path = Join-Path $script:RepoRoot $relative
            if (Test-Path -LiteralPath $path) {
                $null = Test-EditionProfileObject -Profile (Read-JsonObject -Path $path) -SourcePath $path
            } elseif ($Mode -eq "edition-profile") {
                Add-Finding -RuleId "FAE-F002" -Severity "critical" -Decision "block" -Category "edition-profile" -Path $relative -Message "Required edition profile is missing." -Evidence $relative -Remediation "Create the required edition profile."
            }
        }
    }
    return $null
}

function Test-Manifest {
    param([AllowNull()]$Profile)

    if ([string]::IsNullOrWhiteSpace($ManifestPath)) {
        if ($Mode -eq "manifest") {
            Add-Finding -RuleId "FAE-F004" -Severity "critical" -Decision "block" -Category "manifest" -Message "Manifest mode requires -ManifestPath." -Evidence "-ManifestPath" -Remediation "Provide a Forsetti module manifest JSON file."
        }
        return $null
    }

    $path = Resolve-InputPath -Path $ManifestPath
    if (-not (Test-Path -LiteralPath $path)) {
        Add-Finding -RuleId "FAE-F004" -Severity "critical" -Decision "block" -Category "manifest" -Path (Get-RepoPath $path) -Message "Manifest file is missing." -Evidence $ManifestPath -Remediation "Create or provide the module manifest."
        return $null
    }

    $manifest = Read-JsonObject -Path $path
    $required = @("schemaVersion", "manifestTemplateVersion", "moduleID", "displayName", "moduleVersion", "moduleType", "supportedPlatforms", "minForsettiVersion", "capabilitiesRequested", "entryPoint", "runtimeRequirements")
    if ($Profile -and $Profile.manifest.requiredFields) {
        $required = @($Profile.manifest.requiredFields)
    }

    $missing = @()
    foreach ($field in $required) {
        if (-not $manifest.PSObject.Properties[$field]) {
            $missing += $field
        }
    }
    if ($missing.Count -gt 0) {
        Add-Finding -RuleId "FAE-F004" -Severity "critical" -Decision "block" -Category "manifest" -Path (Get-RepoPath $path) -Message "Manifest is missing required fields." -Evidence ($missing -join ", ") -Remediation "Add all manifest 1.1 fields required by the selected profile."
        return $manifest
    }

    if ($manifest.schemaVersion -ne "1.1" -or $manifest.manifestTemplateVersion -ne "1.1") {
        Add-Finding -RuleId "FAE-F004" -Severity "critical" -Decision "block" -Category "manifest" -Path (Get-RepoPath $path) -Message "Manifest schema/template version is unsupported." -Evidence (($manifest.schemaVersion) + "/" + ($manifest.manifestTemplateVersion)) -Remediation "Use schemaVersion and manifestTemplateVersion 1.1."
    }
    if ($manifest.moduleType -notin @("service", "ui", "app")) {
        Add-Finding -RuleId "FAE-F004" -Severity "critical" -Decision "block" -Category "manifest" -Path (Get-RepoPath $path) -Message "Manifest has invalid module type." -Evidence ([string]$manifest.moduleType) -Remediation "Use service, ui, or app."
    }

    if ($Profile) {
        $unsupportedPlatforms = @($manifest.supportedPlatforms | Where-Object { @($Profile.supportedPlatforms) -notcontains $_ })
        if ($unsupportedPlatforms.Count -gt 0) {
            Add-Finding -RuleId "FAE-F003" -Severity "critical" -Decision "block" -Category "manifest" -Path (Get-RepoPath $path) -Message "Manifest platform is not supported by selected profile." -Evidence ($unsupportedPlatforms -join ", ") -Remediation "Select a matching profile or correct supportedPlatforms."
        }
        $unknownCapabilities = @($manifest.capabilitiesRequested | Where-Object { @($Profile.capabilities) -notcontains $_ })
        if ($unknownCapabilities.Count -gt 0) {
            Add-Finding -RuleId "FAE-F009" -Severity "critical" -Decision "block" -Category "manifest" -Path (Get-RepoPath $path) -Message "Manifest requests unknown capabilities." -Evidence ($unknownCapabilities -join ", ") -Remediation "Use only capabilities defined by the selected profile."
        }
    }

    $runtime = $manifest.runtimeRequirements
    foreach ($field in @("io", "ui", "dataIsolation")) {
        if (-not $runtime.PSObject.Properties[$field]) {
            Add-Finding -RuleId "FAE-F010" -Severity "critical" -Decision "block" -Category "manifest" -Path (Get-RepoPath $path) -Message "Runtime requirements are incomplete." -Evidence ("runtimeRequirements." + $field) -Remediation "Declare io, ui, and dataIsolation runtime requirements."
        }
    }
    if ($manifest.moduleType -eq "service" -and $runtime.PSObject.Properties["ui"] -and $null -ne $runtime.ui) {
        Add-Finding -RuleId "FAE-F015" -Severity "critical" -Decision "block" -Category "manifest" -Path (Get-RepoPath $path) -Message "Service module declares UI runtime contribution." -Evidence "runtimeRequirements.ui" -Remediation "Remove UI contribution from service modules or change module type."
    }
    if ($manifest.moduleType -in @("ui", "app") -and $runtime.PSObject.Properties["ui"] -and $null -eq $runtime.ui) {
        Add-Finding -RuleId "FAE-F014" -Severity "critical" -Decision "block" -Category "manifest" -Path (Get-RepoPath $path) -Message "UI/app module lacks active UI runtime surface." -Evidence "runtimeRequirements.ui=null" -Remediation "Declare the UI runtime surface required by the selected profile."
    }
    if ($manifest.PSObject.Properties["defaultModuleRole"] -and $manifest.defaultModuleRole -notin @("app", "ui", "service", "none")) {
        Add-Finding -RuleId "FAE-F004" -Severity "critical" -Decision "block" -Category "manifest" -Path (Get-RepoPath $path) -Message "Manifest has invalid default module role." -Evidence ([string]$manifest.defaultModuleRole) -Remediation "Use app, ui, service, or none for defaultModuleRole."
    }

    Add-Finding -RuleId "FAE-F004" -Severity "info" -Decision "pass" -Category "manifest" -Path (Get-RepoPath $path) -Message "Manifest file was inspected." -Evidence ([string]$manifest.moduleID) -Remediation $null
    return $manifest
}

function Get-ChangedFileList {
    $files = @()
    if (@($ChangedFile).Count -gt 0) {
        $files += @($ChangedFile)
    }
    if (-not [string]::IsNullOrWhiteSpace($ChangedFilesPath)) {
        $path = Resolve-InputPath -Path $ChangedFilesPath
        if (Test-Path -LiteralPath $path) {
            $files += @(Get-Content -LiteralPath $path | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        }
    }
    if ($files.Count -eq 0) {
        try {
            $gitFiles = & git -C $script:RepoRoot status --short 2>$null | ForEach-Object {
                if ($_ -match '^\s*\S+\s+(.+)$') { $Matches[1].Trim() }
            }
            $files += @($gitFiles)
        } catch {
            $files = @()
        }
    }
    return @($files | ForEach-Object { $_.Replace('\', '/') } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)
}

function Get-ReadableChangedFiles {
    $paths = @()
    foreach ($relative in Get-ChangedFileList) {
        $path = Resolve-InputPath -Path $relative
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            $paths += $path
        }
    }
    return $paths
}

function Test-Dependencies {
    param([AllowNull()]$Profile)

    $files = Get-ReadableChangedFiles
    if ($files.Count -eq 0) {
        Add-Finding -RuleId "FAE-F013" -Severity "info" -Decision "pass" -Category "dependencies" -Message "No changed files supplied for dependency inspection." -Evidence "No changed files." -Remediation $null
        return
    }

    $violations = @()
    foreach ($file in $files) {
        $relative = Get-RepoPath $file
        $text = Get-Content -LiteralPath $file -Raw
        if ($relative -match 'Sources/ForsettiCore/' -and $text -match 'import\s+(SwiftUI|UIKit|AppKit|StoreKit|ForsettiPlatform)') {
            $violations += ($relative + " imports platform or upper-layer product from ForsettiCore")
        }
        if ($relative -match 'include/ForsettiCore/|src/ForsettiCore/' -and $text -match '#include\s+[<"].*Forsetti(Platform|HostTemplate)') {
            $violations += ($relative + " includes upper-layer Windows product from ForsettiCore")
        }
        if ($text -match '(internal|private)\s+.*Forsetti' -and $relative -notmatch '(^Sources/Forsetti|^src/Forsetti|^include/Forsetti)') {
            $violations += ($relative + " appears to reference non-public Forsetti internals")
        }
    }

    if ($violations.Count -gt 0) {
        Add-Finding -RuleId "FAE-F013" -Severity "critical" -Decision "block" -Category "dependencies" -Message "Dependency direction or public API boundary violation detected." -Evidence $violations -Remediation "Use public Forsetti products only and preserve one-way dependency direction."
    } else {
        Add-Finding -RuleId "FAE-F013" -Severity "info" -Decision "pass" -Category "dependencies" -Message "Changed files do not show direct dependency boundary violations." -Evidence ("Checked " + $files.Count + " files.") -Remediation $null
    }
}

function Test-Capabilities {
    param([AllowNull()]$Manifest)

    $declared = @()
    if ($Manifest -and $Manifest.capabilitiesRequested) {
        $declared = @($Manifest.capabilitiesRequested)
    }
    $files = Get-ReadableChangedFiles
    if ($files.Count -eq 0) {
        Add-Finding -RuleId "FAE-F009" -Severity "info" -Decision "pass" -Category "capabilities" -Message "No changed files supplied for capability inspection." -Evidence "No changed files." -Remediation $null
        return
    }

    $mapPath = Join-Path $script:RepoRoot "core/validator/rules/forsetti_project_rules.ps1"
    if (Test-Path -LiteralPath $mapPath) {
        . $mapPath
    }
    $capabilityMap = Get-ForsettiCapabilityUseMap
    $used = New-Object System.Collections.Generic.HashSet[string]
    foreach ($file in $files) {
        $text = Get-Content -LiteralPath $file -Raw
        foreach ($capability in $capabilityMap.Keys) {
            foreach ($pattern in @($capabilityMap[$capability])) {
                if ($text -match [regex]::Escape($pattern)) {
                    [void]$used.Add($capability)
                }
            }
        }
    }
    $undeclared = @($used | Where-Object { $declared -notcontains $_ })
    if ($Manifest -and $undeclared.Count -gt 0) {
        Add-Finding -RuleId "FAE-F009" -Severity "critical" -Decision "block" -Category "capabilities" -Message "Changed files use undeclared capabilities." -Evidence ($undeclared -join ", ") -Remediation "Declare each used capability in the module manifest or remove the capability-using behavior."
    } else {
        Add-Finding -RuleId "FAE-F009" -Severity "info" -Decision "pass" -Category "capabilities" -Message "Capability inspection completed." -Evidence ("used=" + (($used | Sort-Object) -join ",") + "; declared=" + ($declared -join ",")) -Remediation $null
    }
}

function Test-ModuleIsolation {
    $files = Get-ReadableChangedFiles
    if ($files.Count -eq 0) {
        Add-Finding -RuleId "FAE-F006" -Severity "info" -Decision "pass" -Category "module-isolation" -Message "No changed files supplied for module-isolation inspection." -Evidence "No changed files." -Remediation $null
        return
    }

    $violations = @()
    foreach ($file in $files) {
        $relative = Get-RepoPath $file
        $text = Get-Content -LiteralPath $file -Raw
        if ($text -match '(import|#include)\s+["<].*(Modules|ExampleModules).*(Module|Service|UI|App)') {
            $violations += ($relative + " imports or includes another module implementation")
        }
        if ($text -match '(sharedDatabase|SharedDatabase|moduleDatabase|directModule|OtherModule)') {
            $violations += ($relative + " appears to use direct module data or implementation coupling")
        }
    }

    if ($violations.Count -gt 0) {
        Add-Finding -RuleId "FAE-F006" -Severity "critical" -Decision "block" -Category "module-isolation" -Message "Direct module coupling was detected." -Evidence $violations -Remediation "Route intermodule interaction through Forsetti orchestration contracts and remove direct coupling."
    } else {
        Add-Finding -RuleId "FAE-F006" -Severity "info" -Decision "pass" -Category "module-isolation" -Message "Changed files do not show direct module coupling patterns." -Evidence ("Checked " + $files.Count + " files.") -Remediation $null
    }
}

function Test-Contract {
    if ([string]::IsNullOrWhiteSpace($ContractPath)) {
        if ($Mode -in @("contract", "contracts")) {
            Add-Finding -RuleId "FAE-C001" -Severity "critical" -Decision "block" -Category "contract" -Message "Contract mode requires -ContractPath." -Evidence "-ContractPath" -Remediation "Provide a governing task contract before execution."
        }
        return
    }
    $path = Resolve-InputPath -Path $ContractPath
    if (-not (Test-Path -LiteralPath $path)) {
        Add-Finding -RuleId "FAE-C001" -Severity "critical" -Decision "block" -Category "contract" -Path (Get-RepoPath $path) -Message "Contract file is missing." -Evidence $ContractPath -Remediation "Provide the governing task contract."
        return
    }
    if ($path.EndsWith(".json", [System.StringComparison]::OrdinalIgnoreCase)) {
        $contract = Read-JsonObject -Path $path
        if (-not $contract.PSObject.Properties["forsetti_project_context"]) {
            Add-Finding -RuleId "FAE-F001" -Severity "critical" -Decision "block" -Category "contract" -Path (Get-RepoPath $path) -Message "Task contract is missing Forsetti project context." -Evidence "forsetti_project_context" -Remediation "Add the required Forsetti project context before Builder execution."
        } else {
            $null = Test-ProjectContextObject -Context $contract.forsetti_project_context -SourcePath $path
        }
    } else {
        $text = Get-Content -LiteralPath $path -Raw
        if ($text -notmatch '##\s+Forsetti Project Context') {
            Add-Finding -RuleId "FAE-F001" -Severity "critical" -Decision "block" -Category "contract" -Path (Get-RepoPath $path) -Message "Markdown task contract is missing Forsetti project context section." -Evidence "## Forsetti Project Context" -Remediation "Add the required context section before Builder execution."
        }
    }
    Add-Finding -RuleId "FAE-C001" -Severity "info" -Decision "pass" -Category "contract" -Path (Get-RepoPath $path) -Message "Task contract was inspected." -Evidence (Get-RepoPath $path) -Remediation $null
}

function Test-Evidence {
    $files = Get-ChangedFileList
    if ($Mode -eq "evidence" -and $files.Count -eq 0 -and [string]::IsNullOrWhiteSpace($ChangedFilesPath)) {
        Add-Finding -RuleId "FAE-F020" -Severity "critical" -Decision "block" -Category "evidence" -Message "Evidence mode requires changed-file evidence." -Evidence "-ChangedFilesPath or -ChangedFiles" -Remediation "Provide changed-file evidence and selected profile validation evidence."
        return
    }
    Add-Finding -RuleId "FAE-F020" -Severity "info" -Decision "pass" -Category "evidence" -Message "Evidence inputs were inspected." -Evidence ("changed_files=" + $files.Count) -Remediation $null
}

function Invoke-SelectedChecks {
    $context = $null
    $profile = $null
    $manifest = $null

    if ($Mode -in @("all", "repo", "files", "structure", "json", "policies", "policy", "docs", "schemas", "schema", "scripts")) {
        Test-Repo
    }
    if ($Mode -in @("all", "contract", "contracts")) {
        Test-Contract
    }
    if ($Mode -in @("all", "project-context")) {
        $context = Test-ProjectContext
    }
    if (-not $profile -and $context) {
        $profilePath = Get-DefaultProfilePath -Context $context
        if ($profilePath -and (Test-Path -LiteralPath $profilePath)) {
            $profile = Read-JsonObject -Path $profilePath
            $null = Test-EditionProfileObject -Profile $profile -SourcePath $profilePath
        }
    }
    if ($Mode -in @("all", "edition-profile") -and -not $profile) {
        $profile = Test-EditionProfile
    } elseif (-not [string]::IsNullOrWhiteSpace($EditionProfilePath) -and -not $profile) {
        $profile = Test-EditionProfile
    }
    if ($Mode -in @("manifest", "all") -or -not [string]::IsNullOrWhiteSpace($ManifestPath)) {
        $manifest = Test-Manifest -Profile $profile
    }
    if ($Mode -in @("dependencies", "all")) {
        Test-Dependencies -Profile $profile
    }
    if ($Mode -in @("capabilities", "all")) {
        Test-Capabilities -Manifest $manifest
    }
    if ($Mode -in @("module-isolation", "all")) {
        Test-ModuleIsolation
    }
    if ($Mode -in @("evidence", "all")) {
        Test-Evidence
    }
}

function New-ValidatorResult {
    $findings = @($script:Findings.ToArray())
    $blockCount = @($findings | Where-Object { $_.decision -eq "block" }).Count
    $requestCount = @($findings | Where-Object { $_.decision -eq "request_changes" }).Count
    $passCount = @($findings | Where-Object { $_.decision -eq "pass" }).Count
    $status = "pass"
    if ($blockCount -gt 0) {
        $status = "block"
    } elseif ($requestCount -gt 0 -or ($Strict -and $requestCount -gt 0)) {
        $status = "request_changes"
    }
    return [pscustomobject][ordered]@{
        schema_version = "1.0"
        status         = $status
        mode           = $Mode
        validator      = [pscustomobject][ordered]@{
            name    = "forsetti_validate"
            version = "0.3.0"
        }
        invocation     = [pscustomobject][ordered]@{
            repo_root            = $script:RepoRoot
            mode                 = $Mode
            strict               = [bool]$Strict
            contract_path        = if ($ContractPath) { Get-RepoPath (Resolve-InputPath -Path $ContractPath) } else { $null }
            project_context_path = if ($ProjectContextPath) { Get-RepoPath (Resolve-InputPath -Path $ProjectContextPath) } else { $null }
            edition_profile_path = if ($EditionProfilePath) { Get-RepoPath (Resolve-InputPath -Path $EditionProfilePath) } else { $null }
            manifest_path        = if ($ManifestPath) { Get-RepoPath (Resolve-InputPath -Path $ManifestPath) } else { $null }
            changed_files_path   = if ($ChangedFilesPath) { Get-RepoPath (Resolve-InputPath -Path $ChangedFilesPath) } else { $null }
            timestamp_utc        = (Get-Date).ToUniversalTime().ToString("o")
        }
        summary        = [pscustomobject][ordered]@{
            status          = $status
            total           = $findings.Count
            passed          = $passCount
            request_changes = $requestCount
            blocks          = $blockCount
            duration_ms     = [int]((Get-Date) - $script:StartTime).TotalMilliseconds
        }
        findings       = $findings
    }
}

function Write-HumanResult {
    param([object]$Result)

    Write-Host "Forsetti Local Validator"
    Write-Host ("Repository: " + $Result.invocation.repo_root)
    Write-Host ("Mode: " + $Result.invocation.mode)
    Write-Host ("Status: " + $Result.status)
    foreach ($finding in $Result.findings) {
        $pathText = if ($finding.path) { " [" + $finding.path + "]" } else { "" }
        Write-Host (($finding.decision).ToUpperInvariant() + " " + $finding.rule_id + $pathText + " - " + $finding.message)
    }
}

$script:RepoRoot = Resolve-ValidationRoot -Path $RepoRoot
Invoke-SelectedChecks
$result = New-ValidatorResult

if (-not [string]::IsNullOrWhiteSpace($OutputJson)) {
    $jsonPath = Resolve-InputPath -Path $OutputJson
    $jsonDir = Split-Path -Parent $jsonPath
    if (-not [string]::IsNullOrWhiteSpace($jsonDir) -and -not (Test-Path -LiteralPath $jsonDir)) {
        New-Item -ItemType Directory -Path $jsonDir -Force | Out-Null
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding -ArgumentList $false
    [System.IO.File]::WriteAllText($jsonPath, ($result | ConvertTo-Json -Depth 20), $utf8NoBom)
}

Write-HumanResult -Result $result

if ($result.status -eq "pass") {
    exit 0
}
if ($result.status -eq "request_changes") {
    exit 1
}
exit 2
