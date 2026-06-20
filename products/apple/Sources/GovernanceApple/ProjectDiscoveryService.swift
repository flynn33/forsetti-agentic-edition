import Foundation
import GovernanceContracts
import GovernanceCore

public struct DiscoveryOptions {
    public let repositoryRoot: URL
    public let outputURL: URL?

    public init(repositoryRoot: URL, outputURL: URL?) {
        self.repositoryRoot = repositoryRoot
        self.outputURL = outputURL
    }
}

public final class ProjectDiscoveryService: ProjectDiscovering {
    private let fileSystem: FileSystem
    private let processRunner: ProcessRunning
    private let resultFactory: ResultFactory
    private let manager: FileManager

    public init(
        fileSystem: FileSystem,
        processRunner: ProcessRunning,
        resultFactory: ResultFactory,
        manager: FileManager = .default
    ) {
        self.fileSystem = fileSystem
        self.processRunner = processRunner
        self.resultFactory = resultFactory
        self.manager = manager
    }

    public func discover(repositoryRoot: URL) throws -> ValidationResult {
        try discover(options: DiscoveryOptions(repositoryRoot: repositoryRoot, outputURL: nil))
    }

    public func discover(options: DiscoveryOptions) throws -> ValidationResult {
        guard fileSystem.directoryExists(at: options.repositoryRoot) else {
            return resultFactory.makeResult(
                status: .block,
                mode: "discover",
                findings: [
                    finding(
                        conditionID: "discover.repository.missing",
                        severity: .critical,
                        decision: .block,
                        message: "Repository root does not exist.",
                        path: options.repositoryRoot.path,
                        evidence: [options.repositoryRoot.path],
                        remediation: "Pass an existing repository root."
                    )
                ]
            )
        }

        let buildSystems = detectBuildSystems(repositoryRoot: options.repositoryRoot)
        var findings: [ValidationFinding] = [
            finding(
                conditionID: "discover.build-systems",
                severity: .info,
                decision: .pass,
                message: "Build systems discovered.",
                path: options.repositoryRoot.path,
                evidence: buildSystems.sorted(),
                remediation: nil
            )
        ]
        var unresolvedItems: [String] = []
        var nativeTargets: [DiscoveredTarget] = []
        var dependencyEdges: [DependencyEdge] = []

        if buildSystems.contains("swiftpm") {
            let swiftResult = inspectSwiftPackage(repositoryRoot: options.repositoryRoot)
            nativeTargets.append(contentsOf: swiftResult.targets)
            dependencyEdges.append(contentsOf: swiftResult.edges)
            unresolvedItems.append(contentsOf: swiftResult.unresolvedItems)
        }
        if buildSystems.contains("xcode") {
            let xcodeResult = inspectXcodeProjects(repositoryRoot: options.repositoryRoot)
            nativeTargets.append(contentsOf: xcodeResult.targets)
            unresolvedItems.append(contentsOf: xcodeResult.unresolvedItems)
        }
        if buildSystems.contains("cmake") {
            let cmakeResult = inspectCMakeFileAPI(repositoryRoot: options.repositoryRoot)
            nativeTargets.append(contentsOf: cmakeResult.targets)
            dependencyEdges.append(contentsOf: cmakeResult.edges)
            unresolvedItems.append(contentsOf: cmakeResult.unresolvedItems)
        }
        if buildSystems.contains("msbuild") {
            unresolvedItems.append("msbuild.structured-inspection.pending")
        }

        let manifests = discoverModuleManifests(repositoryRoot: options.repositoryRoot)
        let proposedModules = buildProposedModules(
            manifests: manifests,
            nativeTargets: nativeTargets,
            buildSystems: buildSystems,
            repositoryRoot: options.repositoryRoot,
            unresolvedItems: &unresolvedItems
        )

        findings.append(contentsOf: duplicateModuleFindings(manifests: manifests))
        findings.append(contentsOf: targetInventoryFindings(
            nativeTargets: nativeTargets,
            proposedModules: proposedModules,
            dependencyEdges: dependencyEdges
        ))
        findings.append(contentsOf: sourceRootFindings(modules: proposedModules))
        findings.append(contentsOf: reconciliationFindings(repositoryRoot: options.repositoryRoot, proposedModules: proposedModules))

        for unresolved in unresolvedItems.sorted() {
            findings.append(finding(
                conditionID: "discover.unresolved",
                severity: .medium,
                decision: .requestChanges,
                message: "Discovery found an unresolved item.",
                path: unresolved,
                evidence: [unresolved],
                remediation: "Reconcile the project inventory manually or add the missing manifest/build metadata."
            ))
        }

        if let outputURL = options.outputURL {
            try manager.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try fileSystem.writeFileAtomically(try modulesInventoryData(modules: proposedModules), to: outputURL)
            findings.append(finding(
                conditionID: "discover.proposal.written",
                severity: .info,
                decision: .pass,
                message: "Proposed module inventory written.",
                path: outputURL.path,
                evidence: [outputURL.path],
                remediation: nil
            ))
        }

        if proposedModules.isEmpty {
            findings.append(finding(
                conditionID: "discover.modules.empty",
                severity: .medium,
                decision: .requestChanges,
                message: "No module manifests were discovered.",
                path: options.repositoryRoot.path,
                evidence: [options.repositoryRoot.path],
                remediation: "Add module manifests or provide a manual inventory."
            ))
        } else {
            findings.append(finding(
                conditionID: "discover.modules.proposed",
                severity: .info,
                decision: .pass,
                message: "Proposed module inventory produced.",
                path: options.repositoryRoot.path,
                evidence: proposedModules.map(\.moduleID).sorted(),
                remediation: nil
            ))
        }

        let status: ValidationStatus
        if findings.contains(where: { $0.decision == .block }) {
            status = .block
        } else if findings.contains(where: { $0.decision == .requestChanges }) {
            status = .requestChanges
        } else {
            status = .pass
        }
        return resultFactory.makeResult(status: status, mode: "discover", findings: findings)
    }

