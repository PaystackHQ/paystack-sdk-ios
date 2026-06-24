import XCTest
import PaystackCore
@testable import PaystackUI

final class ZapViewModelTests: XCTestCase {

    var serviceUnderTest: ZapViewModel!
    var mockChargeContainer: MockChargeContainer!
    var mockRepository: MockZapRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeContainer = MockChargeContainer()
        mockRepository = MockZapRepository()
        // Stub the countdown short so tests don't wait — individual
        // tests that exercise the countdown override this.
        ZapViewModel.mandateWindowSeconds = 0
        serviceUnderTest = ZapViewModel(
            chargeContainer: mockChargeContainer,
            transactionDetails: .example,
            config: .example,
            repository: mockRepository)
    }

    override func tearDownWithError() throws {
        ZapViewModel.mandateWindowSeconds = 5 * 60
        try super.tearDownWithError()
    }

    // MARK: - Initial state

    func testInitialStateIsLoading() {
        XCTAssertEqual(serviceUnderTest.state, .loading())
    }

    // MARK: - initiateMandate

    func testInitiateMandateOnSuccessSetsStateToAwaitingPayment() async {
        mockRepository.expectedMandateResponse = .example

        await serviceUnderTest.initiateMandate()

        if case .awaitingPayment(let details) = serviceUnderTest.state {
            XCTAssertEqual(details.pusherChannel, "DBMAN_6222375579")
        } else {
            XCTFail("Expected .awaitingPayment, got \(serviceUnderTest.state)")
        }
    }

    func testInitiateMandateForwardsConfigFieldsToRepository() async {
        mockRepository.expectedMandateResponse = .example

        await serviceUnderTest.initiateMandate()

        XCTAssertEqual(mockRepository.initiateZapMandateCallCount, 1)
        XCTAssertEqual(mockRepository.initiateZapMandateSubmitted.supportedBankId, 870)
        XCTAssertEqual(mockRepository.initiateZapMandateSubmitted.transactionId, 6222375579)
        XCTAssertEqual(mockRepository.initiateZapMandateSubmitted.walletEmail,
                       "customer@example.com")
    }

    func testInitiateMandateOnApiErrorSetsStateToError() async {
        let expectedError = PaystackError.response(code: 500, message: "Boom")
        mockRepository.expectedErrorResponse = expectedError

        await serviceUnderTest.initiateMandate()

        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(error: expectedError)))
    }

    func testInitiateMandateWithMalformedUrlsSetsStateToError() async {
        // QR / payment URLs that don't parse into a `URL` instance
        // surface as the SDK's generic error path.
        mockRepository.expectedMandateResponse = ZapMandateResponse(
            status: "pending",
            message: "OK",
            pusherChannel: "DBMAN_test",
            paymentUrl: "",
            qrImage: "")

        await serviceUnderTest.initiateMandate()

        if case .error(let error) = serviceUnderTest.state {
            XCTAssertTrue(error.message.contains("malformed")
                          || error.message.contains("URLs"))
        } else {
            XCTFail("Expected .error, got \(serviceUnderTest.state)")
        }
    }

    func testInitiateMandateSetsLoadingStateBeforeAwaitingPayment() async {
        mockRepository.expectedMandateResponse = .example

        XCTAssertEqual(serviceUnderTest.state, .loading())

        await serviceUnderTest.initiateMandate()

        if case .awaitingPayment = serviceUnderTest.state {
            // ok
        } else {
            XCTFail("Expected .awaitingPayment, got \(serviceUnderTest.state)")
        }
    }

    // MARK: - Countdown + sessionExpired

    func testRemainingSecondsInitialisesToMandateWindow() {
        ZapViewModel.mandateWindowSeconds = 300
        let vm = ZapViewModel(chargeContainer: mockChargeContainer,
                              transactionDetails: .example,
                              config: .example,
                              repository: mockRepository)
        XCTAssertEqual(vm.remainingSeconds, 300)
    }

    func testCountdownTicksRemainingSecondsDown() async throws {
        ZapViewModel.mandateWindowSeconds = 5
        serviceUnderTest = ZapViewModel(chargeContainer: mockChargeContainer,
                                        transactionDetails: .example,
                                        config: .example,
                                        repository: mockRepository)
        mockRepository.expectedMandateResponse = .example
        await serviceUnderTest.initiateMandate()

        try await Task.sleep(nanoseconds: 1_300_000_000)

        XCTAssertLessThanOrEqual(serviceUnderTest.remainingSeconds, 4)
        XCTAssertGreaterThanOrEqual(serviceUnderTest.remainingSeconds, 3)
    }

    func testCountdownExpiryTransitionsToSessionExpired() async throws {
        ZapViewModel.mandateWindowSeconds = 1
        serviceUnderTest = ZapViewModel(chargeContainer: mockChargeContainer,
                                        transactionDetails: .example,
                                        config: .example,
                                        repository: mockRepository)
        mockRepository.expectedMandateResponse = .example
        await serviceUnderTest.initiateMandate()

        try await Task.sleep(nanoseconds: 1_400_000_000)

        XCTAssertEqual(serviceUnderTest.state, .sessionExpired)
    }

    func testRetryAfterExpiryReprovisionsMandateAndResetsCountdown() async {
        ZapViewModel.mandateWindowSeconds = 60
        serviceUnderTest = ZapViewModel(chargeContainer: mockChargeContainer,
                                        transactionDetails: .example,
                                        config: .example,
                                        repository: mockRepository)
        // Force state into sessionExpired without waiting.
        serviceUnderTest.state = .sessionExpired
        mockRepository.expectedMandateResponse = .example

        await serviceUnderTest.retryAfterExpiry()

        XCTAssertEqual(mockRepository.initiateZapMandateCallCount, 1)
        if case .awaitingPayment = serviceUnderTest.state {
            // ok
        } else {
            XCTFail("Expected .awaitingPayment after retry, got \(serviceUnderTest.state)")
        }
        XCTAssertGreaterThan(serviceUnderTest.remainingSeconds, 50)
    }

    // MARK: - User actions

    @MainActor
    func testUserTappedChangePaymentMethodCallsRestartFromChannelSelection() {
        serviceUnderTest.userTappedChangePaymentMethod()
        XCTAssertTrue(mockChargeContainer.channelSelectionRestarted)
    }

    // MARK: - displayTransactionError

    func testDisplayTransactionErrorSetsStateToErrorWithGivenError() async {
        let error = ChargeError(message: "Something broke")
        await serviceUnderTest.displayTransactionError(error)
        XCTAssertEqual(serviceUnderTest.state, .error(error))
    }

    // MARK: - processTransactionUpdate — success + failed are the only
    // statuses Zap emits ; everything else is logged + state unchanged.

    func testProcessUpdateWithSuccessCallsContainerProcessSuccessfulTransaction() async {
        await serviceUnderTest.processTransactionUpdate(
            .init(status: .success, message: nil, reference: nil, transactionId: nil))
        XCTAssertTrue(mockChargeContainer.transactionSuccessful)
    }

    func testProcessUpdateWithFailedSetsStateToErrorWithApiMessage() async {
        mockRepository.expectedMandateResponse = .example
        await serviceUnderTest.initiateMandate()

        await serviceUnderTest.processTransactionUpdate(
            .init(status: .failed,
                  message: "Bank declined",
                  reference: nil, transactionId: nil))

        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(message: "Bank declined")))
    }

    func testProcessUpdateWithFailedFallsBackToDefaultMessageWhenNil() async {
        await serviceUnderTest.processTransactionUpdate(
            .init(status: .failed, message: nil,
                  reference: nil, transactionId: nil))

        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(message: ZapViewModel.failedFallbackMessage)))
    }

    /// Zap doesn't emit any of the PWT-shared status cases beyond
    /// `success` / `failed` ; if one ever arrives (forward compat with
    /// shared types) the SDK logs + leaves state unchanged. Regression
    /// guard against accidentally wiring a state change for these cases
    /// in the future.
    func testProcessUpdateWithUnexpectedStatusesDoesNotChangeState() async {
        let unexpectedStatuses: [BankTransferStatus] = [
            .creditRequestPending,
            .creditRequestReceived,
            .creditRequestRejected,
            .incorrectAmountSent,
            .pending,
            .requery,
            .unknown("brand-new")
        ]
        mockRepository.expectedMandateResponse = .example
        await serviceUnderTest.initiateMandate()

        let stateBefore = serviceUnderTest.state

        for status in unexpectedStatuses {
            await serviceUnderTest.processTransactionUpdate(
                .init(status: status, message: nil,
                      reference: nil, transactionId: nil))
            XCTAssertEqual(serviceUnderTest.state, stateBefore,
                           "Status \(status) unexpectedly changed state")
        }
    }

    // MARK: - Listen loop

    func testProvisioningStartsListenLoopOnReturnedChannel() async {
        mockRepository.expectedMandateResponse = .example

        await serviceUnderTest.initiateMandate()
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertGreaterThanOrEqual(mockRepository.listenForZapResponseCallCount, 1)
        XCTAssertEqual(mockRepository.lastListenedChannel, "DBMAN_6222375579")
    }

    func testListenLoopExitsOnSuccessAndRoutesToContainer() async {
        mockRepository.expectedMandateResponse = .example
        mockRepository.expectedListenForZapResponses = [
            .init(status: .success, message: nil,
                  reference: nil, transactionId: nil)
        ]

        let expectation = expectation(description: "container receives success")
        mockChargeContainer.onProcessSuccessfulTransaction = { expectation.fulfill() }

        await serviceUnderTest.initiateMandate()
        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertEqual(mockRepository.listenForZapResponseCallCount, 1)
        XCTAssertTrue(mockChargeContainer.transactionSuccessful)
    }

    func testListenLoopExitsOnFailedStatusToErrorState() async {
        mockRepository.expectedMandateResponse = .example
        mockRepository.expectedListenForZapResponses = [
            .init(status: .failed, message: "Bank declined",
                  reference: nil, transactionId: nil)
        ]

        await serviceUnderTest.initiateMandate()
        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(mockRepository.listenForZapResponseCallCount, 1)
        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(message: "Bank declined")))
    }

    func testListenLoopExitsOnRepositoryErrorWithoutCrashing() async {
        mockRepository.expectedMandateResponse = .example
        mockRepository.expectedListenForZapError = PaystackError.technical

        await serviceUnderTest.initiateMandate()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // State stays at awaitingPayment — listen loop died but
        // initiateMandate still set us up correctly.
        if case .awaitingPayment = serviceUnderTest.state {
            // ok
        } else {
            XCTFail("Expected .awaitingPayment, got \(serviceUnderTest.state)")
        }
    }
}

// MARK: - Fixtures

private extension ZapConfig {
    static let example = ZapConfig(supportedBankId: 870,
                                   transactionId: 6222375579,
                                   walletEmail: "customer@example.com")
}

private extension ZapMandateResponse {
    static let example = ZapMandateResponse(
        status: "pending",
        message: "Transaction Initiated",
        pusherChannel: "DBMAN_6222375579",
        paymentUrl: "https://joinzap.com/app/merchant-payment/f3k3t3c88ovR6P7CDkKu",
        qrImage: "https://example.com/qr.png")
}
