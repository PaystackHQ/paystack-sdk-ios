import Foundation

public struct ZapMandateResponse: Decodable, Equatable {
    public let status: String
    public let message: String
    public let pusherChannel: String
    public let paymentUrl: String
    public let qrImage: String

    public init(status: String,
                message: String,
                pusherChannel: String,
                paymentUrl: String,
                qrImage: String) {
        self.status = status
        self.message = message
        self.pusherChannel = pusherChannel
        self.paymentUrl = paymentUrl
        self.qrImage = qrImage
    }
}
