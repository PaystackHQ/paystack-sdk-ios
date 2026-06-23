import SwiftUI
import PaystackCore

enum SupportedChannel: Equatable, Identifiable {
    case card
    case mobileMoney(MobileMoneyChannel)
    case bankTransfer(BankTransferConfig)
    case zap(ZapConfig)

    var id: String {
        switch self {
        case .card:
            return "card"
        case .mobileMoney(let channel):
            return "mobile_money.\(channel.key)"
        case .bankTransfer:
            return "bank_transfer"
        case .zap:
            return "zap"
        }
    }

    var displayTitle: String {
        switch self {
        case .card:
            return "Card"
        case .mobileMoney(let channel):
            return channel.value
        case .bankTransfer:
            return "Transfer"
        case .zap:
            return "Zap"
        }
    }

    var image: Image {
        switch self {
        case .card:
            return Image("cardLogo", bundle: .current)
        case .mobileMoney(let channel):
            return Self.image(forMobileMoneyKey: channel.key)
        case .bankTransfer:
            return Image(systemName: "building.columns")
        case .zap:
            return Image("zapSingleLogo", bundle: .current)
        }
    }

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
