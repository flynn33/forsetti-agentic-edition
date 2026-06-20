import Foundation
import GovernanceContracts

public final class FoundationJSONLoader: ConfigurationLoading {
    private let decoder: JSONDecoder
    private let fileSystem: FileSystem

    public init(fileSystem: FileSystem) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
        self.fileSystem = fileSystem
    }

    public func loadJSON<T: Decodable>(_ type: T.Type, from url: URL) throws -> T {
        try decoder.decode(T.self, from: fileSystem.readFile(at: url))
    }
}
