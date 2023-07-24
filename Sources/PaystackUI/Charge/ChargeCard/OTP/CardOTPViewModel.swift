import Foundation
import Combine

class CardOTPViewModel: ObservableObject {

    var chargeCardContainer: ChargeCardContainer
    var phoneNumber: String

    @Published
    var otp: String = ""

    init(phoneNumber: String,
         chargeCardContainer: ChargeCardContainer) {
        self.phoneNumber = phoneNumber
        self.chargeCardContainer = chargeCardContainer
    }

    var isValid: Bool {
        !otp.removingAllWhitespaces.isEmpty
    }

    func submitOTP(onComplete: @escaping () -> Void) {
        // TODO: Perform API call
    }

    func cancelTransaction() {
        chargeCardContainer.restartCardPayment()
    }

}
