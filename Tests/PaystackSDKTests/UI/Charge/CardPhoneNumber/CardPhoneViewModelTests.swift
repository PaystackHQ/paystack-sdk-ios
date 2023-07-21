import XCTest
@testable import PaystackUI

final class CardPhoneViewModelTests: XCTestCase {

    var serviceUnderTest: CardPhoneViewModel!
    var mockChargeCardContainer: MockChargeCardContainer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeCardContainer = MockChargeCardContainer()
        serviceUnderTest = CardPhoneViewModel(chargeCardContainer: mockChargeCardContainer)
    }

    func testButtonIsDisabledWhenPhoneNumberIsLessThanTenDigits() {
        serviceUnderTest.phoneNumber = "0123456"
        XCTAssertFalse(serviceUnderTest.isValid)
    }

    func testButtonIsEnabledWhenPhoneNumberIsMoreThanOrEqualToTenDigits() {
        serviceUnderTest.phoneNumber = "0123456789"
        XCTAssertTrue(serviceUnderTest.isValid)

        serviceUnderTest.phoneNumber = "+270123456789"
        XCTAssertTrue(serviceUnderTest.isValid)
    }

    func testCancelTransactionCallsContainerToRestartCardFlow() {
        serviceUnderTest.cancelTransaction()
        XCTAssertTrue(mockChargeCardContainer.cardPaymentRestarted)
    }
}
