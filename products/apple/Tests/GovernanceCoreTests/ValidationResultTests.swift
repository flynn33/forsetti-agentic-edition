import CryptoKit
import Foundation
import GovernanceApple
import GovernanceContracts
import GovernanceCore
import XCTest

final class ValidationResultTests: XCTestCase {
    func testResultEncodingIsStable() throws {
        let fixedDate = Date(timeIntervalSince1970: 1_780_000_000)
        let factory = ResultFactory(
            clock: FixedClock(date: fixedDate),
            identifiers: FixedIdentifierGenerator(value: "invocation-001")
        )
        let result = factory.makeResult(
            status: .pass,
            mode: "version",
            findings: [
                ValidationFinding(
                    canonicalRuleID: "FAE-C011",
                    conditionID: "version.reported",
                    severity: .info,
                    decision: .pass,
                    message: "Product version reported.",
                    evidence: ["1.0.0"],
                    remediation: nil
                )
            ],
            startedAt: fixedDate
        )

        let encoded = try JSONResultCodec().encodeString(result)
        XCTAssertTrue(encoded.contains("\"schemaVersion\" : \"2.0\""))
        XCTAssertTrue(encoded.contains("\"status\" : \"pass\""))
        XCTAssertTrue(encoded.contains("\"invocationID\" : \"invocation-001\""))
    }

    func testBundleVerifierPassesAndBlocksTamper() throws {
        let root = try TemporaryDirectory()
        let payloadURL = try writePayloadBundle(root: root.url)
        let verifier = makeVerifier()
        XCTAssertEqual(try verifier.verify(bundleRoot: root.url).status, .pass)

        try Data("changed".utf8).write(to: payloadURL)
        let result = try verifier.verify(bundleRoot: root.url)
        XCTAssertEqual(result.status, .block)
        XCTAssertTrue(result.findings.contains { $0.conditionID == "bundle.file.hash-mismatch" })
    }

    func testSourceBundleVerifies() throws {
        let result = try makeVerifier().verify(bundleRoot: repoRootURL().appendingPathComponent("bundle", isDirectory: true))
        XCTAssertEqual(result.status, .pass)
        XCTAssertTrue(result.findings.contains { $0.conditionID == "bundle.verified" })
    }

    func testPathTraversalDuplicateUnsupportedVersionAndOptionalMissing() throws {
        let traversalRoot = try TemporaryDirectory()
        _ = try writePayloadBundle(root: traversalRoot.url, path: "../payload.txt")
        let traversal = try makeVerifier().verify(bundleRoot: traversalRoot.url)
        XCTAssertEqual(traversal.status, .block)
        XCTAssertTrue(traversal.findings.contains { $0.conditionID == "bundle.path.invalid" })

        let duplicateRoot = try TemporaryDirectory()
        let payloadURL = duplicateRoot.url.appendingPathComponent("payload.txt")
        try Data("payload".utf8).write(to: payloadURL)
        try writeManifest(root: duplicateRoot.url, files: [
            manifestFile(path: "payload.txt", data: Data("payload".utf8), required: true),
            manifestFile(path: "payload.txt", data: Data("payload".utf8), required: true)
        ])
        let duplicate = try makeVerifier().verify(bundleRoot: duplicateRoot.url)
        XCTAssertEqual(duplicate.status, .block)
        XCTAssertTrue(duplicate.findings.contains { $0.conditionID == "bundle.path.duplicate" })

        let unsupportedRoot = try TemporaryDirectory()
        _ = try writePayloadBundle(root: unsupportedRoot.url, schemaVersion: "3.0")
        let unsupported = try makeVerifier().verify(bundleRoot: unsupportedRoot.url)
        XCTAssertEqual(unsupported.status, .block)
        XCTAssertTrue(unsupported.findings.contains { $0.conditionID == "bundle.manifest.unsupported-version" })

        let optionalRoot = try TemporaryDirectory()
        try writeManifest(root: optionalRoot.url, files: [
            manifestFile(path: "optional.txt", sha256: String(repeating: "0", count: 64), required: false)
        ])
        XCTAssertEqual(try makeVerifier().verify(bundleRoot: optionalRoot.url).status, .pass)
    }

    func testProductLockMismatchBlocks() throws {
        let root = try TemporaryDirectory()
        _ = try writePayloadBundle(root: root.url)
        let lock = """
        {
          "schemaVersion": "2.0",
          "productVersion": "1.0.0",
          "bundleID": "test-bundle",
          "platform": "apple-host",
          "lockedAtUTC": "2026-06-20T00:00:00Z",
          "sha256": "\(String(repeating: "0", count: 64))"
        }
        """
        try Data(lock.utf8).write(to: root.url.appendingPathComponent("product-lock.json"))

        let result = try makeVerifier().verify(bundleRoot: root.url)
        XCTAssertEqual(result.status, .block)
        XCTAssertTrue(result.findings.contains { $0.conditionID == "bundle.product-lock.mismatch" })
    }

