import Foundation

enum ChargeCardState {
    case cardDetails(amount: AmountCurrency, encryptionKey: String)
    case testModeCardSelection(amount: AmountCurrency, encryptionKey: String)
    case pin(encryptionKey: String)
    case phoneNumber(displayMessage: String?)
    case otp(displayMessage: String?)
    case address(states: [String], displayMessage: String?)
    case birthday(displayMessage: String?)
    case error(ChargeError)
    case failed
}
