import Foundation
import Paystack

public struct TransactionTimeline: Decodable {
    public var timeSpent: Int?
    public var attempts: Int?
    // public var authentication: Unknown
    public var errors: Int?
    public var success: Bool?
    public var mobile: Bool?
    // public var input: [Unknown]
    public var channel: Channel?
    public var history: [TransactionHistoryItem]?
}
