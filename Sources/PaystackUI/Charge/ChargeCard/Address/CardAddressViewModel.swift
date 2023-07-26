import Foundation

class CardAddressViewModel: ObservableObject {

    var chargeCardContainer: ChargeCardContainer
    var stateList: [String]

    @Published
    var street: String = ""

    @Published
    var zipCode: String = ""

    @Published
    var state: String?

    @Published
    var city: String = ""

    init(states: [String],
         chargeCardContainer: ChargeCardContainer) {
        self.chargeCardContainer = chargeCardContainer
        self.stateList = states
    }

    var isValid: Bool {
        !street.isEmpty &&
        !zipCode.isEmpty &&
        !city.isEmpty &&
        state != nil
    }

    func submitAddress(onComplete: @escaping () -> Void) {
        // TODO: Perform API call
    }

    func cancelTransaction() {
        chargeCardContainer.restartCardPayment()
    }

}