    func testInitDryRunDoesNotWrite() throws {
        let repository = try makeFixtureRepository()
        let result = try makeBootstrapService().initialize(options: BootstrapOptions(
            repositoryRoot: repository.url,
            bundleRoot: repoRootURL().appendingPathComponent("bundle", isDirectory: true),
            edition: "apple",
            platform: "macOS",
            frameworkVersion: "0.1.3",
            deploymentPattern: "developer_testing",
            dryRun: true
        ))

        XCTAssertEqual(result.status, .pass)
        XCTAssertFalse(FileManager.default.fileExists(atPath: repository.url.appendingPathComponent(".forsetti").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: repository.url.appendingPathComponent("AGENTS.md").path))
    }

    func testInitDoctorAndRepeatedInitAreStable() throws {
        let repository = try makeFixtureRepository()
        try Data("Owner instructions.\n".utf8).write(to: repository.url.appendingPathComponent("AGENTS.md"))
        let service = makeBootstrapService()
        let options = BootstrapOptions(
            repositoryRoot: repository.url,
            bundleRoot: repoRootURL().appendingPathComponent("bundle", isDirectory: true),
            edition: "apple",
            platform: "macOS",
            frameworkVersion: "0.1.3",
            deploymentPattern: "developer_testing",
            dryRun: false
        )

        XCTAssertEqual(try service.initialize(options: options).status, .pass)
        let trackedFiles = [
            "AGENTS.md",
            ".forsetti/project.json",
            ".forsetti/modules.json",
            ".forsetti/profile.lock.json",
            ".forsetti/policy.lock.json",
            ".forsetti/product.lock.json",
            ".forsetti/instructions/GOVERNANCE.md"
        ]
        let firstState = try trackedFiles.map { relativePath in
            try Data(contentsOf: repository.url.appendingPathComponent(relativePath))
        }
        let agents = try String(data: Data(contentsOf: repository.url.appendingPathComponent("AGENTS.md")), encoding: .utf8)
        XCTAssertTrue(agents?.contains("Owner instructions.") == true)
        XCTAssertTrue(agents?.contains("FORSETTI-GOVERNANCE:BEGIN") == true)
        XCTAssertEqual(try service.doctor(repositoryRoot: repository.url, bundleRoot: repoRootURL().appendingPathComponent("bundle", isDirectory: true)).status, .pass)

        XCTAssertEqual(try service.initialize(options: options).status, .pass)
        let secondState = try trackedFiles.map { relativePath in
            try Data(contentsOf: repository.url.appendingPathComponent(relativePath))
        }
        XCTAssertEqual(firstState, secondState)
    }

    func testInitBlocksConflictingAgentsAndInvalidRepository() throws {
        let conflicting = try makeFixtureRepository()
        try Data("<!-- FORSETTI-GOVERNANCE:BEGIN -->\n".utf8).write(to: conflicting.url.appendingPathComponent("AGENTS.md"))
        let service = makeBootstrapService()
        let options = BootstrapOptions(
            repositoryRoot: conflicting.url,
            bundleRoot: repoRootURL().appendingPathComponent("bundle", isDirectory: true),
            edition: "apple",
            platform: "macOS",
            frameworkVersion: "0.1.3",
            deploymentPattern: "developer_testing",
            dryRun: false
        )
        let conflict = try service.initialize(options: options)
        XCTAssertEqual(conflict.status, .block)
        XCTAssertTrue(conflict.findings.contains { $0.conditionID == "init.instructions.conflict" })

        let invalid = try TemporaryDirectory()
        let invalidResult = try service.initialize(options: BootstrapOptions(
            repositoryRoot: invalid.url,
            bundleRoot: repoRootURL().appendingPathComponent("bundle", isDirectory: true),
            edition: "apple",
            platform: "macOS",
            frameworkVersion: "0.1.3",
            deploymentPattern: "developer_testing",
            dryRun: false
        ))
        XCTAssertEqual(invalidResult.status, .block)
        XCTAssertTrue(invalidResult.findings.contains { $0.conditionID == "init.repository.invalid" })
    }

    func testDoctorBlocksMissingInstalledState() throws {
        let repository = try makeFixtureRepository()
        let result = try makeBootstrapService().doctor(
            repositoryRoot: repository.url,
            bundleRoot: repoRootURL().appendingPathComponent("bundle", isDirectory: true)
        )

        XCTAssertEqual(result.status, .block)
        XCTAssertTrue(result.findings.contains { $0.conditionID == "doctor.installation.missing-file" })
    }

