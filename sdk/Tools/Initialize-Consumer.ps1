#requires -Version 7.4
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RepositoryRoot,
    [Parameter(Mandatory)][string]$ProjectContextPath,
    [string]$SDKRoot = (Split-Path -Parent $PSScriptRoot),
    [switch]$DryRun,
    [string]$UpgradeFromSDKRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'SDK-Integrity.ps1')
$trusted = Test-ForsettiSDKIntegrity -SDKRoot $SDKRoot
$SDKRoot = $trusted.SDKRoot
$bundleRoot = $trusted.BundleRoot
$previous = if ($UpgradeFromSDKRoot) { Test-ForsettiSDKIntegrity -SDKRoot $UpgradeFromSDKRoot } else { $null }
$RepositoryRoot = [IO.Path]::GetFullPath($RepositoryRoot)
$utf8 = [Text.UTF8Encoding]::new($false, $true)

function Test-NestedPath([string]$Child, [string]$Parent) {
    $prefix = $Parent.TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    return $Child.Equals($Parent, [StringComparison]::OrdinalIgnoreCase) -or $Child.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)
}

function Assert-SafeTargetPath([string]$Path) {
    $current = [IO.Path]::GetFullPath($Path)
    if (-not (Test-NestedPath $current $RepositoryRoot)) { throw "Installation path escapes repository: $Path" }
    while ($true) {
        $item = Get-Item -LiteralPath $current -Force -ErrorAction SilentlyContinue
        if ($null -ne $item -and ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            throw "Installation path uses a symbolic link or reparse point: $current"
        }
        if ($current -eq $RepositoryRoot) { break }
        $current = [IO.Path]::GetDirectoryName($current)
    }
}

function Read-Bytes([string]$Path) {
    if ([IO.Directory]::Exists($Path)) { throw "Expected file is a directory: $Path" }
    if ([IO.File]::Exists($Path)) { return ,([IO.File]::ReadAllBytes($Path)) }
    return $null
}

function Read-Object([string]$Path) {
    $bytes = Read-Bytes $Path
    if ($null -eq $bytes) { return $null }
    $text = $utf8.GetString($bytes).TrimStart([char]0xfeff)
    $document = [Text.Json.JsonDocument]::Parse($text)
    try { Assert-ForsettiJSONKeys -Element $document.RootElement } finally { $document.Dispose() }
    $object = ConvertFrom-Json -InputObject $text -AsHashtable -Depth 64
    if ($object -isnot [Collections.IDictionary]) { throw "Expected JSON object: $Path" }
    return $object
}

function Test-EqualValue($Left, $Right) {
    if ($null -eq $Left -or $null -eq $Right) { return $null -eq $Left -and $null -eq $Right }
    if ($Left -is [Collections.IDictionary]) {
        if ($Right -isnot [Collections.IDictionary] -or $Left.Count -ne $Right.Count) { return $false }
        foreach ($key in $Left.Keys) {
            if (-not $Right.Contains($key) -or -not (Test-EqualValue $Left[$key] $Right[$key])) { return $false }
        }
        return $true
    }
    if ($Left -is [Collections.IList]) {
        if ($Right -isnot [Collections.IList] -or $Left.Count -ne $Right.Count) { return $false }
        for ($index = 0; $index -lt $Left.Count; $index++) {
            if (-not (Test-EqualValue $Left[$index] $Right[$index])) { return $false }
        }
        return $true
    }
    if ($Left -is [bool] -or $Right -is [bool]) { return $Left.GetType() -eq $Right.GetType() -and $Left -eq $Right }
    return $Left -ceq $Right
}

function JSON-Bytes($Object) { return ,($utf8.GetBytes(($Object | ConvertTo-Json -Depth 64) + "`n")) }
function Test-EqualBytes($Left, $Right) {
    if ($null -eq $Left -or $null -eq $Right) { return $null -eq $Left -and $null -eq $Right }
    return [Convert]::ToBase64String($Left) -ceq [Convert]::ToBase64String($Right)
}
function File-Hash([string]$Path) { return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }

