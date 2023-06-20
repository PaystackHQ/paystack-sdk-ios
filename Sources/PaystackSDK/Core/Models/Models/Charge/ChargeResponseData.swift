import Foundation

public struct ChargeResponseData: Codable {
    public var status: TransactionStatus
    public var amount: Double
    public var currency: String
    public var transactionDate: String
    public var reference: String
    public var domain: Domain
    public var redirectUrl: String?
    public var metadata: [String: String]?
    public var gatewayResponse: String?
    public var message: String?
    public var channel: String
    public var fees: Double
    public var authorization: Authorization?
    public var customer: Customer?
}
