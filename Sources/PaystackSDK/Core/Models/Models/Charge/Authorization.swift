import Foundation

public struct Authorization: Codable {
    public var authorizationCode, bin, last4, expMonth: String
    public var expYear, channel, cardType, bank: String
    public var countryCode, brand: String
    public var reusable: Bool
    public var signature, accountName: String
}
