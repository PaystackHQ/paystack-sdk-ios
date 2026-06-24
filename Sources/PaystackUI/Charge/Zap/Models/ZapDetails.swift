import Foundation
import PaystackCore

struct ZapDetails: Equatable {
    let qrImageURL: URL
    let paymentURL: URL
    let pusherChannel: String
    let expiresAt: Date
}

extension ZapDetails {

    static func from(_ response: ZapMandateResponse,
                     mandateWindowSeconds: Int) -> ZapDetails? {
        guard let qr = URL(string: response.qrImage),
              let payment = URL(string: response.paymentUrl) else {
            return nil
        }
        return ZapDetails(
            qrImageURL: qr,
            paymentURL: payment,
            pusherChannel: response.pusherChannel,
            expiresAt: Date().addingTimeInterval(TimeInterval(mandateWindowSeconds)))
    }
}

extension ZapDetails {
    static var example: ZapDetails {
        ZapDetails(
            qrImageURL: URL(string: "https://example.com/qr.png")!,
            paymentURL: URL(string: "https://joinzap.com/app/merchant-payment/test")!,
            pusherChannel: "DBMAN_6222375579",
            expiresAt: Date().addingTimeInterval(5 * 60))
    }
}
