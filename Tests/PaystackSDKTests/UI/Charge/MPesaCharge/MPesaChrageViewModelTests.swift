import XCTest
import PaystackCore
@testable import PaystackUI

final class MPesaChrageViewModelTests: XCTestCase {

    var serviceUnderTest: MPesaChrageViewModel!
    var mockChargeContainer: MockChargeContainer!
    var mockRepository: MockChargeMobileMoneyRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeContainer = MockChargeContainer()
        mockRepository = MockChargeMobileMoneyRepository()
        serviceUnderTest = MPesaChrageViewModel(chargeCardContainer: mockChargeContainer,
                                                transactionDetails: .example,
                                                repository: mockRepository)
    }

    // MARK: - Phone number validation

    func testIsValidReturnsFalseWhenPhoneNumberIsLessThanTenDigits() {
        serviceUnderTest.phoneNumber = "012345678"
        XCTAssertFalse(serviceUnderTest.isValid)
    }

    func testIsValidReturnsTrueWhenPhoneNumberIsAtLeastTenDigits() {
        serviceUnderTest.phoneNumber = "0123456789"
        XCTAssertTrue(serviceUnderTest.isValid)
    }

    // MARK: - Initial state

    func testInitialStateIsCountdown() {
        XCTAssertEqual(serviceUnderTest.transactionState, .countdown)
    }

    // MARK: - submitPhoneNumber

    func testSubmitPhoneNumberForwardsPhoneTransactionIdAndProviderToRepository() async {
        let expectedTransactionId = 987
        let transactionDetails = VerifyAccessCode(amount: 10000,
                                                  currency: "USD",
                                                  accessCode: "test_access",
                                                  paymentChannels: [.mobileMoney],
                                                  domain: .live,
                                                  merchantName: "Test Merchant",
                                                  publicEncryptionKey: "test_encryption_key",
                                                  reference: "test_reference",
                                                  transactionId: expectedTransactionId,
                                                  channelOptions: .example)
        serviceUnderTest = MPesaChrageViewModel(chargeCardContainer: mockChargeContainer,
                                                transactionDetails: transactionDetails,
                                                repository: mockRepository)
        mockRepository.expectedMobileMoneyTransaction = .mPesaExample

        serviceUnderTest.phoneNumber = "0703362111"
        await serviceUnderTest.submitPhoneNumber()

        XCTAssertEqual(mockRepository.chargeMobileMoneySubmitted.phone, "+254703362111")
        XCTAssertEqual(mockRepository.chargeMobileMoneySubmitted.transactionId, "\(expectedTransactionId)")
        XCTAssertEqual(mockRepository.chargeMobileMoneySubmitted.provider, "MPESA")
    }

    func testSubmitPhoneNumberForwardsFormattedPhoneWhenStartsWith254() async {
        mockRepository.expectedMobileMoneyTransaction = .mPesaExample

        serviceUnderTest.phoneNumber = "254703362111"
        await serviceUnderTest.submitPhoneNumber()

        XCTAssertEqual(mockRepository.chargeMobileMoneySubmitted.phone, "+254703362111")
    }

    func testSubmitPhoneNumberForwardsPhoneUnchangedWhenAlreadyStartsWithPlus254() async {
        mockRepository.expectedMobileMoneyTransaction = .mPesaExample

        serviceUnderTest.phoneNumber = "+254703362111"
        await serviceUnderTest.submitPhoneNumber()

        XCTAssertEqual(mockRepository.chargeMobileMoneySubmitted.phone, "+254703362111")
    }

    func testSubmitPhoneNumberWithMissingTransactionIdDefaultsToZero() async {
        mockRepository.expectedMobileMoneyTransaction = .mPesaExample

        serviceUnderTest.phoneNumber = "0703362111"
        await serviceUnderTest.submitPhoneNumber()

        XCTAssertEqual(mockRepository.chargeMobileMoneySubmitted.transactionId, "0")
    }

    func testSubmitPhoneNumberWithMissingChannelOptionsDefaultsToEmptyProvider() async {
        let transactionDetails = VerifyAccessCode(amount: 10000,
                                                  currency: "USD",
                                                  accessCode: "test_access",
                                                  paymentChannels: [.mobileMoney],
                                                  domain: .live,
                                                  merchantName: "Test Merchant",
                                                  publicEncryptionKey: "test_encryption_key",
                                                  reference: "test_reference",
                                                  transactionId: 1,
                                                  channelOptions: nil)
        serviceUnderTest = MPesaChrageViewModel(chargeCardContainer: mockChargeContainer,
                                                transactionDetails: transactionDetails,
                                                repository: mockRepository)
        mockRepository.expectedMobileMoneyTransaction = .mPesaExample

        serviceUnderTest.phoneNumber = "0703362111"
        await serviceUnderTest.submitPhoneNumber()

        XCTAssertEqual(mockRepository.chargeMobileMoneySubmitted.provider, "")
    }

    func testSubmitPhoneNumberOnSuccessSetsStateToProcessTransaction() async {
        let expectedTransaction = MobileMoneyTransaction.mPesaExample
        mockRepository.expectedMobileMoneyTransaction = expectedTransaction

        serviceUnderTest.phoneNumber = "0703362111"
        await serviceUnderTest.submitPhoneNumber()

        XCTAssertEqual(serviceUnderTest.transactionState,
                       .processTransaction(transaction: expectedTransaction))
    }

    func testSubmitPhoneNumberOnErrorSetsStateToErrorWithMessage() async {
        let expectedErrorMessage = "Network failed"
        let expectedError: PaystackError = .response(code: 400, message: expectedErrorMessage)
        mockRepository.expectedErrorResponse = expectedError

        serviceUnderTest.phoneNumber = "0703362111"
        await serviceUnderTest.submitPhoneNumber()

        XCTAssertEqual(serviceUnderTest.transactionState,
                       .error(ChargeError(message: expectedErrorMessage)))
    }

    // MARK: - processTransactionResponse

    func testProcessResponseWithSuccessCallsContainerProcessSuccessfulTransaction() async {
        let response = ChargeCardTransaction(status: .success)
        await serviceUnderTest.processTransactionResponse(response)
        XCTAssertTrue(mockChargeContainer.transactionSuccessful)
    }

    func testProcessResponseWithFailedUsesMessageWhenProvided() async {
        let response = ChargeCardTransaction(status: .failed, message: "Insufficient funds")
        await serviceUnderTest.processTransactionResponse(response)
        XCTAssertEqual(serviceUnderTest.transactionState,
                       .error(ChargeError(message: "Insufficient funds")))
    }

    func testProcessResponseWithFailedUsesDisplayTextWhenMessageMissing() async {
        let response = ChargeCardTransaction(status: .failed, displayText: "Declined by provider")
        await serviceUnderTest.processTransactionResponse(response)
        XCTAssertEqual(serviceUnderTest.transactionState,
                       .error(ChargeError(message: "Declined by provider")))
    }

    func testProcessResponseWithFailedAndNoMessageOrDisplayTextDefaultsToDeclined() async {
        let response = ChargeCardTransaction(status: .failed)
        await serviceUnderTest.processTransactionResponse(response)
        XCTAssertEqual(serviceUnderTest.transactionState,
                       .error(ChargeError(message: "Declined")))
    }

    func testProcessResponseWithTimeoutUsesDisplayTextWhenProvided() async {
        let response = ChargeCardTransaction(status: .timeout, displayText: "Timed out on provider side")
        await serviceUnderTest.processTransactionResponse(response)
        XCTAssertEqual(serviceUnderTest.transactionState,
                       .fatalError(error: ChargeError(message: "Timed out on provider side")))
    }

    func testProcessResponseWithTimeoutAndNoDisplayTextDefaultsToPaymentTimedOut() async {
        let response = ChargeCardTransaction(status: .timeout)
        await serviceUnderTest.processTransactionResponse(response)
        XCTAssertEqual(serviceUnderTest.transactionState,
                       .fatalError(error: ChargeError(message: "Payment timed out")))
    }

    func testProcessResponseWithPendingDoesNotChangeState() async {
        serviceUnderTest.transactionState = .countdown
        let response = ChargeCardTransaction(status: .pending)
        await serviceUnderTest.processTransactionResponse(response)
        XCTAssertEqual(serviceUnderTest.transactionState, .countdown)
    }

    func testProcessResponseWithUnexpectedStatusSetsStateToFatalError() async {
        let response = ChargeCardTransaction(status: .sendPin)
        await serviceUnderTest.processTransactionResponse(response)
        XCTAssertEqual(serviceUnderTest.transactionState,
                       .fatalError(error: .generic))
    }

    // MARK: - displayTransactionError, restart, cancel

    func testDisplayTransactionErrorSetsStateToErrorWithTheGivenError() async {
        let error = ChargeError(message: "Something broke")
        await serviceUnderTest.displayTransactionError(error)
        XCTAssertEqual(serviceUnderTest.transactionState, .error(error))
    }

    func testRestartMPesaPaymentResetsStateToCountdown() {
        serviceUnderTest.transactionState = .error(.generic)
        serviceUnderTest.restartMPesaPayment()
        XCTAssertEqual(serviceUnderTest.transactionState, .countdown)
    }

    func testCancelTransactionRestartsPayment() {
        serviceUnderTest.transactionState = .error(.generic)
        serviceUnderTest.cancelTransaction()
        XCTAssertEqual(serviceUnderTest.transactionState, .countdown)
    }
}

// MARK: - Equatable conformance for state assertions

extension ChargeMobileMoneyState: Equatable {
    public static func == (lhs: ChargeMobileMoneyState, rhs: ChargeMobileMoneyState) -> Bool {
        switch (lhs, rhs) {
        case (.loading(let first), .loading(let second)):
            return first == second
        case (.countdown, .countdown):
            return true
        case (.error(let first), .error(let second)):
            return first == second
        case (.fatalError(let first), .fatalError(let second)):
            return first == second
        case (.processTransaction(let first), .processTransaction(let second)):
            return first == second
        default:
            return false
        }
    }
}

private extension MobileMoneyTransaction {
    static var mPesaExample: MobileMoneyTransaction {
        MobileMoneyTransaction(transaction: "1504248187",
                               phone: "0703362111",
                               provider: "MPESA",
                               channelName: "MOBILE_MONEY_1504248187",
                               timer: 60,
                               message: "Authorize on your device")
    }
}
