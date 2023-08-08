import Foundation

class TestModeCardSelectionViewModel: ObservableObject {

    var amountDetails: AmountCurrency
    var chargeCardContainer: ChargeCardContainer

    @Published
    var testCard: TestCard?

    init(amountDetails: AmountCurrency,
         chargeCardContainer: ChargeCardContainer) {
        self.amountDetails = amountDetails
        self.chargeCardContainer = chargeCardContainer
    }

    var buttonTitle: String {
        "Pay \(amountDetails.description)"
    }

    var isValid: Bool {
        testCard != nil
    }

    func proceedWithTestCard(onComplete: @escaping () -> Void) {
        // TODO: Perform API call with card details
    }
}
