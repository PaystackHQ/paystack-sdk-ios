import Foundation
@testable import PaystackUI

class MockChargeCardContainer: ChargeCardContainer {

    var cardPaymentRestarted = false

    func restartCardPayment() {
        cardPaymentRestarted = true
    }

}
