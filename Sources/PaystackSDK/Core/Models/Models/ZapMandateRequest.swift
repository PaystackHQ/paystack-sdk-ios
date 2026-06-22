import Foundation

public struct ZapMandateRequest: Equatable {
    
    public let id: Int

    public let transactionId: Int

    public let walletId: String

    public init(id: Int, transactionId: Int, walletId: String) {
        self.id = id
        self.transactionId = transactionId
        self.walletId = walletId
    }
}
