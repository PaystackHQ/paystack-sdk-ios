import Foundation
import PaystackCore

struct MobileMoneyTransaction: Equatable {
    let transaction: String
    let phone: String
    let provider: String
    let channelName: String
    let timer: Int
    let message: String
}

extension MobileMoneyTransaction {

    static func from(_ response: MobileMoneyChargeResponse) -> Self {
        MobileMoneyTransaction(transaction: response.data.transaction,
                               phone: response.data.phone,
                               provider: response.data.provider,
                               channelName: response.data.channelName,
                               timer: response.data.display.timer,
                               message: response.data.display.message)
    }

}
