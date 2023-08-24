import Foundation
@testable import PaystackUI

class MockChargeCardContainer: ChargeCardContainer {

    var cardPaymentRestarted = false
    var inTestMode = false
    var accessCode: String = "Mock_Access_Code"
    var switchedToTestMode = false
    var transactionResponse: ChargeCardTransaction?

    func restartCardPayment() {
        cardPaymentRestarted = true
    }

    func switchToTestModeCardSelection() {
        switchedToTestMode = true
    }

    func processTransactionResponse(_ response: ChargeCardTransaction) {
        transactionResponse = response
    }

}
