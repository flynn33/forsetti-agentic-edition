import Foundation
import GovernanceContracts

public final class VersionService {
    private let resultFactory: ResultFactory

    public init(resultFactory: ResultFactory) {
        self.resultFactory = resultFactory
    }

    public func run() -> CommandExecution {
        let finding = ValidationFinding(
            canonicalRuleID: "FAE-C011",
            conditionID: "version.reported",
            severity: .info,
            decision: .pass,
            message: "Product version reported.",
            evidence: [ProductVersion.current],
            remediation: nil
        )
        let result = resultFactory.makeResult(status: .pass, mode: "version", findings: [finding])
        return CommandExecution(
            result: result,
            exitCode: .pass,
            humanSummary: "forsetti-governance \(ProductVersion.current)"
        )
    }
}