$begin = '<!-- FORSETTI-GOVERNANCE:BEGIN -->'
$end = '<!-- FORSETTI-GOVERNANCE:END -->'
function Get-ManagedBlock([string]$Text) {
    $beginCount = [regex]::Matches($Text, [regex]::Escape($begin)).Count
    $endCount = [regex]::Matches($Text, [regex]::Escape($end)).Count
    if ($beginCount -eq 0 -and $endCount -eq 0) { return $null }
    $start = $Text.IndexOf($begin, [StringComparison]::Ordinal)
    $finish = $Text.IndexOf($end, [StringComparison]::Ordinal)
    if ($beginCount -ne 1 -or $endCount -ne 1 -or $finish -lt $start) { throw 'Malformed or duplicate FORSETTI-GOVERNANCE block in AGENTS.md.' }
    return @{Start = $start; Length = $finish + $end.Length - $start; Text = $Text.Substring($start, $finish + $end.Length - $start)}
}

if (-not [IO.Directory]::Exists($RepositoryRoot) -or -not (Test-Path -LiteralPath (Join-Path $RepositoryRoot '.git'))) {
    throw 'RepositoryRoot must be an existing Git repository; initialization never creates an application or Git repository.'
}
$physicalRepositoryRoot = Resolve-ForsettiPhysicalPath -Path $RepositoryRoot
$physicalSDKRoot = Resolve-ForsettiPhysicalPath -Path $SDKRoot
if ((Test-NestedPath $physicalRepositoryRoot $physicalSDKRoot) -or (Test-NestedPath $physicalSDKRoot $physicalRepositoryRoot)) {
    throw 'Install the immutable SDK outside the governed repository.'
}
if ($null -ne $previous) {
    $physicalPreviousRoot = Resolve-ForsettiPhysicalPath -Path $previous.SDKRoot
    if ((Test-NestedPath $physicalRepositoryRoot $physicalPreviousRoot) -or (Test-NestedPath $physicalPreviousRoot $physicalRepositoryRoot)) {
        throw 'The previous SDK must also remain outside the governed repository.'
    }
}

$context = Read-Object ([IO.Path]::GetFullPath($ProjectContextPath))
if ($null -eq $context) { throw 'An authored project context JSON file is required.' }
# The reusable template contains a schema-location hint; the governed context schema owns the data fields.
$null = $context.Remove('$schema')
$schemaPath = Join-Path $SDKRoot 'core/schemas/forsetti-project-context.schema.json'
if (-not (Test-Json -Json ($context | ConvertTo-Json -Depth 64) -SchemaFile $schemaPath)) { throw 'Project context does not match the approved schema.' }
if ($context.repository_mode -notin @('consumer_app_repo', 'module_repo', 'sample_repo')) { throw 'This installer supports consumer, module and sample repositories only.' }
if (($context.module_type -ne 'not_applicable') -and [string]::IsNullOrWhiteSpace($context.module_id)) { throw 'A module-bearing context requires its actual module_id.' }
if (-not $context.uses_public_api_only -or $context.touches_framework_internals) { throw 'Consumer initialization requires public API-only use and sealed framework internals.' }
$profileRelative = "editions/$($context.forsetti_edition)/forsetti-$($context.forsetti_edition)-$($context.framework_version).profile.json"
if ($context.edition_profile -cne $profileRelative) { throw 'edition_profile must exactly name the selected trusted edition/framework version.' }
$profilePath = Join-Path $bundleRoot $profileRelative
if (-not [IO.File]::Exists($profilePath)) { throw 'Unknown framework version has no trusted edition profile.' }
$profile = Read-Object $profilePath
if ($profile.edition -cne $context.forsetti_edition -or $profile.frameworkVersion -cne $context.framework_version -or
    $context.target_platform -cnotin $profile.supportedPlatforms -or
    $context.manifest_schema_version -cne $profile.manifest.currentSchemaVersion -or
    $context.manifest_template_version -cne $profile.manifest.currentTemplateVersion) { throw 'Project context does not match the trusted profile.' }
