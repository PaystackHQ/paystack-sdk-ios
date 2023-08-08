import Foundation

enum ChargeCardState {
    case cardDetails(amount: AmountCurrency)
    case testModeCardSelection(amount: AmountCurrency)
    case pin
    case phoneNumber
    case otp(phoneNumber: String)
    case address(states: [String])
    case birthday
    case error(ChargeCardError)
}
