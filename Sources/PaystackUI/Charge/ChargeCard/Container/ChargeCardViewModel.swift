import Foundation

class ChargeCardViewModel: ObservableObject, ChargeCardContainer {

    @Published
    var chargeCardState: ChargeCardState

    var amountDetails: AmountCurrency

    init(amountDetails: AmountCurrency) {
        self.amountDetails = amountDetails
        self.chargeCardState = .cardDetails(amount: amountDetails)
    }

    func restartCardPayment() {
        chargeCardState = .cardDetails(amount: amountDetails)
    }
}
