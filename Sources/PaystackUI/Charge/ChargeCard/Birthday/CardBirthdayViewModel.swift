import Foundation

class CardBirthdayViewModel: ObservableObject {
    var chargeCardContainer: ChargeCardContainer

    @Published
    var day: String = ""

    @Published
    var year: String = ""

    init(chargeCardContainer: ChargeCardContainer) {
        self.chargeCardContainer = chargeCardContainer
    }

    var isValid: Bool {
        // TODO: Validation will be done in the next PR
        true
    }

    func submitPhoneNumber(onComplete: @escaping () -> Void) {
        // TODO: Perform API call to submit birthday
    }

    func cancelTransaction() {
        chargeCardContainer.restartCardPayment()
    }
    
}
