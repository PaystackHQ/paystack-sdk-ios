import XCTest
@testable import PaystackUI

final class CardPinViewModelTests: XCTestCase {

    var serviceUnderTest: CardPinViewModel!
    var mockChargeCardContainer: MockChargeCardContainer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeCardContainer = MockChargeCardContainer()
        serviceUnderTest = CardPinViewModel(chargeCardContainer: mockChargeCardContainer)
    }

    func testCancelTransactionCallsContainerToRestartCardFlow() {
        serviceUnderTest.cancelTransaction()
        XCTAssertTrue(mockChargeCardContainer.cardPaymentRestarted)
    }

}
