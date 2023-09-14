import Foundation

public struct Authorization: Codable {
    public var authorizationCode, bin, last4: String?
    public var expMonth, expYear, reusable: String?
    public var channel, cardType, bank: String?
    public var countryCode, brand: String?
    public var signature, accountName: String?
}
