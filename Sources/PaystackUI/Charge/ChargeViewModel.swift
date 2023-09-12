import Foundation
import PaystackCore

class ChargeViewModel: ObservableObject {

    let accessCode: String
    let repository: ChargeRepository

    @Published
    var transactionState: ChargeState = .loading()

    var transactionDetails: VerifyAccessCode?

    init(accessCode: String,
         repository: ChargeRepository = ChargeRepositoryImplementation()) {
        self.accessCode = accessCode
        self.repository = repository
    }

    @MainActor
    func verifyAccessCodeAndProceedWithCard() async {
        do {
            transactionState = .loading()
            let accessCodeResponse = try await repository.verifyAccessCode(accessCode)
            guard accessCodeResponse.paymentChannels.contains(where: { $0 == .card }) else {
                let errorMessage = "Card payments are not supported. " +
                "Please reach out to your merchant for further information"
                throw ChargeError(message: errorMessage)
            }

            self.transactionDetails = accessCodeResponse
            transactionState = .payment(type: .card(transactionInformation: accessCodeResponse))
        } catch {
            let error = ChargeError(error: error)
            transactionState = .error(error)
        }
    }

}

// MARK: - Charge Container
extension ChargeViewModel: ChargeContainer {

    func processSuccessfulTransaction(details: VerifyAccessCode) {
        transactionState = .success(amount: details.amountCurrency, merchant: details.merchantName)
    }

}

// MARK: UI State Management
extension ChargeViewModel {

    var centerView: Bool {
        switch transactionState {
        case .success:
            return true
        default:
            return false
        }
    }

    var displayCloseButtonConfirmation: Bool {
        switch transactionState {
        case .success:
            return false
        default:
            return true
        }
    }

    var inTestMode: Bool {
        transactionDetails?.domain == .test
    }
}
