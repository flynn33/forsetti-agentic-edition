import CryptoKit
import Foundation
import GovernanceContracts
import GovernanceCore

public struct BootstrapOptions {
    public let repositoryRoot: URL
    public let bundleRoot: URL
    public let edition: String?
    public let platform: String?
    public let frameworkVersion: String?
    public let deploymentPattern: String
    public let dryRun: Bool

    public init(
        repositoryRoot: URL,
        bundleRoot: URL,
        edition: String?,
        platform: String?,
        frameworkVersion: String?,
        deploymentPattern: String,
        dryRun: Bool
    ) {
        self.repositoryRoot = repositoryRoot
        self.bundleRoot = bundleRoot
        self.edition = edition
        self.platform = platform
        self.frameworkVersion = frameworkVersion
        self.deploymentPattern = deploymentPattern
        self.dryRun = dryRun
    }
}

public final class RepositoryBootstrapService {
    private let fileSystem: FileSystem
    private let resultFactory: ResultFactory
    private let verifier: BundleVerifying
    private let loader: FoundationJSONLoader
    private let manager: FileManager
    private let clock: Clock
    private let dateFormatter: ISO8601DateFormatter

    public init(
        fileSystem: FileSystem,
        resultFactory: ResultFactory,
        verifier: BundleVerifying,
        clock: Clock,
        manager: FileManager = .default
    ) {
        self.fileSystem = fileSystem
        self.resultFactory = resultFactory
        self.verifier = verifier
        self.loader = FoundationJSONLoader(fileSystem: fileSystem)
        self.manager = manager
        self.clock = clock
        self.dateFormatter = ISO8601DateFormatter()
        self.dateFormatter.formatOptions = [.withInternetDateTime]
    }

    public func initialize(options: BootstrapOptions) throws -> ValidationResult {
        let bundleResult = try verifier.verify(bundleRoot: options.bundleRoot)
        guard bundleResult.status == .pass else {
            return resultFactory.makeResult(status: .block, mode: "init", findings: bundleResult.findings)
        }

        let manifest = try loadManifest(bundleRoot: options.bundleRoot)
        var findings: [ValidationFinding] = []
        guard repositoryRootIsValid(options.repositoryRoot) else {
            return resultFactory.makeResult(
                status: .block,
                mode: "init",
                findings: [
                    blockingFinding(
                        conditionID: "init.repository.invalid",
                        message: "Repository root is missing or is not a Git repository.",
                        path: options.repositoryRoot.path,
                        evidence: [options.repositoryRoot.path],
                        remediation: "Run init from a repository root or pass --repository-root."
                    )
                ]
            )
        }

        let bundleParent = options.bundleRoot.deletingLastPathComponent()
        let containsSDKManifest = fileSystem.fileExists(at: bundleParent.appendingPathComponent("sdk-manifest.json"))
        if rootsOverlap(options.repositoryRoot, options.bundleRoot) ||
            (containsSDKManifest && rootsOverlap(options.repositoryRoot, bundleParent)) {
            return resultFactory.makeResult(status: .block, mode: "init", findings: [blockingFinding(
                conditionID: "init.installation.overlap", message: "The trusted bundle and its SDK installation must remain outside the governed repository.",
                path: options.repositoryRoot.path, evidence: [options.repositoryRoot.path, options.bundleRoot.path],
                remediation: "Use separate external SDK/bundle and target repository directories."
            )])
        }

        let resolved: ResolvedTarget
        do {
            resolved = try resolveTarget(options: options)
        } catch BootstrapResolutionError.ambiguousEdition {
            return resultFactory.makeResult(
                status: .block,
                mode: "init",
                findings: [
                    blockingFinding(
                        conditionID: "init.discovery.ambiguous",
                        message: "Repository edition could not be discovered.",
                        path: options.repositoryRoot.path,
                        evidence: [options.repositoryRoot.path],
                        remediation: "Pass --edition and --platform explicitly."
                    )
                ]
            )
        }
        if let mismatch = resolved.versionMismatchFinding {
            return resultFactory.makeResult(status: .block, mode: "init", findings: [mismatch])
        }
        let plan: InstallPlan
        do {
            plan = try buildInstallPlan(options: options, resolved: resolved, manifest: manifest)
        } catch BootstrapResolutionError.installationConflict(let path) {
            return resultFactory.makeResult(status: .block, mode: "init", findings: [blockingFinding(
                conditionID: "init.installation.conflict", message: "Existing metadata differs or an installation path is unsafe.",
                path: path, evidence: [path], remediation: "Preserve the existing files and use the SDK's explicit upgrade workflow or resolve the conflict before retrying."
            )])
        }
        if let agentsConflict = plan.agentsConflict {
            return resultFactory.makeResult(status: .block, mode: "init", findings: [agentsConflict])
        }

        if options.dryRun {
            findings.append(passFinding(
                conditionID: "init.dry-run",
                message: "Initialization dry run completed.",
                path: options.repositoryRoot.path,
                evidence: plan.targetPaths
            ))
            return resultFactory.makeResult(status: .pass, mode: "init", findings: findings)
        }

        try apply(plan: plan)
        findings.append(passFinding(
            conditionID: "init.completed",
            message: "Repository initialized for governance.",
            path: options.repositoryRoot.path,
            evidence: plan.targetPaths
        ))
        return resultFactory.makeResult(status: .pass, mode: "init", findings: findings)
    }

