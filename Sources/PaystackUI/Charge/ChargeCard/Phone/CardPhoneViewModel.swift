import Foundation

class CardPhoneViewModel: ObservableObject {

    var chargeCardContainer: ChargeCardContainer
    var repository: ChargeCardRepository

    @Published
    var phoneNumber: String = ""

    init(chargeCardContainer: ChargeCardContainer,
         repository: ChargeCardRepository = ChargeCardRepositoryImplementation()) {
        self.chargeCardContainer = chargeCardContainer
        self.repository = repository
    }

    var isValid: Bool {
        phoneNumber.count >= 10
    }

    func submitPhoneNumber() async {
        do {
            let authenticationResult = try await repository.submitPhone(
                phoneNumber, accessCode: chargeCardContainer.accessCode)
            await chargeCardContainer.processTransactionResponse(authenticationResult)
        } catch {
            // TODO: Determine error handling once we have further information
        }
    }

    func cancelTransaction() {
        chargeCardContainer.restartCardPayment()
    }
}
