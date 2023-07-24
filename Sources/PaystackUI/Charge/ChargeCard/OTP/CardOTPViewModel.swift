import Foundation
import Combine

class CardOTPViewModel: ObservableObject {

    var chargeCardContainer: ChargeCardContainer
    var phoneNumber: String

    @Published
    var otp: String = ""

    @Published
    var secondsBeforeResendOTP = 0
    var otpResendLength = 59

    var subscription: AnyCancellable?
    var otpResendAttempts = 0

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

    func resendOTP() {
        otpResendAttempts += 1
        secondsBeforeResendOTP = otpResendLength
        // TODO: Perform API call
    }

    func decreaseOTPCountdownTime() {
        if secondsBeforeResendOTP > 0 {
            secondsBeforeResendOTP -= 1
        } else {
            subscription?.cancel()
        }
    }
}
