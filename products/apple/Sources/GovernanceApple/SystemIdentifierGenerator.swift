import Foundation
import GovernanceContracts

public final class SystemIdentifierGenerator: IdentifierGenerating {
    public init() {}

    public func newIdentifier() -> String {
        UUID().uuidString.lowercased()
    }
}
