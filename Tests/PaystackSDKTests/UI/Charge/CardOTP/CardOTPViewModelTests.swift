import XCTest
@testable import PaystackUI

final class CardOTPViewModelTests: XCTestCase {

    var serviceUnderTest: CardOTPViewModel!
    var mockChargeCardContainer: MockChargeCardContainer!
    var mockRepository: MockChargeCardRepository!
    let mockPhoneNumber = "+234801****5678"

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeCardContainer = MockChargeCardContainer()
        mockRepository = MockChargeCardRepository()
        serviceUnderTest = CardOTPViewModel(phoneNumber: mockPhoneNumber,
                                            chargeCardContainer: mockChargeCardContainer,
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

    func testResendOTPIncreasesResendCountAndResetsTimeToResendLength() {
        let expectedResendLength = 5
        serviceUnderTest.otpResendLength = expectedResendLength
        serviceUnderTest.resendOTP()
        XCTAssertEqual(serviceUnderTest.secondsBeforeResendOTP, expectedResendLength)
        XCTAssertEqual(serviceUnderTest.otpResendAttempts, 1)
    }

    func testDecreaseOTPTimerDecrementsRemainingTimeByOne() {
        serviceUnderTest.secondsBeforeResendOTP = 10
        serviceUnderTest.decreaseOTPCountdownTime()
        XCTAssertEqual(serviceUnderTest.secondsBeforeResendOTP, 9)
    }

    func testDecreaseOTPTimerDoesNotDecrementWhenRemainingTimeIsZero() {
        serviceUnderTest.secondsBeforeResendOTP = 0
        serviceUnderTest.decreaseOTPCountdownTime()
        XCTAssertEqual(serviceUnderTest.secondsBeforeResendOTP, 0)
    }

    func testSubmittingOTPSendsRepositoryResultToCardContainer() async throws {
        let expectedOTP = "123456"
        mockRepository.expectedChargeCardTransaction = .example
        serviceUnderTest.otp = expectedOTP
        await serviceUnderTest.submitOTP()

        XCTAssertEqual(mockRepository.otpSubmitted.otp, expectedOTP)
        XCTAssertEqual(mockChargeCardContainer.transactionResponse, .example)
    }
}
