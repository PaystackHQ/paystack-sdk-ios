import Foundation

class CardPhoneViewModel: ObservableObject {

    var chargeCardContainer: ChargeCardContainer

    @Published
    var phoneNumber: String = ""

    init(chargeCardContainer: ChargeCardContainer) {
        self.chargeCardContainer = chargeCardContainer
    }

    var isValid: Bool {
        phoneNumber.count >= 10
    }

    func submitPhoneNumber(onComplete: @escaping () -> Void) {
        // TODO: Perform API call to submit phone number
    }

    func cancelTransaction() {
        chargeCardContainer.restartCardPayment()
    }
}
