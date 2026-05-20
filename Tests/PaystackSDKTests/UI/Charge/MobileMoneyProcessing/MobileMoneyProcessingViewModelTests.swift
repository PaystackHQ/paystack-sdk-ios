import XCTest
import PaystackCore
@testable import PaystackUI

final class MobileMoneyProcessingViewModelTests: XCTestCase {

    var serviceUnderTest: MobileMoneyProcessingViewModel!
    var mockContainer: MockMobileMoneyContainer!
    var mockRepository: MockChargeMobileMoneyRepository!
    var mobileMoneyTransaction: MobileMoneyTransaction!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockContainer = MockMobileMoneyContainer()
        mockRepository = MockChargeMobileMoneyRepository()
        mobileMoneyTransaction = .mPesaExample
        serviceUnderTest = MobileMoneyProcessingViewModel(container: mockContainer,
                                                          mobileMoneyTransaction: mobileMoneyTransaction,
                                                          repository: mockRepository)
    }

    // MARK: - initializeMobileMoneyAuthorization

    func testInitializeMobileMoneyAuthorizationForwardsTransactionIdToRepository() async {
        mockRepository.expectedChargeCardTransaction = .example
        await serviceUnderTest.initializeMobileMoneyAuthorization()
        XCTAssertEqual(mockRepository.listenForMobileMoneyResponseTransactionId, 1504248187)
    }

    func testInitializeMobileMoneyAuthorizationWithNonNumericTransactionDefaultsToZero() async {
        mobileMoneyTransaction = MobileMoneyTransaction(transaction: "not-a-number",
                                                        phone: "0703362111",
                                                        provider: "MPESA",
                                                        channelName: "MOBILE_MONEY_x",
                                                        timer: 60,
                                                        message: "")
        serviceUnderTest = MobileMoneyProcessingViewModel(container: mockContainer,
                                                          mobileMoneyTransaction: mobileMoneyTransaction,
                                                          repository: mockRepository)
        mockRepository.expectedChargeCardTransaction = .example

        await serviceUnderTest.initializeMobileMoneyAuthorization()

        XCTAssertEqual(mockRepository.listenForMobileMoneyResponseTransactionId, 0)
    }

    func testInitializeMobileMoneyAuthorizationOnSuccessForwardsResponseToContainer() async {
        let expectedResponse = ChargeCardTransaction(status: .success)
        mockRepository.expectedChargeCardTransaction = expectedResponse

        await serviceUnderTest.initializeMobileMoneyAuthorization()

        XCTAssertEqual(mockContainer.transactionResponse, expectedResponse)
    }

    func testInitializeMobileMoneyAuthorizationOnErrorForwardsErrorToContainer() async {
        let expectedErrorMessage = "Subscription failed"
        mockRepository.expectedErrorResponse = PaystackError.response(code: 500, message: expectedErrorMessage)

        await serviceUnderTest.initializeMobileMoneyAuthorization()

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
        XCTAssertTrue(mockContainer.mobileMoneyPaymentRestarted)
    }

    // MARK: - transactionDetails

    func testTransactionDetailsComesFromContainer() {
        XCTAssertEqual(serviceUnderTest.transactionDetails, mockContainer.transactionDetails)
    }

    // MARK: - authorizationPromptText

    func testAuthorizationPromptTextUsesApiMessageWhenPresent() {
        // mPesaExample carries `message: "Authorize on your device"` — the
        // API copy should win over the SDK fallback even when the provider
        // is set.
        XCTAssertEqual(serviceUnderTest.authorizationPromptText,
                       "Authorize on your device")
    }

    func testAuthorizationPromptTextFallsBackToProviderCopyWhenApiMessageEmpty() {
        let transactionWithoutMessage = MobileMoneyTransaction(transaction: "1234",
                                                               phone: "0703362111",
                                                               provider: "MPESA",
                                                               channelName: "MOBILE_MONEY_1234",
                                                               timer: 60,
                                                               message: "")
        mockContainer.provider = MobileMoneyChannel(key: "MTN",
                                                    value: "MTN",
                                                    isNew: false,
                                                    phoneNumberRegex: "")
        serviceUnderTest = MobileMoneyProcessingViewModel(container: mockContainer,
                                                          mobileMoneyTransaction: transactionWithoutMessage,
                                                          repository: mockRepository)
        XCTAssertEqual(serviceUnderTest.authorizationPromptText,
                       "Please authorize the payment with MTN on your phone")
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
