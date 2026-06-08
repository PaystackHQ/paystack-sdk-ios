import Foundation
import PaystackCore
// TODO: Add state for select payment channel
enum ChargeState {
    case loading(message: String? = nil)
    case payment(type: ChargePaymentType)
    case channelSelection (transactionInformation: VerifyAccessCode, supportedChannels: [SupportedChannel])
    case error(ChargeError)
    case success(amount: AmountCurrency, merchant: String,
                 details: ChargeCompletionDetails)
}
