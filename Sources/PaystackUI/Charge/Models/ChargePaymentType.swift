import Foundation

// TODO: Add an extension to map from payment channels once those are defined
enum ChargePaymentType: Equatable {
    case card(transactionInformation: VerifyAccessCode)
}
