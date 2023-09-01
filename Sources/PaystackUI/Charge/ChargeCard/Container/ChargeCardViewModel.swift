import Foundation

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
        switch response.status {
        case .sendAddress:
            await handleSendAddress(with: response)
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

    private func handleSendAddress(with response: ChargeCardTransaction) async {
        guard let countryCode = response.countryCode,
              let states = try? await repository.getAddressStates(for: countryCode) else {
            // TODO: Display error
            return
        }
        chargeCardState = .address(states: states)
    }
}
