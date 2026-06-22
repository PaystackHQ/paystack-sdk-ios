import Foundation

enum BankTransferState: Equatable {

    case loading(message: String? = nil)

    case awaitingPayment(BankTransferDetails)

    case confirmingPayment(BankTransferDetails, phase: ConfirmingPhase)

    case takingLongerThanExpected(BankTransferDetails)

    case delayedConfirmation(BankTransferDetails)

    case refundInitiated(BankTransferDetails, message: String)

    case error(ChargeError)

    case fatalError(error: ChargeError)
}
