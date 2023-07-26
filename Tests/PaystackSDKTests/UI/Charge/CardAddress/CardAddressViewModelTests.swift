import XCTest
@testable import PaystackUI

final class CardAddressViewModelTests: XCTestCase {

    var serviceUnderTest: CardAddressViewModel!
    var mockChargeCardContainer: MockChargeCardContainer!
    let mockStates: [String] = []

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeCardContainer = MockChargeCardContainer()
        serviceUnderTest = CardAddressViewModel(states: mockStates,
                                                chargeCardContainer: mockChargeCardContainer)
    }

    func testFormIsInvalidWhenAllFieldsAreEmpty() {
        serviceUnderTest.street = ""
        serviceUnderTest.zipCode = ""
        serviceUnderTest.city = ""
        serviceUnderTest.state = nil
        XCTAssertFalse(serviceUnderTest.isValid)
    }

    func testFormIsInvalidWhenSomeFieldsAreEmpty() {
        serviceUnderTest.street = "123 Test Street"
        serviceUnderTest.zipCode = "12345"
        serviceUnderTest.city = ""
        serviceUnderTest.state = nil
        XCTAssertFalse(serviceUnderTest.isValid)
    }

    func testFormIsValidIfAllFieldsAreNotEmpty() {
        serviceUnderTest.street = "123 Test Street"
        serviceUnderTest.zipCode = "12345"
        serviceUnderTest.city = "Test City"
        serviceUnderTest.state = "Test State"
        XCTAssertTrue(serviceUnderTest.isValid)
    }

    func testCancelTransactionCallsContainerToRestartCardFlow() {
        serviceUnderTest.cancelTransaction()
        XCTAssertTrue(mockChargeCardContainer.cardPaymentRestarted)
    }

}