    private func detectBuildSystems(repositoryRoot: URL) -> Set<String> {
        var systems = Set<String>()
        if fileSystem.fileExists(at: repositoryRoot.appendingPathComponent("Package.swift")) {
            systems.insert("swiftpm")
        }
        if containsFileExtension(repositoryRoot: repositoryRoot, extensionName: "xcodeproj") {
            systems.insert("xcode")
        }
        if fileSystem.fileExists(at: repositoryRoot.appendingPathComponent("CMakeLists.txt")) {
            systems.insert("cmake")
        }
        if containsFileExtension(repositoryRoot: repositoryRoot, extensionName: "sln") ||
            containsFileExtension(repositoryRoot: repositoryRoot, extensionName: "vcxproj") {
            systems.insert("msbuild")
        }
        return systems
    }

    private func inspectSwiftPackage(repositoryRoot: URL) -> NativeInspectionResult {
        do {
            let result = try processRunner.run(
                executable: "/usr/bin/swift",
                arguments: ["package", "dump-package", "--package-path", repositoryRoot.path],
                workingDirectory: repositoryRoot
            )
            guard result.exitCode == 0 else {
                return NativeInspectionResult(
                    targets: [],
                    edges: [],
                    unresolvedItems: ["swiftpm.dump-package.failed"]
                )
            }
            let object = try JSONSerialization.jsonObject(with: result.stdout) as? [String: Any]
            let targets = (object?["targets"] as? [[String: Any]] ?? []).compactMap { targetObject -> DiscoveredTarget? in
                guard let name = targetObject["name"] as? String,
                      let type = targetObject["type"] as? String,
                      type != "test" else {
                    return nil
                }
                let sourceRoot = "Sources/\(name)"
                return DiscoveredTarget(name: name, buildSystem: "swiftpm", sourceRoot: sourceRoot, moduleBearing: true)
            }
            let edges = (object?["targets"] as? [[String: Any]] ?? []).flatMap { targetObject -> [DependencyEdge] in
                guard let source = targetObject["name"] as? String else {
                    return []
                }
                return (targetObject["dependencies"] as? [[String: Any]] ?? []).compactMap { dependency in
                    guard let byName = dependency["byName"] as? [Any],
                          let target = byName.first as? String else {
                        return nil
                    }
                    return DependencyEdge(source: source, target: target, kind: "target")
                }
            }
            return NativeInspectionResult(targets: targets, edges: edges, unresolvedItems: [])
        } catch {
            return NativeInspectionResult(targets: [], edges: [], unresolvedItems: ["swiftpm.dump-package.unavailable"])
        }
    }

