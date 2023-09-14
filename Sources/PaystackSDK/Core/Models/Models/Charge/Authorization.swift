import Foundation

// TODO: Update this model once the responses are aligned with the contracts
public struct Authorization: Codable {
    public var authorizationCode, bin, last4: String?
    public var expMonth, expYear, reusable: Int?
    public var channel, cardType, bank: String?
    public var countryCode, brand: String?
    public var signature, accountName: String?
}
