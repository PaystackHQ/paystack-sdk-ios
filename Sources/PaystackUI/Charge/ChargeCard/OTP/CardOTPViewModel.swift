import Foundation
import Combine

class CardOTPViewModel: ObservableObject {

    var chargeCardContainer: ChargeCardContainer
    var repository: ChargeCardRepository
    var phoneNumber: String

    @Published
    var otp: String = ""

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
            await chargeCardContainer.processTransactionResponse(authenticationResult)
        } catch {
            let error = ChargeError(error: error)
            chargeCardContainer.displayTransactionError(error)
        }
    }

    func cancelTransaction() {
        chargeCardContainer.restartCardPayment()
    }
}