    public func doctor(repositoryRoot: URL, bundleRoot: URL) throws -> ValidationResult {
        var findings: [ValidationFinding] = []
        let bundleResult = try verifier.verify(bundleRoot: bundleRoot)
        findings.append(contentsOf: bundleResult.findings)
        guard repositoryRootIsValid(repositoryRoot) else {
            findings.append(blockingFinding(
                conditionID: "doctor.repository.invalid",
                message: "Repository root is missing or is not a Git repository.",
                path: repositoryRoot.path,
                evidence: [repositoryRoot.path],
                remediation: "Run doctor from a repository root or pass --repository-root."
            ))
            return resultFactory.makeResult(status: .block, mode: "doctor", findings: findings)
        }

        let manifest = try? loadManifest(bundleRoot: bundleRoot)
        let forsettiRoot = repositoryRoot.appendingPathComponent(".forsetti", isDirectory: true)
        let requiredFiles = [
            "project.json",
            "modules.json",
            "profile.lock.json",
            "policy.lock.json",
            "product.lock.json",
            "instructions/GOVERNANCE.md"
        ]
        for relativePath in requiredFiles {
            let url = forsettiRoot.appendingPathComponent(relativePath)
            if !fileSystem.fileExists(at: url) {
                findings.append(blockingFinding(
                    conditionID: "doctor.installation.missing-file",
                    message: "Required governance file is missing.",
                    path: ".forsetti/\(relativePath)",
                    evidence: [url.path],
                    remediation: "Run init to repair the governance layout."
                ))
            }
        }

        let agentsURL = repositoryRoot.appendingPathComponent("AGENTS.md")
        if let agentsText = try? String(data: fileSystem.readFile(at: agentsURL), encoding: .utf8),
           hasSingleGovernanceSection(agentsText) {
            findings.append(passFinding(
                conditionID: "doctor.instructions.installed",
                message: "Governance instructions are installed.",
                path: "AGENTS.md",
                evidence: ["FORSETTI-GOVERNANCE"]
            ))
        } else {
            findings.append(blockingFinding(
                conditionID: "doctor.instructions.missing",
                message: "Governance instructions are missing or malformed.",
                path: "AGENTS.md",
                evidence: [agentsURL.path],
                remediation: "Run init to install the governed instruction section."
            ))
        }

        if let manifest {
            findings.append(contentsOf: validateLocks(repositoryRoot: repositoryRoot, bundleRoot: bundleRoot, manifest: manifest))
        }
        findings.append(contentsOf: validateNativeTools(repositoryRoot: repositoryRoot))
        findings.append(activeTaskFinding(repositoryRoot: repositoryRoot))

        let blocked = bundleResult.status == .block || findings.contains { $0.decision == .block }
        return resultFactory.makeResult(status: blocked ? .block : .pass, mode: "doctor", findings: findings)
    }

