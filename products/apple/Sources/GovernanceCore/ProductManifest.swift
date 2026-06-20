import Foundation

public struct ProductManifest: Codable, Equatable {
    public let schemaVersion: String
    public let product: String
    public let version: String
    public let bundleID: String
    public let platform: String
    public let architecture: String
    public let entryPoint: String?
    public let policyBundleHash: String?
    public let files: [ProductManifestFile]
    public let createdAtUTC: Date
}

public struct ProductManifestFile: Codable, Equatable {
    public let path: String
    public let sha256: String
    public let required: Bool
    public let executable: Bool?
}

public struct ProductLock: Codable, Equatable {
    public let schemaVersion: String
    public let lockedAtUTC: Date
    public let sha256: String
    public let productVersion: String
    public let bundleID: String
    public let platform: String
}
