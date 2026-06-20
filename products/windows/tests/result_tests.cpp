#include "ForsettiGovernance/BundleVerifier.hpp"
#include "ForsettiGovernance/Contracts.hpp"
#include "ForsettiGovernance/Result.hpp"
#include "ForsettiGovernance/SHA256.hpp"

#include <cassert>
#include <chrono>
#include <filesystem>
#include <fstream>
#include <sstream>
#include <string>

using namespace ForsettiGovernance;

namespace {

class TestFileSystem final : public IFileSystem {
public:
    bool fileExists(const std::filesystem::path& path) const override {
        return std::filesystem::is_regular_file(path);
    }

    std::string readText(const std::filesystem::path& path) const override {
        std::ifstream input(path, std::ios::binary);
        std::ostringstream buffer;
        buffer << input.rdbuf();
        return buffer.str();
    }

    void writeTextAtomically(const std::filesystem::path& path, const std::string& content) const override {
        std::ofstream output(path, std::ios::binary | std::ios::trunc);
        output << content;
    }

    std::filesystem::path currentDirectory() const override {
        return std::filesystem::current_path();
    }
};

std::filesystem::path temporaryRoot(const std::string& name) {
    const auto stamp = std::chrono::steady_clock::now().time_since_epoch().count();
    auto root = std::filesystem::temp_directory_path() / ("ffae-cpp-" + name + "-" + std::to_string(stamp));
    std::filesystem::create_directories(root);
    return root;
}

void writeFile(const std::filesystem::path& path, const std::string& content) {
    std::filesystem::create_directories(path.parent_path());
    std::ofstream output(path, std::ios::binary | std::ios::trunc);
    output << content;
}

std::string manifestEntry(const std::string& path, const std::string& hash, bool required) {
    return "{\"path\":\"" + path + "\",\"sha256\":\"" + hash + "\",\"required\":" + (required ? "true" : "false") + "}";
}

void writeManifest(
    const std::filesystem::path& root,
    const std::string& entries,
    const std::string& schemaVersion = "2.0") {
    writeFile(
        root / "product-manifest.json",
        "{\"schemaVersion\":\"" + schemaVersion + "\","
        "\"product\":\"Forsetti Agentic Edition\","
        "\"version\":\"1.0.0\","
        "\"bundleID\":\"test-bundle\","
        "\"platform\":\"windows-host\","
        "\"architecture\":\"test\","
        "\"entryPoint\":null,"
        "\"files\":[" + entries + "],"
        "\"createdAtUTC\":\"2026-06-20T00:00:00Z\"}");
}

bool hasFinding(const ValidationResult& result, const std::string& conditionID) {
    for (const auto& finding : result.findings) {
        if (finding.conditionID == conditionID) {
            return true;
        }
    }
    return false;
}

void runBundleVerifierTests() {
    assert(sha256Hex("payload") == "239f59ed55e737c77147cf55ad0c1b030b6d7ee748a7426952f9b852d5a935e5");

    TestFileSystem fileSystem;
    SimpleBundleVerifier verifier(fileSystem);

    const auto pristine = temporaryRoot("pristine");
    writeFile(pristine / "payload.txt", "payload");
    writeManifest(pristine, manifestEntry("payload.txt", sha256Hex("payload"), true));
    assert(verifier.verify(pristine).status == ValidationStatus::Pass);
    writeFile(pristine / "payload.txt", "changed");
    const auto tampered = verifier.verify(pristine);
    assert(tampered.status == ValidationStatus::Block);
    assert(hasFinding(tampered, "bundle.file.hash-mismatch"));
    std::filesystem::remove_all(pristine);

    const auto optional = temporaryRoot("optional");
    writeManifest(optional, manifestEntry("optional.txt", std::string(64, '0'), false));
    assert(verifier.verify(optional).status == ValidationStatus::Pass);
    std::filesystem::remove_all(optional);

    const auto invalid = temporaryRoot("invalid");
    writeFile(invalid / "payload.txt", "payload");
    writeManifest(invalid, manifestEntry("../payload.txt", sha256Hex("payload"), true));
    const auto invalidResult = verifier.verify(invalid);
    assert(invalidResult.status == ValidationStatus::Block);
    assert(hasFinding(invalidResult, "bundle.path.invalid"));
    std::filesystem::remove_all(invalid);

    const auto duplicate = temporaryRoot("duplicate");
    writeFile(duplicate / "payload.txt", "payload");
    writeManifest(
        duplicate,
        manifestEntry("payload.txt", sha256Hex("payload"), true) + "," +
            manifestEntry("payload.txt", sha256Hex("payload"), true));
    const auto duplicateResult = verifier.verify(duplicate);
    assert(duplicateResult.status == ValidationStatus::Block);
    assert(hasFinding(duplicateResult, "bundle.path.duplicate"));
    std::filesystem::remove_all(duplicate);

    const auto unsupported = temporaryRoot("unsupported");
    writeFile(unsupported / "payload.txt", "payload");
    writeManifest(unsupported, manifestEntry("payload.txt", sha256Hex("payload"), true), "3.0");
    const auto unsupportedResult = verifier.verify(unsupported);
    assert(unsupportedResult.status == ValidationStatus::Block);
    assert(hasFinding(unsupportedResult, "bundle.manifest.unsupported-version"));
    std::filesystem::remove_all(unsupported);

    const auto lock = temporaryRoot("lock");
    writeFile(lock / "payload.txt", "payload");
    writeManifest(lock, manifestEntry("payload.txt", sha256Hex("payload"), true));
    writeFile(
        lock / "product-lock.json",
        "{\"schemaVersion\":\"2.0\","
        "\"productVersion\":\"1.0.0\","
        "\"bundleID\":\"test-bundle\","
        "\"platform\":\"windows-host\","
        "\"lockedAtUTC\":\"2026-06-20T00:00:00Z\","
        "\"sha256\":\"" + std::string(64, '0') + "\"}");
    const auto lockResult = verifier.verify(lock);
    assert(lockResult.status == ValidationStatus::Block);
    assert(hasFinding(lockResult, "bundle.product-lock.mismatch"));
    std::filesystem::remove_all(lock);
}

} // namespace

int main() {
    ValidationResult result{
        "2.0",
        ValidationStatus::Pass,
        "version",
        "1.0.0",
        "test",
        {ValidationFinding{
            "FAE-C011",
            "version.reported",
            "info",
            ValidationStatus::Pass,
            "Product version reported.",
            "",
            {"1.0.0"},
            ""}}};

    const std::string encoded = toJson(result);
    assert(encoded.find("\"status\":\"pass\"") != std::string::npos);
    assert(toInt(exitCodeForStatus(ValidationStatus::Block)) == 2);
    runBundleVerifierTests();
    return 0;
}
