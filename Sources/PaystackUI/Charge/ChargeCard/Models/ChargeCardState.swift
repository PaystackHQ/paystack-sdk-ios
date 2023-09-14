import Foundation

enum ChargeCardState {
    case loading(message: String? = nil)
    case cardDetails(amount: AmountCurrency, encryptionKey: String)
    case testModeCardSelection(amount: AmountCurrency, encryptionKey: String)
    case pin(encryptionKey: String)
    case phoneNumber(displayMessage: String?)
    case otp(displayMessage: String?)
    case address(states: [String], displayMessage: String?)
    case birthday(displayMessage: String?)
    case error(ChargeError)
    case fatalError(error: ChargeError)
    case failed(displayMessage: String?)
    case redirect(urlString: String, transactionId: Int)
}
