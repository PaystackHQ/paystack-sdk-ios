import Foundation

class CardPinViewModel: ObservableObject {

    @Published
    var pinText: String = ""

    @Published
    var showLoading = false

    var encryptionKey: String
    var chargeCardContainer: ChargeCardContainer
    var repository: ChargeCardRepository

    init(encryptionKey: String,
         chargeCardContainer: ChargeCardContainer,
         repository: ChargeCardRepository = ChargeCardRepositoryImplementation()) {
        self.encryptionKey = encryptionKey
        self.chargeCardContainer = chargeCardContainer
        self.repository = repository
    }

    func submitPin() async {
        showLoading = true
        do {
            let authenticationResult = try await repository.submitPin(
                pinText, publicEncryptionKey: encryptionKey, accessCode: chargeCardContainer.accessCode)
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