    private func buildInstallPlan(
        options: BootstrapOptions,
        resolved: ResolvedTarget,
        manifest: ProductManifest
    ) throws -> InstallPlan {
        let forsettiRoot = options.repositoryRoot.appendingPathComponent(".forsetti", isDirectory: true)
        let plannedPaths = ["AGENTS.md", ".forsetti", ".forsetti/project.json", ".forsetti/modules.json",
            ".forsetti/profile.lock.json", ".forsetti/policy.lock.json", ".forsetti/product.lock.json",
            ".forsetti/instructions", ".forsetti/instructions/GOVERNANCE.md", ".forsetti/contracts",
            ".forsetti/tasks", ".forsetti/evidence", ".forsetti/validation"]
        for path in plannedPaths {
            try requireSafePath(options.repositoryRoot.appendingPathComponent(path), repositoryRoot: options.repositoryRoot)
        }
        let instructionText = try String(
            data: fileSystem.readFile(at: options.bundleRoot.appendingPathComponent("instructions/target-agents-section.md")),
            encoding: .utf8
        ) ?? ""
        let governanceText = instructionText
        let agentsURL = options.repositoryRoot.appendingPathComponent("AGENTS.md")
        let agentsText = try existingAgentsText(url: agentsURL)
        let agentsUpdate = updateAgents(existingText: agentsText, section: instructionText)
        let profileURL = profileURL(
            bundleRoot: options.bundleRoot,
            edition: resolved.edition,
            frameworkVersion: resolved.frameworkVersion
        )
        let profileData = try fileSystem.readFile(at: profileURL)
        let profileHash = sha256Hex(profileData)
        let manifestData = try fileSystem.readFile(at: options.bundleRoot.appendingPathComponent("product-manifest.json"))
        let manifestHash = sha256Hex(manifestData)
        let profileMetadata = try profileMetadata(from: profileData)
        let now = dateFormatter.string(from: clock.now())
        let projectURL = forsettiRoot.appendingPathComponent("project.json")
        let profileLockURL = forsettiRoot.appendingPathComponent("profile.lock.json")
        let policyLockURL = forsettiRoot.appendingPathComponent("policy.lock.json")
        let productLockURL = forsettiRoot.appendingPathComponent("product.lock.json")
        let initializedAt = existingStringField(at: projectURL, field: "initializedAtUTC") ?? now
        let profileLockedAt = existingStringField(at: profileLockURL, field: "lockedAtUTC") ?? now
        let policyLockedAt = existingStringField(at: policyLockURL, field: "lockedAtUTC") ?? now
        let productLockedAt = existingStringField(at: productLockURL, field: "lockedAtUTC") ?? now

        var writes: [PlannedWrite] = []
        writes.append(PlannedWrite(url: agentsURL, data: Data(agentsUpdate.text.utf8)))
        writes.append(PlannedWrite(
            url: projectURL,
            data: try jsonData([
                "schemaVersion": "2.0",
                "projectID": projectID(for: options.repositoryRoot),
                "repositoryType": resolved.repositoryType,
                "edition": resolved.edition,
                "targetPlatforms": [resolved.platform],
                "frameworkVersion": resolved.frameworkVersion,
                "deploymentPattern": options.deploymentPattern,
                "modulesPath": ".forsetti/modules.json",
                "profileLockPath": ".forsetti/profile.lock.json",
                "policyLockPath": ".forsetti/policy.lock.json",
                "productLockPath": ".forsetti/product.lock.json",
                "initializedAtUTC": initializedAt,
                "initializedByVersion": existingStringField(at: projectURL, field: "initializedByVersion") ?? ProductVersion.current
            ])
        ))
        writes.append(PlannedWrite(
            url: forsettiRoot.appendingPathComponent("modules.json"),
            data: try jsonData([
                "schemaVersion": "2.0",
                "modules": []
            ])
        ))
        writes.append(PlannedWrite(
            url: profileLockURL,
            data: try jsonData([
                "schemaVersion": "2.0",
                "profileID": profileMetadata.profileID,
                "profileVersion": ProductVersion.current,
                "frameworkVersion": resolved.frameworkVersion,
                "sourceRevision": profileHash,
                "supportStatus": "supported",
                "lockedAtUTC": profileLockedAt,
                "sha256": profileHash
            ])
        ))
        writes.append(PlannedWrite(
            url: policyLockURL,
            data: try jsonData([
                "schemaVersion": "2.0",
                "policyBundleID": "ffae-policy-\(manifest.version)",
                "policyBundleVersion": manifest.version,
                "lockedAtUTC": policyLockedAt,
                "sha256": manifest.policyBundleHash ?? sha256Hex(Data())
            ])
        ))
        writes.append(PlannedWrite(
            url: productLockURL,
            data: try jsonData([
                "schemaVersion": "2.0",
                "productVersion": manifest.version,
                "bundleID": manifest.bundleID,
                "platform": productLockPlatform(for: resolved.edition),
                "lockedAtUTC": productLockedAt,
                "sha256": manifestHash
            ])
        ))
        writes.append(PlannedWrite(
            url: forsettiRoot.appendingPathComponent("instructions/GOVERNANCE.md"),
            data: Data(governanceText.utf8)
        ))

        for index in writes.indices {
            let write = writes[index]
            if fileSystem.directoryExists(at: write.url) {
                throw BootstrapResolutionError.installationConflict(write.url.path)
            }
            guard fileSystem.fileExists(at: write.url) else { continue }
            let existing = try fileSystem.readFile(at: write.url)
            if write.url.lastPathComponent == "modules.json" {
                guard let object = try? JSONSerialization.jsonObject(with: existing) as? [String: Any],
                      object["schemaVersion"] as? String == "2.0", object["modules"] is [Any] else {
                    throw BootstrapResolutionError.installationConflict(write.url.path)
                }
                writes[index] = PlannedWrite(url: write.url, data: existing, expectedExisting: existing)
            } else if write.url.pathExtension == "json" {
                guard let oldObject = try? JSONSerialization.jsonObject(with: existing),
                      let newObject = try? JSONSerialization.jsonObject(with: write.data),
                      (oldObject as AnyObject).isEqual(newObject) else {
                    throw BootstrapResolutionError.installationConflict(write.url.path)
                }
                writes[index] = PlannedWrite(url: write.url, data: existing, expectedExisting: existing)
            } else if write.url.lastPathComponent != "AGENTS.md" && existing != write.data {
                throw BootstrapResolutionError.installationConflict(write.url.path)
            } else {
                writes[index] = PlannedWrite(url: write.url, data: write.data, expectedExisting: existing)
            }
        }

        let directories = [
            forsettiRoot,
            forsettiRoot.appendingPathComponent("instructions", isDirectory: true),
            forsettiRoot.appendingPathComponent("contracts", isDirectory: true),
            forsettiRoot.appendingPathComponent("tasks", isDirectory: true),
            forsettiRoot.appendingPathComponent("evidence", isDirectory: true),
            forsettiRoot.appendingPathComponent("validation", isDirectory: true)
        ]
        return InstallPlan(
            directories: directories,
            writes: writes,
            agentsConflict: agentsUpdate.conflict,
            targetPaths: directories.map(\.path) + writes.map(\.url.path)
        )
    }

