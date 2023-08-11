import Foundation

class ChargeCardViewModel: ObservableObject, ChargeCardContainer {

    @Published
    var chargeCardState: ChargeCardState

    var transactionDetails: VerifyAccessCode

    init(transactionDetails: VerifyAccessCode) {
        self.transactionDetails = transactionDetails
        let amountDetails = transactionDetails.amountCurrency
        self.chargeCardState = transactionDetails.domain == .live ?
            .cardDetails(amount: amountDetails) :
            .testModeCardSelection(amount: amountDetails)
    }

    var inTestMode: Bool {
        transactionDetails.domain == .test
    }

    func restartCardPayment() {
        chargeCardState = .cardDetails(amount: transactionDetails.amountCurrency)
    }

    func switchToTestModeCardSelection() {
        chargeCardState = .testModeCardSelection(amount: transactionDetails.amountCurrency)
    }
}
