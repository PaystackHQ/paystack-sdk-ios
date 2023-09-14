import Foundation

public struct ChargeResponseData: Codable {
    public var status: TransactionStatus
    public var amount: Double
    public var currency: String
    public var transactionDate: String?
    public var reference: String?
    public var domain: Domain
    public var redirectUrl: String?
    public var url: String?
    public var ussdCode: String?
    public var qrCode: String?
    public var displayText: String?
    // TODO: Update this field once the responses are aligned with the contracts
    public var metadata: String?
    public var gatewayResponse: String?
    public var message: String?
    public var channel: String?
    public var fees: Double?
    public var authorization: Authorization?
    public var customer: Customer?
}