    private func apply(plan: InstallPlan) throws {
        var createdDirectories: [URL] = []
        var fileBackups: [(url: URL, data: Data?, written: Data)] = []
        let repositoryRoot = plan.directories[0].deletingLastPathComponent()
        do {
            for directory in plan.directories {
                try requireSafePath(directory, repositoryRoot: repositoryRoot)
                if !fileSystem.directoryExists(at: directory) {
                    try manager.createDirectory(at: directory, withIntermediateDirectories: true)
                    createdDirectories.append(directory)
                }
            }
            for write in plan.writes {
                try requireSafePath(write.url, repositoryRoot: repositoryRoot)
                let previous = fileSystem.fileExists(at: write.url) ? try fileSystem.readFile(at: write.url) : nil
                guard previous == write.expectedExisting else {
                    throw BootstrapResolutionError.installationConflict(write.url.path)
                }
                if previous == write.data { continue }
                fileBackups.append((write.url, previous, write.data))
                try fileSystem.writeFileAtomically(write.data, to: write.url)
            }
        } catch {
            var recoveryPaths: [String] = []
            for (url, data, written) in fileBackups.reversed() {
                do {
                    try requireSafePath(url, repositoryRoot: repositoryRoot)
                    let current = fileSystem.fileExists(at: url) ? try fileSystem.readFile(at: url) : nil
                    if current == data { continue }
                    guard current == written else { throw BootstrapResolutionError.installationConflict(url.path) }
                    if let data {
                        try fileSystem.writeFileAtomically(data, to: url)
                    } else {
                        try manager.removeItem(at: url)
                    }
                } catch {
                    recoveryPaths.append(url.path)
                }
            }
            for directory in createdDirectories.reversed() {
                if (try? manager.contentsOfDirectory(atPath: directory.path).isEmpty) == true {
                    try? manager.removeItem(at: directory)
                }
            }
            if !recoveryPaths.isEmpty {
                throw BootstrapResolutionError.rollbackIncomplete(original: String(describing: error), paths: recoveryPaths)
            }
            throw error
        }
    }

