import Foundation
import PaystackCore

struct ZapConfig: Equatable {
    let supportedBankId: Int
    let transactionId: Int
    let walletEmail: String
}
