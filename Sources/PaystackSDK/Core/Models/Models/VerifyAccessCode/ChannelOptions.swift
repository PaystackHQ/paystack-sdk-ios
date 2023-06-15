import Foundation

public struct ChannelOptions: Codable {

    public var bankTransfer: [String]?
    public var ussd: [String]?
    public var qr: [String]?

    public init(bankTransfer: [String]? = nil, ussd: [String]? = nil, qr: [String]? = nil) {
        self.bankTransfer = bankTransfer
        self.ussd = ussd
        self.qr = qr
    }

    enum CodingKeys: String, CodingKey {
        case ussd, qr
        case bankTransfer = "bank_transfer"
    }
}
