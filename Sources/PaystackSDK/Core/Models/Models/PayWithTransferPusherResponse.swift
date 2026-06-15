import Foundation

public struct PayWithTransferPusherResponse: Codable, Equatable {
    public let status: String
    public let message: String
    public let data: PayWithTransferEventData?
    public let errors: [String]?
}

public struct PayWithTransferEventData: Codable, Equatable {
    public let messageType: String?
    public let transactionId: String?
    public let referenceId: String?
    public let reference: String?
    public let trxref: String?
    public let trans: String?
    public let response: String?
    public let redirecturl: String?
}
