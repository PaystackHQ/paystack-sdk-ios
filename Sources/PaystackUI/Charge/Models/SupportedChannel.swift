import SwiftUI
import PaystackCore

/// A resolved payment channel that the SDK is willing to route to for the
/// current transaction. One entry per card option, plus one entry per
/// supported mobile money provider returned by `verifyAccessCode`.
enum SupportedChannel: Equatable, Identifiable {
    case card
    case mobileMoney(MobileMoneyChannel)

    var id: String {
        switch self {
        case .card:
            return "card"
        case .mobileMoney(let channel):
            return "mobile_money.\(channel.key)"
        }
    }

    var displayTitle: String {
        switch self {
        case .card:
            return "Card"
        case .mobileMoney(let channel):
            return channel.value
        }
    }

    var image: Image {
        switch self {
        case .card:
            return Image("cardLogo", bundle: .current)
        case .mobileMoney(let channel):
            return Self.image(forMobileMoneyKey: channel.key)
        }
    }

    /// Maps known Paystack mobile money provider keys to a bundled logo.
    /// Falls back to a generic SF Symbol when the SDK has no logo for the
    /// provider yet — keeps the channel-selection screen renderable when a
    /// future provider lights up via the allowlist.
    private static func image(forMobileMoneyKey key: String) -> Image {
        switch key.uppercased() {
        case "MPESA", "ATL_KE":
            return Image("kenyaSHLogo", bundle: .current)
        case "MTN", "ATL", "VOD":
            return Image("kenyaSHLogo", bundle: .current)
        default:
            return Image(systemName: "creditcard")
        }
    }
}
