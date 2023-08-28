import Foundation

class ChargeCardViewModel: ObservableObject, ChargeCardContainer {

    @Published
    var chargeCardState: ChargeCardState

    var transactionDetails: VerifyAccessCode
    var chargeContainer: ChargeContainer

    init(transactionDetails: VerifyAccessCode,
         chargeContainer: ChargeContainer) {
        self.transactionDetails = transactionDetails
        self.chargeContainer = chargeContainer
        let amountDetails = transactionDetails.amountCurrency
        self.chargeCardState = transactionDetails.domain == .live ?
            .cardDetails(amount: amountDetails) :
            .testModeCardSelection(amount: amountDetails)
    }

    var accessCode: String {
        transactionDetails.accessCode
    }

    var inTestMode: Bool {
        transactionDetails.domain == .test
    }

    func restartCardPayment() {
        chargeCardState = .cardDetails(amount: transactionDetails.amountCurrency)
    }

    func switchToTestModeCardSelection() {
        chargeCardState = .testModeCardSelection(amount: transactionDetails.amountCurrency)
    }

    @MainActor
    func processTransactionResponse(_ response: ChargeCardTransaction) {
        switch response.status {
        case .sendAddress:
            // TODO: Fetch states from API
            let mockStates = ["Test State A", "Test State B"]
            chargeCardState = .address(states: mockStates)
        case .sendBirthday:
            chargeCardState = .birthday
        case .sendPhone:
            chargeCardState = .phoneNumber
        case .sendOtp:
            if let phoneNumber = response.customerPhone {
                chargeCardState = .otp(phoneNumber: phoneNumber)
            } else {
                // TODO: Display error
            }
        case .sendPin:
            chargeCardState = .pin
        case .success:
            chargeContainer.processSuccessfulTransaction(details: transactionDetails)
        case .failed:
            chargeContainer.processFailedTransaction()
        case .pending:
            // TODO: Add logic for pending state
            break
        case .redirect:
            // TODO: Add logic for 3DS
            break
        case .timeout:
            // TODO: Add logic for timeout
            break
        }
    }
}
