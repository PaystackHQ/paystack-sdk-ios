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
            transactionState = .cardDetails(amount: accessCodeResponse.amountCurrency)
        } catch {
            transactionState = .error(error)
        }
    }

}

// MARK: UI State Management
extension ChargeViewModel {

    var displaySecuredByPaystack: Bool {
        // TODO: This will change once we add states that don't display the secured logo
        return true
    }

    var centerView: Bool {
        switch transactionState {
        case .success:
            return true
        default:
            return false
        }
    }
}
