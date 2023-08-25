import Foundation

class CardPinViewModel: ObservableObject {

    @Published
    var pinText: String = ""

    @Published
    var showLoading = false

    var chargeCardContainer: ChargeCardContainer
    var repository: ChargeCardRepository

    init(chargeCardContainer: ChargeCardContainer,
         repository: ChargeCardRepository = ChargeCardRepositoryImplementation()) {
        self.chargeCardContainer = chargeCardContainer
        self.repository = repository
    }

    func submitPin() async {
        showLoading = true
        do {
            let authenticationResult = try await repository.submitPin(
                pinText, accessCode: chargeCardContainer.accessCode)
            chargeCardContainer.processTransactionResponse(authenticationResult)
        } catch {
            // TODO: Determine error handling once we have further information
        }
    }

    func cancelTransaction() {
        chargeCardContainer.restartCardPayment()
    }
}