    func testDiscoverSingleSwiftPackageModuleWritesProposal() throws {
        let repository = try makeSwiftPackageFixture(targets: [("AppModule", [])])
        try writeModuleManifest(
            repository: repository.url,
            targetName: "AppModule",
            moduleID: "com.example.app",
            moduleType: "app"
        )
        let output = repository.url.appendingPathComponent(".forsetti/discovery/modules.proposed.json")

        let result = try makeDiscoveryService().discover(options: DiscoveryOptions(
            repositoryRoot: repository.url,
            outputURL: output
        ))

        XCTAssertEqual(result.status, .pass)
        XCTAssertTrue(result.findings.contains { $0.conditionID == "discover.modules.proposed" })
        XCTAssertTrue(FileManager.default.fileExists(atPath: output.path))
        let proposed = try String(contentsOf: output, encoding: .utf8)
        XCTAssertTrue(proposed.contains("com.example.app"))
    }

    func testDiscoverDetectsMissingManifestAndDuplicateModuleID() throws {
        let missingManifest = try makeSwiftPackageFixture(targets: [("AppModule", [])])
        let missingResult = try makeDiscoveryService().discover(repositoryRoot: missingManifest.url)
        XCTAssertEqual(missingResult.status, .requestChanges)
        XCTAssertTrue(missingResult.findings.contains { $0.conditionID == "discover.target.missing-manifest" })

        let duplicate = try makeSwiftPackageFixture(targets: [("AppModule", []), ("ServiceModule", [])])
        try writeModuleManifest(
            repository: duplicate.url,
            targetName: "AppModule",
            moduleID: "com.example.duplicate",
            moduleType: "app"
        )
        try writeModuleManifest(
            repository: duplicate.url,
            targetName: "ServiceModule",
            moduleID: "com.example.duplicate",
            moduleType: "service"
        )
        let duplicateResult = try makeDiscoveryService().discover(repositoryRoot: duplicate.url)
        XCTAssertEqual(duplicateResult.status, .block)
        XCTAssertTrue(duplicateResult.findings.contains { $0.conditionID == "discover.module.duplicate-id" })
    }

    func testDiscoverDetectsDirectModuleDependencyEdge() throws {
        let repository = try makeSwiftPackageFixture(targets: [("AppModule", ["ServiceModule"]), ("ServiceModule", [])])
        try writeModuleManifest(
            repository: repository.url,
            targetName: "AppModule",
            moduleID: "com.example.app",
            moduleType: "app"
        )
        try writeModuleManifest(
            repository: repository.url,
            targetName: "ServiceModule",
            moduleID: "com.example.service",
            moduleType: "service"
        )

        let result = try makeDiscoveryService().discover(repositoryRoot: repository.url)

        XCTAssertEqual(result.status, .requestChanges)
        XCTAssertTrue(result.findings.contains { $0.conditionID == "discover.module.direct-edge" })
    }

    private func makeVerifier() -> SHA256BundleVerifier {
        SHA256BundleVerifier(
            fileSystem: LocalFileSystem(),
            resultFactory: ResultFactory(clock: FixedClock(date: Date()), identifiers: FixedIdentifierGenerator(value: "bundle-test"))
        )
    }

    private func makeBootstrapService() -> RepositoryBootstrapService {
        let clock = FixedClock(date: Date(timeIntervalSince1970: 1_780_000_000))
        let factory = ResultFactory(clock: clock, identifiers: FixedIdentifierGenerator(value: "bootstrap-test"))
        let fileSystem = LocalFileSystem()
        return RepositoryBootstrapService(
            fileSystem: fileSystem,
            resultFactory: factory,
            verifier: SHA256BundleVerifier(fileSystem: fileSystem, resultFactory: factory),
            clock: clock
        )
    }

    private func makeDiscoveryService() -> ProjectDiscoveryService {
        ProjectDiscoveryService(
            fileSystem: LocalFileSystem(),
            processRunner: LocalProcessRunner(),
            resultFactory: ResultFactory(
                clock: FixedClock(date: Date(timeIntervalSince1970: 1_780_000_000)),
                identifiers: FixedIdentifierGenerator(value: "discovery-test")
            )
        )
    }

