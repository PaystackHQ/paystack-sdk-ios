import Foundation
@testable import PaystackUI

class MockMPesaContainer: MPesaContainer {

    var transactionDetails: VerifyAccessCode = .example

    var mPesaPaymentRestarted = false
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

    func restartMPesaPayment() {
        mPesaPaymentRestarted = true
    }
}
