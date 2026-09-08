import XCTest
import PaystackCore
@testable import PaystackUI

final class CapitecPayViewModelTests: XCTestCase {

    var serviceUnderTest: CapitecPayViewModel!
    var mockChargeContainer: MockChargeContainer!
    var mockRepository: MockCapitecPayRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeContainer = MockChargeContainer()
        mockRepository = MockCapitecPayRepository()
        serviceUnderTest = CapitecPayViewModel(
            chargeContainer: mockChargeContainer,
            transactionDetails: .example,
            config: .example,
            repository: mockRepository)
    }

    override func tearDownWithError() throws {
        CapitecPayViewModel.requeryPollIntervalSeconds = 10
        CapitecPayViewModel.requeryMaxIterations = 18
        try super.tearDownWithError()
    }

    func testInitialStateIsIdentifierEntry() {
        XCTAssertEqual(serviceUnderTest.state, .identifierEntry)
        XCTAssertEqual(serviceUnderTest.identifier, .cellphone)
        XCTAssertEqual(serviceUnderTest.value, "")
    }

    func testIsValidWithValidCellphoneNumber() {
        serviceUnderTest.identifier = .cellphone
        serviceUnderTest.value = "0609603632"
        XCTAssertTrue(serviceUnderTest.isValid)
    }

    func testIsValidWithInvalidCellphoneNumber() {
        serviceUnderTest.identifier = .cellphone
        serviceUnderTest.value = "0509603632"
        XCTAssertFalse(serviceUnderTest.isValid)
    }

    func testIsValidWithValidSAIDNumber() {
        serviceUnderTest.identifier = .idNumber
        serviceUnderTest.value = "8001015009087"
        XCTAssertTrue(serviceUnderTest.isValid)
    }

    func testIsValidWithInvalidSAIDNumber() {
        serviceUnderTest.identifier = .idNumber
        serviceUnderTest.value = "1234567890123"
        XCTAssertFalse(serviceUnderTest.isValid)
    }

    func testIsValidWithNonEmptyAccountNumber() {
        serviceUnderTest.identifier = .accountNumber
        serviceUnderTest.value = "123456789"
        XCTAssertTrue(serviceUnderTest.isValid)
    }

    func testIsValidWithEmptyAccountNumber() {
        serviceUnderTest.identifier = .accountNumber
        serviceUnderTest.value = ""
        XCTAssertFalse(serviceUnderTest.isValid)
    }

    func testSubmitIdentifierWhenInvalidDoesNotCallRepository() async {
        serviceUnderTest.identifier = .cellphone
        serviceUnderTest.value = "invalid"

        await serviceUnderTest.submitIdentifier()

        XCTAssertEqual(mockRepository.authenticateCallCount, 0)
        XCTAssertEqual(serviceUnderTest.state, .identifierEntry)
    }

    func testSubmitIdentifierForwardsIdentifierAndValueToRepository() async {
        mockRepository.expectedDetails = .example
        serviceUnderTest.identifier = .cellphone
        serviceUnderTest.value = "0609603632"

        await serviceUnderTest.submitIdentifier()

        XCTAssertEqual(mockRepository.authenticateCallCount, 1)
        XCTAssertEqual(mockRepository.authenticateSubmitted.identifier, .cellphone)
        XCTAssertEqual(mockRepository.authenticateSubmitted.value, "0609603632")
        XCTAssertEqual(mockRepository.authenticateSubmitted.transactionId, 5900549926)
        XCTAssertEqual(mockRepository.authenticateSubmitted.publicEncryptionKey,
                       "test_encryption_key")
    }

    func testSubmitIdentifierOnSuccessTransitionsToAwaitingApproval() async {
        let expectedDetails = CapitecPayDetails.example
        mockRepository.expectedDetails = expectedDetails
        serviceUnderTest.identifier = .cellphone
        serviceUnderTest.value = "0609603632"

        await serviceUnderTest.submitIdentifier()

        if case .awaitingApproval(let details) = serviceUnderTest.state {
            XCTAssertEqual(details, expectedDetails)
        } else {
            XCTFail("Expected .awaitingApproval, got \(serviceUnderTest.state)")
        }
        XCTAssertEqual(serviceUnderTest.remainingSeconds, 120)
    }

    func testSubmitIdentifierOnErrorTransitionsToError() async {
        let expectedError = PaystackError.response(code: 500, message: "Boom")
        mockRepository.expectedErrorResponse = expectedError
        serviceUnderTest.identifier = .cellphone
        serviceUnderTest.value = "0609603632"

        await serviceUnderTest.submitIdentifier()

        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(error: expectedError)))
    }

    // MARK: - Terminal status handling

    @MainActor
    func testReactToPollResultWithSuccessRoutesToContainer() {
        let resolved = serviceUnderTest.reactToPollResult(
            ChargeCapitecTransaction(status: "success", message: "Charge successful"))

        XCTAssertTrue(resolved)
        XCTAssertTrue(mockChargeContainer.transactionSuccessful)
    }

    @MainActor
    func testReactToPollResultWithFailedTransitionsToErrorWithServerMessage() {
        let resolved = serviceUnderTest.reactToPollResult(
            ChargeCapitecTransaction(status: "failed", message: "Bank declined"))

        XCTAssertTrue(resolved)
        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(message: "Bank declined")))
    }

    @MainActor
    func testReactToPollResultWithFailedFallsBackToDefaultMessage() {
        let resolved = serviceUnderTest.reactToPollResult(
            ChargeCapitecTransaction(status: "failed", message: nil))

        XCTAssertTrue(resolved)
        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(message: CapitecPayViewModel.failedFallbackMessage)))
    }

    @MainActor
    func testReactToPollResultWithNonTerminalStatusDoesNotChangeState() {
        let stateBefore = serviceUnderTest.state

        let resolved = serviceUnderTest.reactToPollResult(
            ChargeCapitecTransaction(status: "pending", message: nil))

        XCTAssertFalse(resolved)
        XCTAssertEqual(serviceUnderTest.state, stateBefore)
    }

    /// A Pusher envelope with `status: true` and no `data` maps to an empty
    /// status — nothing terminal to act on, requery resolves it instead.
    @MainActor
    func testReactToPollResultWithEmptyStatusDoesNotChangeState() {
        let stateBefore = serviceUnderTest.state

        let resolved = serviceUnderTest.reactToPollResult(
            ChargeCapitecTransaction(status: "", message: "Charge pending"))

        XCTAssertFalse(resolved)
        XCTAssertEqual(serviceUnderTest.state, stateBefore)
    }

    func testUserTappedIveApprovedThePaymentFiresOneRequery() async {
        mockRepository.expectedRequeryResults = [
            ChargeCapitecTransaction(status: "pending", message: nil)
        ]

        await MainActor.run {
            serviceUnderTest.userTappedIveApprovedThePayment()
        }
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockRepository.requeryCallCount, 1)
        XCTAssertEqual(mockRepository.lastRequeryReference,
                       serviceUnderTest.transactionDetails.reference)
    }

    func testUserTappedIveApprovedWithSuccessRoutesToContainer() async {
        mockRepository.expectedRequeryResults = [
            ChargeCapitecTransaction(status: "success", message: nil)
        ]

        await MainActor.run {
            serviceUnderTest.userTappedIveApprovedThePayment()
        }
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockChargeContainer.transactionSuccessful)
    }

    @MainActor
    func testUserTappedChangePaymentMethodRestartsChannelSelection() {
        serviceUnderTest.userTappedChangePaymentMethod()
        XCTAssertTrue(mockChargeContainer.channelSelectionRestarted)
    }

    @MainActor
    func testDisplayTransactionErrorSetsStateToErrorWithGivenError() async {
        let error = ChargeError(message: "Something broke")
        await serviceUnderTest.displayTransactionError(error)
        XCTAssertEqual(serviceUnderTest.state, .error(error))
    }

    // MARK: - Pusher listen loop (PR CP-E)

    func testSubmitIdentifierStartsListenLoopOnReturnedChannel() async {
        mockRepository.expectedDetails = .example
        serviceUnderTest.identifier = .cellphone
        serviceUnderTest.value = "0609603632"

        await serviceUnderTest.submitIdentifier()
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertGreaterThanOrEqual(mockRepository.listenCallCount, 1)
        XCTAssertEqual(mockRepository.lastListenedChannel, "CAPITECPAY_5900549926")
    }

    func testListenResolvesOnSuccessAndRoutesToContainer() async {
        mockRepository.expectedDetails = .example
        mockRepository.expectedListenResponses = [
            ChargeCapitecTransaction(status: "success", message: nil)
        ]
        let expectation = expectation(description: "container receives success")
        mockChargeContainer.onProcessSuccessfulTransaction = { expectation.fulfill() }
        serviceUnderTest.identifier = .cellphone
        serviceUnderTest.value = "0609603632"

        await serviceUnderTest.submitIdentifier()
        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertTrue(mockChargeContainer.transactionSuccessful)
    }

    func testListenResolvesOnFailedStatusToErrorState() async {
        mockRepository.expectedDetails = .example
        mockRepository.expectedListenResponses = [
            ChargeCapitecTransaction(status: "failed", message: "Bank declined")
        ]
        serviceUnderTest.identifier = .cellphone
        serviceUnderTest.value = "0609603632"

        await serviceUnderTest.submitIdentifier()
        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(message: "Bank declined")))
    }

    // MARK: - Pusher failure degrades to requery polling

    func testListenFailureStartsRequeryPollingWithoutChangingState() async throws {
        mockRepository.expectedDetails = .example
        mockRepository.expectedListenError = MockError.stubNotProvided
        mockRepository.expectedRequeryResults = [
            ChargeCapitecTransaction(status: "pending", message: nil)
        ]
        CapitecPayViewModel.requeryPollIntervalSeconds = 1
        CapitecPayViewModel.requeryMaxIterations = 5
        serviceUnderTest.identifier = .cellphone
        serviceUnderTest.value = "0609603632"

        await serviceUnderTest.submitIdentifier()
        try await Task.sleep(nanoseconds: 1_600_000_000)

        XCTAssertGreaterThanOrEqual(mockRepository.requeryCallCount, 1)
        // The customer keeps the countdown + in-app approval steps on screen.
        if case .awaitingApproval = serviceUnderTest.state {
            // ok
        } else {
            XCTFail("Expected .awaitingApproval, got \(serviceUnderTest.state)")
        }
    }

    func testListenFailureFallbackRequeryResolvesSuccess() async throws {
        mockRepository.expectedDetails = .example
        mockRepository.expectedListenError = MockError.stubNotProvided
        mockRepository.expectedRequeryResults = [
            ChargeCapitecTransaction(status: "success", message: nil)
        ]
        CapitecPayViewModel.requeryPollIntervalSeconds = 1
        CapitecPayViewModel.requeryMaxIterations = 5
        let expectation = expectation(description: "container receives success")
        mockChargeContainer.onProcessSuccessfulTransaction = { expectation.fulfill() }
        serviceUnderTest.identifier = .cellphone
        serviceUnderTest.value = "0609603632"

        await serviceUnderTest.submitIdentifier()
        await fulfillment(of: [expectation], timeout: 3.0)

        XCTAssertTrue(mockChargeContainer.transactionSuccessful)
    }

    /// The countdown expiring must not start a second, overlapping loop on top
    /// of the one the Pusher fallback already started.
    func testFallbackAndCountdownDoNotStartOverlappingRequeryLoops() async throws {
        mockRepository.expectedDetails = CapitecPayDetails(
            timeToLive: 1,
            expiryDate: Date().addingTimeInterval(1),
            pusherChannel: "CAPITECPAY_5900549926")
        mockRepository.expectedListenError = MockError.stubNotProvided
        mockRepository.expectedRequeryResults = [
            ChargeCapitecTransaction(status: "pending", message: nil),
            ChargeCapitecTransaction(status: "pending", message: nil),
            ChargeCapitecTransaction(status: "pending", message: nil)
        ]
        CapitecPayViewModel.requeryPollIntervalSeconds = 1
        CapitecPayViewModel.requeryMaxIterations = 5
        serviceUnderTest.identifier = .cellphone
        serviceUnderTest.value = "0609603632"

        await serviceUnderTest.submitIdentifier()
        try await Task.sleep(nanoseconds: 2_600_000_000)

        // One loop at ~1s intervals over ~2.6s — two or three polls, not double.
        XCTAssertLessThanOrEqual(mockRepository.requeryCallCount, 3)
        XCTAssertGreaterThanOrEqual(mockRepository.requeryCallCount, 1)
    }

    // MARK: - Countdown + requery loop (PR CP-E / CP-F)

    func testCountdownExpiryTransitionsToRequerying() async throws {
        mockRepository.expectedDetails = CapitecPayDetails(
            timeToLive: 1,
            expiryDate: Date().addingTimeInterval(1),
            pusherChannel: "CAPITECPAY_5900549926")
        // Non-terminal Pusher event: resolves the single-shot listener without
        // erroring, so the countdown — not the failure fallback — is what
        // starts the requery loop here.
        mockRepository.expectedListenResponses = [
            ChargeCapitecTransaction(status: "pending", message: nil)
        ]
        CapitecPayViewModel.requeryPollIntervalSeconds = 100
        CapitecPayViewModel.requeryMaxIterations = 5
        serviceUnderTest.identifier = .cellphone
        serviceUnderTest.value = "0609603632"

        await serviceUnderTest.submitIdentifier()
        try await Task.sleep(nanoseconds: 1_400_000_000)

        if case .requerying = serviceUnderTest.state {
            // ok
        } else {
            XCTFail("Expected .requerying, got \(serviceUnderTest.state)")
        }
    }

    func testRequeryLoopResolvesOnSuccess() async throws {
        mockRepository.expectedDetails = CapitecPayDetails(
            timeToLive: 1,
            expiryDate: Date().addingTimeInterval(1),
            pusherChannel: "CAPITECPAY_5900549926")
        mockRepository.expectedListenResponses = [
            ChargeCapitecTransaction(status: "pending", message: nil)
        ]
        mockRepository.expectedRequeryResults = [
            ChargeCapitecTransaction(status: "success", message: nil)
        ]
        CapitecPayViewModel.requeryPollIntervalSeconds = 1
        CapitecPayViewModel.requeryMaxIterations = 5
        serviceUnderTest.identifier = .cellphone
        serviceUnderTest.value = "0609603632"

        await serviceUnderTest.submitIdentifier()
        try await Task.sleep(nanoseconds: 2_500_000_000)

        XCTAssertTrue(mockChargeContainer.transactionSuccessful)
    }

    func testRequeryLoopResolvesOnFailed() async throws {
        mockRepository.expectedDetails = CapitecPayDetails(
            timeToLive: 1,
            expiryDate: Date().addingTimeInterval(1),
            pusherChannel: "CAPITECPAY_5900549926")
        mockRepository.expectedListenResponses = [
            ChargeCapitecTransaction(status: "pending", message: nil)
        ]
        mockRepository.expectedRequeryResults = [
            ChargeCapitecTransaction(status: "failed", message: "Bank declined")
        ]
        CapitecPayViewModel.requeryPollIntervalSeconds = 1
        CapitecPayViewModel.requeryMaxIterations = 5
        serviceUnderTest.identifier = .cellphone
        serviceUnderTest.value = "0609603632"

        await serviceUnderTest.submitIdentifier()
        try await Task.sleep(nanoseconds: 2_500_000_000)

        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(message: "Bank declined")))
    }

    func testRequeryLoopTransitionsToFatalErrorAfterMaxIterations() async throws {
        mockRepository.expectedDetails = CapitecPayDetails(
            timeToLive: 1,
            expiryDate: Date().addingTimeInterval(1),
            pusherChannel: "CAPITECPAY_5900549926")
        mockRepository.expectedListenResponses = [
            ChargeCapitecTransaction(status: "pending", message: nil)
        ]
        mockRepository.expectedRequeryResults = [
            ChargeCapitecTransaction(status: "pending", message: nil),
            ChargeCapitecTransaction(status: "pending", message: nil)
        ]
        CapitecPayViewModel.requeryPollIntervalSeconds = 1
        CapitecPayViewModel.requeryMaxIterations = 2
        serviceUnderTest.identifier = .cellphone
        serviceUnderTest.value = "0609603632"

        await serviceUnderTest.submitIdentifier()
        try await Task.sleep(nanoseconds: 4_000_000_000)

        if case .fatalError(let error) = serviceUnderTest.state {
            XCTAssertEqual(error.message, CapitecPayViewModel.failedFallbackMessage)
        } else {
            XCTFail("Expected .fatalError, got \(serviceUnderTest.state)")
        }
    }
}

private extension CapitecPayConfig {
    static let example = CapitecPayConfig(
        transactionId: 5900549926,
        transactionReference: "T_ref_5900549926",
        publicEncryptionKey: "test_encryption_key")
}
