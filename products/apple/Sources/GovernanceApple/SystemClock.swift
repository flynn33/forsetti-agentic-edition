import Foundation
import GovernanceContracts

public final class SystemClock: Clock {
    public init() {}

    public func now() -> Date {
        Date()
    }
}
