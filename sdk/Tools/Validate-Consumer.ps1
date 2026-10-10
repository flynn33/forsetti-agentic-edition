# Validate a separate governed repository against an immutable external toolkit.
#requires -Version 7.4
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RepoRoot,
    [string]$SDKRoot = (Join-Path $PSScriptRoot '..'),
    [ValidateSet('consumer', 'contract', 'project-context', 'edition-profile', 'manifest', 'dependencies', 'capabilities', 'module-isolation', 'evidence')]
    [string]$Mode = 'consumer',
    [string]$ContractPath,
    [string]$ProjectContextPath = '.forsetti/project-context.json',
    [string]$ManifestPath,
    [string]$ChangedFilesPath,
    [Alias('ChangedFiles')][string[]]$ChangedFile,
    [string]$OutputJson,
    [switch]$Strict
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'SDK-Integrity.ps1')

try {
    $sdk = Test-ForsettiSDKIntegrity -SDKRoot $SDKRoot
    $target = [System.IO.Path]::GetFullPath($RepoRoot)
    if (-not (Test-Path -LiteralPath $target -PathType Container)) { throw 'Target repository is missing.' }
    $targetRoot = (Resolve-ForsettiPhysicalPath -Path $target).TrimEnd([char[]]'\/')
    $toolkitRoot = (Resolve-ForsettiPhysicalPath -Path $sdk.SDKRoot).TrimEnd([char[]]'\/')
    $separator = [System.IO.Path]::DirectorySeparatorChar
    if ($targetRoot -eq $toolkitRoot -or $targetRoot.StartsWith($toolkitRoot + $separator, [System.StringComparison]::OrdinalIgnoreCase) -or
        $toolkitRoot.StartsWith($targetRoot + $separator, [System.StringComparison]::OrdinalIgnoreCase)) { throw 'Consumer target and external SDK installation must not overlap.' }
    if ([System.IO.Path]::IsPathRooted($ProjectContextPath)) {
        $prefix = $target.TrimEnd([char[]]'\/') + [System.IO.Path]::DirectorySeparatorChar
        $full = [System.IO.Path]::GetFullPath($ProjectContextPath)
        if (-not $full.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) { throw 'Project context must belong to the target repository.' }
        $ProjectContextPath = $full.Substring($prefix.Length).Replace('\', '/')
    }
    $contextPath = Resolve-ForsettiTrustedPath -Root $target -RelativePath $ProjectContextPath
    $context = Read-ForsettiSDKJson -Path $contextPath
    $contextSchema = Join-Path $sdk.SDKRoot 'core/schemas/forsetti-project-context.schema.json'
    if (-not (Test-Json -Json ($context | ConvertTo-Json -Depth 30) -SchemaFile $contextSchema -ErrorAction SilentlyContinue)) {
        throw 'Target project context does not satisfy the canonical schema.'
    }
    $profileRelative = 'editions/' + $context.forsetti_edition + '/forsetti-' + $context.forsetti_edition + '-' + $context.framework_version + '.profile.json'
    if ([string]$context.edition_profile -cne $profileRelative) { throw 'Target context must select its exact trusted edition/version profile.' }
    $profilePath = Resolve-ForsettiTrustedPath -Root $sdk.BundleRoot -RelativePath $profileRelative
    $profile = Read-ForsettiSDKJson -Path $profilePath
    if (@($profile.supportedPlatforms) -notcontains $context.target_platform) { throw 'Target platform does not match the selected edition profile.' }

    $project = Read-ForsettiSDKJson -Path (Resolve-ForsettiTrustedPath -Root $target -RelativePath '.forsetti/project.json')
    $profileLock = Read-ForsettiSDKJson -Path (Resolve-ForsettiTrustedPath -Root $target -RelativePath '.forsetti/profile.lock.json')
    $policyLock = Read-ForsettiSDKJson -Path (Resolve-ForsettiTrustedPath -Root $target -RelativePath '.forsetti/policy.lock.json')
    $productLock = Read-ForsettiSDKJson -Path (Resolve-ForsettiTrustedPath -Root $target -RelativePath '.forsetti/product.lock.json')
    $modules = Read-ForsettiSDKJson -Path (Resolve-ForsettiTrustedPath -Root $target -RelativePath '.forsetti/modules.json')
    $repositoryTypes = @{ consumer_app_repo = 'application_repository'; module_repo = 'module_repository'; sample_repo = 'sample_repository' }
    $repositoryType = $repositoryTypes[[string]$context.repository_mode]
    if (-not $repositoryType -or $project.schemaVersion -ne '2.0' -or $project.repositoryType -ne $repositoryType -or
        $project.edition -ne $context.forsetti_edition -or $project.frameworkVersion -ne $context.framework_version -or
        @($project.targetPlatforms).Count -ne 1 -or $project.targetPlatforms[0] -ne $context.target_platform -or
        $project.deploymentPattern -ne $context.deployment_pattern -or $modules.schemaVersion -ne '2.0' -or
        $project.modulesPath -ne '.forsetti/modules.json' -or $project.profileLockPath -ne '.forsetti/profile.lock.json' -or
        $project.policyLockPath -ne '.forsetti/policy.lock.json' -or $project.productLockPath -ne '.forsetti/product.lock.json') {
        throw 'Native project metadata differs from the canonical target context or approved metadata paths.'
    }
    $profileHash = Get-ForsettiSHA256 -Path $profilePath
    $bundleHash = Get-ForsettiSHA256 -Path (Join-Path $sdk.BundleRoot 'product-manifest.json')
    $version = $sdk.BundleManifest.version
    $lockPlatform = if ($context.forsetti_edition -eq 'apple') { 'apple-host' } else { 'windows-host' }
    if ($profileLock.schemaVersion -ne '2.0' -or $profileLock.profileID -ne ('forsetti-' + $context.forsetti_edition + '-' + $context.framework_version) -or
        $profileLock.profileVersion -ne $version -or $profileLock.frameworkVersion -ne $context.framework_version -or
        $profileLock.sourceRevision -cne $profileHash -or $profileLock.sha256 -cne $profileHash -or $profileLock.supportStatus -ne 'supported') {
        throw 'Profile lock differs from the selected immutable profile or release.'
    }
    if ($policyLock.schemaVersion -ne '2.0' -or $policyLock.policyBundleID -ne ('ffae-policy-' + $version) -or
        $policyLock.policyBundleVersion -ne $version -or $policyLock.sha256 -cne $sdk.BundleManifest.policyBundleHash) {
        throw 'Policy lock differs from the immutable policy bundle.'
    }
    if ($productLock.schemaVersion -ne '2.0' -or $productLock.productVersion -ne $version -or
        $productLock.bundleID -ne $sdk.BundleManifest.bundleID -or $productLock.platform -ne $lockPlatform -or $productLock.sha256 -cne $bundleHash) {
        throw 'Product lock differs from the immutable product bundle.'
    }
    if ($Mode -in @('consumer', 'manifest', 'capabilities') -and $context.module_type -ne 'not_applicable' -and -not $ManifestPath) {
        throw 'Module-bearing consumer validation requires its actual module manifest.'
    }
    if ($ManifestPath) {
        $manifestTarget = if ([System.IO.Path]::IsPathRooted($ManifestPath)) { [System.IO.Path]::GetFullPath($ManifestPath) } else { Resolve-ForsettiTrustedPath -Root $target -RelativePath $ManifestPath.Replace('\', '/') }
        $targetPrefix = $target.TrimEnd([char[]]'\/') + [System.IO.Path]::DirectorySeparatorChar
        if (-not $manifestTarget.StartsWith($targetPrefix, [System.StringComparison]::OrdinalIgnoreCase)) { throw 'Module manifest must belong to the target repository.' }
        $null = Resolve-ForsettiTrustedPath -Root $target -RelativePath $manifestTarget.Substring($targetPrefix.Length).Replace('\', '/')
        $manifest = Read-ForsettiSDKJson -Path $manifestTarget
        if (-not (Test-Json -Json ($manifest | ConvertTo-Json -Depth 30) -SchemaFile (Join-Path $sdk.SDKRoot 'core/schemas/module-manifest-1.1.schema.json') -ErrorAction SilentlyContinue)) {
            throw 'Module manifest does not satisfy the canonical manifest 1.1 schema.'
        }
        if ($manifest.moduleID -ne $context.module_id -or $manifest.moduleType -ne $context.module_type -or
            @($manifest.supportedPlatforms) -notcontains $context.target_platform -or
            (($manifest.capabilitiesRequested | Sort-Object) -join ',') -cne (($context.capabilities_requested | Sort-Object) -join ',')) {
            throw 'Module manifest differs from the authorized project context.'
        }
    }
    if ($Mode -eq 'consumer' -and ([string]::IsNullOrWhiteSpace($ContractPath) -or
        ([string]::IsNullOrWhiteSpace($ChangedFilesPath) -and @($ChangedFile).Count -eq 0))) {
        throw 'Consumer workflow requires an authorized contract and actual changed-file evidence.'
    }
    foreach ($inputName in @('ContractPath', 'ChangedFilesPath', 'OutputJson')) {
        $inputValue = Get-Variable -Name $inputName -ValueOnly
        if ($inputValue) {
            $prefix = $target.TrimEnd([char[]]'\/') + [System.IO.Path]::DirectorySeparatorChar
            $inputFull = if ([System.IO.Path]::IsPathRooted($inputValue)) { [System.IO.Path]::GetFullPath($inputValue) } else { Resolve-ForsettiTrustedPath -Root $target -RelativePath $inputValue.Replace('\', '/') }
            if (-not $inputFull.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) { throw "$inputName must belong to the target repository." }
            $null = Resolve-ForsettiTrustedPath -Root $target -RelativePath $inputFull.Substring($prefix.Length).Replace('\', '/')
            if ($inputName -eq 'OutputJson') {
                if ([System.IO.Path]::GetExtension($inputFull) -ne '.json') { throw 'OutputJson must be a JSON report path.' }
                $ownedInputs = @('AGENTS.md', '.forsetti/project.json', '.forsetti/modules.json', '.forsetti/profile.lock.json', '.forsetti/policy.lock.json', '.forsetti/product.lock.json', '.forsetti/instructions/GOVERNANCE.md', $ProjectContextPath, $ContractPath, $ManifestPath, $ChangedFilesPath) + @($ChangedFile)
                if ($ChangedFilesPath) {
                    $changedList = if ([System.IO.Path]::IsPathRooted($ChangedFilesPath)) { $ChangedFilesPath } else { Join-Path $target $ChangedFilesPath }
                    if ([System.IO.File]::Exists($changedList)) { $ownedInputs += [System.IO.File]::ReadAllLines($changedList) }
                }
                foreach ($ownedInput in @($ownedInputs | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })) {
                    $ownedPath = if ([System.IO.Path]::IsPathRooted($ownedInput)) { [System.IO.Path]::GetFullPath($ownedInput) } else { [System.IO.Path]::GetFullPath((Join-Path $target $ownedInput)) }
                    if ($inputFull.Equals($ownedPath, [System.StringComparison]::OrdinalIgnoreCase)) { throw 'OutputJson must not replace application inputs, metadata, contracts, or changed-file evidence.' }
                }
                if ([System.IO.File]::Exists($inputFull)) {
                    $previousReport = Read-ForsettiSDKJson -Path $inputFull
                    if ($previousReport.validator.name -ne 'forsetti_validate') { throw 'OutputJson would overwrite an existing non-validator file.' }
                }
            }
        }
    }
    $arguments = @{ RepoRoot = $target; SDKRoot = $sdk.SDKRoot; BundleRoot = $sdk.BundleRoot; Mode = $Mode; ProjectContextPath = $ProjectContextPath }
    foreach ($name in @('ContractPath', 'ManifestPath', 'ChangedFilesPath', 'OutputJson')) {
        $value = Get-Variable -Name $name -ValueOnly
        if ($value) { $arguments[$name] = $value }
    }
    if (@($ChangedFile).Count -gt 0) { $arguments.ChangedFile = $ChangedFile }
    if ($Strict) { $arguments.Strict = $true }
    & (Join-Path $sdk.SDKRoot 'core/validator/forsetti_validate.ps1') @arguments
    exit $LASTEXITCODE
} catch {
    Write-Error -Message ('Consumer validation blocked: ' + $_.Exception.Message) -ErrorAction Continue
    exit 2
}
