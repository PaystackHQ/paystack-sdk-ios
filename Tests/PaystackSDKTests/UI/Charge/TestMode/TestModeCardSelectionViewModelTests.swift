import XCTest
@testable import PaystackUI

final class TestModeCardSelectionViewModelTests: XCTestCase {

    var serviceUnderTest: TestModeCardSelectionViewModel!
    var mockAmountCurrency = AmountCurrency(amount: 10000, currency: "USD")
    var mockChargeCardContainer: MockChargeCardContainer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeCardContainer = MockChargeCardContainer()
        serviceUnderTest = TestModeCardSelectionViewModel(amountDetails: mockAmountCurrency,
                                                          chargeCardContainer: mockChargeCardContainer)
    }

    func testFormIsValidIfTestCardIsSelected() {
        serviceUnderTest.testCard = .bankAuthentication
        XCTAssertTrue(serviceUnderTest.isValid)
    }

    func testFormIsNotValidIfTestCardIsNotSelected() {
        serviceUnderTest.testCard = nil
        XCTAssertFalse(serviceUnderTest.isValid)
    }
}
