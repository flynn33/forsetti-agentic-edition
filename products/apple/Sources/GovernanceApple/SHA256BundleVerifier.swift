import CryptoKit
import Foundation
import GovernanceContracts
import GovernanceCore

public final class SHA256BundleVerifier: BundleVerifying {
    private let fileSystem: FileSystem
    private let loader: FoundationJSONLoader
    private let resultFactory: ResultFactory

    public init(fileSystem: FileSystem, resultFactory: ResultFactory) {
        self.fileSystem = fileSystem
        self.loader = FoundationJSONLoader(fileSystem: fileSystem)
        self.resultFactory = resultFactory
    }

    public func verify(bundleRoot: URL) throws -> ValidationResult {
        let manifestURL = bundleRoot.appendingPathComponent("product-manifest.json")
        guard fileSystem.fileExists(at: manifestURL) else {
            return resultFactory.makeResult(
                status: .block,
                mode: "bundle verify",
                findings: [
                    ValidationFinding(
                        canonicalRuleID: "FAE-F020",
                        conditionID: "bundle.manifest.missing",
                        severity: .critical,
                        decision: .block,
                        message: "Product manifest is missing.",
                        path: "product-manifest.json",
                        moduleID: nil,
                        evidence: [manifestURL.path],
                        remediation: "Install or rebuild the product bundle."
                    )
                ]
            )
        }

        let manifestData = try fileSystem.readFile(at: manifestURL)
        let manifest = try loader.loadJSON(ProductManifest.self, from: manifestURL)
        var findings: [ValidationFinding] = []
        var blocked = false
        var seenPaths = Set<String>()

        if manifest.schemaVersion != "2.0" {
            blocked = true
            findings.append(blockingFinding(
                conditionID: "bundle.manifest.unsupported-version",
                message: "Product manifest schema version is unsupported.",
                path: "product-manifest.json",
                evidence: [manifest.schemaVersion]
            ))
        }

        let manifestHash = sha256Hex(manifestData)
        let lockURL = bundleRoot.appendingPathComponent("product-lock.json")
        if fileSystem.fileExists(at: lockURL) {
            let lock = try loader.loadJSON(ProductLock.self, from: lockURL)
            if lock.schemaVersion != "2.0" {
                blocked = true
                findings.append(blockingFinding(
                    conditionID: "bundle.product-lock.unsupported-version",
                    message: "Product lock schema version is unsupported.",
                    path: "product-lock.json",
                    evidence: [lock.schemaVersion]
                ))
            }
            if lock.productVersion != manifest.version || lock.bundleID != manifest.bundleID || lock.platform != manifest.platform || lock.sha256 != manifestHash {
                blocked = true
                findings.append(blockingFinding(
                    conditionID: "bundle.product-lock.mismatch",
                    message: "Product lock does not match the verified manifest.",
                    path: "product-lock.json",
                    evidence: [
                        "lockVersion=\(lock.productVersion)",
                        "manifestVersion=\(manifest.version)",
                        "lockBundleID=\(lock.bundleID)",
                        "manifestBundleID=\(manifest.bundleID)",
                        "lockPlatform=\(lock.platform)",
                        "manifestPlatform=\(manifest.platform)",
                        "lockHash=\(lock.sha256)",
                        "manifestHash=\(manifestHash)"
                    ]
                ))
            }
        }

        for file in manifest.files {
            if isUnsafeManifestPath(file.path) {
                blocked = true
                findings.append(blockingFinding(
                    conditionID: "bundle.path.invalid",
                    message: "Bundle manifest contains an invalid path.",
                    path: file.path,
                    evidence: [file.path]
                ))
                continue
            }
            guard seenPaths.insert(file.path).inserted else {
                blocked = true
                findings.append(blockingFinding(
                    conditionID: "bundle.path.duplicate",
                    message: "Bundle manifest contains a duplicate path.",
                    path: file.path,
                    evidence: [file.path]
                ))
                continue
            }
            let fileURL = bundleRoot.appendingPathComponent(file.path)
            guard fileSystem.fileExists(at: fileURL) else {
                if file.required {
                    blocked = true
                    findings.append(blockingFinding(
                        conditionID: "bundle.file.missing",
                        message: "Required bundle file is missing.",
                        path: file.path,
                        evidence: [fileURL.path]
                    ))
                }
                continue
            }
            let actual = sha256Hex(try fileSystem.readFile(at: fileURL))
            if actual != file.sha256 {
                blocked = true
                findings.append(blockingFinding(
                    conditionID: "bundle.file.hash-mismatch",
                    message: "Bundle file hash does not match manifest.",
                    path: file.path,
                    evidence: ["expected=\(file.sha256)", "actual=\(actual)"]
                ))
            }
        }

        if findings.isEmpty {
            findings.append(
                ValidationFinding(
                    canonicalRuleID: "FAE-F020",
                    conditionID: "bundle.verified",
                    severity: .info,
                    decision: .pass,
                    message: "Product bundle verified.",
                    path: nil,
                    moduleID: nil,
                    evidence: [manifest.bundleID],
                    remediation: nil
                )
            )
        }

        return resultFactory.makeResult(
            status: blocked ? .block : .pass,
            mode: "bundle verify",
            findings: findings
        )
    }

    private func blockingFinding(
        conditionID: String,
        message: String,
        path: String,
        evidence: [String]
    ) -> ValidationFinding {
        ValidationFinding(
            canonicalRuleID: "FAE-F020",
            conditionID: conditionID,
            severity: .critical,
            decision: .block,
            message: message,
            path: path,
            moduleID: nil,
            evidence: evidence,
            remediation: "Restore the verified product bundle."
        )
    }

    private func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private func isUnsafeManifestPath(_ path: String) -> Bool {
        if path.isEmpty || path.hasPrefix("/") || path.contains("\\") {
            return true
        }
        return path.split(separator: "/").contains("..") || path.split(separator: "/").contains(".")
    }
}
