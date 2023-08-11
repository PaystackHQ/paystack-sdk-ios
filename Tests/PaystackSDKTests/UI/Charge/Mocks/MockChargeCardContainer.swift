import Foundation
@testable import PaystackUI

class MockChargeCardContainer: ChargeCardContainer {

    var cardPaymentRestarted = false
    var inTestMode = false
    var switchedToTestMode = false

    func restartCardPayment() {
        cardPaymentRestarted = true
    }

    func switchToTestModeCardSelection() {
        switchedToTestMode = true
    }

}
