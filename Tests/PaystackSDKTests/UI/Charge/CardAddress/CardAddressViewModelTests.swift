import XCTest
import PaystackCore
@testable import PaystackUI

final class CardAddressViewModelTests: XCTestCase {

    var serviceUnderTest: CardAddressViewModel!
    var mockChargeCardContainer: MockChargeCardContainer!
    var mockRepository: MockChargeCardRepository!
    let mockStates: [String] = []

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeCardContainer = MockChargeCardContainer()
        mockRepository = MockChargeCardRepository()
        serviceUnderTest = CardAddressViewModel(states: mockStates,
                                                chargeCardContainer: mockChargeCardContainer,
                                                repository: mockRepository)
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

    func testSubmittingAddressSendsRepositoryResultToCardContainer() async throws {
        let expectedAddress = Address(address: "123 Test Street",
                                      city: "Test City",
                                      state: "Test State",
                                      zipCode: "12345")

        serviceUnderTest.street = "123 Test Street"
        serviceUnderTest.zipCode = "12345"
        serviceUnderTest.city = "Test City"
        serviceUnderTest.state = "Test State"
        mockRepository.expectedChargeCardTransaction = .example
        await serviceUnderTest.submitAddress()

        XCTAssertEqual(mockRepository.addressSubmitted.address, expectedAddress)
        XCTAssertEqual(mockChargeCardContainer.transactionResponse, .example)
    }

    func testSubmittingAddressWithErrorForwardsErrorToCardContainer() async {
        let expectedErrorMessage = "Error Message"
        let expectedError: PaystackError = .response(code: 400, message: expectedErrorMessage)
        mockRepository.expectedErrorResponse = expectedError

        serviceUnderTest.street = "123 Test Street"
        serviceUnderTest.zipCode = "12345"
        serviceUnderTest.city = "Test City"
        serviceUnderTest.state = "Test State"
        await serviceUnderTest.submitAddress()

        XCTAssertEqual(mockChargeCardContainer.transactionError,
                       .init(message: expectedErrorMessage))
    }

}
