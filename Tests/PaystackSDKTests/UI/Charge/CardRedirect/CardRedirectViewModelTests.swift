import XCTest
import PaystackCore
@testable import PaystackUI

final class CardRedirectViewModelTests: PSTestCase {

    var serviceUnderTest: CardRedirectViewModel!
    var mockChargeCardContainer: MockChargeCardContainer!
    var mockRepository: MockChargeCardRepository!
    var expectedTransactionId = 1234

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeCardContainer = MockChargeCardContainer()
        mockRepository = MockChargeCardRepository()
        serviceUnderTest = CardRedirectViewModel(transactionId: expectedTransactionId,
                                                 chargeCardContainer: mockChargeCardContainer,
                                                 repository: mockRepository)
    }

    func testAwaiting3DSResponseDisplaysWebviewAndSendsResultToContainerWhenReceived() async throws {
        mockRepository.expectedChargeCardTransaction = .example
        await serviceUnderTest.initiateAndAwaitBankAuthentication()

        XCTAssertTrue(serviceUnderTest.displayWebview)
        XCTAssertEqual(mockRepository.redirectTranactionId, expectedTransactionId)
        XCTAssertEqual(mockChargeCardContainer.transactionResponse, .example)
    }

    func testAwaiting3DSResponseWithErrorSendsErrorToContainerWhenReceived() async throws {
        let expectedErrorMessage = "Error Message"
        let expectedError: PaystackError = .response(code: 400, message: expectedErrorMessage)
        mockRepository.expectedErrorResponse = expectedError

        await serviceUnderTest.initiateAndAwaitBankAuthentication()
        XCTAssertEqual(mockChargeCardContainer.transactionError,
                       .init(message: expectedErrorMessage))
    }

    func testCancelTransactionCallsContainerToRestartCardFlow() {
        serviceUnderTest.cancelTransaction()
        XCTAssertTrue(mockChargeCardContainer.cardPaymentRestarted)
    }

}
