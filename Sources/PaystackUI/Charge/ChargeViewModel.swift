import Foundation
import PaystackCore

class ChargeViewModel: ObservableObject {

    let accessCode: String
    let repository: ChargeRepository

    @Published
    var transactionState: ChargeState = .loading()

    init(accessCode: String,
         repository: ChargeRepository) {
        self.accessCode = accessCode
        self.repository = repository
    }

    var displaySecuredByPaystack: Bool {
        // TODO: This will change once we add states that don't display the secured logo
        return true
    }

    @MainActor
    func verifyAccessCodeAndProceedWithCard() async {
        do {
            transactionState = .loading()
            let accessCodeResponse = try await repository.verifyAccessCode(accessCode)
            transactionState = .cardDetails(accessCodeResponse)
        } catch {
            transactionState = .error(error)
        }
    }

}
