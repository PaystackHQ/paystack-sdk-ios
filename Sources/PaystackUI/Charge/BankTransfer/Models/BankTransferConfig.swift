import Foundation

struct BankTransferConfig: Equatable {
    let fulfilLateNotification: Bool

    let transactionId: Int

    let availableProviders: [String]
}
