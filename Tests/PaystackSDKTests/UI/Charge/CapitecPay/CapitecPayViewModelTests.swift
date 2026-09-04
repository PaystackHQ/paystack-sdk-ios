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

    func testProcessTransactionUpdateWithSuccessRoutesToContainer() async {
        await serviceUnderTest.processTransactionUpdate(
            ChargeCardTransaction(status: .success))
        XCTAssertTrue(mockChargeContainer.transactionSuccessful)
    }

    func testProcessTransactionUpdateWithFailedTransitionsToError() async {
        await serviceUnderTest.processTransactionUpdate(
            ChargeCardTransaction(status: .failed, message: "Bank declined"))

        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(message: "Bank declined")))
    }

    func testProcessTransactionUpdateWithFailedFallsBackToDefaultMessage() async {
        await serviceUnderTest.processTransactionUpdate(
            ChargeCardTransaction(status: .failed))

        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(message: CapitecPayViewModel.failedFallbackMessage)))
    }

    func testProcessTransactionUpdateWithNonTerminalStatusDoesNotChangeState() async {
        let stateBefore = serviceUnderTest.state
        await serviceUnderTest.processTransactionUpdate(
            ChargeCardTransaction(status: .pending))
        XCTAssertEqual(serviceUnderTest.state, stateBefore)
    }

    func testUserTappedIveApprovedThePaymentFiresOneRequery() async {
        mockRepository.expectedRequeryResults = [
            ChargeCardTransaction(status: .pending)
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
            ChargeCardTransaction(status: .success)
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
            ChargeCardTransaction(status: .success)
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
            ChargeCardTransaction(status: .failed, message: "Bank declined")
        ]
        serviceUnderTest.identifier = .cellphone
        serviceUnderTest.value = "0609603632"

        await serviceUnderTest.submitIdentifier()
        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(message: "Bank declined")))
    }

    // MARK: - Countdown + requery loop (PR CP-E / CP-F)

    func testCountdownExpiryTransitionsToRequerying() async throws {
        mockRepository.expectedDetails = CapitecPayDetails(
            timeToLive: 1,
            expiryDate: Date().addingTimeInterval(1),
            pusherChannel: "CAPITECPAY_5900549926")
        CapitecPayViewModel.requeryPollIntervalSeconds = 100
        CapitecPayViewModel.requeryMaxIterations = 0
        serviceUnderTest.identifier = .cellphone
        serviceUnderTest.value = "0609603632"

        await serviceUnderTest.submitIdentifier()
        try await Task.sleep(nanoseconds: 1_400_000_000)

        if case .requerying = serviceUnderTest.state {
            // ok
        } else if case .fatalError = serviceUnderTest.state {
            // ok — 0 iterations tips immediately to fatal, still confirms
            // the requerying-loop path fired.
        } else {
            XCTFail("Expected .requerying or .fatalError, got \(serviceUnderTest.state)")
        }
    }

    func testRequeryLoopResolvesOnSuccess() async throws {
        mockRepository.expectedDetails = CapitecPayDetails(
            timeToLive: 1,
            expiryDate: Date().addingTimeInterval(1),
            pusherChannel: "CAPITECPAY_5900549926")
        mockRepository.expectedRequeryResults = [
            ChargeCardTransaction(status: .success)
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
        mockRepository.expectedRequeryResults = [
            ChargeCardTransaction(status: .failed, displayText: nil, message: "Bank declined")
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
        mockRepository.expectedRequeryResults = [
            ChargeCardTransaction(status: .pending),
            ChargeCardTransaction(status: .pending)
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
