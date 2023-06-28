import Foundation
import Combine

class CardDetailsViewModel: ObservableObject {

    @Published
    var cardNumber: String = ""

    @Published
    var cardType: CardType = .unknown

    var transactionDetails: VerifyAccessCode

    init(transactionDetails: VerifyAccessCode) {
        self.transactionDetails = transactionDetails
    }

    var buttonTitle: String {
        "Pay \(transactionDetails.currency) \(transactionDetails.amount)"
    }

    var isValid: Bool {
        false
    }

    func formatAndSetCardNumber(_ cardNumber: String) {
        self.cardType = CardType.fromNumber(cardNumber)
        self.cardNumber = cardType.formatAndGroup(cardNumber: cardNumber)
    }

    func submitCardDetails(onComplete: @escaping () -> Void) {
        // TODO: Perform API call with card details
    }
}
