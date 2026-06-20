import Foundation
import GovernanceApple
import GovernanceContracts
import GovernanceCore

let fileSystem = LocalFileSystem()
let clock = SystemClock()
let identifiers = SystemIdentifierGenerator()
let resultFactory = ResultFactory(clock: clock, identifiers: identifiers)
let codec = JSONResultCodec()

let execution: CommandExecution
do {
    execution = try CommandLineRouter(
        fileSystem: fileSystem,
        resultFactory: resultFactory,
        codec: codec
    ).run(arguments: Array(CommandLine.arguments.dropFirst()))
} catch {
    let result = resultFactory.makeResult(
        status: .block,
        mode: "invalid",
        findings: [
            ValidationFinding(
                canonicalRuleID: "FAE-C011",
                conditionID: "command.failed",
                severity: .critical,
                decision: .block,
                message: "Command failed.",
                evidence: [String(describing: error)],
                remediation: "Run a supported command with valid arguments."
            )
        ]
    )
    execution = CommandExecution(result: result, exitCode: .internalProductFailure, humanSummary: "Command failed.")
}

do {
    if CommandLine.arguments.contains("--format"), CommandLine.arguments.contains("json") {
        print(try codec.encodeString(execution.result))
    } else {
        print(execution.humanSummary)
        for finding in execution.result.findings where finding.decision != .pass {
            print("\(finding.decision.rawValue): \(finding.message)")
        }
    }
} catch {
    fputs("Unable to render command result.\n", stderr)
    exit(ExitCode.internalProductFailure.rawValue)
}

exit(execution.exitCode.rawValue)
