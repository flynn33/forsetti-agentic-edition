import Foundation

public struct ProcessResult: Equatable, Sendable {
    public let executable: String
    public let arguments: [String]
    public let workingDirectory: URL
    public let exitCode: Int32
    public let stdout: Data
    public let stderr: Data

    public init(
        executable: String,
        arguments: [String],
        workingDirectory: URL,
        exitCode: Int32,
        stdout: Data,
        stderr: Data
    ) {
        self.executable = executable
        self.arguments = arguments
        self.workingDirectory = workingDirectory
        self.exitCode = exitCode
        self.stdout = stdout
        self.stderr = stderr
    }
}

public protocol FileSystem {
    func fileExists(at url: URL) -> Bool
    func directoryExists(at url: URL) -> Bool
    func readFile(at url: URL) throws -> Data
    func writeFileAtomically(_ data: Data, to url: URL) throws
    func currentDirectory() -> URL
}

public protocol ProcessRunning {
    func run(executable: String, arguments: [String], workingDirectory: URL) throws -> ProcessResult
}

public protocol GitRepositoryReading {
    func headCommit(repositoryRoot: URL) throws -> String
    func changedFiles(repositoryRoot: URL, baselineCommit: String) throws -> [String]
}

public protocol BundleVerifying {
    func verify(bundleRoot: URL) throws -> ValidationResult
}

public protocol ConfigurationLoading {
    func loadJSON<T: Decodable>(_ type: T.Type, from url: URL) throws -> T
}

public protocol ProjectDiscovering {
    func discover(repositoryRoot: URL) throws -> ValidationResult
}

public protocol RuleEvaluating {
    func evaluate(request: ValidationRequest) throws -> ValidationResult
}

public protocol EvidenceWriting {
    func writeEvidence(_ result: ValidationResult, to url: URL) throws
}

public protocol Clock {
    func now() -> Date
}

public protocol IdentifierGenerating {
    func newIdentifier() -> String
}
