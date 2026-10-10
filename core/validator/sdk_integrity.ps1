# Portable integrity checks for immutable governance SDK and bundle resources.

function Assert-ForsettiJSONKeys {
    param($Element)
    if ($Element.ValueKind -eq [System.Text.Json.JsonValueKind]::Object) {
        $names = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        foreach ($property in $Element.EnumerateObject()) {
            if (-not $names.Add($property.Name)) { throw "Duplicate JSON property: $($property.Name)" }
            Assert-ForsettiJSONKeys -Element $property.Value
        }
    } elseif ($Element.ValueKind -eq [System.Text.Json.JsonValueKind]::Array) {
        foreach ($item in $Element.EnumerateArray()) { Assert-ForsettiJSONKeys -Element $item }
    }
}

function Read-ForsettiSDKJson {
    param([Parameter(Mandatory)][string]$Path)
    $text = [System.IO.File]::ReadAllText($Path)
    $document = [System.Text.Json.JsonDocument]::Parse($text)
    try { Assert-ForsettiJSONKeys -Element $document.RootElement } finally { $document.Dispose() }
    return ($text | ConvertFrom-Json)
}

function Resolve-ForsettiTrustedPath {
    param([Parameter(Mandatory)][string]$Root, [Parameter(Mandatory)][string]$RelativePath)
    if ($RelativePath -match '[\\:<>"|?*\x00-\x1f]' -or $RelativePath.StartsWith('/') -or
        @($RelativePath.Split('/') | Where-Object { $_ -in @('', '.', '..') -or $_ -match '[. ]$' -or $_ -match '^(?i:CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(?:\..*)?$' }).Count -gt 0) {
        throw "Unsafe trusted inventory path: $RelativePath"
    }
    $rootPath = [System.IO.Path]::GetFullPath($Root).TrimEnd([char[]]'\/')
    if (-not [System.IO.Directory]::Exists($rootPath)) { throw "Trusted root is missing: $Root" }
    $current = $rootPath
    foreach ($part in @('') + $RelativePath.Split('/')) {
        if ($part) { $current = Join-Path $current $part }
        try {
            $attributes = [System.IO.File]::GetAttributes($current)
            if (($attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "Links are not allowed in trusted resources: $current"
            }
        } catch [System.IO.FileNotFoundException] { } catch [System.IO.DirectoryNotFoundException] { }
    }
    return $current
}

function Get-ForsettiSHA256 {
    param([Parameter(Mandatory)][string]$Path)
    $stream = [System.IO.File]::OpenRead($Path)
    $digest = [System.Security.Cryptography.SHA256]::Create()
    try { return [System.BitConverter]::ToString($digest.ComputeHash($stream)).Replace('-', '').ToLowerInvariant() }
    finally { $digest.Dispose(); $stream.Dispose() }
}

function Resolve-ForsettiPhysicalPath {
    param([Parameter(Mandatory)][string]$Path, [int]$LinkDepth = 0)
    if ($LinkDepth -gt 40) { throw "Physical path link depth exceeds the safe limit: $Path" }
    $full = [System.IO.Path]::GetFullPath($Path)
    $current = [System.IO.Path]::GetPathRoot($full)
    foreach ($part in $full.Substring($current.Length).Split([System.IO.Path]::DirectorySeparatorChar)) {
        if (-not $part) { continue }
        $current = [System.IO.Path]::Combine($current, $part)
        try {
            $attributes = [System.IO.File]::GetAttributes($current)
            if (($attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                $info = if (($attributes -band [System.IO.FileAttributes]::Directory) -ne 0) { [System.IO.DirectoryInfo]::new($current) } else { [System.IO.FileInfo]::new($current) }
                $destination = $info.ResolveLinkTarget($true)
                if ($null -eq $destination) { throw "Cannot resolve physical path: $current" }
                $current = Resolve-ForsettiPhysicalPath -Path $destination.FullName -LinkDepth ($LinkDepth + 1)
            }
        } catch [System.IO.FileNotFoundException] { } catch [System.IO.DirectoryNotFoundException] { }
    }
    return $current
}

function Test-ForsettiInventory {
    param([string]$Root, $Entries, [string[]]$UnhashedFiles)
    $expected = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $directories = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($entry in @($Entries)) {
        $relative = [string]$entry.path
        $path = Resolve-ForsettiTrustedPath -Root $Root -RelativePath $relative
        if (-not $expected.Add($relative)) { throw "Duplicate inventory path: $relative" }
        if ([string]$entry.sha256 -cnotmatch '^[a-f0-9]{64}$') { throw "Invalid SHA-256 inventory value: $relative" }
        if (-not [System.IO.File]::Exists($path)) { throw "Missing trusted file: $relative" }
        if ((Get-ForsettiSHA256 -Path $path) -cne [string]$entry.sha256) { throw "Altered trusted file: $relative" }
    }
    foreach ($relative in @($UnhashedFiles)) {
        $null = Resolve-ForsettiTrustedPath -Root $Root -RelativePath $relative
        if (-not $expected.Add($relative)) { throw "Self-referential inventory path: $relative" }
    }
    foreach ($relative in $expected) {
        $parts = $relative.Split('/')
        for ($index = 1; $index -lt $parts.Count; $index++) {
            [void]$directories.Add(($parts[0..($index - 1)] -join '/'))
        }
    }
    $rootPath = [System.IO.Path]::GetFullPath($Root).TrimEnd([char[]]'\/')
    $queue = [System.Collections.Generic.Stack[System.IO.DirectoryInfo]]::new()
    $queue.Push([System.IO.DirectoryInfo]::new($rootPath))
    while ($queue.Count -gt 0) {
      foreach ($item in $queue.Pop().EnumerateFileSystemInfos()) {
        $relative = $item.FullName.Substring($rootPath.Length + 1).Replace('\', '/')
        if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Links are not allowed in trusted resources: $relative" }
        if (($item.Attributes -band [System.IO.FileAttributes]::Directory) -ne 0) {
            if (-not $directories.Contains($relative)) { throw "Unexpected trusted directory: $relative" }
            $queue.Push([System.IO.DirectoryInfo]$item)
        } elseif (-not $expected.Contains($relative)) { throw "Unexpected trusted file: $relative" }
      }
    }
    return $expected
}

function Test-ForsettiBundleIntegrity {
    param([Parameter(Mandatory)][string]$BundleRoot)
    $manifestPath = Resolve-ForsettiTrustedPath -Root $BundleRoot -RelativePath 'product-manifest.json'
    $manifest = Read-ForsettiSDKJson -Path $manifestPath
    if ($manifest.schemaVersion -ne '2.0' -or $manifest.product -ne 'Forsetti Agentic Edition' -or
        $manifest.platform -ne 'source' -or $manifest.architecture -ne 'portable' -or $null -ne $manifest.entryPoint) {
        throw 'Unsupported source governance bundle identity or schema.'
    }
    if (@($manifest.files).Count -eq 0 -or @($manifest.files | Where-Object { $_.required -ne $true }).Count -gt 0) {
        throw 'Every source governance bundle inventory entry must be required.'
    }
    $null = Test-ForsettiInventory -Root $BundleRoot -Entries $manifest.files -UnhashedFiles @('product-manifest.json')
    if ([System.IO.File]::ReadAllText((Join-Path $BundleRoot 'VERSION')).Trim() -ne $manifest.version -or
        $manifest.bundleID -ne ('ffae-' + $manifest.version + '-source')) { throw 'Bundle version identity is inconsistent.' }
    $stream = [System.IO.MemoryStream]::new()
    try {
        foreach ($entry in @($manifest.files | Sort-Object -Property path -CaseSensitive)) {
            if ([string]$entry.path -match '^(policies|editions|schemas)/') {
                $bytes = [System.Text.Encoding]::UTF8.GetBytes([string]$entry.path + [char]0 + [string]$entry.sha256 + [char]0)
                $stream.Write($bytes, 0, $bytes.Length)
            }
        }
        $digest = [System.Security.Cryptography.SHA256]::Create()
        try { $hash = [System.BitConverter]::ToString($digest.ComputeHash($stream.ToArray())).Replace('-', '').ToLowerInvariant() }
        finally { $digest.Dispose() }
    } finally { $stream.Dispose() }
    if ($hash -cne [string]$manifest.policyBundleHash) { throw 'Policy bundle aggregate hash is inconsistent.' }
    return $manifest
}

function Test-ForsettiSDKIntegrity {
    param([Parameter(Mandatory)][string]$SDKRoot)
    $rootPath = [System.IO.Path]::GetFullPath($SDKRoot)
    $manifestPath = Resolve-ForsettiTrustedPath -Root $rootPath -RelativePath 'sdk-manifest.json'
    $manifest = Read-ForsettiSDKJson -Path $manifestPath
    if ($manifest.schemaVersion -ne '1.0' -or $manifest.product -ne 'Forsetti Agentic Edition SDK' -or
        $manifest.variant -notin @('portable', 'macos-arm64') -or
        [string]$manifest.sourceRevision -cnotmatch '^[a-f0-9]{40}$') { throw 'Unsupported SDK identity, variant, provenance or schema.' }
    $null = Test-ForsettiInventory -Root $rootPath -Entries $manifest.files -UnhashedFiles @('sdk-manifest.json')
    $map = Read-ForsettiSDKJson -Path (Join-Path $rootPath 'payload-map.json')
    if ($map.schemaVersion -ne '1.0' -or @($map.entries).Count -eq 0) { throw 'Unsupported or empty SDK payload map.' }
    $destinations = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $sourceCopies = [System.Collections.Generic.Dictionary[string,string]]::new([System.StringComparer]::Ordinal)
    foreach ($entry in @($map.entries)) {
        $null = Resolve-ForsettiTrustedPath -Root $rootPath -RelativePath ([string]$entry.destination)
        if (-not $destinations.Add([string]$entry.destination)) { throw "Duplicate payload destination: $($entry.destination)" }
        $null = Resolve-ForsettiTrustedPath -Root $rootPath -RelativePath ([string]$entry.source)
        $copyHash = Get-ForsettiSHA256 -Path (Join-Path $rootPath ([string]$entry.destination))
        if ($sourceCopies.ContainsKey([string]$entry.source) -and $sourceCopies[[string]$entry.source] -cne $copyHash) {
            throw "Mapped canonical source copies differ: $($entry.source)"
        }
        $sourceCopies[[string]$entry.source] = $copyHash
    }
    if (-not $destinations.Add('payload-map.json')) { throw 'Payload map cannot map itself.' }
    if ($manifest.variant -eq 'macos-arm64' -and -not $destinations.Add('bin/forsetti-governance')) { throw 'Native binary must be a build asset, not a source mapping.' }
    $inventory = @($manifest.files | ForEach-Object { [string]$_.path })
    if ($inventory.Count -ne $destinations.Count -or @($inventory | Where-Object { -not $destinations.Contains($_) }).Count -gt 0) {
        throw 'SDK inventory differs from reviewed payload map and host asset.'
    }
    $approvedOutputs = @('AGENTS.md', '.forsetti/project.json', '.forsetti/modules.json', '.forsetti/project-context.json', '.forsetti/profile.lock.json', '.forsetti/policy.lock.json', '.forsetti/product.lock.json', '.forsetti/instructions/GOVERNANCE.md')
    $generated = @($manifest.generatedDestinations)
    if ($generated.Count -ne $approvedOutputs.Count -or @($generated | Sort-Object -Unique).Count -ne $generated.Count -or
        @($generated | Where-Object { $_ -notin $approvedOutputs }).Count -gt 0) { throw 'SDK generated destinations differ from the approved consumer outputs.' }
    $bundleRoot = Join-Path $rootPath 'bundle'
    $bundle = Test-ForsettiBundleIntegrity -BundleRoot $bundleRoot
    if ($manifest.version -ne $bundle.version -or
        [System.IO.File]::ReadAllText((Join-Path $rootPath 'VERSION')).Trim() -ne $manifest.version -or
        (Get-ForsettiSHA256 -Path (Join-Path $bundleRoot 'product-manifest.json')) -cne $manifest.bundleManifestSHA256) {
        throw 'SDK/bundle release version or manifest hash is inconsistent.'
    }
    if ($manifest.consumptionPolicy.sourcePath -ne 'CONSUMPTION_POLICY.md' -or
        $manifest.consumptionPolicy.sourceRevision -ne $manifest.sourceRevision -or
        (Get-ForsettiSHA256 -Path (Join-Path $rootPath 'CONSUMPTION_POLICY.md')) -cne $manifest.consumptionPolicy.sha256) {
        throw 'Complete consumption policy provenance is inconsistent.'
    }
    return [pscustomobject]@{ SDKManifest = $manifest; BundleManifest = $bundle; SDKRoot = $rootPath; BundleRoot = $bundleRoot }
}
