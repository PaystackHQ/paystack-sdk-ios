import Foundation

public struct VerifyAccessCodeData: Decodable {
    public var id: Int?
    public var email: String
    public var amount: Decimal
    public var reference: String
    public var accessCode: String
    public var merchantLogo: String?
    public var merchantName: String
    public var domain: Domain
    public var currency: String
    public var channels: [Channel]
    public var channelOptions: ChannelOptions
    public var publicEncryptionKey: String

    public init(id: Int?, email: String, amount: Decimal, reference: String, accessCode: String,
                merchantLogo: String? = nil, merchantName: String, domain: Domain,
                currency: String, channels: [Channel], channelOptions: ChannelOptions,
                publicEncryptionKey: String) {
        self.id = id
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
        self.publicEncryptionKey = publicEncryptionKey
    }
}
