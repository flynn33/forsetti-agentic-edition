import Foundation

public enum ValidationStatus: String, Codable, Sendable {
    case pass
    case requestChanges = "request_changes"
    case block
}

public enum FindingSeverity: String, Codable, Sendable {
    case info
    case low
    case medium
    case high
    case critical
}

public struct ValidationRequest: Codable, Equatable, Sendable {
    public let schemaVersion: String
    public let mode: String
    public let repositoryRoot: String
    public let productBundleRoot: String

    public init(
        schemaVersion: String = "2.0",
        mode: String,
        repositoryRoot: String,
        productBundleRoot: String
    ) {
        self.schemaVersion = schemaVersion
        self.mode = mode
        self.repositoryRoot = repositoryRoot
        self.productBundleRoot = productBundleRoot
    }
}

public struct ValidationFinding: Codable, Equatable, Sendable {
    public let canonicalRuleID: String
    public let localRuleID: String?
    public let conditionID: String
    public let severity: FindingSeverity
    public let decision: ValidationStatus
    public let message: String
    public let path: String?
    public let moduleID: String?
    public let evidence: [String]
    public let remediation: String?

    public init(
        canonicalRuleID: String,
        localRuleID: String? = nil,
        conditionID: String,
        severity: FindingSeverity,
        decision: ValidationStatus,
        message: String,
        path: String? = nil,
        moduleID: String? = nil,
        evidence: [String],
        remediation: String?
    ) {
        self.canonicalRuleID = canonicalRuleID
        self.localRuleID = localRuleID
        self.conditionID = conditionID
        self.severity = severity
        self.decision = decision
        self.message = message
        self.path = path
        self.moduleID = moduleID
        self.evidence = evidence
        self.remediation = remediation
    }
}

public struct ValidationSummary: Codable, Equatable, Sendable {
    public let total: Int
    public let passed: Int
    public let requestChanges: Int
    public let blocked: Int

    public init(total: Int, passed: Int, requestChanges: Int, blocked: Int) {
        self.total = total
        self.passed = passed
        self.requestChanges = requestChanges
        self.blocked = blocked
    }
}

public struct ValidationResult: Codable, Equatable, Sendable {
    public let schemaVersion: String
    public let status: ValidationStatus
    public let mode: String
    public let productVersion: String
    public let invocationID: String
    public let startedAtUTC: Date
    public let finishedAtUTC: Date
    public let summary: ValidationSummary
    public let findings: [ValidationFinding]

    public init(
        schemaVersion: String = "2.0",
        status: ValidationStatus,
        mode: String,
        productVersion: String,
        invocationID: String,
        startedAtUTC: Date,
        finishedAtUTC: Date,
        summary: ValidationSummary,
        findings: [ValidationFinding]
    ) {
        self.schemaVersion = schemaVersion
        self.status = status
        self.mode = mode
        self.productVersion = productVersion
        self.invocationID = invocationID
        self.startedAtUTC = startedAtUTC
        self.finishedAtUTC = finishedAtUTC
        self.summary = summary
        self.findings = findings
    }
}