    private func resolveTarget(options: BootstrapOptions) throws -> ResolvedTarget {
        let discovered = discoverEdition(repositoryRoot: options.repositoryRoot)
        guard let edition = options.edition ?? discovered.edition else {
            throw BootstrapResolutionError.ambiguousEdition
        }
        let platform = options.platform ?? defaultPlatform(for: edition)
        guard ["apple", "windows"].contains(edition),
              (edition == "apple" ? ["iOS", "macOS"] : ["Windows"]).contains(platform),
              options.frameworkVersion == nil || options.frameworkVersion?.range(of: "^[0-9]+\\.[0-9]+\\.[0-9]+$", options: .regularExpression) != nil,
              ["single_app_module", "multi_module_single_app", "developer_testing", "dashboard", "framework_governance"].contains(options.deploymentPattern) else {
            return ResolvedTarget(edition: edition, platform: platform, frameworkVersion: options.frameworkVersion ?? "0.0.0",
                repositoryType: discovered.repositoryType, versionMismatchFinding: blockingFinding(
                    conditionID: "init.selection.invalid", message: "Edition, platform, framework version or deployment pattern is invalid.",
                    path: options.repositoryRoot.path, evidence: [edition, platform, options.deploymentPattern],
                    remediation: "Select a supported edition profile and its declared target platform."
                ))
        }
        let profileURL = profileURL(
            bundleRoot: options.bundleRoot,
            edition: edition,
            frameworkVersion: options.frameworkVersion
        )
        guard fileSystem.fileExists(at: profileURL) else {
            return ResolvedTarget(
                edition: edition,
                platform: platform,
                frameworkVersion: options.frameworkVersion ?? "0.0.0",
                repositoryType: "application_repository",
                versionMismatchFinding: blockingFinding(
                    conditionID: "init.profile.missing",
                    message: "Compatible edition profile is missing from the product bundle.",
                    path: profileURL.path,
                    evidence: [profileURL.path],
                    remediation: "Use a product bundle containing the selected edition profile."
                )
            )
        }
        let profile = try profileMetadata(from: fileSystem.readFile(at: profileURL))
        let frameworkVersion = options.frameworkVersion ?? profile.frameworkVersion
        let mismatch: ValidationFinding? = options.frameworkVersion != nil && options.frameworkVersion != profile.frameworkVersion
            ? blockingFinding(
                conditionID: "init.profile.version-mismatch",
                message: "Requested framework version does not match the selected profile.",
                path: profileURL.path,
                evidence: ["requested=\(frameworkVersion)", "profile=\(profile.frameworkVersion)"],
                remediation: "Select a compatible profile or pass the framework version from the installed profile."
            )
            : nil
        return ResolvedTarget(
            edition: edition,
            platform: platform,
            frameworkVersion: frameworkVersion,
            repositoryType: discovered.repositoryType,
            versionMismatchFinding: mismatch
        )
    }

    private func discoverEdition(repositoryRoot: URL) -> DiscoveryResult {
        let hasApple = fileSystem.fileExists(at: repositoryRoot.appendingPathComponent("Package.swift")) ||
            containsFileExtension(repositoryRoot: repositoryRoot, extensionName: "xcodeproj")
        let hasWindows = fileSystem.fileExists(at: repositoryRoot.appendingPathComponent("CMakeLists.txt")) ||
            containsFileExtension(repositoryRoot: repositoryRoot, extensionName: "sln") ||
            containsFileExtension(repositoryRoot: repositoryRoot, extensionName: "vcxproj")
        if hasApple && !hasWindows {
            return DiscoveryResult(edition: "apple", repositoryType: "application_repository")
        }
        if hasWindows && !hasApple {
            return DiscoveryResult(edition: "windows", repositoryType: "application_repository")
        }
        return DiscoveryResult(edition: nil, repositoryType: "application_repository")
    }

    private func containsFileExtension(repositoryRoot: URL, extensionName: String) -> Bool {
        guard let enumerator = manager.enumerator(at: repositoryRoot, includingPropertiesForKeys: nil) else {
            return false
        }
        for case let url as URL in enumerator {
            if url.path.contains("/.git/") || url.path.contains("/.forsetti/") {
                enumerator.skipDescendants()
                continue
            }
            if url.pathExtension == extensionName {
                return true
            }
        }
        return false
    }

