import XCTest
import PaystackCore
@testable import PaystackUI

final class CardOTPViewModelTests: XCTestCase {

    var serviceUnderTest: CardOTPViewModel!
    var mockChargeCardContainer: MockChargeCardContainer!
    var mockRepository: MockChargeCardRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeCardContainer = MockChargeCardContainer()
        mockRepository = MockChargeCardRepository()
        serviceUnderTest = CardOTPViewModel(chargeCardContainer: mockChargeCardContainer,
                                            repository: mockRepository)
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

    func testSubmittingOTPSendsRepositoryResultToCardContainer() async throws {
        let expectedOTP = "123456"
        mockRepository.expectedChargeCardTransaction = .example
        serviceUnderTest.otp = expectedOTP
        await serviceUnderTest.submitOTP()

        XCTAssertEqual(mockRepository.otpSubmitted.otp, expectedOTP)
        XCTAssertEqual(mockChargeCardContainer.transactionResponse, .example)
    }

    func testSubmittingOTPWithErrorForwardsErrorToCardContainer() async {
        let expectedErrorMessage = "Error Message"
        let expectedError: PaystackError = .response(code: 400, message: expectedErrorMessage)
        mockRepository.expectedErrorResponse = expectedError

        serviceUnderTest.otp = "123456"
        await serviceUnderTest.submitOTP()

        XCTAssertEqual(mockChargeCardContainer.transactionError,
                       .init(message: expectedErrorMessage))
    }
}
