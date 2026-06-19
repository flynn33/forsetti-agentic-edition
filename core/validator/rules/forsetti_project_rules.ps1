# Forsetti project rule helpers for the local validator.

function Get-ForsettiRequiredProjectContextFields {
    return @(
        "repository_mode",
        "forsetti_edition",
        "target_platform",
        "framework_version",
        "edition_profile",
        "manifest_schema_version",
        "manifest_template_version",
        "deployment_pattern",
        "module_type",
        "capabilities_requested",
        "runtime_requirements_declared",
        "uses_public_api_only",
        "touches_framework_internals"
    )
}

function Get-ForsettiCapabilityUseMap {
    return [ordered]@{
        storage          = @("StorageService", "storage", "UserDefaults", "filesystem", "file system")
        secure_storage   = @("SecureStorage", "Keychain", "DPAPI", "credential")
        networking       = @("URLSession", "WinHTTP", "HttpClient", "network", "socket")
        file_export      = @("export", "save panel", "NSSavePanel", "IFileSaveDialog")
        toolbar_items    = @("toolbarItem", "toolbar_items", "ToolbarItem")
        view_injection   = @("viewInjection", "view_injection", "injectView", "contributeView")
        routing_overlay  = @("routing_overlay", "routeIDs", "overlay route")
        ui_theme_mask    = @("ui_theme_mask", "themeIDs", "theme mask")
        event_publishing = @("event_publishing", "publishEvent", "EventPublisher")
    }
}

function Get-ForsettiManifestRuntimeRequirementFields {
    return @("io", "ui", "dataIsolation")
}