    private func inspectXcodeProjects(repositoryRoot: URL) -> NativeInspectionResult {
        let projects = findURLs(repositoryRoot: repositoryRoot) { $0.pathExtension == "xcodeproj" }
        var targets: [DiscoveredTarget] = []
        var unresolved: [String] = []
        for project in projects {
            do {
                let result = try processRunner.run(
                    executable: "/usr/bin/xcodebuild",
                    arguments: ["-list", "-json", "-project", project.path],
                    workingDirectory: repositoryRoot
                )
                guard result.exitCode == 0,
                      let object = try JSONSerialization.jsonObject(with: result.stdout) as? [String: Any],
                      let projectObject = object["project"] as? [String: Any] else {
                    unresolved.append("xcode.list.failed:\(relativePath(project, repositoryRoot: repositoryRoot))")
                    continue
                }
                for name in projectObject["targets"] as? [String] ?? [] {
                    targets.append(DiscoveredTarget(name: name, buildSystem: "xcode", sourceRoot: name, moduleBearing: true))
                }
            } catch {
                unresolved.append("xcode.list.unavailable:\(relativePath(project, repositoryRoot: repositoryRoot))")
            }
        }
        return NativeInspectionResult(targets: targets, edges: [], unresolvedItems: unresolved)
    }

    private func inspectCMakeFileAPI(repositoryRoot: URL) -> NativeInspectionResult {
        let replyRoot = repositoryRoot.appendingPathComponent(".cmake/api/v1/reply", isDirectory: true)
        guard fileSystem.directoryExists(at: replyRoot) else {
            return NativeInspectionResult(targets: [], edges: [], unresolvedItems: ["cmake.file-api.reply-missing"])
        }
        let codemodels = findURLs(repositoryRoot: replyRoot) {
            $0.lastPathComponent.hasPrefix("codemodel") && $0.pathExtension == "json"
        }
        guard !codemodels.isEmpty else {
            return NativeInspectionResult(targets: [], edges: [], unresolvedItems: ["cmake.file-api.codemodel-missing"])
        }
        var targets: [DiscoveredTarget] = []
        for codemodel in codemodels {
            guard let object = try? JSONSerialization.jsonObject(with: fileSystem.readFile(at: codemodel)) as? [String: Any] else {
                continue
            }
            for configuration in object["configurations"] as? [[String: Any]] ?? [] {
                for target in configuration["targets"] as? [[String: Any]] ?? [] {
                    if let name = target["name"] as? String {
                        targets.append(DiscoveredTarget(name: name, buildSystem: "cmake", sourceRoot: name, moduleBearing: true))
                    }
                }
            }
        }
        return NativeInspectionResult(targets: targets, edges: [], unresolvedItems: [])
    }

