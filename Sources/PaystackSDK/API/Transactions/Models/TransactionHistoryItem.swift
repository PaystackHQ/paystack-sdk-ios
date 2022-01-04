import Foundation

public struct TransactionHistoryItem: Decodable {
    public var type: String
    public var message: String
    public var time: Int
}
