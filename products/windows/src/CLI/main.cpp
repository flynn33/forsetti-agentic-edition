#include "ForsettiGovernance/BundleVerifier.hpp"
#include "ForsettiGovernance/Result.hpp"
#include "../Windows/WindowsFileSystem.hpp"

#include <algorithm>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>

using namespace ForsettiGovernance;

namespace {

bool hasArgument(const std::vector<std::string>& arguments, const std::string& value) {
    return std::find(arguments.begin(), arguments.end(), value) != arguments.end();
}

std::filesystem::path optionValue(
    const std::vector<std::string>& arguments,
    const std::string& option,
    const std::filesystem::path& fallback) {
    const auto iterator = std::find(arguments.begin(), arguments.end(), option);
    if (iterator == arguments.end()) {
        return fallback;
    }
    const auto valueIterator = std::next(iterator);
    if (valueIterator == arguments.end()) {
        return fallback;
    }
    return *valueIterator;
}

} // namespace

int main(int argc, char** argv) {
    std::vector<std::string> arguments;
    for (int index = 1; index < argc; ++index) {
        arguments.emplace_back(argv[index]);
    }

    const bool json = hasArgument(arguments, "--format") && hasArgument(arguments, "json");
    WindowsFileSystem fileSystem;

    if (arguments.empty() || arguments[0] == "version") {
        ValidationResult result{
            "2.0",
            ValidationStatus::Pass,
            "version",
            "1.0.0",
            "version",
            {ValidationFinding{
                "FAE-C011",
                "version.reported",
                "info",
                ValidationStatus::Pass,
                "Product version reported.",
                "",
                {"1.0.0"},
                ""}}};
        if (json) {
            std::cout << toJson(result) << "\n";
        } else {
            std::cout << "forsetti-governance 1.0.0\n";
        }
        return toInt(ExitCode::Pass);
    }

    if (arguments.size() >= 2 && arguments[0] == "bundle" && arguments[1] == "verify") {
        const auto bundleRoot = optionValue(arguments, "--bundle-root", fileSystem.currentDirectory());
        const auto result = SimpleBundleVerifier(fileSystem).verify(bundleRoot);
        if (json) {
            std::cout << toJson(result) << "\n";
        } else {
            std::cout << (result.status == ValidationStatus::Pass ? "Product bundle verified." : "Product bundle verification failed.") << "\n";
        }
        return result.status == ValidationStatus::Pass ? toInt(ExitCode::Pass) : toInt(ExitCode::IntegrityFailure);
    }

    ValidationResult result{
        "2.0",
        ValidationStatus::Block,
        "unsupported",
        "1.0.0",
        "unsupported",
        {ValidationFinding{
            "FAE-C011",
            "command.unsupported",
            "critical",
            ValidationStatus::Block,
            "Unsupported command.",
            "",
            arguments,
            "Run a supported command."}}};
    if (json) {
        std::cout << toJson(result) << "\n";
    } else {
        std::cerr << "Unsupported command.\n";
    }
    return toInt(ExitCode::InvalidUsage);
}
