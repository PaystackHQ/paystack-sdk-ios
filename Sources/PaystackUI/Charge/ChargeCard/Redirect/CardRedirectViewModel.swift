import Foundation

class CardRedirectViewModel: ObservableObject {

    var chargeCardContainer: ChargeCardContainer
    var repository: ChargeCardRepository
    var transactionId: Int

    @Published
    var displayWebview = false

    init(transactionId: Int,
         chargeCardContainer: ChargeCardContainer,
         repository: ChargeCardRepository = ChargeCardRepositoryImplementation()) {
        self.transactionId = transactionId
        self.chargeCardContainer = chargeCardContainer
        self.repository = repository
    }

    @MainActor
    func initiateAndAwaitBankAuthentication() async {
        do {
            displayWebview = true
            let authenticationResult = try await repository.listenFor3DS(for: transactionId)
            await chargeCardContainer.processTransactionResponse(authenticationResult)
        } catch {
            let error = ChargeError(error: error)
            chargeCardContainer.displayTransactionError(error)
        }
    }

    func cancelTransaction() {
        chargeCardContainer.restartCardPayment()
    }

}
