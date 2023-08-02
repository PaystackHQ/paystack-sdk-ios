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

    func testFormIsInvalidWhenAllFieldsAreEmpty() {
        serviceUnderTest.year = ""
        serviceUnderTest.day = ""
        serviceUnderTest.month = nil
        XCTAssertFalse(serviceUnderTest.isValid)
    }

    func testFormIsInvalidWhenSomeFieldsAreEmpty() {
        serviceUnderTest.year = "2000"
        serviceUnderTest.day = "01"
        serviceUnderTest.month = nil
        XCTAssertFalse(serviceUnderTest.isValid)
    }

    func testFormIsValidIfAllFieldsAreNotEmpty() {
        serviceUnderTest.year = "2000"
        serviceUnderTest.day = "01"
        serviceUnderTest.month = .january
        XCTAssertTrue(serviceUnderTest.isValid)
    }
}