foreach ($capability in $context.capabilities_requested) {
    if ($capability -cnotin $profile.capabilities) { throw "Capability is unavailable in the selected edition profile: $capability" }
}

$directories = @('.forsetti', '.forsetti/instructions', '.forsetti/contracts', '.forsetti/tasks', '.forsetti/evidence', '.forsetti/validation')
$destinations = @('AGENTS.md', '.forsetti/project.json', '.forsetti/project-context.json', '.forsetti/modules.json',
    '.forsetti/profile.lock.json', '.forsetti/policy.lock.json', '.forsetti/product.lock.json', '.forsetti/instructions/GOVERNANCE.md')
foreach ($relative in @($directories) + @($destinations)) {
    Assert-SafeTargetPath (Join-Path $RepositoryRoot $relative)
}
foreach ($relative in $directories) {
    $path = Join-Path $RepositoryRoot $relative
    if ([IO.File]::Exists($path)) { throw "Expected directory is a file: $relative" }
}
foreach ($relative in $destinations) {
    if ($relative -cnotin $trusted.SDKManifest.generatedDestinations) { throw "Destination is not allowlisted by the SDK: $relative" }
}

$version = $trusted.BundleManifest.version
$now = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
$oldProject = Read-Object (Join-Path $RepositoryRoot '.forsetti/project.json')
if ($null -ne $previous -and $null -eq $oldProject) { throw 'An explicit upgrade requires an existing initialized project.' }
$repositoryType = @{consumer_app_repo = 'application_repository'; module_repo = 'module_repository'; sample_repo = 'sample_repository'}[$context.repository_mode]
$name = [IO.Path]::GetFileName($RepositoryRoot.TrimEnd([IO.Path]::DirectorySeparatorChar)) -replace '[^\p{L}\p{N}.-]', '-'
$name = $name.Trim('-.')
if ($name.Length -lt 3) { $name = 'forsetti-project' }
$project = [ordered]@{schemaVersion = '2.0'; projectID = $name; repositoryType = $repositoryType;
    edition = $context.forsetti_edition; targetPlatforms = @($context.target_platform); frameworkVersion = $context.framework_version;
    deploymentPattern = $context.deployment_pattern; modulesPath = '.forsetti/modules.json'; profileLockPath = '.forsetti/profile.lock.json';
    policyLockPath = '.forsetti/policy.lock.json'; productLockPath = '.forsetti/product.lock.json';
    initializedAtUTC = $(if ($oldProject) { $oldProject.initializedAtUTC } else { $now });
    initializedByVersion = $(if ($oldProject) { $oldProject.initializedByVersion } else { $version })}
if ($oldProject -and -not (Test-EqualValue $oldProject $project)) { throw 'Existing native project.json differs from the authored selection; it was preserved.' }
$oldContext = Read-Object (Join-Path $RepositoryRoot '.forsetti/project-context.json')
if ($oldContext -and -not (Test-EqualValue $oldContext $context)) { throw 'Existing project-context.json differs from the authored context; it was preserved.' }
$modules = Read-Object (Join-Path $RepositoryRoot '.forsetti/modules.json')
if ($modules) {
    if ($modules.schemaVersion -cne '2.0' -or $modules.modules -isnot [Collections.IList]) { throw 'Existing module inventory is malformed; it was preserved.' }
} else { $modules = [ordered]@{schemaVersion = '2.0'; modules = @()} }

