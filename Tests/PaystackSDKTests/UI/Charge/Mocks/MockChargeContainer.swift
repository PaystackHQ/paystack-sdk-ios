import Foundation
@testable import PaystackUI

class MockChargeContainer: ChargeContainer {
    var transactionSuccessful = false
    var transactionFailed = false

    func processSuccessfulTransaction(details: VerifyAccessCode) {
        transactionSuccessful = true
    }

    func processFailedTransaction() {
        transactionFailed = true
    }

}
