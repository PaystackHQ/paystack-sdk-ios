import Foundation
import Combine

class CardDetailsViewModel: ObservableObject {

    @Published
    var cardNumber: String = ""

    @Published
    var cardType: CardType = .unknown

    var transactionDetails: VerifyAccessCode
    var subscriptions = Set<AnyCancellable>()

    init(transactionDetails: VerifyAccessCode) {
        self.transactionDetails = transactionDetails
    }

    var buttonTitle: String {
        "Pay \(transactionDetails.currency) \(transactionDetails.amount)"
    }

    var isValid: Bool {
        false
    }

    func setUpListeners() {
        $cardNumber
            .removeDuplicates()
            .sink { self.cardType = CardType.fromNumber($0) }
            .store(in: &subscriptions)
    }

    func submitCardDetails(onComplete: @escaping () -> Void) {
        // TODO: Perform API call with card details
    }
}
