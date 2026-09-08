import SwiftUI
import PaystackCore

enum SupportedChannel: Equatable, Identifiable {
    case card
    case mobileMoney(MobileMoneyChannel)
    case bankTransfer(BankTransferConfig)
    case zap(ZapConfig)
    case capitecPay(CapitecPayConfig)
    case scanToPay(QRConfig)
    case snapScan(QRConfig)

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
        case .capitecPay:
            return "capitec_pay"
        case .scanToPay:
            return "scan_to_pay"
        case .snapScan:
            return "snap_scan"
        }
    }

    var displayTitle: String {
        switch self {
        case .card:
            return "Card"
        case .mobileMoney(let channel):
            return channel.value
        case .bankTransfer(let config):
            return config.provider == .pesalink ? "Pesalink" : "Bank Transfer"
        case .zap:
            return "Zap"
        case .capitecPay:
            return "Capitec Pay"
        case .scanToPay:
            return QRVariant.scanToPay.displayTitle
        case .snapScan:
            return QRVariant.snapScan.displayTitle
        }
    }

    var image: Image {
        switch self {
        case .card:
            return Image("cardLogo", bundle: .current)
        case .mobileMoney(let channel):
            return Self.image(forMobileMoneyKey: channel.key)
        case .bankTransfer(let config):
            return config.provider == .pesalink
                ? Image("pesalinkLogo", bundle: .current)
                : Image("bankTransferLogo", bundle: .current)
        case .zap:
            return Image("zapSingleLogo", bundle: .current)
        case .capitecPay:
            return Image("capitecPayLogo", bundle: .current)
        case .scanToPay:
            return Image(QRVariant.scanToPay.logoAsset, bundle: .current)
        case .snapScan:
            return Image(QRVariant.snapScan.logoAsset, bundle: .current)
        }
    }

    private static func image(forMobileMoneyKey key: String) -> Image {
        switch key.uppercased() {
        case "MPESA":
            return Image("mpesaLogo", bundle: .current)
        case "ATL_KE", "ATL":
            return Image("atlLogo", bundle: .current)
        case "MTN":
            return Image("mtnLogo", bundle: .current)
            case "VOD":
            return Image("vodLogo", bundle: .current)
        default:
            return Image(systemName: "kenyaSHLogo")
        }
    }
}
