import Foundation
import PaystackCore

struct QRDetails: Equatable {
    let qrImageURL: URL
    let qrReference: String?
    let pusherChannel: String
}

extension QRDetails {

    static func from(_ response: QRGenerateResponse,
                     variant: QRVariant) -> QRDetails? {
        guard let url = URL(string: response.data.url) else { return nil }
        return QRDetails(
            qrImageURL: url,
            qrReference: variant.showsQRReferenceRow ? response.data.qrCode : nil,
            pusherChannel: response.data.channel)
    }
}

extension QRDetails {

    static var scanToPayExample: QRDetails {
        QRDetails(
            qrImageURL: URL(string: "https://example.paystack.co/qr.png")!,
            qrReference: "1490884538",
            pusherChannel: "api_mpass_olti_qr_51826223921246")
    }

    static var snapScanExample: QRDetails {
        QRDetails(
            qrImageURL: URL(string: "https://example.paystack.co/qr.png")!,
            qrReference: nil,
            pusherChannel: "api_mpass_olti_qr_51826223921246")
    }
}
