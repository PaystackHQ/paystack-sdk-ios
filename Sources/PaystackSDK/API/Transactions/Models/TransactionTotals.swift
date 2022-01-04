import Foundation
import Paystack

public struct TransactionTotals: Decodable {
    public var totalTransactions: Int
    public var uniqueCustomers: Int?
    public var totalVolume: Int
    public var totalVolumeByCurrency: [Amount]
    public var pendingTransfers: Int
    public var pendingTransfersByCurrency: [Amount]
}
