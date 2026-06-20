import Foundation
import GovernanceApple
import GovernanceContracts
import GovernanceCore

final class CommandLineRouter {
    private let fileSystem: FileSystem
    private let resultFactory: ResultFactory
    private let codec: JSONResultCodec

    init(fileSystem: FileSystem, resultFactory: ResultFactory, codec: JSONResultCodec) {
        self.fileSystem = fileSystem
        self.resultFactory = resultFactory
        self.codec = codec
    }

    func run(arguments: [String]) throws -> CommandExecution {
        let parser = OptionParser(arguments: arguments)
        let command = parser.commandWords

        if command == ["version"] || command.isEmpty {
            return VersionService(resultFactory: resultFactory).run()
        }
        if command == ["bundle", "verify"] {
            let bundleRoot = parser.directoryURL(for: "--bundle-root", default: fileSystem.currentDirectory())
            let result = try SHA256BundleVerifier(
                fileSystem: fileSystem,
                resultFactory: resultFactory
            ).verify(bundleRoot: bundleRoot)
            return CommandExecution(
                result: result,
                exitCode: result.status == .pass ? .pass : .integrityFailure,
                humanSummary: result.status == .pass ? "Product bundle verified." : "Product bundle verification failed."
            )
        }
        if command == ["init"] {
            let clock = SystemClock()
            let verifier = SHA256BundleVerifier(fileSystem: fileSystem, resultFactory: resultFactory)
            let service = RepositoryBootstrapService(
                fileSystem: fileSystem,
                resultFactory: resultFactory,
                verifier: verifier,
                clock: clock
            )
            let result = try service.initialize(options: BootstrapOptions(
                repositoryRoot: parser.directoryURL(for: "--repository-root", default: fileSystem.currentDirectory()),
                bundleRoot: parser.directoryURL(for: "--bundle-root", default: fileSystem.currentDirectory().appendingPathComponent("bundle", isDirectory: true)),
                edition: parser.value(for: "--edition"),
                platform: parser.value(for: "--platform"),
                frameworkVersion: parser.value(for: "--framework-version"),
                deploymentPattern: parser.value(for: "--deployment-pattern") ?? "developer_testing",
                dryRun: parser.hasFlag("--dry-run")
            ))
            return CommandExecution(
                result: result,
                exitCode: exitCode(for: result),
                humanSummary: result.status == .pass ? "Repository initialized." : "Repository initialization failed."
            )
        }
        if command == ["doctor"] {
            let clock = SystemClock()
            let verifier = SHA256BundleVerifier(fileSystem: fileSystem, resultFactory: resultFactory)
            let service = RepositoryBootstrapService(
                fileSystem: fileSystem,
                resultFactory: resultFactory,
                verifier: verifier,
                clock: clock
            )
            let result = try service.doctor(
                repositoryRoot: parser.directoryURL(for: "--repository-root", default: fileSystem.currentDirectory()),
                bundleRoot: parser.directoryURL(for: "--bundle-root", default: fileSystem.currentDirectory().appendingPathComponent("bundle", isDirectory: true))
            )
            return CommandExecution(
                result: result,
                exitCode: exitCode(for: result),
                humanSummary: result.status == .pass ? "Doctor checks passed." : "Doctor checks failed."
            )
        }
        if command == ["discover"] {
            let bundleRoot = parser.directoryURL(for: "--bundle-root", default: fileSystem.currentDirectory().appendingPathComponent("bundle", isDirectory: true))
            let verifier = SHA256BundleVerifier(fileSystem: fileSystem, resultFactory: resultFactory)
            let bundleResult = try verifier.verify(bundleRoot: bundleRoot)
            guard bundleResult.status == .pass else {
                let result = resultFactory.makeResult(status: .block, mode: "discover", findings: bundleResult.findings)
                return CommandExecution(result: result, exitCode: .integrityFailure, humanSummary: "Discovery failed.")
            }
            let service = ProjectDiscoveryService(
                fileSystem: fileSystem,
                processRunner: LocalProcessRunner(),
                resultFactory: resultFactory
            )
            let result = try service.discover(options: DiscoveryOptions(
                repositoryRoot: parser.directoryURL(for: "--repository-root", default: fileSystem.currentDirectory()),
                outputURL: parser.fileURL(for: "--output")
            ))
            return CommandExecution(
                result: result,
                exitCode: exitCode(for: result),
                humanSummary: result.status == .pass ? "Discovery completed." : "Discovery requires reconciliation."
            )
        }

        let result = resultFactory.makeResult(
            status: .block,
            mode: command.joined(separator: " "),
            findings: [
                ValidationFinding(
                    canonicalRuleID: "FAE-C011",
                    conditionID: "command.unsupported",
                    severity: .critical,
                    decision: .block,
                    message: "Unsupported command.",
                    evidence: [command.joined(separator: " ")],
                    remediation: "Run a supported command."
                )
            ]
        )
        return CommandExecution(result: result, exitCode: .invalidUsage, humanSummary: "Unsupported command.")
    }

    private func exitCode(for result: ValidationResult) -> ExitCode {
        switch result.status {
        case .pass:
            return .pass
        case .requestChanges:
            return .requestChanges
        case .block:
            break
        }
        if result.findings.contains(where: { $0.canonicalRuleID == "FAE-F020" && $0.decision == .block }) {
            return .integrityFailure
        }
        return .block
    }
}

private struct OptionParser {
    let arguments: [String]

    var commandWords: [String] {
        var words: [String] = []
        var index = 0
        while index < arguments.count {
            let argument = arguments[index]
            if argument.hasPrefix("--") {
                index += valueConsumingOption(argument) ? 2 : 1
                continue
            }
            words.append(argument)
            index += 1
        }
        return words
    }

    func value(for option: String) -> String? {
        guard let index = arguments.firstIndex(of: option) else {
            return nil
        }
        let valueIndex = arguments.index(after: index)
        guard valueIndex < arguments.endIndex else {
            return nil
        }
        return arguments[valueIndex]
    }

    func hasFlag(_ option: String) -> Bool {
        arguments.contains(option)
    }

    func directoryURL(for option: String, default defaultURL: URL) -> URL {
        value(for: option).map { URL(fileURLWithPath: $0, isDirectory: true) } ?? defaultURL
    }

    func fileURL(for option: String) -> URL? {
        value(for: option).map { URL(fileURLWithPath: $0) }
    }

    private func valueConsumingOption(_ option: String) -> Bool {
        [
            "--format",
            "--repo-root",
            "--repository-root",
            "--bundle-root",
            "--output",
            "--edition",
            "--platform",
            "--framework-version",
            "--deployment-pattern"
        ].contains(option)
    }
}
