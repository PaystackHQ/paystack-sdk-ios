import Foundation

public enum Channel: String, Codable {
    case bank
    case bankTransfer = "bank_transfer"
    case card
    case mobileMoney = "mobile_money"
    case qr
    case ussd
}