    private func validateLocks(repositoryRoot: URL, bundleRoot: URL, manifest: ProductManifest) -> [ValidationFinding] {
        let forsettiRoot = repositoryRoot.appendingPathComponent(".forsetti", isDirectory: true)
        let manifestURL = bundleRoot.appendingPathComponent("product-manifest.json")
        let manifestHash = (try? fileSystem.readFile(at: manifestURL)).map(sha256Hex) ?? ""
        var findings: [ValidationFinding] = []

        if let project = try? jsonObject(at: forsettiRoot.appendingPathComponent("project.json")),
           let edition = project["edition"] as? String {
            let frameworkVersion = project["frameworkVersion"] as? String
            let profileURL = profileURL(
                bundleRoot: bundleRoot,
                edition: edition,
                frameworkVersion: frameworkVersion
            )
            let expectedProfileHash = (try? fileSystem.readFile(at: profileURL)).map(sha256Hex)
            let profileLock = try? jsonObject(at: forsettiRoot.appendingPathComponent("profile.lock.json"))
            if profileLock?["sha256"] as? String == expectedProfileHash {
                findings.append(passFinding(
                    conditionID: "doctor.profile-lock.verified",
                    message: "Profile lock matches the installed bundle.",
                    path: ".forsetti/profile.lock.json",
                    evidence: [expectedProfileHash ?? ""]
                ))
            } else {
                findings.append(blockingFinding(
                    conditionID: "doctor.profile-lock.mismatch",
                    message: "Profile lock does not match the installed bundle.",
                    path: ".forsetti/profile.lock.json",
                    evidence: [expectedProfileHash ?? ""],
                    remediation: "Preserve the lock and use the SDK's explicit upgrade workflow for a reviewed profile change."
                ))
            }
        }

        let policyLock = try? jsonObject(at: forsettiRoot.appendingPathComponent("policy.lock.json"))
        if policyLock?["sha256"] as? String == manifest.policyBundleHash {
            findings.append(passFinding(
                conditionID: "doctor.policy-lock.verified",
                message: "Policy lock matches the installed bundle.",
                path: ".forsetti/policy.lock.json",
                evidence: [manifest.policyBundleHash ?? ""]
            ))
        } else {
            findings.append(blockingFinding(
                conditionID: "doctor.policy-lock.mismatch",
                message: "Policy lock does not match the installed bundle.",
                path: ".forsetti/policy.lock.json",
                evidence: [manifest.policyBundleHash ?? ""],
                remediation: "Preserve the lock and use the SDK's explicit upgrade workflow for a reviewed policy change."
            ))
        }

        let productLock = try? jsonObject(at: forsettiRoot.appendingPathComponent("product.lock.json"))
        if productLock?["sha256"] as? String == manifestHash,
           productLock?["productVersion"] as? String == manifest.version,
           productLock?["bundleID"] as? String == manifest.bundleID {
            findings.append(passFinding(
                conditionID: "doctor.product-lock.verified",
                message: "Product lock matches the installed bundle.",
                path: ".forsetti/product.lock.json",
                evidence: [manifestHash]
            ))
        } else {
            findings.append(blockingFinding(
                conditionID: "doctor.product-lock.mismatch",
                message: "Product lock does not match the installed bundle.",
                path: ".forsetti/product.lock.json",
                evidence: [manifestHash],
                remediation: "Preserve the lock and use the SDK's explicit upgrade workflow for a reviewed product change."
            ))
        }
        return findings
    }

    private func validateNativeTools(repositoryRoot: URL) -> [ValidationFinding] {
        let projectURL = repositoryRoot.appendingPathComponent(".forsetti/project.json")
        guard let project = try? jsonObject(at: projectURL),
              let edition = project["edition"] as? String else {
            return [
                blockingFinding(
                    conditionID: "doctor.project.unreadable",
                    message: "Project configuration cannot be read.",
                    path: ".forsetti/project.json",
                    evidence: [projectURL.path],
                    remediation: "Preserve existing metadata and restore the reviewed project configuration before initialization."
                )
            ]
        }
        let requiredTools: [(String, [String])]
        switch edition {
        case "apple":
            requiredTools = [("swift", ["/usr/bin/swift"]), ("xcodebuild", ["/usr/bin/xcodebuild"])]
        case "windows":
            requiredTools = [("cmake", ["/usr/bin/cmake", "/opt/homebrew/bin/cmake"]), ("pwsh", ["/usr/local/bin/pwsh", "/opt/homebrew/bin/pwsh"])]
        default:
            requiredTools = []
        }
        var findings: [ValidationFinding] = []
        for (tool, candidatePaths) in requiredTools {
            if candidatePaths.contains(where: { manager.isExecutableFile(atPath: $0) }) {
                findings.append(passFinding(
                    conditionID: "doctor.native-tool.available",
                    message: "Required native tool is available.",
                    path: tool,
                    evidence: candidatePaths
                ))
            } else {
                findings.append(blockingFinding(
                    conditionID: "doctor.native-tool.missing",
                    message: "Required native tool is unavailable.",
                    path: tool,
                    evidence: candidatePaths,
                    remediation: "Install the required native tool before running governed validation."
                ))
            }
        }
        return findings
    }

    private func activeTaskFinding(repositoryRoot: URL) -> ValidationFinding {
        let tasksRoot = repositoryRoot.appendingPathComponent(".forsetti/tasks", isDirectory: true)
        let states = ((try? manager.contentsOfDirectory(at: tasksRoot, includingPropertiesForKeys: nil)) ?? [])
            .filter { fileSystem.fileExists(at: $0.appendingPathComponent("state.json")) }
        return passFinding(
            conditionID: "doctor.task-state",
            message: "Active task state inspected.",
            path: ".forsetti/tasks",
            evidence: ["activeTaskCount=\(states.count)"]
        )
    }

