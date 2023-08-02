import Foundation

class CardBirthdayViewModel: ObservableObject {
    var chargeCardContainer: ChargeCardContainer

    @Published
    var day: String = ""

    @Published
    var month: Month?

    @Published
    var year: String = ""

    init(chargeCardContainer: ChargeCardContainer) {
        self.chargeCardContainer = chargeCardContainer
    }

    var isValid: Bool {
        !day.isEmpty &&
        !year.isEmpty &&
        month != nil
    }

    func submitPhoneNumber(onComplete: @escaping () -> Void) {
        // TODO: Perform API call to submit birthday
    }

    func cancelTransaction() {
        chargeCardContainer.restartCardPayment()
    }

}
