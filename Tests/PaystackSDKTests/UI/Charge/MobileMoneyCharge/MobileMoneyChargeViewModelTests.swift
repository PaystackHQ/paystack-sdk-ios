import XCTest
import PaystackCore
@testable import PaystackUI

final class MobileMoneyChargeViewModelTests: XCTestCase {

    var serviceUnderTest: MobileMoneyChargeViewModel!
    var mockChargeContainer: MockChargeContainer!
    var mockRepository: MockChargeMobileMoneyRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeContainer = MockChargeContainer()
        mockRepository = MockChargeMobileMoneyRepository()
        serviceUnderTest = MobileMoneyChargeViewModel(chargeCardContainer: mockChargeContainer,
                                                      transactionDetails: .example,
                                                      provider: .example,
                                                      repository: mockRepository)
    }

    // MARK: - Phone number validation

    func testIsValidReturnsTrueWhenPhoneMatchesProviderRegex() {
        // .example is MPESA: the regex requires +254 followed by 7xx or 11x.
        // 0703... formats to +254703... which satisfies the 7([0-2]\d|...) branch.
        serviceUnderTest.phoneNumber = "0703362111"
        XCTAssertTrue(serviceUnderTest.isValid)
    }

    func testIsValidReturnsFalseWhenFormattedPhoneFailsProviderRegex() {
        // Same provider (MPESA) but the formatted input (+254123456789) doesn't
        // match the regex (first digit after +254 must be 7 or 1-then-1).
        serviceUnderTest.phoneNumber = "0123456789"
        XCTAssertFalse(serviceUnderTest.isValid)
    }

    func testIsValidFallsBackToMinLengthWhenProviderHasNoRegex() {
        let providerWithoutRegex = MobileMoneyChannel(key: "UNKNOWN",
                                                      value: "Unknown",
                                                      isNew: false,
                                                      phoneNumberRegex: "")
        serviceUnderTest = MobileMoneyChargeViewModel(chargeCardContainer: mockChargeContainer,
                                                      transactionDetails: .example,
                                                      provider: providerWithoutRegex,
                                                      repository: mockRepository)
        serviceUnderTest.phoneNumber = "0123456789" // 10 digits — passes minLength
        XCTAssertTrue(serviceUnderTest.isValid)
    }

    func testIsValidFallsBackToMinLengthAndFailsForShortInput() {
        let providerWithoutRegex = MobileMoneyChannel(key: "UNKNOWN",
                                                      value: "Unknown",
                                                      isNew: false,
                                                      phoneNumberRegex: "")
        serviceUnderTest = MobileMoneyChargeViewModel(chargeCardContainer: mockChargeContainer,
                                                      transactionDetails: .example,
                                                      provider: providerWithoutRegex,
                                                      repository: mockRepository)
        serviceUnderTest.phoneNumber = "012345678" // 9 digits — fails minLength
        XCTAssertFalse(serviceUnderTest.isValid)
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
        serviceUnderTest = MobileMoneyChargeViewModel(chargeCardContainer: mockChargeContainer,
                                                      transactionDetails: transactionDetails,
                                                      provider: .example,
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

    func testSubmitPhoneNumberForwardsTheInjectedProviderKeyEvenWhenNotMPesa() async {
        let mtnProvider = MobileMoneyChannel(key: "MTN",
                                             value: "MTN",
                                             isNew: false,
                                             phoneNumberRegex: "")
        serviceUnderTest = MobileMoneyChargeViewModel(chargeCardContainer: mockChargeContainer,
                                                      transactionDetails: .example,
                                                      provider: mtnProvider,
                                                      repository: mockRepository)
        mockRepository.expectedMobileMoneyTransaction = .mPesaExample

        serviceUnderTest.phoneNumber = "0703362111"
        await serviceUnderTest.submitPhoneNumber()

        XCTAssertEqual(mockRepository.chargeMobileMoneySubmitted.provider, "MTN")
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

    func testRestartMobileMoneyPaymentResetsStateToCountdown() {
        serviceUnderTest.transactionState = .error(.generic)
        serviceUnderTest.restartMobileMoneyPayment()
        XCTAssertEqual(serviceUnderTest.transactionState, .countdown)
    }

    @MainActor
    func testUserTappedChangePaymentMethodRestartsChannelSelection() {
        serviceUnderTest.userTappedChangePaymentMethod()
        XCTAssertTrue(mockChargeContainer.channelSelectionRestarted)
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
