import XCTest
@testable import PaystackUI

final class CardOTPViewModelTests: XCTestCase {

    var serviceUnderTest: CardOTPViewModel!
    var mockChargeCardContainer: MockChargeCardContainer!
    let mockPhoneNumber = "+234801****5678"

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeCardContainer = MockChargeCardContainer()
        serviceUnderTest = CardOTPViewModel(phoneNumber: mockPhoneNumber,
                                            chargeCardContainer: mockChargeCardContainer)
    }

    func testFormIsInvalidIfOTPIsEmpty() {
        serviceUnderTest.otp = ""
        XCTAssertFalse(serviceUnderTest.isValid)

        serviceUnderTest.otp = " "
        XCTAssertFalse(serviceUnderTest.isValid)
    }

    func testFormIsValidIfOTPHasAtLeastOneDigit() {
        serviceUnderTest.otp = "1"
        XCTAssertTrue(serviceUnderTest.isValid)
    }

    func testCancelTransactionCallsContainerToRestartCardFlow() {
        serviceUnderTest.cancelTransaction()
        XCTAssertTrue(mockChargeCardContainer.cardPaymentRestarted)
    }
}
