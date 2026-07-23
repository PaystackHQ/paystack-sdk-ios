import XCTest
import PaystackCore
@testable import PaystackUI

final class QRViewModelTests: XCTestCase {

    var serviceUnderTest: QRViewModel!
    var mockChargeContainer: MockChargeContainer!
    var mockRepository: MockQRRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeContainer = MockChargeContainer()
        mockRepository = MockQRRepository()
        serviceUnderTest = QRViewModel(
            chargeContainer: mockChargeContainer,
            transactionDetails: .example,
            config: .scanToPayExample,
            repository: mockRepository)
    }

    func testInitialStateIsLoadingQR() {
        XCTAssertEqual(serviceUnderTest.state, .loadingQR)
    }

    func testVariantExposesConfigVariant() {
        XCTAssertEqual(serviceUnderTest.variant, .scanToPay)
    }

    func testOnAppearCallsGenerateWithConfigChannelAndTransactionId() async {
        mockRepository.expectedDetails = .scanToPayExample

        await serviceUnderTest.onAppear()

        XCTAssertEqual(mockRepository.generateCallCount, 1)
        XCTAssertEqual(mockRepository.generateSubmitted.channelOption, "MPASS_OLTI")
        XCTAssertEqual(mockRepository.generateSubmitted.reference,
                       "\(QRConfig.scanToPayExample.transactionId)")
        XCTAssertEqual(mockRepository.generateSubmitted.variant, .scanToPay)
    }

    func testOnAppearOnSuccessTransitionsToAwaitingScan() async {
        mockRepository.expectedDetails = .scanToPayExample

        await serviceUnderTest.onAppear()

        if case .awaitingScan(let details) = serviceUnderTest.state {
            XCTAssertEqual(details, .scanToPayExample)
        } else {
            XCTFail("Expected .awaitingScan, got \(serviceUnderTest.state)")
        }
    }

    func testOnAppearOnErrorTransitionsToError() async {
        let expectedError = PaystackError.response(code: 500, message: "Boom")
        mockRepository.expectedGenerateError = expectedError

        await serviceUnderTest.onAppear()

        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(error: expectedError)))
    }

    func testOnAppearDoesNothingWhenNotInLoadingQRState() async {
        mockRepository.expectedDetails = .scanToPayExample
        await serviceUnderTest.onAppear()
        let stateAfterFirst = serviceUnderTest.state
        let callsAfterFirst = mockRepository.generateCallCount

        await serviceUnderTest.onAppear()

        XCTAssertEqual(serviceUnderTest.state, stateAfterFirst)
        XCTAssertEqual(mockRepository.generateCallCount, callsAfterFirst)
    }

    func testUserTappedICompletedPaymentTransitionsToVerifying() async {
        mockRepository.expectedDetails = .scanToPayExample
        mockRepository.expectedCheckPendingResults = [
            ChargeCardTransaction(status: .pending)
        ]
        await serviceUnderTest.onAppear()

        await MainActor.run {
            serviceUnderTest.userTappedICompletedPayment()
        }

        if case .verifying(let details) = serviceUnderTest.state {
            XCTAssertEqual(details, .scanToPayExample)
        } else if case .awaitingScan = serviceUnderTest.state {
            XCTAssertNotNil(serviceUnderTest.inlineBanner,
                            "Pending fallback should surface an inline banner")
        } else {
            XCTFail("Expected .verifying or bounced back to .awaitingScan, got \(serviceUnderTest.state)")
        }
    }

    func testUserTappedICompletedPaymentOnSuccessRoutesToContainer() async {
        mockRepository.expectedDetails = .scanToPayExample
        mockRepository.expectedCheckPendingResults = [
            ChargeCardTransaction(status: .success)
        ]
        await serviceUnderTest.onAppear()

        await MainActor.run {
            serviceUnderTest.userTappedICompletedPayment()
        }
        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertTrue(mockChargeContainer.transactionSuccessful)
        XCTAssertEqual(mockRepository.lastCheckPendingAccessCode,
                       serviceUnderTest.transactionDetails.accessCode)
    }

    func testUserTappedICompletedPaymentOnFailedTransitionsToError() async {
        mockRepository.expectedDetails = .scanToPayExample
        mockRepository.expectedCheckPendingResults = [
            ChargeCardTransaction(status: .failed, message: "Bank declined")
        ]
        await serviceUnderTest.onAppear()

        await MainActor.run {
            serviceUnderTest.userTappedICompletedPayment()
        }
        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(message: "Bank declined")))
    }

    func testUserTappedICompletedPaymentOnPendingReturnsToAwaitingScanWithBanner() async {
        mockRepository.expectedDetails = .scanToPayExample
        mockRepository.expectedCheckPendingResults = [
            ChargeCardTransaction(status: .pending)
        ]
        await serviceUnderTest.onAppear()

        await MainActor.run {
            serviceUnderTest.userTappedICompletedPayment()
        }
        try? await Task.sleep(nanoseconds: 200_000_000)

        if case .awaitingScan = serviceUnderTest.state {
        } else {
            XCTFail("Expected pending to bounce back to .awaitingScan, got \(serviceUnderTest.state)")
        }
        XCTAssertEqual(serviceUnderTest.inlineBanner,
                       QRViewModel.checkPendingFallbackMessage)
    }

    @MainActor
    func testUserTappedChangePaymentMethodRestartsChannelSelection() {
        serviceUnderTest.userTappedChangePaymentMethod()
        XCTAssertTrue(mockChargeContainer.channelSelectionRestarted)
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
                       .error(ChargeError(message: QRViewModel.failedFallbackMessage)))
    }

    func testProcessTransactionUpdateWithNonTerminalStatusDoesNotChangeState() async {
        let stateBefore = serviceUnderTest.state
        await serviceUnderTest.processTransactionUpdate(
            ChargeCardTransaction(status: .pending))
        XCTAssertEqual(serviceUnderTest.state, stateBefore)
    }

    // MARK: - Pusher (single-shot, PR QR-E)

    func testOnAppearStartsListenOnReturnedChannel() async {
        mockRepository.expectedDetails = .scanToPayExample

        await serviceUnderTest.onAppear()
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertGreaterThanOrEqual(mockRepository.listenCallCount, 1)
        XCTAssertEqual(mockRepository.lastListenedChannel,
                       QRDetails.scanToPayExample.pusherChannel)
    }

    func testListenResolvesOnSuccessAndRoutesToContainer() async {
        mockRepository.expectedDetails = .scanToPayExample
        mockRepository.expectedListenResponses = [
            ChargeCardTransaction(status: .success)
        ]
        let expectation = expectation(description: "container receives success")
        mockChargeContainer.onProcessSuccessfulTransaction = { expectation.fulfill() }

        await serviceUnderTest.onAppear()
        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertTrue(mockChargeContainer.transactionSuccessful)
    }

    func testListenResolvesOnFailedStatusToErrorState() async {
        mockRepository.expectedDetails = .scanToPayExample
        mockRepository.expectedListenResponses = [
            ChargeCardTransaction(status: .failed, message: "Bank declined")
        ]

        await serviceUnderTest.onAppear()
        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(message: "Bank declined")))
    }

    // MARK: - Retry (PR QR-D)

    func testRetryResetsToLoadingQRAndCallsGenerateAgain() async {
        mockRepository.expectedGenerateError = PaystackError.response(code: 500, message: "Boom")
        await serviceUnderTest.onAppear()
        XCTAssertEqual(serviceUnderTest.state,
                       .error(ChargeError(error: PaystackError.response(code: 500, message: "Boom"))))
        mockRepository.expectedGenerateError = nil
        mockRepository.expectedDetails = .scanToPayExample

        await serviceUnderTest.retry()

        XCTAssertEqual(mockRepository.generateCallCount, 2)
        if case .awaitingScan = serviceUnderTest.state {
        } else {
            XCTFail("Expected .awaitingScan after retry, got \(serviceUnderTest.state)")
        }
    }
}
