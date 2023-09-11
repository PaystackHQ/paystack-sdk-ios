import Foundation
import PaystackCore

class ChargeCardViewModel: ObservableObject, ChargeCardContainer {

    @Published
    var chargeCardState: ChargeCardState

    var transactionDetails: VerifyAccessCode
    var chargeContainer: ChargeContainer
    var repository: ChargeCardRepository

    init(transactionDetails: VerifyAccessCode,
         chargeContainer: ChargeContainer,
         repository: ChargeCardRepository = ChargeCardRepositoryImplementation()) {
        self.transactionDetails = transactionDetails
        self.chargeContainer = chargeContainer
        self.repository = repository
        let amountDetails = transactionDetails.amountCurrency
        let encryptionKey = transactionDetails.publicEncryptionKey
        self.chargeCardState = transactionDetails.domain == .live ?
            .cardDetails(amount: amountDetails, encryptionKey: encryptionKey) :
            .testModeCardSelection(amount: amountDetails, encryptionKey: encryptionKey)
    }

    var accessCode: String {
        transactionDetails.accessCode
    }

    var inTestMode: Bool {
        transactionDetails.domain == .test
    }

    func restartCardPayment() {
        chargeCardState = .cardDetails(amount: transactionDetails.amountCurrency,
                                       encryptionKey: transactionDetails.publicEncryptionKey)
    }

    func switchToTestModeCardSelection() {
        chargeCardState = .testModeCardSelection(amount: transactionDetails.amountCurrency,
                                                 encryptionKey: transactionDetails.publicEncryptionKey)
    }

    @MainActor
    func processTransactionResponse(_ response: ChargeCardTransaction) async {
        let displayText = response.displayText
        switch response.status {
        case .sendAddress:
            await handleSendAddress(with: response)
        case .sendBirthday:
            chargeCardState = .birthday(displayMessage: displayText)
        case .sendPhone:
            chargeCardState = .phoneNumber(displayMessage: displayText)
        case .sendOtp:
            chargeCardState = .otp(displayMessage: displayText)
        case .sendPin:
            chargeCardState = .pin(encryptionKey: transactionDetails.publicEncryptionKey)
        case .success:
            chargeContainer.processSuccessfulTransaction(details: transactionDetails)
        case .failed:
            chargeCardState = .failed
        case .pending:
            // TODO: Add logic for pending state
            break
        case .openUrl:
            // TODO: Add logic for 3DS
            break
        case .timeout:
            // TODO: Add logic for timeout
            break
        }
    }

    @MainActor
    func displayTransactionError(_ error: ChargeError) {
        Logger.error("Displaying error: %@", arguments: error.message)
        chargeCardState = .error(error)
    }

    private func handleSendAddress(with response: ChargeCardTransaction) async {
        guard let countryCode = response.countryCode,
              let states = try? await repository.getAddressStates(for: countryCode) else {
            Logger.error("Unable to retrieve address states")
            chargeCardState = .error(.generic)
            return
        }
        chargeCardState = .address(states: states, displayMessage: response.displayText)
    }
}
