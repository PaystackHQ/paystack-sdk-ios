import Foundation

struct QRConfig: Equatable {
    let channelOption: String
    let transactionId: Int
    let variant: QRVariant
}

extension QRConfig {
    static let scanToPayExample = QRConfig(
        channelOption: "MPASS_OLTI",
        transactionId: 5900549926,
        variant: .scanToPay)

    static let snapScanExample = QRConfig(
        channelOption: "MPASS_OLTI",
        transactionId: 5900549926,
        variant: .snapScan)
}