    private func updateAgents(existingText: String?, section: String) -> AgentsUpdate {
        let begin = "<!-- FORSETTI-GOVERNANCE:BEGIN -->"
        let end = "<!-- FORSETTI-GOVERNANCE:END -->"
        guard let existingText, !existingText.isEmpty else {
            return AgentsUpdate(text: section.trimmingCharacters(in: .whitespacesAndNewlines) + "\n", conflict: nil)
        }
        let beginCount = existingText.components(separatedBy: begin).count - 1
        let endCount = existingText.components(separatedBy: end).count - 1
        if beginCount != endCount || beginCount > 1 {
            return AgentsUpdate(
                text: existingText,
                conflict: blockingFinding(
                    conditionID: "init.instructions.conflict",
                    message: "Existing governance instruction block is malformed.",
                    path: "AGENTS.md",
                    evidence: ["begin=\(beginCount)", "end=\(endCount)"],
                    remediation: "Repair the existing governed section before running init."
                )
            )
        }
        if beginCount == 1,
           let beginRange = existingText.range(of: begin),
           let endRange = existingText.range(of: end, range: beginRange.upperBound..<existingText.endIndex) {
            if existingText[beginRange.lowerBound..<endRange.upperBound] != section.trimmingCharacters(in: .whitespacesAndNewlines) {
                return AgentsUpdate(text: existingText, conflict: blockingFinding(
                    conditionID: "init.instructions.conflict", message: "Existing governance block differs from the selected bundle.",
                    path: "AGENTS.md", evidence: ["FORSETTI-GOVERNANCE"],
                    remediation: "Preserve the block and use the SDK's explicit upgrade workflow."
                ))
            }
            return AgentsUpdate(text: existingText, conflict: nil)
        }
        if beginCount == 1 {
            return AgentsUpdate(text: existingText, conflict: blockingFinding(
                conditionID: "init.instructions.conflict", message: "Governance instruction markers are out of order.",
                path: "AGENTS.md", evidence: ["FORSETTI-GOVERNANCE"], remediation: "Repair the managed block before running init."
            ))
        }
        let separator = existingText.hasSuffix("\n") ? "\n" : "\n\n"
        return AgentsUpdate(
            text: existingText + separator + section.trimmingCharacters(in: .whitespacesAndNewlines) + "\n",
            conflict: nil
        )
    }

    private func hasSingleGovernanceSection(_ text: String) -> Bool {
        let beginCount = text.components(separatedBy: "<!-- FORSETTI-GOVERNANCE:BEGIN -->").count - 1
        let endCount = text.components(separatedBy: "<!-- FORSETTI-GOVERNANCE:END -->").count - 1
        guard beginCount == 1 && endCount == 1,
              let begin = text.range(of: "<!-- FORSETTI-GOVERNANCE:BEGIN -->"),
              let end = text.range(of: "<!-- FORSETTI-GOVERNANCE:END -->") else { return false }
        return begin.upperBound <= end.lowerBound
    }

    private func existingAgentsText(url: URL) throws -> String? {
        guard fileSystem.fileExists(at: url) else {
            return nil
        }
        guard let text = String(data: try fileSystem.readFile(at: url), encoding: .utf8) else {
            throw BootstrapResolutionError.installationConflict(url.path)
        }
        return text
    }

    private func repositoryRootIsValid(_ repositoryRoot: URL) -> Bool {
        fileSystem.directoryExists(at: repositoryRoot) &&
            (fileSystem.directoryExists(at: repositoryRoot.appendingPathComponent(".git", isDirectory: true)) ||
             fileSystem.fileExists(at: repositoryRoot.appendingPathComponent(".git")))
    }

    private func requireSafePath(_ url: URL, repositoryRoot: URL) throws {
        let root = repositoryRoot.standardizedFileURL
        var current = url.standardizedFileURL
        guard current.path.hasPrefix(root.path + "/") else {
            throw BootstrapResolutionError.installationConflict(url.path)
        }
        while current.path.hasPrefix(root.path + "/") || current == root {
            if (try? current.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) == true {
                throw BootstrapResolutionError.installationConflict(current.path)
            }
            if current == root { break }
            current.deleteLastPathComponent()
        }
    }

