import XCTest
@testable import PaystackUI

final class ChargeCardViewModelTests: PSTestCase {

    var serviceUnderTest: ChargeCardViewModel!
    var mockAmountCurrency = AmountCurrency(amount: 10000, currency: "USD")

    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceUnderTest = ChargeCardViewModel(amountDetails: mockAmountCurrency)
    }

    func testRestartCardPaymentResetsStateToCardDetailsWithAmount() {
        serviceUnderTest.chargeCardState = .pin
        serviceUnderTest.restartCardPayment()
        XCTAssertEqual(serviceUnderTest.chargeCardState,
            .cardDetails(amount: mockAmountCurrency))
    }

}

extension ChargeCardState: Equatable {
    public static func == (lhs: ChargeCardState, rhs: ChargeCardState) -> Bool {
        switch (lhs, rhs) {
        case (.cardDetails(let first), .cardDetails(let second)):
            return first == second
        case (.pin, .pin):
            return true
        default:
            return false
        }
    }
}
