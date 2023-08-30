import Foundation
import PaystackCore

class TestModeCardSelectionViewModel: ObservableObject {

    var amountDetails: AmountCurrency
    var encryptionKey: String
    var chargeCardContainer: ChargeCardContainer
    var repository: ChargeCardRepository

    @Published
    var testCard: TestCard?

    init(amountDetails: AmountCurrency,
         encryptionKey: String,
         chargeCardContainer: ChargeCardContainer,
         repository: ChargeCardRepository = ChargeCardRepositoryImplementation()) {
        self.amountDetails = amountDetails
        self.encryptionKey = encryptionKey
        self.chargeCardContainer = chargeCardContainer
        self.repository = repository
    }

    var buttonTitle: String {
        "Pay \(amountDetails.description)"
    }

    var isValid: Bool {
        testCard != nil
    }

    func proceedWithTestCard() async {
        do {
            guard let testCard else { return }
            let card = CardCharge(number: testCard.cardNumber,
                                  cvv: testCard.cvv,
                                  expiryMonth: testCard.expiryMonth,
                                  expiryYear: testCard.expiryYear)

            let authenticationResult = try await repository.submitCardDetails(
                card, publicEncryptionKey: encryptionKey, accessCode: chargeCardContainer.accessCode)
            chargeCardContainer.processTransactionResponse(authenticationResult)
        } catch {
            print(error)
            // TODO: Determine error handling once we have further information
        }
    }

    func displayManualCardDetailsEntry() {
        chargeCardContainer.restartCardPayment()
    }
}
