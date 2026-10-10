#include "ForsettiGovernance/BundleVerifier.hpp"
#include "ForsettiGovernance/SHA256.hpp"

#include <optional>
#include <algorithm>
#include <cctype>
#include <regex>
#include <set>
#include <sstream>
#ifdef _WIN32
#include <windows.h>
#endif

namespace ForsettiGovernance {
namespace {

struct ManifestEntry final {
    std::string path;
    std::string sha256;
    bool required = true;
};

std::string stringField(const std::string& text, const std::string& fieldName) {
    const std::regex pattern("\"" + fieldName + "\"\\s*:\\s*\"([^\"]*)\"");
    std::smatch match;
    if (!std::regex_search(text, match, pattern)) {
        return {};
    }
    return match[1].str();
}

std::optional<bool> boolField(const std::string& text, const std::string& fieldName) {
    const std::regex pattern("\"" + fieldName + "\"\\s*:\\s*(true|false)");
    std::smatch match;
    if (!std::regex_search(text, match, pattern)) {
        return std::nullopt;
    }
    return match[1].str() == "true";
}

std::string filesArray(const std::string& manifestText) {
    const auto fieldPosition = manifestText.find("\"files\"");
    if (fieldPosition == std::string::npos) {
        return {};
    }
    const auto arrayStart = manifestText.find('[', fieldPosition);
    if (arrayStart == std::string::npos) {
        return {};
    }
    int depth = 0;
    bool inString = false;
    bool escaped = false;
    for (std::size_t index = arrayStart; index < manifestText.size(); ++index) {
        const char character = manifestText[index];
        if (escaped) {
            escaped = false;
            continue;
        }
        if (character == '\\') {
            escaped = inString;
            continue;
        }
        if (character == '"') {
            inString = !inString;
            continue;
        }
        if (inString) {
            continue;
        }
        if (character == '[') {
            ++depth;
        } else if (character == ']') {
            --depth;
            if (depth == 0) {
                return manifestText.substr(arrayStart + 1U, index - arrayStart - 1U);
            }
        }
    }
    return {};
}

std::vector<std::string> objectTexts(const std::string& arrayText) {
    std::vector<std::string> objects;
    int depth = 0;
    bool inString = false;
    bool escaped = false;
    std::size_t objectStart = 0;
    for (std::size_t index = 0; index < arrayText.size(); ++index) {
        const char character = arrayText[index];
        if (escaped) {
            escaped = false;
            continue;
        }
        if (character == '\\') {
            escaped = inString;
            continue;
        }
        if (character == '"') {
            inString = !inString;
            continue;
        }
        if (inString) {
            continue;
        }
        if (character == '{') {
            if (depth == 0) {
                objectStart = index;
            }
            ++depth;
        } else if (character == '}') {
            --depth;
            if (depth == 0) {
                objects.push_back(arrayText.substr(objectStart, index - objectStart + 1U));
            }
        }
    }
    return objects;
}

std::vector<ManifestEntry> parseEntries(const std::string& manifestText) {
    std::vector<ManifestEntry> entries;
    for (const auto& objectText : objectTexts(filesArray(manifestText))) {
        const auto required = boolField(objectText, "required");
        ManifestEntry entry{
            stringField(objectText, "path"),
            stringField(objectText, "sha256"),
            required.value_or(true)};
        entries.push_back(entry);
    }
    return entries;
}

bool unsafeManifestPath(const std::string& path) {
    if (path.empty() || path.front() == '/' || path.back() == '/' || path.find('\\') != std::string::npos || path.find(':') != std::string::npos) {
        return true;
    }
    std::istringstream parts(path);
    std::string part;
    while (std::getline(parts, part, '/')) {
        if (part.empty() || part == "." || part == "..") {
            return true;
        }
    }
    return false;
}

bool unsafeLink(const std::filesystem::path& path, const std::filesystem::path& root) {
    auto current = path;
    for (;;) {
        std::error_code error;
        if (std::filesystem::is_symlink(std::filesystem::symlink_status(current, error))) { return true; }
#ifdef _WIN32
        const auto attributes = GetFileAttributesW(current.c_str());
        if (attributes != INVALID_FILE_ATTRIBUTES && (attributes & FILE_ATTRIBUTE_REPARSE_POINT) != 0) { return true; }
#endif
        if (current == root || current.empty() || current == current.parent_path()) { break; }
        current = current.parent_path();
    }
    return false;
}

std::string portablePathKey(std::string path) {
    std::transform(path.begin(), path.end(), path.begin(), [](unsigned char value) { return static_cast<char>(std::tolower(value)); });
    return path;
}

ValidationFinding blockingFinding(
    const std::string& conditionID,
    const std::string& message,
    const std::string& path,
    const std::vector<std::string>& evidence) {
    return ValidationFinding{
        "FAE-F020",
        conditionID,
        "critical",
        ValidationStatus::Block,
        message,
        path,
        evidence,
        "Restore the verified product bundle."};
}

} // namespace

SimpleBundleVerifier::SimpleBundleVerifier(const IFileSystem& fileSystem)
    : fileSystem_(fileSystem) {}

ValidationResult SimpleBundleVerifier::verify(const std::filesystem::path& bundleRoot) const {
    const auto manifestPath = bundleRoot / "product-manifest.json";
    if (unsafeLink(manifestPath, bundleRoot)) {
        return ValidationResult{"2.0", ValidationStatus::Block, "bundle verify", "1.2.0", "bundle-verification",
            {blockingFinding("bundle.path.unsafe-link", "Bundle paths must not use symbolic links or reparse points.", "product-manifest.json", {manifestPath.string()})}};
    }
    if (!fileSystem_.fileExists(manifestPath)) {
        return ValidationResult{
            "2.0",
            ValidationStatus::Block,
            "bundle verify",
            "1.2.0",
            "bundle-verification",
            {ValidationFinding{
                "FAE-F020",
                "bundle.manifest.missing",
                "critical",
                ValidationStatus::Block,
                "Product manifest is missing.",
                "product-manifest.json",
                {manifestPath.string()},
                "Install or rebuild the product bundle."}}};
    }

    const auto manifestText = fileSystem_.readText(manifestPath);
    std::vector<ValidationFinding> findings;
    bool blocked = false;

    const auto schemaVersion = stringField(manifestText, "schemaVersion");
    const auto productVersion = stringField(manifestText, "version");
    const auto bundleID = stringField(manifestText, "bundleID");
    const auto platform = stringField(manifestText, "platform");

    if (schemaVersion != "2.0") {
        blocked = true;
        findings.push_back(blockingFinding(
            "bundle.manifest.unsupported-version",
            "Product manifest schema version is unsupported.",
            "product-manifest.json",
            {schemaVersion}));
    }

    const auto lockPath = bundleRoot / "product-lock.json";
    if (unsafeLink(lockPath, bundleRoot)) {
        blocked = true;
        findings.push_back(blockingFinding("bundle.path.unsafe-link", "Bundle paths must not use symbolic links or reparse points.", "product-lock.json", {lockPath.string()}));
    } else if (fileSystem_.fileExists(lockPath)) {
        const auto lockText = fileSystem_.readText(lockPath);
        const auto manifestHash = sha256Hex(manifestText);
        const auto lockSchemaVersion = stringField(lockText, "schemaVersion");
        const auto lockProductVersion = stringField(lockText, "productVersion");
        const auto lockBundleID = stringField(lockText, "bundleID");
        const auto lockPlatform = stringField(lockText, "platform");
        const auto lockHash = stringField(lockText, "sha256");
        if (lockSchemaVersion != "2.0") {
            blocked = true;
            findings.push_back(blockingFinding(
                "bundle.product-lock.unsupported-version",
                "Product lock schema version is unsupported.",
                "product-lock.json",
                {lockSchemaVersion}));
        }
        if (lockProductVersion != productVersion || lockBundleID != bundleID || lockPlatform != platform || lockHash != manifestHash) {
            blocked = true;
            findings.push_back(blockingFinding(
                "bundle.product-lock.mismatch",
                "Product lock does not match the verified manifest.",
                "product-lock.json",
                {
                    "lockVersion=" + lockProductVersion,
                    "manifestVersion=" + productVersion,
                    "lockBundleID=" + lockBundleID,
                    "manifestBundleID=" + bundleID,
                    "lockPlatform=" + lockPlatform,
                    "manifestPlatform=" + platform,
                    "lockHash=" + lockHash,
                    "manifestHash=" + manifestHash}));
        }
    }

    std::set<std::string> seenPaths;
    const auto entries = parseEntries(manifestText);
    if (entries.empty()) {
        blocked = true;
        findings.push_back(blockingFinding(
            "bundle.manifest.files-missing",
            "Product manifest has no file entries.",
            "product-manifest.json",
            {"files"}));
    }

    for (const auto& entry : entries) {
        if (unsafeManifestPath(entry.path)) {
            blocked = true;
            findings.push_back(blockingFinding(
                "bundle.path.invalid",
                "Bundle manifest contains an invalid path.",
                entry.path,
                {entry.path}));
            continue;
        }
        if (!seenPaths.insert(portablePathKey(entry.path)).second) {
            blocked = true;
            findings.push_back(blockingFinding(
                "bundle.path.duplicate",
                "Bundle manifest contains a duplicate path.",
                entry.path,
                {entry.path}));
            continue;
        }
        const auto filePath = bundleRoot / std::filesystem::path(entry.path);
        if (unsafeLink(filePath, bundleRoot)) {
            blocked = true;
            findings.push_back(blockingFinding("bundle.path.unsafe-link", "Bundle paths must not use symbolic links or reparse points.", entry.path, {filePath.string()}));
            continue;
        }
        if (!fileSystem_.fileExists(filePath)) {
            if (entry.required) {
                blocked = true;
                findings.push_back(blockingFinding(
                    "bundle.file.missing",
                    "Required bundle file is missing.",
                    entry.path,
                    {filePath.string()}));
            }
            continue;
        }
        const auto actual = sha256Hex(fileSystem_.readText(filePath));
        if (actual != entry.sha256) {
            blocked = true;
            findings.push_back(blockingFinding(
                "bundle.file.hash-mismatch",
                "Bundle file hash does not match manifest.",
                entry.path,
                {"expected=" + entry.sha256, "actual=" + actual}));
        }
    }

    std::set<std::string> allowedPaths{"product-manifest.json", "product-lock.json"};
    for (const auto& entry : entries) { allowedPaths.insert(entry.path); }
    std::set<std::string> allowedDirectories;
    for (const auto& entry : entries) {
        auto directory = std::filesystem::path(entry.path).parent_path();
        while (!directory.empty()) {
            allowedDirectories.insert(directory.generic_string());
            directory = directory.parent_path();
        }
    }
    std::error_code walkError;
    std::filesystem::recursive_directory_iterator iterator(bundleRoot, walkError), end;
    for (; !walkError && iterator != end; iterator.increment(walkError)) {
        const auto path = iterator->path();
        const auto relative = path.lexically_relative(bundleRoot).generic_string();
        if (unsafeLink(path, bundleRoot)) {
            iterator.disable_recursion_pending();
            blocked = true;
            findings.push_back(blockingFinding("bundle.path.unsafe-link", "Bundle paths must not use symbolic links or reparse points.", relative, {path.string()}));
        } else if (iterator->is_directory() && !allowedDirectories.contains(relative)) {
            blocked = true;
            findings.push_back(blockingFinding("bundle.directory.unexpected", "Bundle contains an unlisted directory.", relative, {relative}));
        } else if (!iterator->is_directory() && !allowedPaths.contains(relative)) {
            blocked = true;
            findings.push_back(blockingFinding("bundle.file.unexpected", "Bundle contains an unlisted file.", relative, {relative}));
        }
    }
    if (walkError) {
        blocked = true;
        findings.push_back(blockingFinding("bundle.inventory.unreadable", "Bundle inventory cannot be read.", bundleRoot.string(), {walkError.message()}));
    }

    if (!blocked) {
        findings.push_back(ValidationFinding{
            "FAE-F020",
            "bundle.verified",
            "info",
            ValidationStatus::Pass,
            "Product bundle verified.",
            "",
            {bundleID},
            ""});
    }

    return ValidationResult{
        "2.0",
        blocked ? ValidationStatus::Block : ValidationStatus::Pass,
        "bundle verify",
        "1.2.0",
        "bundle-verification",
        findings};
}

} // namespace ForsettiGovernance
