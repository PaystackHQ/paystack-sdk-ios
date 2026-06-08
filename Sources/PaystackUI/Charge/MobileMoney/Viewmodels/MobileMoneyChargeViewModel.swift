import Foundation
import PaystackCore

protocol MobileMoneyContainer {
    var transactionDetails: VerifyAccessCode { get }
    var provider: MobileMoneyChannel { get }
    func processTransactionResponse(_ response: ChargeCardTransaction) async
    func displayTransactionError(_ error: ChargeError)
    func restartMobileMoneyPayment()
}

class MobileMoneyChargeViewModel: ObservableObject, @MainActor MobileMoneyContainer {

    var chargeCardContainer: ChargeContainer
    var repository: ChargeMobileMoneyRepository
    var transactionDetails: VerifyAccessCode
    let provider: MobileMoneyChannel
    @Published
    var phoneNumber: String = ""

    @Published
    var transactionState: ChargeMobileMoneyState = .countdown

    init(chargeCardContainer: ChargeContainer,
         transactionDetails: VerifyAccessCode,
         provider: MobileMoneyChannel,
         repository: ChargeMobileMoneyRepository = ChargeMobileMoneyRepositoryImplementation()) {
        self.chargeCardContainer = chargeCardContainer
        self.repository = repository
        self.transactionDetails = transactionDetails
        self.provider = provider
    }

    var isValid: Bool {
        if !provider.phoneNumberRegex.isEmpty,
           let regex = try? NSRegularExpression(pattern: provider.phoneNumberRegex) {
            let formatted = phoneNumber.formatted(for: provider)
            let range = NSRange(location: 0, length: formatted.utf16.count)
            return regex.firstMatch(in: formatted, range: range) != nil
        }
        return phoneNumber.count >= 10
    }

    @MainActor
    func submitPhoneNumber() async {
        do {
            let authenticationResult = try await repository.chargeMobileMoney(
                phone: phoneNumber.formatted(for: provider),
                transactionId: "\(transactionDetails.transactionId ?? 0)",
                provider: provider.key)
            transactionState = .processTransaction(transaction: authenticationResult)
        } catch {
            displayTransactionError(ChargeError(error: error))
        }
    }

    func restartMobileMoneyPayment() {
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
            Logger.error("Unexpected mobile money transaction status: %@",
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
       restartMobileMoneyPayment()
    }
}

enum ChargeMobileMoneyState {
    case loading(message: String? = nil)
    case countdown
    case error(ChargeError)
    case fatalError(error: ChargeError)
    case processTransaction(transaction: MobileMoneyTransaction)
}
