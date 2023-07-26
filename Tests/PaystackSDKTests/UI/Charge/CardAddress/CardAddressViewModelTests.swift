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

    func testFormIsValidIfAllFieldsAreNotEmpty() {
        // TODO: Add this test once we complete the last field
    }

    func testCancelTransactionCallsContainerToRestartCardFlow() {
        serviceUnderTest.cancelTransaction()
        XCTAssertTrue(mockChargeCardContainer.cardPaymentRestarted)
    }

}
