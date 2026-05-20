import Foundation
import SwiftUI
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

// MARK: - Provider-aware UI helpers

extension MobileMoneyChannel {

    var expectedCountryCode: String {
        switch key.uppercased() {
        case "MPESA", "ATL_KE":
            return "254"
        case "MTN", "ATL", "VOD":   // Ghana
            return "233"
        case "WAVE_CI", "ORANGE_CI", "MTN_CI":  // Côte d'Ivoire
            return "225"
        default:
            return ""
        }
    }

    var phoneInputAccessory: AnyView? {
        switch key.uppercased() {
        case "MPESA", "ATL_KE":
            return AnyView(Image.kenyaFlagLogo)
        case "MTN", "ATL", "VOD":
            return AnyView(Image.ghanaFlagLogo)
        default:
            return nil
        }
    }
}
