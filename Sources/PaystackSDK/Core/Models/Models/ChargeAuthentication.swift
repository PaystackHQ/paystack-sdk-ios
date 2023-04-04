import Foundation

public struct ChargeAuthentication: Codable {
    var id: Int?
    var domain, status, reference: String?
    var amount: Int?
    var message, gatewayResponse, dataPaidAt, dataCreatedAt: String?
    var channel, currency, ipAddress, metadata: String?
    var log: String?
    var fees: Int?
    var feesSplit: String?
    var authorization: Authorization?
    var customer: Customer?
    var plan, split, orderID, paidAt: String?
    var createdAt: String?
    var requestedAmount: Int?
    var posTransactionData, source, feesBreakdown, transactionDate: String?
    var planObject, subaccount: String?

    enum CodingKeys: String, CodingKey {
        case id, domain, status, reference, amount, message
        case gatewayResponse = "gateway_response"
        case dataPaidAt = "paid_at"
        case dataCreatedAt = "created_at"
        case channel, currency
        case ipAddress = "ip_address"
        case metadata, log, fees
        case feesSplit = "fees_split"
        case authorization, customer, plan, split
        case orderID = "order_id"
        case paidAt, createdAt
        case requestedAmount = "requested_amount"
        case posTransactionData = "pos_transaction_data"
        case source
        case feesBreakdown = "fees_breakdown"
        case transactionDate = "transaction_date"
        case planObject = "plan_object"
        case subaccount
    }
}
