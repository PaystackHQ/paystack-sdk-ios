import Foundation

public struct ChannelOptions: Codable {

    public var bankTransfer: [String]?
    public var ussd: [String]?
    public var qrCode: [String]?
    public var mobileMoney: [MobileMoney]?

    public init(bankTransfer: [String]? = nil, ussd: [String]? = nil, qrCode: [String]? = nil, mobileMoney: [MobileMoney]? = nil) {
        self.bankTransfer = bankTransfer
        self.ussd = ussd
        self.qrCode = qrCode
        self.mobileMoney = mobileMoney
    }

    enum CodingKeys: String, CodingKey {
        case ussd
        case qrCode = "qr"
        case bankTransfer = "bank_transfer"
        case mobileMoney
    }
}
