import Foundation

public struct VerifyAccessCodeData: Decodable {
    public var email: String
    public var amount: Double
    public var reference: String
    public var accessCode: String
    public var merchantLogo: String?
    public var merchantName: String
    public var domain: Domain
    public var currency: String
    public var channels: [String]
    public var channelOptions: ChannelOptions

    public init(email: String, amount: Double, reference: String, accessCode: String,
                merchantLogo: String? = nil, merchantName: String, domain: Domain,
                currency: String, channels: [String], channelOptions: ChannelOptions) {
        self.email = email
        self.amount = amount
        self.reference = reference
        self.accessCode = accessCode
        self.merchantLogo = merchantLogo
        self.merchantName = merchantName
        self.domain = domain
        self.currency = currency
        self.channels = channels
        self.channelOptions = channelOptions
    }

    enum CodingKeys: String, CodingKey {
        case email, amount, reference, domain,
             currency, channels
        case accessCode = "access_code"
        case merchantLogo = "merchant_logo"
        case merchantName = "merchant_name"
        case channelOptions = "channel_options"
    }
}
