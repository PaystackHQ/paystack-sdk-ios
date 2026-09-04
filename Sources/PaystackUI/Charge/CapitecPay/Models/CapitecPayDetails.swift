import Foundation
import PaystackCore

struct CapitecPayDetails: Equatable {
    let timeToLive: Int
    let expiryDate: Date
    let pusherChannel: String
}

extension CapitecPayDetails {
    static func from(_ response: CapitecPayAuthenticateResponse,
                     transactionId: Int) -> CapitecPayDetails {
        CapitecPayDetails(
            timeToLive: response.data.timeToLive,
            expiryDate: response.data.expiryDate,
            pusherChannel: "CAPITECPAY_\(transactionId)")
    }
}

extension CapitecPayDetails {
    static var example: CapitecPayDetails {
        CapitecPayDetails(
            timeToLive: 120,
            expiryDate: Date().addingTimeInterval(120),
            pusherChannel: "CAPITECPAY_5900549926")
    }
}
