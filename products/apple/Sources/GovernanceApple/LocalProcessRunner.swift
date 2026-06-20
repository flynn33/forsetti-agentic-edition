import Foundation
import GovernanceContracts

public final class LocalProcessRunner: ProcessRunning {
    public init() {}

    public func run(executable: String, arguments: [String], workingDirectory: URL) throws -> ProcessResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.currentDirectoryURL = workingDirectory

        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr

        try process.run()
        process.waitUntilExit()

        return ProcessResult(
            executable: executable,
            arguments: arguments,
            workingDirectory: workingDirectory,
            exitCode: process.terminationStatus,
            stdout: stdout.fileHandleForReading.readDataToEndOfFile(),
            stderr: stderr.fileHandleForReading.readDataToEndOfFile()
        )
    }
}
