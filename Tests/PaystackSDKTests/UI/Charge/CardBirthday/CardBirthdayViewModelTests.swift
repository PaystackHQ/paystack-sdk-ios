import XCTest
@testable import PaystackUI

final class CardBirthdayViewModelTests: XCTestCase {

    var serviceUnderTest: CardBirthdayViewModel!
    var mockChargeCardContainer: MockChargeCardContainer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeCardContainer = MockChargeCardContainer()
        serviceUnderTest = CardBirthdayViewModel(chargeCardContainer: mockChargeCardContainer)
    }

    func testCancelTransactionCallsContainerToRestartCardFlow() {
        serviceUnderTest.cancelTransaction()
        XCTAssertTrue(mockChargeCardContainer.cardPaymentRestarted)
    }
}
