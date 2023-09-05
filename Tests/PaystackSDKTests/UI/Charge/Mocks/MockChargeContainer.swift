import Foundation
@testable import PaystackUI

class MockChargeContainer: ChargeContainer {
    var transactionSuccessful = false

    func processSuccessfulTransaction(details: VerifyAccessCode) {
        transactionSuccessful = true
    }

}
