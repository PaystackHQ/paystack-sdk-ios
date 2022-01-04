import Foundation
import Paystack

public struct Authorization: Decodable {
    public var authorizationCode: String?
    public var cardType: CardType?
    public var last4: String?
    public var expMonth: String?
    public var expYear: String?
    public var bin: String?
    public var bank: String?
    public var channel: Channel?
    public var signature: String?
    public var reusable: Bool?
    public var countryCode: String?
    public var accountName: String?
}
