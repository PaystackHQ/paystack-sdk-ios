import Foundation
import Paystack

public struct Transaction: Decodable {
    public var id: Int
    public var amount: Int
    public var currency: Currency
    public var transactionDate: Date?
    public var status: TransactionStatus
    public var reference: String
    public var domain: Domain
    public var metadata: Metadata?
    public var gatewayResponse: String
    public var message: String?
    public var channel: Channel
    public var ipAddress: String?
    public var log: TransactionTimeline?
    public var fees: TransactionFees?
    public var authorization: Authorization?
    public var customer: Customer?
    public var plan: OptionalStringObject?
    public var requestedAmount: Int?
}
