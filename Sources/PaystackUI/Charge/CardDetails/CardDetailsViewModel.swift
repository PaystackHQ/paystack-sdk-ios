import Foundation
import Combine

class CardDetailsViewModel: ObservableObject {

    @Published
    var cardNumber: String = ""

    @Published
    var cvv: String = ""

    @Published
    var cardExpiry: String = ""

    @Published
    var showCvvError: Bool = false

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

    var maximumCvvDigits: Int {
        cardType.maximumCvvDigits
    }

    func formatAndSetCardNumber(_ cardNumber: String) {
        self.cardType = CardType.fromNumber(cardNumber)
        self.cardNumber = cardType.formatAndGroup(cardNumber: cardNumber)
    }

    func formatAndSetCardExpiry(_ expiry: String) {
        if cardExpiry.count <= expiry.count && expiry.count >= 2 {
            let sanitizedExpiry = expiry.replacingOccurrences(of: "/", with: "").removingAllWhitespaces
            let months = sanitizedExpiry.prefix(2)
            let remainingDigits = sanitizedExpiry.dropFirst(2)
            self.cardExpiry = months + " / " + remainingDigits
        } else {
            self.cardExpiry = expiry
        }
    }

    func submitCardDetails(onComplete: @escaping () -> Void) {
        // TODO: Perform API call with card details
    }
}