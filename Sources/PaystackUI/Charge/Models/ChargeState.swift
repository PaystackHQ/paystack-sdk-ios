import Foundation

// TODO: Add state for select payment channel
enum ChargeState {
    case loading(message: String? = nil)
    case payment(type: ChargePaymentType)
    case error(ChargeError)
    case success(amount: AmountCurrency, merchant: String,
                 details: ChargeCompletionDetails)
}
