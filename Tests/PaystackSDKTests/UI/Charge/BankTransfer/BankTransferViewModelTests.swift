import XCTest
import PaystackCore
@testable import PaystackUI

final class BankTransferViewModelTests: XCTestCase {

    var serviceUnderTest: BankTransferViewModel!
    var mockChargeContainer: MockChargeContainer!
    var mockRepository: MockBankTransferRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeContainer = MockChargeContainer()
        mockRepository = MockBankTransferRepository()
        serviceUnderTest = BankTransferViewModel(
            chargeContainer: mockChargeContainer,
            transactionDetails: .example,
            config: .example,
            repository: mockRepository)
    }

    // MARK: - Provisioning

    func testInitialStateIsLoading() {
        XCTAssertEqual(serviceUnderTest.state, .loading())
    }

    func testProvisionVirtualAccountOnSuccessSetsStateToAwaitingPayment() async {
        let expectedDetails: BankTransferDetails = .example
        mockRepository.expectedBankTransferDetails = expectedDetails

        await serviceUnderTest.provisionVirtualAccount()

        XCTAssertEqual(serviceUnderTest.state, .awaitingPayment(expectedDetails))
    }

    func testProvisionVirtualAccountForwardsConfigFieldsToRepository() async {
        let config = BankTransferConfig(
            fulfilLateNotification: true,
            transactionId: 999,
            availableProviders: ["wema-bank"])
        serviceUnderTest = BankTransferViewModel(
            chargeContainer: mockChargeContainer,
            transactionDetails: .example,
            config: config,
            repository: mockRepository)
        mockRepository.expectedBankTransferDetails = .example

        await serviceUnderTest.provisionVirtualAccount()

        XCTAssertEqual(mockRepository.payWithTransferSubmitted.fulfilLateNotification, true)
        XCTAssertEqual(mockRepository.payWithTransferSubmitted.transactionId, 999)
        XCTAssertNil(mockRepository.payWithTransferSubmitted.preferredProvider)
    }

    func testProvisionVirtualAccountOnErrorSetsStateToError() async {
        let expectedError = PaystackError.response(code: 500, message: "Boom")
        mockRepository.expectedErrorResponse = expectedError

        await serviceUnderTest.provisionVirtualAccount()

        XCTAssertEqual(serviceUnderTest.state, .error(ChargeError(error: expectedError)))
    }

    func testProvisionVirtualAccountSetsLoadingStateBeforeAwaitingPayment() async {
        let expectedDetails: BankTransferDetails = .example
        mockRepository.expectedBankTransferDetails = expectedDetails

        XCTAssertEqual(serviceUnderTest.state, .loading())

        await serviceUnderTest.provisionVirtualAccount()

        XCTAssertEqual(serviceUnderTest.state, .awaitingPayment(expectedDetails))
    }

    func testRetryProvisioningCallsRepositoryAgain() async {
        mockRepository.expectedErrorResponse = PaystackError.technical
        await serviceUnderTest.provisionVirtualAccount()
        XCTAssertEqual(mockRepository.payWithTransferCallCount, 1)

        let expectedDetails: BankTransferDetails = .example
        mockRepository.expectedErrorResponse = nil
        mockRepository.expectedBankTransferDetails = expectedDetails
        await serviceUnderTest.retryProvisioning()

        XCTAssertEqual(mockRepository.payWithTransferCallCount, 2)
        XCTAssertEqual(serviceUnderTest.state, .awaitingPayment(expectedDetails))
    }

    // MARK: - User actions

    @MainActor func testUserTappedChangePaymentMethodCallsRestartFromChannelSelection() {
        serviceUnderTest.userTappedChangePaymentMethod()
        XCTAssertTrue(mockChargeContainer.channelSelectionRestarted)
    }

    func testUserTappedIveSentTheMoneyTransitionsToConfirmingPaymentWaitingForCredit() async {
        let expectedDetails: BankTransferDetails = .example
        mockRepository.expectedBankTransferDetails = expectedDetails
        await serviceUnderTest.provisionVirtualAccount()
        serviceUnderTest.confirmationWindowSeconds = 0

        await serviceUnderTest.userTappedIveSentTheMoney()

        XCTAssertEqual(serviceUnderTest.state,
                       .confirmingPayment(expectedDetails, phase: .waitingForCredit))
    }

    func testUserTappedIveSentTheMoneyCallsCheckPendingChargeOnce() async {
        mockRepository.expectedBankTransferDetails = .example
        await serviceUnderTest.provisionVirtualAccount()
        serviceUnderTest.confirmationWindowSeconds = 0
        mockRepository.expectedChargeCardTransaction = ChargeCardTransaction(status: .pending)

        await serviceUnderTest.userTappedIveSentTheMoney()

        XCTAssertEqual(mockRepository.checkPendingChargeCallCount, 1)
        XCTAssertEqual(mockRepository.pendingChargeAccessCode,
                       serviceUnderTest.transactionDetails.accessCode)
    }

    func testUserTappedIveSentTheMoneyWithCheckPendingChargeSuccessRoutesToContainer() async {
        mockRepository.expectedBankTransferDetails = .example
        await serviceUnderTest.provisionVirtualAccount()
        serviceUnderTest.confirmationWindowSeconds = 0
        mockRepository.expectedChargeCardTransaction = ChargeCardTransaction(status: .success)

        await serviceUnderTest.userTappedIveSentTheMoney()

        XCTAssertTrue(mockChargeContainer.transactionSuccessful)
    }

    func testUserTappedIveSentTheMoneyWithCheckPendingChargeFailureLeavesStateAsConfirmingPayment() async {
        let expectedDetails: BankTransferDetails = .example
        mockRepository.expectedBankTransferDetails = expectedDetails
        await serviceUnderTest.provisionVirtualAccount()
        serviceUnderTest.confirmationWindowSeconds = 0

        mockRepository.expectedErrorResponse = PaystackError.technical

        await serviceUnderTest.userTappedIveSentTheMoney()

        XCTAssertEqual(serviceUnderTest.state,
                       .confirmingPayment(expectedDetails, phase: .waitingForCredit))
        XCTAssertFalse(mockChargeContainer.transactionSuccessful)
    }

    func testUserTappedIveSentTheMoneyFromLoadingStateDoesNothing() async {
        XCTAssertEqual(serviceUnderTest.state, .loading())

        await serviceUnderTest.userTappedIveSentTheMoney()

        XCTAssertEqual(serviceUnderTest.state, .loading())
        XCTAssertEqual(mockRepository.checkPendingChargeCallCount, 0)
    }

    func testUserTappedBackToAccountNumberReturnsToAwaitingPayment() async {
        let expectedDetails: BankTransferDetails = .example
        mockRepository.expectedBankTransferDetails = expectedDetails
        await serviceUnderTest.provisionVirtualAccount()
        serviceUnderTest.confirmationWindowSeconds = 0
        mockRepository.expectedChargeCardTransaction = ChargeCardTransaction(status: .pending)
        await serviceUnderTest.userTappedIveSentTheMoney()
        XCTAssertEqual(serviceUnderTest.state,
                       .confirmingPayment(expectedDetails, phase: .waitingForCredit))

        await serviceUnderTest.userTappedBackToAccountNumber()

        XCTAssertEqual(serviceUnderTest.state, .awaitingPayment(expectedDetails))
    }

    func testUserTappedBackToAccountNumberResetsConfirmationElapsedSeconds() async {
        mockRepository.expectedBankTransferDetails = .example
        await serviceUnderTest.provisionVirtualAccount()
        serviceUnderTest.confirmationWindowSeconds = 0
        mockRepository.expectedChargeCardTransaction = ChargeCardTransaction(status: .pending)
        await serviceUnderTest.userTappedIveSentTheMoney()

        serviceUnderTest.confirmationElapsedSeconds = 42
        await serviceUnderTest.userTappedBackToAccountNumber()

        XCTAssertEqual(serviceUnderTest.confirmationElapsedSeconds, 0)
    }

    @MainActor func testUserTappedBackToAccountNumberFromLoadingStateDoesNothing() {
        XCTAssertEqual(serviceUnderTest.state, .loading())

        serviceUnderTest.userTappedBackToAccountNumber()

        XCTAssertEqual(serviceUnderTest.state, .loading())
    }

    // MARK: - Confirmation countdown

    func testInitialConfirmationElapsedSecondsIsZero() {
        XCTAssertEqual(serviceUnderTest.confirmationElapsedSeconds, 0)
    }

    func testConfirmationCountdownIsSkippedWhenWindowIsZero() async {
        mockRepository.expectedBankTransferDetails = .example
        await serviceUnderTest.provisionVirtualAccount()
        serviceUnderTest.confirmationWindowSeconds = 0
        mockRepository.expectedChargeCardTransaction = ChargeCardTransaction(status: .pending)

        await serviceUnderTest.userTappedIveSentTheMoney()

        XCTAssertEqual(serviceUnderTest.confirmationElapsedSeconds, 0)
    }

    func testConfirmationCountdownTicksElapsedSeconds() async throws {
        mockRepository.expectedBankTransferDetails = .example
        await serviceUnderTest.provisionVirtualAccount()
        serviceUnderTest.confirmationWindowSeconds = 5
        mockRepository.expectedChargeCardTransaction = ChargeCardTransaction(status: .pending)

        await serviceUnderTest.userTappedIveSentTheMoney()
        try await Task.sleep(nanoseconds: 1_300_000_000)

        XCTAssertGreaterThanOrEqual(serviceUnderTest.confirmationElapsedSeconds, 1)
        XCTAssertLessThanOrEqual(serviceUnderTest.confirmationElapsedSeconds, 2)

        await serviceUnderTest.userTappedBackToAccountNumber()
    }

    func testConfirmationCountdownExpiryTransitionsToTakingLongerThanExpected() async throws {
        let expectedDetails: BankTransferDetails = .example
        mockRepository.expectedBankTransferDetails = expectedDetails
        await serviceUnderTest.provisionVirtualAccount()

        serviceUnderTest.confirmationWindowSeconds = 1
        mockRepository.expectedChargeCardTransaction = ChargeCardTransaction(status: .pending)
        await serviceUnderTest.userTappedIveSentTheMoney()

        try await Task.sleep(nanoseconds: 1_400_000_000)

        XCTAssertEqual(serviceUnderTest.state,
                       .takingLongerThanExpected(expectedDetails))
    }

    func testConfirmationCountdownExpiryAfterStateAlreadyMovedDoesNotOverwrite() async throws {
        let expectedDetails: BankTransferDetails = .example
        mockRepository.expectedBankTransferDetails = expectedDetails
        await serviceUnderTest.provisionVirtualAccount()
        serviceUnderTest.confirmationWindowSeconds = 1
        mockRepository.expectedChargeCardTransaction = ChargeCardTransaction(status: .pending)
        await serviceUnderTest.userTappedIveSentTheMoney()

        await serviceUnderTest.userTappedBackToAccountNumber()
        try await Task.sleep(nanoseconds: 1_400_000_000)

        XCTAssertEqual(serviceUnderTest.state,
                       .awaitingPayment(expectedDetails))
    }

    func testUserTappedChangePaymentMethodAfterConfirmingResetsBackToChannelSelection() async {
        mockRepository.expectedBankTransferDetails = .example
        await serviceUnderTest.provisionVirtualAccount()
        serviceUnderTest.confirmationWindowSeconds = 0
        mockRepository.expectedChargeCardTransaction = ChargeCardTransaction(status: .pending)
        await serviceUnderTest.userTappedIveSentTheMoney()

        await serviceUnderTest.userTappedChangePaymentMethod()

        XCTAssertTrue(mockChargeContainer.channelSelectionRestarted)
    }

    func testDisplayTransactionErrorSetsStateToErrorWithGivenError() async {
        let error = ChargeError(message: "Something broke")
        await serviceUnderTest.displayTransactionError(error)
        XCTAssertEqual(serviceUnderTest.state, .error(error))
    }

    @MainActor func testUserTappedBackToAccountNumberFromTakingLongerReturnsToAwaitingPayment() {
        let expectedDetails: BankTransferDetails = .example
        serviceUnderTest.state = .takingLongerThanExpected(expectedDetails)

        serviceUnderTest.userTappedBackToAccountNumber()

        XCTAssertEqual(serviceUnderTest.state, .awaitingPayment(expectedDetails))
    }

    // MARK: - Get help / keep waiting / close from delayed-confirmation

    @MainActor func testUserTappedGetHelpFromTakingLongerTransitionsToDelayedConfirmation() {
        let expectedDetails: BankTransferDetails = .example
        serviceUnderTest.state = .takingLongerThanExpected(expectedDetails)

        serviceUnderTest.userTappedGetHelp()

        XCTAssertEqual(serviceUnderTest.state,
                       .delayedConfirmation(expectedDetails))
    }

    @MainActor func testUserTappedGetHelpFromOtherStateDoesNothing() {
        let expectedDetails: BankTransferDetails = .example
        serviceUnderTest.state = .awaitingPayment(expectedDetails)

        serviceUnderTest.userTappedGetHelp()

        XCTAssertEqual(serviceUnderTest.state,
                       .awaitingPayment(expectedDetails))
    }

    @MainActor func testUserTappedKeepWaitingFromDelayedConfirmationReturnsToTakingLonger() {
        let expectedDetails: BankTransferDetails = .example
        serviceUnderTest.state = .delayedConfirmation(expectedDetails)

        serviceUnderTest.userTappedKeepWaiting()

        XCTAssertEqual(serviceUnderTest.state,
                       .takingLongerThanExpected(expectedDetails))
    }

    @MainActor func testUserTappedKeepWaitingFromOtherStateDoesNothing() {
        let expectedDetails: BankTransferDetails = .example
        serviceUnderTest.state = .takingLongerThanExpected(expectedDetails)

        serviceUnderTest.userTappedKeepWaiting()

        XCTAssertEqual(serviceUnderTest.state,
                       .takingLongerThanExpected(expectedDetails))
    }

    @MainActor
    func testUserTappedChangePaymentMethodFromDelayedConfirmationRestartsChannelSelection() {
        serviceUnderTest.state = .delayedConfirmation(.example)

        serviceUnderTest.userTappedChangePaymentMethod()

        XCTAssertTrue(mockChargeContainer.channelSelectionRestarted)
    }

    // MARK: - processTransferUpdate — success / unknown

    func testProcessUpdateWithSuccessCallsContainerProcessSuccessfulTransaction() async {
        await serviceUnderTest.processTransferUpdate(
            .init(status: .success, message: nil, reference: nil, transactionId: nil))
        XCTAssertTrue(mockChargeContainer.transactionSuccessful)
    }

    func testProcessUpdateWithUnknownStatusDoesNotChangeState() async {
        let details: BankTransferDetails = .example
        serviceUnderTest.state = .confirmingPayment(details, phase: .waitingForCredit)

        await serviceUnderTest.processTransferUpdate(
            .init(status: .unknown("brand-new-status"),
                  message: nil, reference: nil, transactionId: nil))

        XCTAssertEqual(serviceUnderTest.state,
                       .confirmingPayment(details, phase: .waitingForCredit))
    }

    // MARK: - processTransferUpdate — auto-advance from awaitingPayment (PR 2)

    func testProcessUpdateWithCreditRequestPendingFromAwaitingPaymentAutoAdvances() async {
        let details: BankTransferDetails = .example
        serviceUnderTest.state = .awaitingPayment(details)
        serviceUnderTest.confirmationWindowSeconds = 0

        await serviceUnderTest.processTransferUpdate(
            .init(status: .creditRequestPending, message: nil,
                  reference: nil, transactionId: nil))

        XCTAssertEqual(serviceUnderTest.state,
                       .confirmingPayment(details, phase: .waitingForCredit))
    }

    func testProcessUpdateWithGenericPendingFromAwaitingPaymentAutoAdvances() async {
        let details: BankTransferDetails = .example
        serviceUnderTest.state = .awaitingPayment(details)
        serviceUnderTest.confirmationWindowSeconds = 0

        await serviceUnderTest.processTransferUpdate(
            .init(status: .pending, message: nil,
                  reference: nil, transactionId: nil))

        XCTAssertEqual(serviceUnderTest.state,
                       .confirmingPayment(details, phase: .waitingForCredit))
    }

    func testProcessUpdateWithCreditRequestReceivedFromAwaitingPaymentAutoAdvancesToTransferOnTheWay() async {
        let details: BankTransferDetails = .example
        serviceUnderTest.state = .awaitingPayment(details)
        serviceUnderTest.confirmationWindowSeconds = 0

        await serviceUnderTest.processTransferUpdate(
            .init(status: .creditRequestReceived, message: nil,
                  reference: nil, transactionId: nil))

        XCTAssertEqual(serviceUnderTest.state,
                       .confirmingPayment(details, phase: .transferOnTheWay))
    }

    func testProcessUpdateWithCreditRequestReceivedFromConfirmingAdvancesPhase() async {
        let details: BankTransferDetails = .example
        serviceUnderTest.state = .confirmingPayment(details, phase: .waitingForCredit)
        serviceUnderTest.confirmationWindowSeconds = 0

        await serviceUnderTest.processTransferUpdate(
            .init(status: .creditRequestReceived, message: nil,
                  reference: nil, transactionId: nil))

        XCTAssertEqual(serviceUnderTest.state,
                       .confirmingPayment(details, phase: .transferOnTheWay))
    }

    // MARK: - processTransferUpdate — phase downgrade is prevented (Q6)

    func testProcessUpdateWithCreditRequestPendingDoesNotDowngradeFromTransferOnTheWay() async {
        let details: BankTransferDetails = .example
        serviceUnderTest.state = .confirmingPayment(details, phase: .transferOnTheWay)

        await serviceUnderTest.processTransferUpdate(
            .init(status: .creditRequestPending, message: nil,
                  reference: nil, transactionId: nil))

        XCTAssertEqual(serviceUnderTest.state,
                       .confirmingPayment(details, phase: .transferOnTheWay))
    }

    func testProcessUpdateWithGenericPendingDoesNotDowngradeFromTransferOnTheWay() async {
        let details: BankTransferDetails = .example
        serviceUnderTest.state = .confirmingPayment(details, phase: .transferOnTheWay)

        await serviceUnderTest.processTransferUpdate(
            .init(status: .pending, message: nil,
                  reference: nil, transactionId: nil))

        XCTAssertEqual(serviceUnderTest.state,
                       .confirmingPayment(details, phase: .transferOnTheWay))
    }

    // MARK: - processTransferUpdate — refundInitiated (was banner / error)

    func testProcessUpdateWithCreditRequestRejectedTransitionsToRefundInitiatedWithApiMessage() async {
        let details: BankTransferDetails = .example
        serviceUnderTest.state = .confirmingPayment(details, phase: .waitingForCredit)

        await serviceUnderTest.processTransferUpdate(
            .init(status: .creditRequestRejected,
                  message: "Bank declined transfer",
                  reference: nil, transactionId: nil))

        XCTAssertEqual(serviceUnderTest.state,
                       .refundInitiated(details, message: "Bank declined transfer"))
    }

    func testProcessUpdateWithCreditRequestRejectedFallsBackToCannedRefundCopyWhenNil() async {
        let details: BankTransferDetails = .example
        serviceUnderTest.state = .confirmingPayment(details, phase: .waitingForCredit)

        await serviceUnderTest.processTransferUpdate(
            .init(status: .creditRequestRejected,
                  message: nil, reference: nil, transactionId: nil))

        XCTAssertEqual(serviceUnderTest.state,
                       .refundInitiated(details,
                                        message: BankTransferViewModel.refundInitiatedFallbackMessage))
    }

    func testProcessUpdateWithIncorrectAmountSentTransitionsToRefundInitiated() async {
        let details: BankTransferDetails = .example
        serviceUnderTest.state = .confirmingPayment(details, phase: .waitingForCredit)

        await serviceUnderTest.processTransferUpdate(
            .init(status: .incorrectAmountSent,
                  message: "Wrong amount, refund coming",
                  reference: nil, transactionId: nil))

        XCTAssertEqual(serviceUnderTest.state,
                       .refundInitiated(details, message: "Wrong amount, refund coming"))
    }

    func testProcessUpdateWithIncorrectAmountSentFromAwaitingPaymentAlsoRoutesToRefund() async {
        let details: BankTransferDetails = .example
        serviceUnderTest.state = .awaitingPayment(details)

        await serviceUnderTest.processTransferUpdate(
            .init(status: .incorrectAmountSent,
                  message: nil, reference: nil, transactionId: nil))

        // Auto-routing semantics: refund-initiated is terminal regardless
        // of which screen the customer is on when the event arrives.
        XCTAssertEqual(serviceUnderTest.state,
                       .refundInitiated(details,
                                        message: BankTransferViewModel.refundInitiatedFallbackMessage))
    }

    // MARK: - processTransferUpdate — failed (new)

    func testProcessUpdateWithFailedSetsStateToErrorWithApiMessage() async {
        let details: BankTransferDetails = .example
        serviceUnderTest.state = .confirmingPayment(details, phase: .waitingForCredit)

        await serviceUnderTest.processTransferUpdate(
            .init(status: .failed,
                  message: "Transaction declined",
                  reference: nil, transactionId: nil))

        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(message: "Transaction declined")))
    }

    func testProcessUpdateWithFailedFallsBackToDefaultMessageWhenNil() async {
        await serviceUnderTest.processTransferUpdate(
            .init(status: .failed, message: nil,
                  reference: nil, transactionId: nil))

        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(message: BankTransferViewModel.failedFallbackMessage)))
    }

    // MARK: - processTransferUpdate — requery (new)

    func testProcessUpdateWithRequeryTriggersSingleCheckPendingChargeCall() async {
        mockRepository.expectedBankTransferDetails = .example
        await serviceUnderTest.provisionVirtualAccount()
        mockRepository.expectedChargeCardTransaction = ChargeCardTransaction(status: .pending)
        let baseline = mockRepository.checkPendingChargeCallCount

        await serviceUnderTest.processTransferUpdate(
            .init(status: .requery, message: nil,
                  reference: nil, transactionId: nil))
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockRepository.checkPendingChargeCallCount, baseline + 1)
        XCTAssertEqual(mockRepository.pendingChargeAccessCode,
                       serviceUnderTest.transactionDetails.accessCode)
    }

    func testProcessUpdateWithRequeryWithSuccessfulPollResolvesTransaction() async {
        mockRepository.expectedBankTransferDetails = .example
        await serviceUnderTest.provisionVirtualAccount()
        mockRepository.expectedChargeCardTransaction = ChargeCardTransaction(status: .success)

        await serviceUnderTest.processTransferUpdate(
            .init(status: .requery, message: nil,
                  reference: nil, transactionId: nil))
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockChargeContainer.transactionSuccessful)
    }

    // MARK: - Pusher listen loop

    func testProvisioningStartsListenLoopOnReturnedChannel() async {
        let details: BankTransferDetails = .example
        mockRepository.expectedBankTransferDetails = details

        await serviceUnderTest.provisionVirtualAccount()
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertGreaterThanOrEqual(mockRepository.listenForTransferResponseCallCount, 1)
        XCTAssertEqual(mockRepository.lastListenedChannel, details.pusherChannel)
    }

    func testListenLoopProcessesMultipleNonTerminalEventsBeforeTerminating() async {
        let details: BankTransferDetails = .example
        mockRepository.expectedBankTransferDetails = details
        mockRepository.expectedListenForTransferResponses = [
            .init(status: .creditRequestReceived, message: nil,
                  reference: nil, transactionId: nil),
            .init(status: .creditRequestPending, message: nil,
                  reference: nil, transactionId: nil),
            .init(status: .success, message: nil,
                  reference: nil, transactionId: nil)
        ]

        let expectation = expectation(description: "container receives success")
        mockChargeContainer.onProcessSuccessfulTransaction = { expectation.fulfill() }

        await serviceUnderTest.provisionVirtualAccount()
        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertEqual(mockRepository.listenForTransferResponseCallCount, 3)
        XCTAssertTrue(mockChargeContainer.transactionSuccessful)
    }

    func testListenLoopExitsOnRejectedStatusWithRefundInitiated() async {
        let details: BankTransferDetails = .example
        mockRepository.expectedBankTransferDetails = details
        mockRepository.expectedListenForTransferResponses = [
            .init(status: .creditRequestReceived, message: nil,
                  reference: nil, transactionId: nil),
            .init(status: .creditRequestRejected, message: "Bank declined",
                  reference: nil, transactionId: nil)
        ]

        await serviceUnderTest.provisionVirtualAccount()
        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(mockRepository.listenForTransferResponseCallCount, 2)
        XCTAssertEqual(serviceUnderTest.state,
                       .refundInitiated(details, message: "Bank declined"))
    }

    func testListenLoopExitsOnFailedStatusToErrorState() async {
        let details: BankTransferDetails = .example
        mockRepository.expectedBankTransferDetails = details
        mockRepository.expectedListenForTransferResponses = [
            .init(status: .failed, message: "Bank rejected",
                  reference: nil, transactionId: nil)
        ]

        await serviceUnderTest.provisionVirtualAccount()
        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(mockRepository.listenForTransferResponseCallCount, 1)
        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(message: "Bank rejected")))
    }

    func testListenLoopExitsOnRepositoryErrorWithoutCrashing() async {
        // After auto-advance the state is .confirmingPayment(.transferOnTheWay)
        // — that's what the customer sees when the listen loop dies, not
        // .awaitingPayment as in the old behaviour.
        let details: BankTransferDetails = .example
        mockRepository.expectedBankTransferDetails = details
        mockRepository.expectedListenForTransferResponses = [
            .init(status: .creditRequestReceived, message: nil,
                  reference: nil, transactionId: nil)
        ]
        mockRepository.expectedListenForTransferError = PaystackError.technical

        await serviceUnderTest.provisionVirtualAccount()
        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(mockRepository.listenForTransferResponseCallCount, 2)
        XCTAssertEqual(serviceUnderTest.state,
                       .confirmingPayment(details, phase: .transferOnTheWay))
    }

    // MARK: - refundInitiated → "Choose another payment method"

    @MainActor func testUserTappedChooseAnotherPaymentMethodFromRefundRestartsChannelSelection() {
        serviceUnderTest.state = .refundInitiated(.example, message: "Refund initiated")

        serviceUnderTest.userTappedChooseAnotherPaymentMethodFromRefund()

        XCTAssertTrue(mockChargeContainer.channelSelectionRestarted)
    }

    // MARK: - currentBankSlug

    func testAvailableBankSlugsForwardsFromConfig() {
        XCTAssertEqual(serviceUnderTest.availableBankSlugs,
                       ["wema-bank", "titan-paystack"])
    }

    func testCurrentBankSlugIsNilWhenStateIsLoading() {
        XCTAssertEqual(serviceUnderTest.state, .loading())
        XCTAssertNil(serviceUnderTest.currentBankSlug)
    }

    func testCurrentBankSlugReturnsSlugFromAwaitingPayment() {
        let details: BankTransferDetails = .example
        serviceUnderTest.state = .awaitingPayment(details)
        XCTAssertEqual(serviceUnderTest.currentBankSlug, details.bankSlug)
    }

    func testCurrentBankSlugReturnsSlugFromConfirmingPayment() {
        let details: BankTransferDetails = .example
        serviceUnderTest.state = .confirmingPayment(details, phase: .waitingForCredit)
        XCTAssertEqual(serviceUnderTest.currentBankSlug, details.bankSlug)
    }

    func testCurrentBankSlugReturnsSlugFromTakingLongerAndDelayedConfirmation() {
        let details: BankTransferDetails = .example
        serviceUnderTest.state = .takingLongerThanExpected(details)
        XCTAssertEqual(serviceUnderTest.currentBankSlug, details.bankSlug)

        serviceUnderTest.state = .delayedConfirmation(details)
        XCTAssertEqual(serviceUnderTest.currentBankSlug, details.bankSlug)
    }

    func testCurrentBankSlugReturnsSlugFromRefundInitiated() {
        let details: BankTransferDetails = .example
        serviceUnderTest.state = .refundInitiated(details, message: "x")
        XCTAssertEqual(serviceUnderTest.currentBankSlug, details.bankSlug)
    }

    // MARK: - User selected bank

    func testUserSelectedBankCallsRepositoryWithPreferredProvider() async {
        let newDetails = BankTransferDetails(
            accountName: "WEMA TEST",
            accountNumber: "1234567890",
            bankName: "Wema Bank",
            bankSlug: "wema-bank",
            transactionReference: "T_new",
            pusherChannel: "PWT_new",
            accountExpiresAt: Date().addingTimeInterval(30 * 60),
            transactionId: "9999")
        mockRepository.expectedBankTransferDetails = newDetails

        await serviceUnderTest.userSelectedBank(slug: "wema-bank")

        XCTAssertEqual(mockRepository.payWithTransferSubmitted.preferredProvider,
                       "wema-bank")
        XCTAssertEqual(mockRepository.payWithTransferSubmitted.fulfilLateNotification,
                       false)
        XCTAssertEqual(mockRepository.payWithTransferSubmitted.transactionId, 1234)
    }

    func testUserSelectedBankTransitionsToAwaitingPaymentWithNewDetails() async {
        let newDetails = BankTransferDetails(
            accountName: "WEMA TEST",
            accountNumber: "1234567890",
            bankName: "Wema Bank",
            bankSlug: "wema-bank",
            transactionReference: "T_new",
            pusherChannel: "PWT_new",
            accountExpiresAt: Date().addingTimeInterval(30 * 60),
            transactionId: "9999")
        mockRepository.expectedBankTransferDetails = newDetails

        await serviceUnderTest.userSelectedBank(slug: "wema-bank")

        XCTAssertEqual(serviceUnderTest.state, .awaitingPayment(newDetails))
    }

    func testUserSelectedBankStartsFreshPusherSubscriptionOnNewChannel() async {
        let initialDetails: BankTransferDetails = .example
        mockRepository.expectedBankTransferDetails = initialDetails
        await serviceUnderTest.provisionVirtualAccount()
        try? await Task.sleep(nanoseconds: 100_000_000)
        let callsAfterInitial = mockRepository.listenForTransferResponseCallCount

        let newChannel = "PWT_brand_new"
        let newDetails = BankTransferDetails(
            accountName: "X", accountNumber: "Y", bankName: "Wema Bank",
            bankSlug: "wema-bank", transactionReference: "Z",
            pusherChannel: newChannel,
            accountExpiresAt: Date().addingTimeInterval(30 * 60),
            transactionId: "9999")
        mockRepository.expectedBankTransferDetails = newDetails

        await serviceUnderTest.userSelectedBank(slug: "wema-bank")
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertGreaterThan(mockRepository.listenForTransferResponseCallCount,
                             callsAfterInitial)
        XCTAssertEqual(mockRepository.lastListenedChannel, newChannel)
    }

    func testUserSelectedBankCancelsConfirmationTimer() async {
        mockRepository.expectedBankTransferDetails = .example
        await serviceUnderTest.provisionVirtualAccount()
        serviceUnderTest.confirmationWindowSeconds = 0
        mockRepository.expectedChargeCardTransaction = ChargeCardTransaction(status: .pending)
        await serviceUnderTest.userTappedIveSentTheMoney()
        serviceUnderTest.confirmationElapsedSeconds = 17

        let newDetails = BankTransferDetails(
            accountName: "X", accountNumber: "Y", bankName: "Wema Bank",
            bankSlug: "wema-bank", transactionReference: "Z",
            pusherChannel: "PWT_new",
            accountExpiresAt: Date().addingTimeInterval(30 * 60),
            transactionId: "9999")
        mockRepository.expectedBankTransferDetails = newDetails

        await serviceUnderTest.userSelectedBank(slug: "wema-bank")

        XCTAssertEqual(serviceUnderTest.confirmationElapsedSeconds, 0)
        XCTAssertEqual(serviceUnderTest.state, .awaitingPayment(newDetails))
    }

    func testUserSelectedBankOnErrorSetsStateToError() async {
        mockRepository.expectedBankTransferDetails = .example
        await serviceUnderTest.provisionVirtualAccount()

        let expectedError = PaystackError.response(code: 500, message: "Boom")
        mockRepository.expectedBankTransferDetails = nil
        mockRepository.expectedErrorResponse = expectedError

        await serviceUnderTest.userSelectedBank(slug: "wema-bank")

        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(error: expectedError)))
    }
}

private extension BankTransferConfig {
    static let example = BankTransferConfig(
        fulfilLateNotification: false,
        transactionId: 1234,
        availableProviders: ["wema-bank", "titan-paystack"])
}
