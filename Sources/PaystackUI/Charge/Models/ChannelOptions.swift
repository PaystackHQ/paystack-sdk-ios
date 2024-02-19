import Foundation
import PaystackCore

struct ChannelOptions: Equatable {
    var mobileMoney: [MobileMoneyChannel]?
}

extension ChannelOptions {

    static func from(_ response: PaystackCore.ChannelOptions) -> Self {
        return ChannelOptions(mobileMoney: response.mobileMoney?.map({
            MobileMoneyChannel.from($0)
        }))
    }
}

extension ChannelOptions {
    static var example: Self {
        .init(mobileMoney: [.example])
    }
}
