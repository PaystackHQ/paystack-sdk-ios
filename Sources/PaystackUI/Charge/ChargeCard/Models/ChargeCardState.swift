import Foundation

enum ChargeCardState {
    case cardDetails(amount: AmountCurrency, encryptionKey: String)
    case testModeCardSelection(amount: AmountCurrency, encryptionKey: String)
    case pin
    case phoneNumber
    case otp(phoneNumber: String)
    case address(states: [String])
    case birthday
    case error(ChargeError)
}
