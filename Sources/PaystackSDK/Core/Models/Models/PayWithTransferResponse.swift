import Foundation

public struct PayWithTransferResponse: Codable, Equatable {
    public let status: Bool
    public let message: String
    public let data: PayWithTransferData
}

public struct PayWithTransferData: Codable, Equatable {
    public let accountName: String
    public let accountNumber: String
    public let transactionReference: String
    public let bank: TransferBank
    public let accountExpiresAt: Date
    public let assignmentExpiresAt: Date
    public let transactionId: String
    public let pusherChannel: String
}

public struct TransferBank: Codable, Equatable {
    public let slug: String
    public let name: String
    public let id: Int
}
