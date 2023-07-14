import Foundation
import PaystackCore

class ChargeViewModel: ObservableObject {

    let accessCode: String
    let repository: ChargeRepository

    @Published
    var transactionState: ChargeState = .loading()

    var transactionDetails: VerifyAccessCode?

    init(accessCode: String,
         repository: ChargeRepository) {
        self.accessCode = accessCode
        self.repository = repository
    }

    @MainActor
    func verifyAccessCodeAndProceedWithCard() async {
        do {
            transactionState = .loading()
            let accessCodeResponse = try await repository.verifyAccessCode(accessCode)
            self.transactionDetails = accessCodeResponse
            transactionState = .payment(type: .card(amountInformation: accessCodeResponse.amountCurrency))
        } catch {
            transactionState = .error(error)
        }
    }

}

// MARK: UI State Management
extension ChargeViewModel {

    var displaySecuredByPaystack: Bool {
        switch transactionState {
        case .success:
            return false
        default:
            return true
        }
    }

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
}
