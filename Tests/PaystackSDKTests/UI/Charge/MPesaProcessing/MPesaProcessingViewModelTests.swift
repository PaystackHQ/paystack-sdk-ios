import XCTest
import PaystackCore
@testable import PaystackUI

final class MPesaProcessingViewModelTests: XCTestCase {

    var serviceUnderTest: MPesaProcessingViewModel!
    var mockContainer: MockMPesaContainer!
    var mockRepository: MockChargeMobileMoneyRepository!
    var mobileMoneyTransaction: MobileMoneyTransaction!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockContainer = MockMPesaContainer()
        mockRepository = MockChargeMobileMoneyRepository()
        mobileMoneyTransaction = .mPesaExample
        serviceUnderTest = MPesaProcessingViewModel(container: mockContainer,
                                                    mobileMoneyTransaction: mobileMoneyTransaction,
                                                    repository: mockRepository)
    }

    // MARK: - initializeMPesaAuthorization

    func testInitializeMPesaAuthorizationForwardsTransactionIdToRepository() async {
        mockRepository.expectedChargeCardTransaction = .example
        await serviceUnderTest.initializeMPesaAuthorization()
        XCTAssertEqual(mockRepository.listenForMPesaTransactionId, 1504248187)
    }

    func testInitializeMPesaAuthorizationWithNonNumericTransactionDefaultsToZero() async {
        mobileMoneyTransaction = MobileMoneyTransaction(transaction: "not-a-number",
                                                        phone: "0703362111",
                                                        provider: "MPESA",
                                                        channelName: "MOBILE_MONEY_x",
                                                        timer: 60,
                                                        message: "")
        serviceUnderTest = MPesaProcessingViewModel(container: mockContainer,
                                                    mobileMoneyTransaction: mobileMoneyTransaction,
                                                    repository: mockRepository)
        mockRepository.expectedChargeCardTransaction = .example

        await serviceUnderTest.initializeMPesaAuthorization()

        XCTAssertEqual(mockRepository.listenForMPesaTransactionId, 0)
    }

    func testInitializeMPesaAuthorizationOnSuccessForwardsResponseToContainer() async {
        let expectedResponse = ChargeCardTransaction(status: .success)
        mockRepository.expectedChargeCardTransaction = expectedResponse

        await serviceUnderTest.initializeMPesaAuthorization()

        XCTAssertEqual(mockContainer.transactionResponse, expectedResponse)
    }

    func testInitializeMPesaAuthorizationOnErrorForwardsErrorToContainer() async {
        let expectedErrorMessage = "Subscription failed"
        mockRepository.expectedErrorResponse = PaystackError.response(code: 500, message: expectedErrorMessage)

        await serviceUnderTest.initializeMPesaAuthorization()

        XCTAssertEqual(mockContainer.transactionError, ChargeError(message: expectedErrorMessage))
    }

    // MARK: - checkTransactionStatus (fire-and-forget Task wrapper)

    func testCheckTransactionStatusCallsRepositoryWithContainerAccessCodeAndForwardsResponse() async {
        let accessCode = mockContainer.transactionDetails.accessCode
        let expectedResponse = ChargeCardTransaction(status: .success)
        mockRepository.expectedChargeCardTransaction = expectedResponse

        let expectation = expectation(description: "container receives processed response")
        mockContainer.onProcessTransactionResponse = { expectation.fulfill() }

        serviceUnderTest.checkTransactionStatus()
        await fulfillment(of: [expectation], timeout: 1.0)

        XCTAssertEqual(mockRepository.pendingChargeAccessCode, accessCode)
        XCTAssertEqual(mockContainer.transactionResponse, expectedResponse)
    }

    func testCheckTransactionStatusOnErrorForwardsErrorToContainer() async {
        let expectedErrorMessage = "Pending charge check failed"
        mockRepository.expectedErrorResponse = PaystackError.response(code: 500, message: expectedErrorMessage)

        let expectation = expectation(description: "container receives error")
        mockContainer.onDisplayTransactionError = { expectation.fulfill() }

        serviceUnderTest.checkTransactionStatus()
        await fulfillment(of: [expectation], timeout: 1.0)

        XCTAssertEqual(mockContainer.transactionError, ChargeError(message: expectedErrorMessage))
    }

    // MARK: - cancelTransaction

    func testCancelTransactionAsksContainerToRestart() {
        serviceUnderTest.cancelTransaction()
        XCTAssertTrue(mockContainer.mPesaPaymentRestarted)
    }

    // MARK: - transactionDetails

    func testTransactionDetailsComesFromContainer() {
        XCTAssertEqual(serviceUnderTest.transactionDetails, mockContainer.transactionDetails)
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
