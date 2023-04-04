import Foundation

public struct Authorization: Codable {
    var authorizationCode, bin, last4, expMonth: String?
    var expYear, channel, cardType, bank: String?
    var countryCode, brand: String?
    var reusable: Bool?
    var signature, accountName: String?

    enum CodingKeys: String, CodingKey {
        case authorizationCode = "authorization_code"
        case bin, last4
        case expMonth = "exp_month"
        case expYear = "exp_year"
        case channel
        case cardType = "card_type"
        case bank
        case countryCode = "country_code"
        case brand, reusable, signature
        case accountName = "account_name"
    }
}
