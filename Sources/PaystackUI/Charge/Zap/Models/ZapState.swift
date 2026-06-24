import Foundation

enum ZapState: Equatable {

    case loading(message: String? = nil)

    case awaitingPayment(ZapDetails)

    case sessionExpired

    case error(ChargeError)

    case fatalError(error: ChargeError)
}
