import Foundation

public struct MobileMoneyData: Equatable {
    let phone: String
    let transaction: String
    let provider: String

    public init(phone: String, transaction: String, provider: String) {
        self.phone = phone
        self.transaction = transaction
        self.provider = provider
    }
}
