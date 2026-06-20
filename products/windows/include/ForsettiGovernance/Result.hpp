#pragma once

#include <string>
#include <vector>

namespace ForsettiGovernance {

enum class ValidationStatus {
    Pass,
    RequestChanges,
    Block
};

enum class ExitCode {
    Pass = 0,
    RequestChanges = 1,
    Block = 2,
    InvalidUsage = 3,
    IntegrityFailure = 4,
    UnsupportedProfileOrVersion = 5,
    IoFailure = 6,
    NativeToolchainUnavailable = 7,
    InternalProductFailure = 8
};

struct ValidationFinding final {
    std::string canonicalRuleID;
    std::string conditionID;
    std::string severity;
    ValidationStatus decision;
    std::string message;
    std::string path;
    std::vector<std::string> evidence;
    std::string remediation;
};

struct ValidationResult final {
    std::string schemaVersion = "2.0";
    ValidationStatus status = ValidationStatus::Pass;
    std::string mode;
    std::string productVersion = "1.0.0";
    std::string invocationID;
    std::vector<ValidationFinding> findings;
};

std::string toString(ValidationStatus status);
int toInt(ExitCode code);
ExitCode exitCodeForStatus(ValidationStatus status);
std::string toJson(const ValidationResult& result);

} // namespace ForsettiGovernance
