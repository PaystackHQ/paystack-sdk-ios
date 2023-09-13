import XCTest
import PaystackCore
@testable import PaystackUI

final class CardPinViewModelTests: XCTestCase {

    var serviceUnderTest: CardPinViewModel!
    var mockEncryptionKey = "MOCK_ENCRYPTION_KEY"
    var mockRepository: MockChargeCardRepository!
    var mockChargeCardContainer: MockChargeCardContainer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeCardContainer = MockChargeCardContainer()
        mockRepository = MockChargeCardRepository()
        serviceUnderTest = CardPinViewModel(encryptionKey: mockEncryptionKey,
                                            chargeCardContainer: mockChargeCardContainer,
                                            repository: mockRepository)
    }

    func testCancelTransactionCallsContainerToRestartCardFlow() {
        serviceUnderTest.cancelTransaction()
        XCTAssertTrue(mockChargeCardContainer.cardPaymentRestarted)
    }

    func testSubmittingPinSendsRepositoryResultToCardContainer() async throws {
        let expectedPin = "12345"
        mockRepository.expectedChargeCardTransaction = .example
        serviceUnderTest.pinText = expectedPin
        await serviceUnderTest.submitPin()

        XCTAssertEqual(mockRepository.pinSubmitted.pin, expectedPin)
        XCTAssertEqual(mockChargeCardContainer.transactionResponse, .example)
    }

    func testSubmittingPinWithErrorForwardsErrorToCardContainer() async {
        let expectedErrorMessage = "Error Message"
        let expectedError: PaystackError = .response(code: 400, message: expectedErrorMessage)
        mockRepository.expectedErrorResponse = expectedError

        serviceUnderTest.pinText = "1234"
        await serviceUnderTest.submitPin()

        XCTAssertEqual(mockChargeCardContainer.transactionError,
                       .init(message: expectedErrorMessage))
    }

}
