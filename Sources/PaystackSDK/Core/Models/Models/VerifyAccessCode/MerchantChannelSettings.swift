import Foundation

public struct MerchantChannelSettings: Codable, Equatable {
    public var bankTransfer: BankTransferMerchantSettings?

    public init(bankTransfer: BankTransferMerchantSettings? = nil) {
        self.bankTransfer = bankTransfer
    }
}

public struct BankTransferMerchantSettings: Codable, Equatable {
    public var fulfilLateNotification: Bool?

    public init(fulfilLateNotification: Bool? = nil) {
        self.fulfilLateNotification = fulfilLateNotification
    }
}
