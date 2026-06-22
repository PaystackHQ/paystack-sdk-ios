import Foundation
@testable import PaystackUI

class MockChargeContainer: ChargeContainer {
    var transactionSuccessful = false
    var channelSelectionRestarted = false

    var onProcessSuccessfulTransaction: (() -> Void)?

    func processSuccessfulTransaction(details: VerifyAccessCode) {
        transactionSuccessful = true
        onProcessSuccessfulTransaction?()
    }

    func restartFromChannelSelection() {
        channelSelectionRestarted = true
    }

}
