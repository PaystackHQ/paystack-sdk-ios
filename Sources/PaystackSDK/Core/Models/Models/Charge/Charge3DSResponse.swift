import Foundation

public struct Charge3DSResponse: Decodable {
    public var redirectUrl: String?
    public var transaction: String?
    public var transactionReference: String?
    public var reference: String?
    public var status: Charge3DSResponseStatus
    public var message: String?
    public var response: String?

    enum CodingKeys: String, CodingKey {
        case redirectUrl, reference, status, message, response
        case transaction = "trans"
        case transactionReference = "trxref"
    }
}
