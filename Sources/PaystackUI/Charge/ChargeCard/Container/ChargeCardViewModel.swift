import Foundation

class ChargeCardViewModel: ObservableObject {

    @Published
    var chargeCardState: ChargeCardState

    init(amountDetails: AmountCurrency) {
        self.chargeCardState = .cardDetails(amount: amountDetails)
    }
}
