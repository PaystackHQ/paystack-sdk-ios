import Foundation
@testable import PaystackUI

class MockMobileMoneyContainer: MobileMoneyContainer {

    var transactionDetails: VerifyAccessCode = .example
    var provider: MobileMoneyChannel = .example

    var mobileMoneyPaymentRestarted = false
    var transactionResponse: ChargeCardTransaction?
    var transactionError: ChargeError?

    var onProcessTransactionResponse: (() -> Void)?
    var onDisplayTransactionError: (() -> Void)?

    func processTransactionResponse(_ response: ChargeCardTransaction) async {
        transactionResponse = response
        onProcessTransactionResponse?()
    }

    func displayTransactionError(_ error: ChargeError) {
        transactionError = error
        onDisplayTransactionError?()
    }

    func restartMobileMoneyPayment() {
        mobileMoneyPaymentRestarted = true
    }
}
