import Foundation
import GovernanceContracts

public enum ProductVersion {
    public static let current = "1.0.0"
}

public enum ExitCode: Int32 {
    case pass = 0
    case requestChanges = 1
    case block = 2
    case invalidUsage = 3
    case integrityFailure = 4
    case unsupportedProfileOrVersion = 5
    case ioFailure = 6
    case nativeToolchainUnavailable = 7
    case internalProductFailure = 8

    public init(status: ValidationStatus) {
        switch status {
        case .pass:
            self = .pass
        case .requestChanges:
            self = .requestChanges
        case .block:
            self = .block
        }
    }
}

public enum CommandFormat: String {
    case human
    case json
}

public struct CommandOptions: Equatable {
    public let format: CommandFormat
    public let repositoryRoot: URL?
    public let bundleRoot: URL?
    public let outputPath: URL?
    public let dryRun: Bool

    public init(
        format: CommandFormat = .human,
        repositoryRoot: URL? = nil,
        bundleRoot: URL? = nil,
        outputPath: URL? = nil,
        dryRun: Bool = false
    ) {
        self.format = format
        self.repositoryRoot = repositoryRoot
        self.bundleRoot = bundleRoot
        self.outputPath = outputPath
        self.dryRun = dryRun
    }
}

public struct CommandExecution {
    public let result: ValidationResult
    public let exitCode: ExitCode
    public let humanSummary: String

    public init(result: ValidationResult, exitCode: ExitCode, humanSummary: String) {
        self.result = result
        self.exitCode = exitCode
        self.humanSummary = humanSummary
    }
}