    private func rootsOverlap(_ first: URL, _ second: URL) -> Bool {
        let firstPath = first.resolvingSymlinksInPath().standardizedFileURL.path.lowercased()
        let secondPath = second.resolvingSymlinksInPath().standardizedFileURL.path.lowercased()
        let firstPrefix = firstPath.hasSuffix("/") ? firstPath : firstPath + "/"
        let secondPrefix = secondPath.hasSuffix("/") ? secondPath : secondPath + "/"
        return firstPath == secondPath || firstPath.hasPrefix(secondPrefix) || secondPath.hasPrefix(firstPrefix)
    }

    private func loadManifest(bundleRoot: URL) throws -> ProductManifest {
        try loader.loadJSON(ProductManifest.self, from: bundleRoot.appendingPathComponent("product-manifest.json"))
    }

    private func profileURL(
        bundleRoot: URL,
        edition: String,
        frameworkVersion: String? = nil
    ) -> URL {
        let selectedVersion = frameworkVersion ?? defaultFrameworkVersion(for: edition)
        return bundleRoot.appendingPathComponent(
            "editions/\(edition)/forsetti-\(edition)-\(selectedVersion).profile.json"
        )
    }

    private func defaultFrameworkVersion(for edition: String) -> String {
        edition == "windows" ? "0.2.0" : "0.1.5"
    }

    private func defaultPlatform(for edition: String) -> String {
        edition == "windows" ? "Windows" : "macOS"
    }

    private func productLockPlatform(for edition: String) -> String {
        edition == "windows" ? "windows-host" : "apple-host"
    }

    private func projectID(for repositoryRoot: URL) -> String {
        let raw = repositoryRoot.lastPathComponent
        let sanitized = raw.map { character in
            character.isLetter || character.isNumber || character == "-" || character == "." ? character : "-"
        }
        let value = String(sanitized).trimmingCharacters(in: CharacterSet(charactersIn: "-."))
        return value.count >= 3 ? value : "forsetti-project"
    }

    private func profileMetadata(from data: Data) throws -> ProfileMetadata {
        let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let edition = object?["edition"] as? String ?? "unknown"
        let frameworkVersion = object?["frameworkVersion"] as? String ?? "0.0.0"
        return ProfileMetadata(
            profileID: "forsetti-\(edition)-\(frameworkVersion)",
            frameworkVersion: frameworkVersion
        )
    }

    private func jsonObject(at url: URL) throws -> [String: Any] {
        try JSONSerialization.jsonObject(with: fileSystem.readFile(at: url)) as? [String: Any] ?? [:]
    }

    private func existingStringField(at url: URL, field: String) -> String? {
        (try? jsonObject(at: url))?[field] as? String
    }

    private func jsonData(_ object: [String: Any]) throws -> Data {
        var data = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
        data.append(0x0a)
        return data
    }

    private func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private func passFinding(conditionID: String, message: String, path: String?, evidence: [String]) -> ValidationFinding {
        ValidationFinding(
            canonicalRuleID: "FAE-F030",
            conditionID: conditionID,
            severity: .info,
            decision: .pass,
            message: message,
            path: path,
            moduleID: nil,
            evidence: evidence,
            remediation: nil
        )
    }

    private func blockingFinding(
        conditionID: String,
        message: String,
        path: String?,
        evidence: [String],
        remediation: String
    ) -> ValidationFinding {
        ValidationFinding(
            canonicalRuleID: "FAE-F030",
            conditionID: conditionID,
            severity: .critical,
            decision: .block,
            message: message,
            path: path,
            moduleID: nil,
            evidence: evidence,
            remediation: remediation
        )
    }
}

private struct ResolvedTarget {
    let edition: String
    let platform: String
    let frameworkVersion: String
    let repositoryType: String
    let versionMismatchFinding: ValidationFinding?
}

private struct DiscoveryResult {
    let edition: String?
    let repositoryType: String
}

private struct InstallPlan {
    let directories: [URL]
    let writes: [PlannedWrite]
    let agentsConflict: ValidationFinding?
    let targetPaths: [String]
}

private struct PlannedWrite {
    let url: URL
    let data: Data
    let expectedExisting: Data?

    init(url: URL, data: Data, expectedExisting: Data? = nil) {
        self.url = url
        self.data = data
        self.expectedExisting = expectedExisting
    }
}

private struct AgentsUpdate {
    let text: String
    let conflict: ValidationFinding?
}

private struct ProfileMetadata {
    let profileID: String
    let frameworkVersion: String
}

private enum BootstrapResolutionError: Error {
    case ambiguousEdition
    case installationConflict(String)
    case rollbackIncomplete(original: String, paths: [String])
}