    private func repoRootURL() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 {
            url.deleteLastPathComponent()
        }
        return url
    }

    @discardableResult
    private func writePayloadBundle(root: URL, path: String = "payload.txt", schemaVersion: String = "2.0") throws -> URL {
        let payload = Data("payload".utf8)
        let payloadURL = root.appendingPathComponent("payload.txt")
        try payload.write(to: payloadURL)
        try writeManifest(root: root, schemaVersion: schemaVersion, files: [
            manifestFile(path: path, data: payload, required: true)
        ])
        return payloadURL
    }

    private func writeManifest(root: URL, schemaVersion: String = "2.0", files: [String]) throws {
        let manifest = """
        {
          "schemaVersion": "\(schemaVersion)",
          "product": "Forsetti Agentic Edition",
          "version": "1.0.0",
          "bundleID": "test-bundle",
          "platform": "apple-host",
          "architecture": "test",
          "entryPoint": null,
          "files": [
            \(files.joined(separator: ",\n"))
          ],
          "createdAtUTC": "2026-06-20T00:00:00Z"
        }
        """
        try Data(manifest.utf8).write(to: root.appendingPathComponent("product-manifest.json"))
    }

    private func manifestFile(path: String, data: Data, required: Bool) -> String {
        manifestFile(path: path, sha256: sha256Hex(data), required: required)
    }

    private func manifestFile(path: String, sha256: String, required: Bool) -> String {
        """
            {
              "path": "\(path)",
              "sha256": "\(sha256)",
              "required": \(required ? "true" : "false"),
              "executable": false
            }
        """
    }

    private func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private func makeFixtureRepository() throws -> TemporaryDirectory {
        let repository = try TemporaryDirectory()
        try FileManager.default.createDirectory(
            at: repository.url.appendingPathComponent(".git", isDirectory: true),
            withIntermediateDirectories: true
        )
        try Data("// swift package fixture\n".utf8).write(to: repository.url.appendingPathComponent("Package.swift"))
        return repository
    }

    private func makeSwiftPackageFixture(targets: [(name: String, dependencies: [String])]) throws -> TemporaryDirectory {
        let repository = try TemporaryDirectory()
        try FileManager.default.createDirectory(
            at: repository.url.appendingPathComponent(".git", isDirectory: true),
            withIntermediateDirectories: true
        )
        let targetDefinitions = targets.map { target in
            let dependencies = target.dependencies.map { "\"\($0)\"" }.joined(separator: ", ")
            return ".target(name: \"\(target.name)\", dependencies: [\(dependencies)])"
        }.joined(separator: ",\n        ")
        let package = """
        // swift-tools-version: 5.10
        import PackageDescription

        let package = Package(
            name: "DiscoveryFixture",
            products: [
                .library(name: "DiscoveryFixture", targets: ["\(targets[0].name)"])
            ],
            targets: [
                \(targetDefinitions)
            ]
        )
        """
        try Data(package.utf8).write(to: repository.url.appendingPathComponent("Package.swift"))
        for target in targets {
            let targetRoot = repository.url.appendingPathComponent("Sources/\(target.name)", isDirectory: true)
            try FileManager.default.createDirectory(at: targetRoot, withIntermediateDirectories: true)
            try Data("public enum \(target.name)Fixture {}\n".utf8)
                .write(to: targetRoot.appendingPathComponent("\(target.name).swift"))
        }
        return repository
    }

    private func writeModuleManifest(
        repository: URL,
        targetName: String,
        moduleID: String,
        moduleType: String
    ) throws {
        let targetRoot = repository.appendingPathComponent("Sources/\(targetName)", isDirectory: true)
        let manifest = """
        {
          "schemaVersion": "1.1",
          "manifestTemplateVersion": "1.1",
          "moduleID": "\(moduleID)",
          "displayName": "\(targetName)",
          "moduleVersion": "1.0.0",
          "moduleType": "\(moduleType)",
          "supportedPlatforms": ["macOS"],
          "minForsettiVersion": "1.0.0",
          "capabilitiesRequested": [],
          "entryPoint": "Sources/\(targetName)/\(targetName).swift",
          "runtimeRequirements": {
            "io": [],
            "ui": null,
            "dataIsolation": {
              "scope": "module_private"
            }
          }
        }
        """
        try Data(manifest.utf8).write(to: targetRoot.appendingPathComponent("forsetti-module.json"))
    }
}

private final class FixedClock: Clock {
    private let date: Date

    init(date: Date) {
        self.date = date
    }

    func now() -> Date {
        date
    }
}

private final class FixedIdentifierGenerator: IdentifierGenerating {
    private let value: String

    init(value: String) {
        self.value = value
    }

    func newIdentifier() -> String {
        value
    }
}

private final class TemporaryDirectory {
    let url: URL

    init() throws {
        url = FileManager.default.temporaryDirectory
            .appendingPathComponent("ffae-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    deinit {
        try? FileManager.default.removeItem(at: url)
    }
}