    private func discoverModuleManifests(repositoryRoot: URL) -> [ModuleManifest] {
        findURLs(repositoryRoot: repositoryRoot) { $0.pathExtension == "json" }.compactMap { url in
            guard !url.path.contains("/.git/"),
                  !url.path.contains("/.forsetti/"),
                  let data = try? fileSystem.readFile(at: url),
                  let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let moduleID = object["moduleID"] as? String,
                  let moduleType = object["moduleType"] as? String,
                  let template = object["manifestTemplateVersion"] as? String else {
                return nil
            }
            let entryPoint = object["entryPoint"] as? String
            return ModuleManifest(
                moduleID: moduleID,
                moduleType: moduleType,
                defaultModuleRole: object["defaultModuleRole"] as? String,
                manifestTemplateVersion: template,
                manifestPath: relativePath(url, repositoryRoot: repositoryRoot),
                displayName: object["displayName"] as? String,
                entryPoint: entryPoint,
                sourceRoot: sourceRoot(forEntryPoint: entryPoint, manifestURL: url, repositoryRoot: repositoryRoot),
                capabilitiesRequested: object["capabilitiesRequested"] as? [String] ?? [],
                runtimeRequirementsDeclared: object["runtimeRequirements"] != nil,
                platforms: object["supportedPlatforms"] as? [String] ?? []
            )
        }
    }

    private func buildProposedModules(
        manifests: [ModuleManifest],
        nativeTargets: [DiscoveredTarget],
        buildSystems: Set<String>,
        repositoryRoot: URL,
        unresolvedItems: inout [String]
    ) -> [ProposedModule] {
        let targetsByName = Dictionary(uniqueKeysWithValues: nativeTargets.map { ($0.name, $0) })
        return manifests.map { manifest in
            let target = targetsByName[manifest.moduleID] ?? manifest.displayName.flatMap { targetsByName[$0] }
            if target == nil {
                unresolvedItems.append("manifest-without-target:\(manifest.manifestPath)")
            }
            return ProposedModule(
                moduleID: manifest.moduleID,
                moduleType: manifest.moduleType,
                defaultModuleRole: manifest.defaultModuleRole,
                manifestPath: manifest.manifestPath,
                targetName: target?.name ?? manifest.moduleID,
                buildSystem: target?.buildSystem ?? buildSystems.sorted().first,
                sourceRoots: [target?.sourceRoot ?? manifest.sourceRoot],
                resourceRoots: resourceRoots(for: manifest, repositoryRoot: repositoryRoot),
                capabilitiesRequested: manifest.capabilitiesRequested.sorted(),
                runtimeRequirementsDeclared: manifest.runtimeRequirementsDeclared,
                platforms: manifest.platforms.sorted(),
                publicDependencies: []
            )
        }.sorted { $0.moduleID < $1.moduleID }
    }

    private func duplicateModuleFindings(manifests: [ModuleManifest]) -> [ValidationFinding] {
        let grouped = Dictionary(grouping: manifests, by: \.moduleID)
        return grouped.filter { $0.value.count > 1 }.map { moduleID, manifests in
            finding(
                conditionID: "discover.module.duplicate-id",
                severity: .critical,
                decision: .block,
                message: "Duplicate module ID discovered.",
                path: moduleID,
                evidence: manifests.map(\.manifestPath).sorted(),
                remediation: "Assign unique module IDs before approving inventory."
            )
        }
    }

    private func targetInventoryFindings(
        nativeTargets: [DiscoveredTarget],
        proposedModules: [ProposedModule],
        dependencyEdges: [DependencyEdge]
    ) -> [ValidationFinding] {
        let moduleTargets = Set(proposedModules.map(\.targetName))
        var findings: [ValidationFinding] = []
        for target in nativeTargets where target.moduleBearing && !moduleTargets.contains(target.name) {
            findings.append(finding(
                conditionID: "discover.target.missing-manifest",
                severity: .medium,
                decision: .requestChanges,
                message: "Build target appears module-bearing but has no module manifest.",
                path: target.name,
                evidence: [target.buildSystem, target.sourceRoot],
                remediation: "Add a module manifest or approve manual inventory."
            ))
        }
        for edge in dependencyEdges where moduleTargets.contains(edge.source) && moduleTargets.contains(edge.target) {
            findings.append(finding(
                conditionID: "discover.module.direct-edge",
                severity: .medium,
                decision: .requestChanges,
                message: "Direct module dependency edge discovered.",
                path: edge.source,
                evidence: ["\(edge.source)->\(edge.target)", edge.kind],
                remediation: "Route module interaction through public framework contracts."
            ))
        }
        return findings
    }

