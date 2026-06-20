#include "ForsettiGovernance/Result.hpp"

#include <sstream>

namespace ForsettiGovernance {

std::string toString(const ValidationStatus status) {
    switch (status) {
    case ValidationStatus::Pass:
        return "pass";
    case ValidationStatus::RequestChanges:
        return "request_changes";
    case ValidationStatus::Block:
        return "block";
    }
    return "block";
}

int toInt(const ExitCode code) {
    return static_cast<int>(code);
}

ExitCode exitCodeForStatus(const ValidationStatus status) {
    switch (status) {
    case ValidationStatus::Pass:
        return ExitCode::Pass;
    case ValidationStatus::RequestChanges:
        return ExitCode::RequestChanges;
    case ValidationStatus::Block:
        return ExitCode::Block;
    }
    return ExitCode::Block;
}

std::string toJson(const ValidationResult& result) {
    std::ostringstream output;
    output << "{";
    output << "\"schemaVersion\":\"" << result.schemaVersion << "\",";
    output << "\"status\":\"" << toString(result.status) << "\",";
    output << "\"mode\":\"" << result.mode << "\",";
    output << "\"productVersion\":\"" << result.productVersion << "\",";
    output << "\"invocationID\":\"" << result.invocationID << "\",";
    output << "\"findings\":[";
    for (std::size_t index = 0; index < result.findings.size(); ++index) {
        const auto& finding = result.findings[index];
        if (index > 0) {
            output << ",";
        }
        output << "{";
        output << "\"canonicalRuleID\":\"" << finding.canonicalRuleID << "\",";
        output << "\"conditionID\":\"" << finding.conditionID << "\",";
        output << "\"severity\":\"" << finding.severity << "\",";
        output << "\"decision\":\"" << toString(finding.decision) << "\",";
        output << "\"message\":\"" << finding.message << "\"";
        output << "}";
    }
    output << "]";
    output << "}";
    return output.str();
}

} // namespace ForsettiGovernance
