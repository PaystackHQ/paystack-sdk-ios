import XCTest
import PaystackCore
@testable import PaystackUI

final class TestModeCardSelectionViewModelTests: XCTestCase {

    var serviceUnderTest: TestModeCardSelectionViewModel!
    var mockAmountCurrency = AmountCurrency(amount: 10000, currency: "USD")
    var mockChargeCardContainer: MockChargeCardContainer!
    var mockEncryptionKey = "MOCK_ENCRYPTION_KEY"
    var mockRepository: MockChargeCardRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeCardContainer = MockChargeCardContainer()
        mockRepository = MockChargeCardRepository()
        serviceUnderTest = TestModeCardSelectionViewModel(amountDetails: mockAmountCurrency,
                                                          encryptionKey: mockEncryptionKey,
                                                          chargeCardContainer: mockChargeCardContainer,
                                                          repository: mockRepository)
    }

    func testFormIsValidIfTestCardIsSelected() {
        serviceUnderTest.testCard = .bankAuthentication
        XCTAssertTrue(serviceUnderTest.isValid)
    }

    func testFormIsNotValidIfTestCardIsNotSelected() {
        serviceUnderTest.testCard = nil
        XCTAssertFalse(serviceUnderTest.isValid)
    }

    func testUseManualCardEntryCallsContainerToSwitchToCardDetailsFlow() {
        serviceUnderTest.displayManualCardDetailsEntry()
        XCTAssertTrue(mockChargeCardContainer.cardPaymentRestarted)
    }

    func testSubmittingTestCardDetailsBuildsCardModelAndForwardsRepositoryResponseToContainer() async throws {
        serviceUnderTest.testCard = .success

        mockRepository.expectedChargeCardTransaction = .example
        await serviceUnderTest.proceedWithTestCard()

        let expectedCard = CardCharge(number: TestCard.success.cardNumber,
                                      cvv: TestCard.success.cvv,
                                      expiryMonth: TestCard.success.expiryMonth,
                                      expiryYear: TestCard.success.expiryYear)

        XCTAssertEqual(mockRepository.cardDetailsSubmitted.card, expectedCard)
        XCTAssertEqual(mockChargeCardContainer.transactionResponse, .example)
    }

    func testSubmittingTestCardDetailsWithErrorForwardsErrorToCardContainer() async {
        let expectedErrorMessage = "Error Message"
        let expectedError: PaystackError = .response(code: 400, message: expectedErrorMessage)
        mockRepository.expectedErrorResponse = expectedError

        serviceUnderTest.testCard = .success
        await serviceUnderTest.proceedWithTestCard()

        XCTAssertEqual(mockChargeCardContainer.transactionError,
                       .init(message: expectedErrorMessage))
    }
}
