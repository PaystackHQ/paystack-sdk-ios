import Foundation
import PaystackCore

class MPesaChrageViewModel: ObservableObject {

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
            let authenticationResult = try await repository.chargeMobileMoney(phone: phoneNumber, transactionId: "\(transactionDetails.transactionId ?? 0)", provider: transactionDetails.channelOptions?.mobileMoney?.first?.key ?? "")
            transactionState = .processTransaction(transaction: authenticationResult)
        } catch {
            let chargeError = ChargeError(error: error)
            transactionState = .error(chargeError)
            Logger.error("Submitting your phone number failed with error: %@",
                         arguments: error.localizedDescription)
        }
    }

    func cancelTransaction() {
       // TODO: cancel transaction code
    }
}

enum ChargeMobileMoneyState {
    case loading(message: String? = nil)
    case countdown
    case error(ChargeError)
    case fatalError(error: ChargeError)
    case processTransaction(transaction: MobileMoneyTransaction)
}
