import Foundation
import PaystackCore

struct ChannelOptions: Equatable {
    var mobileMoney: [MobileMoneyChannel]?
    var bankTransfer: [String]?
    var qrCode: [String]?
}

extension ChannelOptions {

    static func from(_ response: PaystackCore.ChannelOptions) -> Self {
        return ChannelOptions(
            mobileMoney: response.mobileMoney?.map({ MobileMoneyChannel.from($0) }),
            bankTransfer: response.bankTransfer,
            qrCode: response.qrCode)
    }
}

extension ChannelOptions {
    static var example: Self {
        .init(mobileMoney: [.example])
    }
}
