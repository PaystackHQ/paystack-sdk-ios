import Foundation

enum QRVariant: String, Equatable {
    case scanToPay
    case snapScan

    var displayTitle: String {
        switch self {
        case .scanToPay:
            return "Scan to Pay"
        case .snapScan:
            return "SnapScan"
        }
    }

    var logoAsset: String {
        switch self {
        case .scanToPay:
            return "scanToPayLogo"
        case .snapScan:
            return "snapScanLogo"
        }
    }

    var instructionCopy: String {
        switch self {
        case .scanToPay:
            return "Open any Scan to Pay app on your phone to scan the QR code"
        case .snapScan:
            return "Scan the QR code below in your SnapScan mobile app to complete the payment"
        }
    }

    var showsQRReferenceRow: Bool {
        switch self {
        case .scanToPay:
            return true
        case .snapScan:
            return false
        }
    }
}
