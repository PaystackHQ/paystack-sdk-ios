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

    func processTransactionResponse(_ response: ChargeCardTransaction) {
        // TODO: Will handle processing the responses in a future PR
    }
}
