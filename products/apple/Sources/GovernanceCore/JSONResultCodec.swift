import Foundation
import GovernanceContracts

public final class JSONResultCodec {
    private let encoder: JSONEncoder

    public init() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder = encoder
    }

    public func encode(_ result: ValidationResult) throws -> Data {
        try encoder.encode(result)
    }

    public func encodeString(_ result: ValidationResult) throws -> String {
        String(decoding: try encode(result), as: UTF8.self)
    }
}