function Make-Locks($Installation) {
    $manifest = $Installation.BundleManifest
    $profileFile = Join-Path $Installation.BundleRoot $profileRelative
    if (-not [IO.File]::Exists($profileFile)) { throw 'The previous SDK does not contain the selected profile; explicit profile migration is required.' }
    $hash = File-Hash $profileFile
    $profileLock = Read-Object (Join-Path $RepositoryRoot '.forsetti/profile.lock.json')
    $policyLock = Read-Object (Join-Path $RepositoryRoot '.forsetti/policy.lock.json')
    $productLock = Read-Object (Join-Path $RepositoryRoot '.forsetti/product.lock.json')
    return @{
        '.forsetti/profile.lock.json' = [ordered]@{schemaVersion = '2.0'; profileID = "forsetti-$($context.forsetti_edition)-$($context.framework_version)";
            profileVersion = $manifest.version; frameworkVersion = $context.framework_version; sourceRevision = $hash; supportStatus = 'supported';
            lockedAtUTC = $(if ($profileLock) { $profileLock.lockedAtUTC } else { $now }); sha256 = $hash};
        '.forsetti/policy.lock.json' = [ordered]@{schemaVersion = '2.0'; policyBundleID = "ffae-policy-$($manifest.version)"; policyBundleVersion = $manifest.version;
            lockedAtUTC = $(if ($policyLock) { $policyLock.lockedAtUTC } else { $now }); sha256 = $manifest.policyBundleHash};
        '.forsetti/product.lock.json' = [ordered]@{schemaVersion = '2.0'; productVersion = $manifest.version; bundleID = $manifest.bundleID;
            platform = $(if ($context.forsetti_edition -eq 'windows') { 'windows-host' } else { 'apple-host' });
            lockedAtUTC = $(if ($productLock) { $productLock.lockedAtUTC } else { $now }); sha256 = (File-Hash (Join-Path $Installation.BundleRoot 'product-manifest.json'))}
    }
}
$locks = Make-Locks $trusted
$expectedExistingLocks = if ($null -ne $previous) { Make-Locks $previous } else { $locks }
foreach ($relative in $locks.Keys) {
    $existing = Read-Object (Join-Path $RepositoryRoot $relative)
    if (($null -ne $previous -and $null -eq $existing) -or ($existing -and -not (Test-EqualValue $existing $expectedExistingLocks[$relative]))) {
        throw "Existing lock conflicts with the verified SDK; preserved: $relative"
    }
}

$instructionBytes = [IO.File]::ReadAllBytes((Join-Path $bundleRoot 'instructions/target-agents-section.md'))
$instruction = $utf8.GetString($instructionBytes).Trim()
$null = Get-ManagedBlock $instruction
$expectedInstructionBytes = if ($null -ne $previous) { [IO.File]::ReadAllBytes((Join-Path $previous.BundleRoot 'instructions/target-agents-section.md')) } else { $instructionBytes }
$expectedInstruction = $utf8.GetString($expectedInstructionBytes).Trim()
$existingGovernance = Read-Bytes (Join-Path $RepositoryRoot '.forsetti/instructions/GOVERNANCE.md')
if (($null -ne $previous -and $null -eq $existingGovernance) -or ($null -ne $existingGovernance -and -not (Test-EqualBytes $existingGovernance $expectedInstructionBytes))) {
    throw 'Existing GOVERNANCE.md differs from the verified SDK; it was preserved.'
}
$agentsBytes = Read-Bytes (Join-Path $RepositoryRoot 'AGENTS.md')
$agentsText = if ($null -ne $agentsBytes) { $utf8.GetString($agentsBytes) } else { '' }
$block = Get-ManagedBlock $agentsText
if ($null -ne $block) {
    if ($block.Text -cne $expectedInstruction) { throw 'Managed AGENTS.md content differs from the verified SDK; it was preserved.' }
    $newAgents = $agentsText.Substring(0, $block.Start) + $instruction + $agentsText.Substring($block.Start + $block.Length)
} else {
    if ($null -ne $previous) { throw 'An explicit upgrade requires the existing managed AGENTS.md block.' }
    $separator = if ($agentsText.Length -eq 0) { '' } elseif ($agentsText.EndsWith("`n")) { "`n" } else { "`n`n" }
    $newAgents = $agentsText + $separator + $instruction + "`n"
}

