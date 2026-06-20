import Foundation
import GovernanceContracts

public final class LocalFileSystem: FileSystem {
    private let manager: FileManager

    public init(manager: FileManager = .default) {
        self.manager = manager
    }

    public func fileExists(at url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return manager.fileExists(atPath: url.path, isDirectory: &isDirectory) && !isDirectory.boolValue
    }

    public func directoryExists(at url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return manager.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }

    public func readFile(at url: URL) throws -> Data {
        try Data(contentsOf: url)
    }

    public func writeFileAtomically(_ data: Data, to url: URL) throws {
        let directory = url.deletingLastPathComponent()
        let temporaryURL = directory.appendingPathComponent(".\(url.lastPathComponent).tmp-\(UUID().uuidString)")
        try data.write(to: temporaryURL, options: .atomic)
        if fileExists(at: url) {
            _ = try manager.replaceItemAt(url, withItemAt: temporaryURL)
        } else {
            try manager.moveItem(at: temporaryURL, to: url)
        }
    }

    public func currentDirectory() -> URL {
        URL(fileURLWithPath: manager.currentDirectoryPath, isDirectory: true)
    }
}
