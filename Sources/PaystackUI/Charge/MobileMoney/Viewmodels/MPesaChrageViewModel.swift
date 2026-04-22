import Foundation
import PaystackCore

protocol MPesaContainer {
    var transactionDetails: VerifyAccessCode { get }
    func processTransactionResponse(_ response: ChargeCardTransaction) async
    func displayTransactionError(_ error: ChargeError)
    func restartMPesaPayment()
}

class MPesaChrageViewModel: ObservableObject, @MainActor MPesaContainer {

    var chargeCardContainer: ChargeContainer
    var repository: ChargeMobileMoneyRepository
    var transactionDetails: VerifyAccessCode
    @Published
    var phoneNumber: String = ""

    @Published
    var transactionState: ChargeMobileMoneyState = .countdown

    init(chargeCardContainer: ChargeContainer,
         transactionDetails: VerifyAccessCode,
         repository: ChargeMobileMoneyRepository = ChargeMobileMoneyRepositoryImplementation()) {
        self.chargeCardContainer = chargeCardContainer
        self.repository = repository
        self.transactionDetails = transactionDetails
    }

    var isValid: Bool {
        phoneNumber.count >= 10
    }

    @MainActor
    func submitPhoneNumber() async {
        do {
            let authenticationResult = try await repository.chargeMobileMoney(
                phone: phoneNumber.formattedKenyanPhoneNumber,
                transactionId: "\(transactionDetails.transactionId ?? 0)",
                provider: transactionDetails.channelOptions?.mobileMoney?.first?.key ?? "")
            transactionState = .processTransaction(transaction: authenticationResult)
        } catch {
            displayTransactionError(ChargeError(error: error))
        }
    }

    func restartMPesaPayment() {
        transactionState = .countdown
    }

    @MainActor
    func processTransactionResponse(_ response: ChargeCardTransaction) async {
        switch response.status {
        case .success:
            chargeCardContainer.processSuccessfulTransaction(details: transactionDetails)
        case .failed:
            let message = response.message ?? response.displayText ?? "Declined"
            transactionState = .error(ChargeError(message: message))
        case .timeout:
            let message = response.displayText ?? "Payment timed out"
            transactionState = .fatalError(error: .init(message: message))
        case .pending:
            break
        default:
            Logger.error("Unexpected M-Pesa transaction status: %@",
                         arguments: response.status.rawValue)
            transactionState = .fatalError(
                error: .generic(withCause: "Unexpected transaction status: \(response.status.rawValue)"))
        }
    }

    @MainActor
    func displayTransactionError(_ error: ChargeError) {
        Logger.error("Displaying error: %@", arguments: error.localizedDescription)
        transactionState = .error(error)
    }

    func cancelTransaction() {
       restartMPesaPayment()
    }
}

enum ChargeMobileMoneyState {
    case loading(message: String? = nil)
    case countdown
    case error(ChargeError)
    case fatalError(error: ChargeError)
    case processTransaction(transaction: MobileMoneyTransaction)
}
