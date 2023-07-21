import Foundation

enum ChargeCardState {
    case cardDetails(amount: AmountCurrency)
    case pin
    case phoneNumber
}
