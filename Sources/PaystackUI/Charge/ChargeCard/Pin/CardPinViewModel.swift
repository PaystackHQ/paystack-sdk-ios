import Foundation

class CardPinViewModel: ObservableObject {

    @Published
    var pinText: String = ""

    @Published
    var showLoading = false

    var chargeCardContainer: ChargeCardContainer

    init(chargeCardContainer: ChargeCardContainer) {
        self.chargeCardContainer = chargeCardContainer
    }

    func submitPin() {
        showLoading = true
        // TODO: Perform API call
    }

    func cancelTransaction() {
        chargeCardContainer.restartCardPayment()
    }
}
