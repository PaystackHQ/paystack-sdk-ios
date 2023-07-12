import Foundation

// TODO: Add more states here as we need them
enum ChargeState {
    case loading(message: String? = nil)
    case cardDetails(amount: AmountCurrency)
    case error(Error)
    case success(amount: AmountCurrency, merchant: String)
}
