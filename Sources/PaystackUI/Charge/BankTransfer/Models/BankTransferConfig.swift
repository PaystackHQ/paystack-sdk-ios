import Foundation

struct BankTransferConfig: Equatable {
    let fulfilLateNotification: Bool

    let transactionId: Int

    let availableProviders: [String]
    
    let provider: BankTransferProvider

    init(fulfilLateNotification: Bool,
         transactionId: Int,
         availableProviders: [String],
         provider: BankTransferProvider = .standard) {
        self.fulfilLateNotification = fulfilLateNotification
        self.transactionId = transactionId
        self.availableProviders = availableProviders
        self.provider = provider
    }
}
