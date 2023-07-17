import Foundation

// TODO: Add state for select payment channel and payment failure
enum ChargeState {
    case loading(message: String? = nil)
    case payment(type: ChargePaymentType)
    case error(Error)
    case success(amount: AmountCurrency, merchant: String)
}
