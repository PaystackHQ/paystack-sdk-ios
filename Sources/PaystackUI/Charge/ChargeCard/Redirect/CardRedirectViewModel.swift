import Foundation

class CardRedirectViewModel: ObservableObject {

    var chargeCardContainer: ChargeCardContainer
    var repository: ChargeCardRepository
    var transactionId: Int

    init(transactionId: Int,
         chargeCardContainer: ChargeCardContainer,
         repository: ChargeCardRepository = ChargeCardRepositoryImplementation()) {
        self.transactionId = transactionId
        self.chargeCardContainer = chargeCardContainer
        self.repository = repository
    }

    func awaitAuthenticationResponse() async {
        do {
            let authenticationResult = try await repository.listenFor3DS(for: transactionId)
            await chargeCardContainer.processTransactionResponse(authenticationResult)
        } catch {
            let error = ChargeError(error: error)
            chargeCardContainer.displayTransactionError(error)
        }
    }

}
