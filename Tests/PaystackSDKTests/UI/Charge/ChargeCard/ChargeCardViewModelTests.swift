import XCTest
@testable import PaystackUI

final class ChargeCardViewModelTests: PSTestCase {

    var serviceUnderTest: ChargeCardViewModel!
    var mockTransactionDetails = VerifyAccessCode.example
    var mockChargeContainer: MockChargeContainer!
    var mockRepository: MockChargeCardRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeContainer = MockChargeContainer()
        mockRepository = MockChargeCardRepository()
        serviceUnderTest = ChargeCardViewModel(transactionDetails: mockTransactionDetails,
                                               chargeContainer: mockChargeContainer,
                                               repository: mockRepository)
    }

    func testRestartCardPaymentResetsStateToCardDetailsWithAmount() {
        serviceUnderTest.chargeCardState = .birthday(displayMessage: "Test")
        serviceUnderTest.restartCardPayment()
        XCTAssertEqual(serviceUnderTest.chargeCardState,
                       .cardDetails(amount: mockTransactionDetails.amountCurrency,
                                    encryptionKey: mockTransactionDetails.publicEncryptionKey))
    }

    func testInitialStateIsSetToCardDetailsInLiveMode() {
        let transactionDetails: VerifyAccessCode = .init(amount: 10000,
                                                         currency: "USD",
                                                         accessCode: "test_access",
                                                         paymentChannels: [], domain: .live,
                                                         merchantName: "Test Merchant",
                                                         publicEncryptionKey: "test_encryption_key",
                                                         reference: "test_reference")
        serviceUnderTest = ChargeCardViewModel(transactionDetails: transactionDetails,
                                               chargeContainer: mockChargeContainer,
                                               repository: mockRepository)
        XCTAssertEqual(serviceUnderTest.chargeCardState,
                       .cardDetails(amount: transactionDetails.amountCurrency,
                                    encryptionKey: transactionDetails.publicEncryptionKey))
    }

    func testInitialStateIsSetToTestModeCardSelectionInTestMode() {
        let transactionDetails: VerifyAccessCode = .init(amount: 10000,
                                                         currency: "USD",
                                                         accessCode: "test_access",
                                                         paymentChannels: [], domain: .test,
                                                         merchantName: "Test Merchant",
                                                         publicEncryptionKey: "test_encryption_key",
                                                         reference: "test_reference")
        serviceUnderTest = ChargeCardViewModel(transactionDetails: transactionDetails,
                                               chargeContainer: mockChargeContainer,
                                               repository: mockRepository)
        XCTAssertEqual(serviceUnderTest.chargeCardState,
                       .testModeCardSelection(amount: transactionDetails.amountCurrency,
                                              encryptionKey: transactionDetails.publicEncryptionKey))
    }

    func testInTestModeReturnsTrueIfDomainIsTest() {
        let transactionDetails: VerifyAccessCode = .init(amount: 10000,
                                                         currency: "USD",
                                                         accessCode: "test_access",
                                                         paymentChannels: [], domain: .test,
                                                         merchantName: "Test Merchant",
                                                         publicEncryptionKey: "test_encryption_key",
                                                         reference: "test_reference")
        serviceUnderTest = ChargeCardViewModel(transactionDetails: transactionDetails,
                                               chargeContainer: mockChargeContainer,
                                               repository: mockRepository)
        XCTAssertTrue(serviceUnderTest.inTestMode)
    }

    func testInTestModeReturnsFalseIfDomainIsLive() {
        let transactionDetails: VerifyAccessCode = .init(amount: 10000,
                                                         currency: "USD",
                                                         accessCode: "test_access",
                                                         paymentChannels: [], domain: .live,
                                                         merchantName: "Test Merchant",
                                                         publicEncryptionKey: "test_encryption_key",
                                                         reference: "test_reference")
        serviceUnderTest = ChargeCardViewModel(transactionDetails: transactionDetails,
                                               chargeContainer: mockChargeContainer,
                                               repository: mockRepository)
        XCTAssertFalse(serviceUnderTest.inTestMode)
    }

    func testSwitchToTestModeCardSelectionChangesState() {
        let transactionDetails: VerifyAccessCode = .init(amount: 10000,
                                                         currency: "USD",
                                                         accessCode: "test_access",
                                                         paymentChannels: [], domain: .live,
                                                         merchantName: "Test Merchant",
                                                         publicEncryptionKey: "test_encryption_key",
                                                         reference: "test_reference")
        serviceUnderTest.switchToTestModeCardSelection()
        XCTAssertEqual(serviceUnderTest.chargeCardState,
                       .testModeCardSelection(amount: transactionDetails.amountCurrency,
                                              encryptionKey: transactionDetails.publicEncryptionKey))
    }

    func testProcessResponseWithAddressStatusSetsStateToAddressAndFetchesAddreses() async {
        let expectedDisplayText = "Test Display Text"
        let addressResponse = ChargeCardTransaction(status: .sendAddress,
                                                    displayText: expectedDisplayText,
                                                    countryCode: "US")
        let mockStates = ["Test State A", "Test State B"]

        mockRepository.expectedAddressStates = mockStates

        await serviceUnderTest.processTransactionResponse(addressResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState, .address(states: mockStates,
                                                                  displayMessage: expectedDisplayText))
    }

    func testProcessResponseWithAddressStatusSetsStatusToFatalErrorIfCountryCodeIsNotPresent() async {
        let addressResponse = ChargeCardTransaction(status: .sendAddress)
        mockRepository.expectedAddressStates = ["Test State A", "Test State B"]

        await serviceUnderTest.processTransactionResponse(addressResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState, .fatalError(error: .generic))
    }

    func testProcessResponseWithAddressStatusSetsStatusToFatalErrorIfFetchingAddressStatesFails() async {
        let addressResponse = ChargeCardTransaction(status: .sendAddress)

        mockRepository.expectedErrorResponse = MockError.general

        await serviceUnderTest.processTransactionResponse(addressResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState, .fatalError(error: .generic))
    }

    func testProcessResponseWithBirthdayStatusSetsStateToBirthday() async {
        let expectedDisplayText = "Test Display Text"
        let birthdayResponse = ChargeCardTransaction(status: .sendBirthday,
                                                     displayText: expectedDisplayText)
        await serviceUnderTest.processTransactionResponse(birthdayResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState,
            .birthday(displayMessage: expectedDisplayText))
    }

    func testProcessResponseWithPhoneStatusSetsStateToPhone() async {
        let expectedDisplayText = "Test Display Text"
        let phoneResponse = ChargeCardTransaction(status: .sendPhone,
                                                  displayText: expectedDisplayText)
        await serviceUnderTest.processTransactionResponse(phoneResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState,
            .phoneNumber(displayMessage: expectedDisplayText))
    }

    func testProcessResponseWithOTPStatusSetsStateToOTP() async {
        let expectedDisplayText = "Test Display Text"
        let otpResponse = ChargeCardTransaction(status: .sendOtp, displayText: expectedDisplayText)
        await serviceUnderTest.processTransactionResponse(otpResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState,
            .otp(displayMessage: expectedDisplayText))
    }

    func testProcessResponseWithPinStatusSetsStateToPin() async {
        let pinResponse = ChargeCardTransaction(status: .sendPin)
        await serviceUnderTest.processTransactionResponse(pinResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState,
            .pin(encryptionKey: "test_encryption_key"))
    }

    func testProcessResponseWithSuccessStatusCallsChargeContainerToUpdateStatus() async {
        let successResponse = ChargeCardTransaction(status: .success)
        await serviceUnderTest.processTransactionResponse(successResponse)
        XCTAssertTrue(mockChargeContainer.transactionSuccessful)
    }

    func testProcessResponseWithFailureSetsStateToFailed() async {
        let expectedFailureMessage = "Declined"
        let failedResponse = ChargeCardTransaction(status: .failed, message: expectedFailureMessage)
        await serviceUnderTest.processTransactionResponse(failedResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState,
            .failed(displayMessage: expectedFailureMessage))
    }

    func testProcessResponseWithTimeoutSetsStateToFatalError() async {
        let expectedFailureMessage = "Timeout"
        let expectedError = ChargeError(message: expectedFailureMessage)
        let timeoutResponse = ChargeCardTransaction(status: .timeout, displayText: expectedFailureMessage)
        await serviceUnderTest.processTransactionResponse(timeoutResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState,
                       .fatalError(error: expectedError))
    }

    func testProcessValidResponseWithOpenUrlSetsStateToRedirect() async {
        let expectedTransactionId = 1234
        let expectedUrl = "redirect.url.com"
        let transactionDetails: VerifyAccessCode = .init(amount: 10000,
                                                         currency: "USD",
                                                         accessCode: "test_access",
                                                         paymentChannels: [], domain: .test,
                                                         merchantName: "Test Merchant",
                                                         publicEncryptionKey: "test_encryption_key",
                                                         reference: "test_reference",
                                                         transactionId: expectedTransactionId)

        serviceUnderTest.transactionDetails = transactionDetails
        let redirectResponse = ChargeCardTransaction(status: .openUrl,
                                                     url: expectedUrl)
        await serviceUnderTest.processTransactionResponse(redirectResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState,
                       .redirect(urlString: expectedUrl, transactionId: expectedTransactionId))
    }

    func testProcessResponseWithOpenUrlButMissingUrlInResponseSetsStateToFatalError() async {
        let expectedTransactionId = 1234
        let transactionDetails: VerifyAccessCode = .init(amount: 10000,
                                                         currency: "USD",
                                                         accessCode: "test_access",
                                                         paymentChannels: [], domain: .test,
                                                         merchantName: "Test Merchant",
                                                         publicEncryptionKey: "test_encryption_key",
                                                         reference: "test_reference",
                                                         transactionId: expectedTransactionId)

        serviceUnderTest.transactionDetails = transactionDetails
        let redirectResponse = ChargeCardTransaction(status: .openUrl)
        await serviceUnderTest.processTransactionResponse(redirectResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState,
                       .fatalError(error: .generic))
    }

    func testProcessResponseWithOpenUrlButMissingTransactionIdSetsStateToFatalError() async {
        let expectedUrl = "redirect.url.com"
        let transactionDetails: VerifyAccessCode = .init(amount: 10000,
                                                         currency: "USD",
                                                         accessCode: "test_access",
                                                         paymentChannels: [], domain: .test,
                                                         merchantName: "Test Merchant",
                                                         publicEncryptionKey: "test_encryption_key",
                                                         reference: "test_reference")

        serviceUnderTest.transactionDetails = transactionDetails
        let redirectResponse = ChargeCardTransaction(status: .openUrl,
                                                     url: expectedUrl)
        await serviceUnderTest.processTransactionResponse(redirectResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState,
                       .fatalError(error: .generic))
    }

    func testProcessResponseWithPendingUrlChecksPendingChargeStatusAndUpdatesWithTheNewStatus() async {
        let pendingResponse = ChargeCardTransaction(status: .pending)

        let expectedOTPDisplayText = "Test Display Text"
        let otpResponse = ChargeCardTransaction(status: .sendOtp, displayText: expectedOTPDisplayText)
        mockRepository.expectedChargeCardTransaction = otpResponse

        serviceUnderTest.checkPendingChargeDelay = 0
        await serviceUnderTest.processTransactionResponse(pendingResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState, .otp(displayMessage: expectedOTPDisplayText))
    }

    func testCallingDisplayTransactionErrorSetsStateToErrorStateWithTheAccompanyingError() async {
        let error = ChargeError(message: "Test")
        await serviceUnderTest.displayTransactionError(error)
        XCTAssertEqual(serviceUnderTest.chargeCardState, .error(error))
    }
}

extension ChargeCardState: Equatable {
    public static func == (lhs: ChargeCardState, rhs: ChargeCardState) -> Bool {
        switch (lhs, rhs) {
        case (.cardDetails(let first), .cardDetails(let second)):
            return first == second
        case (.testModeCardSelection(let first), testModeCardSelection(let second)):
            return first == second
        case (.pin, .pin):
            return true
        case (.phoneNumber(let first), .phoneNumber(let second)):
            return first == second
        case (.otp(let first), .otp(let second)):
            return first == second
        case (.address(let first), .address(let second)):
            return first == second
        case (.birthday(let first), .birthday(let second)):
            return first == second
        case (.error(let first), .error(let second)):
            return first == second
        case (.fatalError(let first), .fatalError(let second)):
            return first == second
        case (.failed(let first), .failed(let second)):
            return first == second
        case (.redirect(let first), .redirect(let second)):
            return first == second
        default:
            return false
        }
    }
}