    private func sourceRootFindings(modules: [ProposedModule]) -> [ValidationFinding] {
        var findings: [ValidationFinding] = []
        for left in modules {
            for right in modules where left.moduleID < right.moduleID {
                for leftRoot in left.sourceRoots {
                    for rightRoot in right.sourceRoots where leftRoot != rightRoot {
                        if leftRoot.hasPrefix("\(rightRoot)/") || rightRoot.hasPrefix("\(leftRoot)/") {
                            findings.append(finding(
                                conditionID: "discover.source-root.overlap",
                                severity: .medium,
                                decision: .requestChanges,
                                message: "Module source roots overlap.",
                                path: left.moduleID,
                                evidence: [leftRoot, rightRoot],
                                remediation: "Split source roots or approve a manual inventory."
                            ))
                        }
                    }
                }
            }
            let unsupported = left.platforms.filter { !["iOS", "macOS", "Windows"].contains($0) }
            if !unsupported.isEmpty {
                findings.append(finding(
                    conditionID: "discover.platform.unsupported",
                    severity: .critical,
                    decision: .block,
                    message: "Module declares unsupported platform.",
                    path: left.moduleID,
                    evidence: unsupported,
                    remediation: "Remove unsupported platforms from the module manifest."
                ))
            }
        }
        return findings
    }

    private func reconciliationFindings(repositoryRoot: URL, proposedModules: [ProposedModule]) -> [ValidationFinding] {
        let approvedURL = repositoryRoot.appendingPathComponent(".forsetti/modules.json")
        guard fileSystem.fileExists(at: approvedURL),
              let approvedData = try? fileSystem.readFile(at: approvedURL),
              let proposedData = try? modulesInventoryData(modules: proposedModules),
              approvedData != proposedData else {
            return []
        }
        return [
            finding(
                conditionID: "discover.inventory.reconciliation-required",
                severity: .medium,
                decision: .requestChanges,
                message: "Observed inventory differs from approved modules.json.",
                path: ".forsetti/modules.json",
                evidence: [approvedURL.path],
                remediation: "Review the proposed inventory and update approved modules.json explicitly."
            )
        ]
    }

    private func modulesInventoryData(modules: [ProposedModule]) throws -> Data {
        let object: [String: Any] = [
            "schemaVersion": "2.0",
            "modules": modules.map(\.jsonObject)
        ]
        var data = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
        data.append(0x0a)
        return data
    }

    private func resourceRoots(for manifest: ModuleManifest, repositoryRoot: URL) -> [String] {
        let sourceRoot = repositoryRoot.appendingPathComponent(manifest.sourceRoot, isDirectory: true)
        let candidates = [
            sourceRoot.appendingPathComponent("Resources", isDirectory: true),
            sourceRoot.deletingLastPathComponent().appendingPathComponent("Resources", isDirectory: true)
        ]
        return candidates.filter { fileSystem.directoryExists(at: $0) }
            .map { relativePath($0, repositoryRoot: repositoryRoot) }
            .sorted()
    }

