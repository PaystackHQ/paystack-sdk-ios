import Foundation

public struct MobileMoneyData: Equatable {
    let channelName: String
    let amount: Int
    let email: String
    let phone: String
    let transaction: String
    let provider: String

    public init(channelName: String, amount: Int, email: String, phone: String, transaction: String, provider: String) {
        self.channelName = channelName
        self.amount = amount
        self.email = email
        self.phone = phone
        self.transaction = transaction
        self.provider = provider
    }
}
