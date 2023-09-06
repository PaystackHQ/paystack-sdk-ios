import Foundation
import Combine
import PaystackCore

class CardDetailsViewModel: ObservableObject {

    @Published
    var cardNumber: String = ""

    @Published
    var cvv: String = ""

    @Published
    var cardExpiry: String = ""

    @Published
    var cardType: CardType = .unknown

    var amountDetails: AmountCurrency
    var encryptionKey: String
    var chargeCardContainer: ChargeCardContainer
    var repository: ChargeCardRepository

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
        cvv.count == maximumCvvDigits &&
        cardExpiry.count == 7 &&
        cardNumber.removingAllWhitespaces.count >= cardType.minimumDigits
    }

    var maximumCvvDigits: Int {
        cardType.maximumCvvDigits
    }

    func formatAndSetCardNumber(_ cardNumber: String) {
        self.cardType = CardType.fromNumber(cardNumber)
        self.cardNumber = cardType.formatAndGroup(cardNumber: cardNumber)
    }

    func formatAndSetCardExpiry(_ expiry: String) {
        if cardExpiry.count <= expiry.count && expiry.count >= 2 {
            let dateComponents = dateComponents(from: expiry)
            self.cardExpiry = dateComponents.month + " / " + dateComponents.year
        } else {
            self.cardExpiry = expiry
        }
    }

    private func dateComponents(from date: String) -> (month: String, year: String) {
        let sanitizedDate = date.replacingOccurrences(of: "/", with: "").removingAllWhitespaces
        let month = sanitizedDate.prefix(2)
        let remainingDigits = sanitizedDate.dropFirst(2)
        return (String(month), String(remainingDigits))
    }

    func submitCardDetails() async {
        do {
            let dateComponents = dateComponents(from: cardExpiry)
            let card = CardCharge(number: cardNumber,
                                  cvv: cvv,
                                  expiryMonth: dateComponents.month,
                                  expiryYear: dateComponents.year)
            let authenticationResult = try await repository.submitCardDetails(
                card, publicEncryptionKey: encryptionKey, accessCode: chargeCardContainer.accessCode)
            await chargeCardContainer.processTransactionResponse(authenticationResult)
        } catch {
            let error = ChargeError(error: error)
            chargeCardContainer.displayTransactionError(error)
        }
    }

    func switchToTestModeCardSelection() {
        chargeCardContainer.switchToTestModeCardSelection()
    }
}