    private func sourceRoot(forEntryPoint entryPoint: String?, manifestURL: URL, repositoryRoot: URL) -> String {
        guard let entryPoint, !entryPoint.isEmpty else {
            return relativePath(manifestURL.deletingLastPathComponent(), repositoryRoot: repositoryRoot)
        }
        let entryURL = repositoryRoot.appendingPathComponent(entryPoint)
        let sourceURL = entryPoint.hasSuffix(".swift") || entryPoint.hasSuffix(".cpp") || entryPoint.hasSuffix(".hpp")
            ? entryURL.deletingLastPathComponent()
            : entryURL
        return relativePath(sourceURL, repositoryRoot: repositoryRoot)
    }

    private func findURLs(repositoryRoot: URL, where predicate: (URL) -> Bool) -> [URL] {
        guard let enumerator = manager.enumerator(at: repositoryRoot, includingPropertiesForKeys: nil) else {
            return []
        }
        var urls: [URL] = []
        for case let url as URL in enumerator {
            if url.path.contains("/.git/") || url.path.contains("/.build/") || url.path.contains("/.forsetti/") {
                enumerator.skipDescendants()
                continue
            }
            if predicate(url) {
                urls.append(url)
            }
        }
        return urls
    }

    private func containsFileExtension(repositoryRoot: URL, extensionName: String) -> Bool {
        !findURLs(repositoryRoot: repositoryRoot) { $0.pathExtension == extensionName }.isEmpty
    }

    private func relativePath(_ url: URL, repositoryRoot: URL) -> String {
        let rootPath = repositoryRoot.standardizedFileURL.path
        let path = url.standardizedFileURL.path
        guard path.hasPrefix(rootPath) else {
            return path
        }
        let start = path.index(path.startIndex, offsetBy: rootPath.count)
        return String(path[start...]).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    private func finding(
        conditionID: String,
        severity: FindingSeverity,
        decision: ValidationStatus,
        message: String,
        path: String?,
        evidence: [String],
        remediation: String?
    ) -> ValidationFinding {
        ValidationFinding(
            canonicalRuleID: "FAE-F040",
            conditionID: conditionID,
            severity: severity,
            decision: decision,
            message: message,
            path: path,
            moduleID: nil,
            evidence: evidence,
            remediation: remediation
        )
    }
}

private struct NativeInspectionResult {
    let targets: [DiscoveredTarget]
    let edges: [DependencyEdge]
    let unresolvedItems: [String]
}

private struct DiscoveredTarget {
    let name: String
    let buildSystem: String
    let sourceRoot: String
    let moduleBearing: Bool
}

private struct DependencyEdge {
    let source: String
    let target: String
    let kind: String
}

private struct ModuleManifest {
    let moduleID: String
    let moduleType: String
    let defaultModuleRole: String?
    let manifestTemplateVersion: String
    let manifestPath: String
    let displayName: String?
    let entryPoint: String?
    let sourceRoot: String
    let capabilitiesRequested: [String]
    let runtimeRequirementsDeclared: Bool
    let platforms: [String]
}

private struct ProposedModule {
    let moduleID: String
    let moduleType: String
    let defaultModuleRole: String?
    let manifestPath: String
    let targetName: String
    let buildSystem: String?
    let sourceRoots: [String]
    let resourceRoots: [String]
    let capabilitiesRequested: [String]
    let runtimeRequirementsDeclared: Bool
    let platforms: [String]
    let publicDependencies: [String]

    var jsonObject: [String: Any] {
        var object: [String: Any] = [
            "moduleID": moduleID,
            "moduleType": moduleType,
            "manifestPath": manifestPath,
            "targetName": targetName,
            "sourceRoots": sourceRoots,
            "resourceRoots": resourceRoots,
            "capabilitiesRequested": capabilitiesRequested,
            "runtimeRequirementsDeclared": runtimeRequirementsDeclared,
            "platforms": platforms,
            "publicDependencies": publicDependencies
        ]
        if let defaultModuleRole {
            object["defaultModuleRole"] = defaultModuleRole
        } else {
            object["defaultModuleRole"] = NSNull()
        }
        if let buildSystem {
            object["buildSystem"] = buildSystem
        }
        return object
    }
}
