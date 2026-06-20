import Foundation
import GovernanceContracts

public final class ResultFactory {
    private let clock: Clock
    private let identifiers: IdentifierGenerating

    public init(clock: Clock, identifiers: IdentifierGenerating) {
        self.clock = clock
        self.identifiers = identifiers
    }

    public func makeResult(
        status: ValidationStatus,
        mode: String,
        findings: [ValidationFinding],
        startedAt: Date? = nil
    ) -> ValidationResult {
        let started = startedAt ?? clock.now()
        let blocked = findings.filter { $0.decision == .block }.count
        let requestChanges = findings.filter { $0.decision == .requestChanges }.count
        let passed = findings.filter { $0.decision == .pass }.count
        return ValidationResult(
            status: status,
            mode: mode,
            productVersion: ProductVersion.current,
            invocationID: identifiers.newIdentifier(),
            startedAtUTC: started,
            finishedAtUTC: clock.now(),
            summary: ValidationSummary(
                total: findings.count,
                passed: passed,
                requestChanges: requestChanges,
                blocked: blocked
            ),
            findings: findings
        )
    }
}
