import Foundation
import Combine

class CardOTPViewModel: ObservableObject {

    var chargeCardContainer: ChargeCardContainer
    var repository: ChargeCardRepository
    var phoneNumber: String

    @Published
    var otp: String = ""

    @Published
    var secondsBeforeResendOTP = 0
    var otpResendLength = 60

    var subscription: AnyCancellable?
    var otpResendAttempts = 0

    init(phoneNumber: String,
         chargeCardContainer: ChargeCardContainer,
         repository: ChargeCardRepository = ChargeCardRepositoryImplementation()) {
        self.phoneNumber = phoneNumber
        self.chargeCardContainer = chargeCardContainer
        self.repository = repository
    }

    var isValid: Bool {
        !otp.removingAllWhitespaces.isEmpty
    }

    func submitOTP() async {
        do {
            let authenticationResult = try await repository.submitOTP(
                otp, accessCode: chargeCardContainer.accessCode)
            chargeCardContainer.processTransactionResponse(authenticationResult)
        } catch {
            // TODO: Determine error handling once we have further information
        }
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
