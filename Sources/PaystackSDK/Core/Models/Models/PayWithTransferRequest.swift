import Foundation

public struct PayWithTransferRequest: Codable, Equatable {
    public let fulfilLateNotification: Bool
    public let transactionId: Int
    public let preferredProvider: String?

    public init(fulfilLateNotification: Bool,
                transactionId: Int,
                preferredProvider: String? = nil) {
        self.fulfilLateNotification = fulfilLateNotification
        self.transactionId = transactionId
        self.preferredProvider = preferredProvider
    }
}
