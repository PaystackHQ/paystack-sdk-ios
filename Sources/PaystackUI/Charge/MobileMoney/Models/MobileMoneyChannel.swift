import Foundation
import PaystackCore

struct MobileMoneyChannel: Equatable {
    let key: String
    let value: String
    let isNew: Bool
    let phoneNumberRegex: String
}

extension MobileMoneyChannel {

    static func from(_ response: MobileMoney) -> Self {
        return MobileMoneyChannel(key: response.key, value: response.value, isNew: response.isNew, phoneNumberRegex: response.phoneNumberRegex)
    }
}

extension MobileMoneyChannel {
    static var example: Self {
        .init(key: "MPESA", value: "M-PESA", isNew: true, phoneNumberRegex: "^\\+254(7([0-2]\\d|4\\d|5(7|8|9)|6(8|9)|9[0-9])|(11\\d))\\d{6}$")
    }
}
