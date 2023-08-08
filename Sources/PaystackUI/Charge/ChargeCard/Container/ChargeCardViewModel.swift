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

    func restartCardPayment() {
        chargeCardState = .cardDetails(amount: transactionDetails.amountCurrency)
    }
}