$objects = @{'.forsetti/project.json' = $project; '.forsetti/project-context.json' = $context; '.forsetti/modules.json' = $modules}
foreach ($relative in $locks.Keys) { $objects[$relative] = $locks[$relative] }
$plan = [Collections.Generic.List[object]]::new()
foreach ($relative in $destinations) {
    $path = Join-Path $RepositoryRoot $relative
    $old = Read-Bytes $path
    $data = if ($relative -eq 'AGENTS.md') { $utf8.GetBytes($newAgents) } elseif ($relative -eq '.forsetti/instructions/GOVERNANCE.md') { $instructionBytes } else { JSON-Bytes $objects[$relative] }
    if ($objects.ContainsKey($relative) -and $null -ne $old -and (Test-EqualValue (Read-Object $path) $objects[$relative])) { $data = $old }
    $plan.Add(@{Path = $path; Relative = $relative; Before = $old; After = $data; Changed = (-not (Test-EqualBytes $old $data))})
}
if ($DryRun) {
    [ordered]@{status = 'planned'; mode = 'initialize'; writes = @($plan | Where-Object Changed | ForEach-Object Relative); generatedDestinations = $destinations} | ConvertTo-Json -Depth 8
    exit 0
}

function Write-Atomic([string]$Path, [byte[]]$Bytes) {
    $temporary = Join-Path ([IO.Path]::GetDirectoryName($Path)) ('.' + [IO.Path]::GetFileName($Path) + '.tmp-' + [Guid]::NewGuid().ToString('N'))
    try { [IO.File]::WriteAllBytes($temporary, $Bytes); [IO.File]::Move($temporary, $Path, $true) }
    finally { if ([IO.File]::Exists($temporary)) { [IO.File]::Delete($temporary) } }
}
$createdDirectories = [Collections.Generic.List[string]]::new()
$written = [Collections.Generic.List[object]]::new()
try {
    foreach ($relative in $directories) {
        $path = Join-Path $RepositoryRoot $relative
        Assert-SafeTargetPath $path
        if (-not [IO.Directory]::Exists($path)) { $null = [IO.Directory]::CreateDirectory($path); $createdDirectories.Add($path) }
    }
    foreach ($write in $plan) {
        Assert-SafeTargetPath $write.Path
        if (-not (Test-EqualBytes (Read-Bytes $write.Path) $write.Before)) { throw "File changed during initialization: $($write.Relative)" }
        if ($write.Changed) { Write-Atomic $write.Path $write.After; $written.Add($write) }
    }
} catch {
    $failure = $_.Exception.Message
    $recovery = [Collections.Generic.List[string]]::new()
    for ($index = $written.Count - 1; $index -ge 0; $index--) {
        $write = $written[$index]
        try {
            Assert-SafeTargetPath $write.Path
            if (-not (Test-EqualBytes (Read-Bytes $write.Path) $write.After)) { throw 'File changed concurrently.' }
            if ($null -eq $write.Before) { [IO.File]::Delete($write.Path) } else { Write-Atomic $write.Path $write.Before }
        } catch { $recovery.Add($write.Relative) }
    }
    for ($index = $createdDirectories.Count - 1; $index -ge 0; $index--) {
        $path = $createdDirectories[$index]
        if ([IO.Directory]::Exists($path) -and [IO.Directory]::GetFileSystemEntries($path).Length -eq 0) { [IO.Directory]::Delete($path) }
    }
    if ($recovery.Count) { throw "$failure Rollback incomplete; restore these paths from your backup before retrying: $($recovery -join ', ')" }
    throw "$failure Initialization writes were rolled back."
}
[ordered]@{status = 'initialized'; mode = 'initialize'; writes = @($plan | Where-Object Changed | ForEach-Object Relative); generatedDestinations = $destinations;
    review = 'Initialization is metadata setup, not validation or an independent approval.'} | ConvertTo-Json -Depth 8
