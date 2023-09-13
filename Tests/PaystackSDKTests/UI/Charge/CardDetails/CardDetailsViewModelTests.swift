import XCTest
import PaystackCore
@testable import PaystackUI

final class CardDetailsViewModelTests: XCTestCase {

    var serviceUnderTest: CardDetailsViewModel!
    var mockAmountCurrency = AmountCurrency(amount: 100, currency: "USD")
    var mockChargeCardContainer: MockChargeCardContainer!
    var mockEncryptionKey = "MOCK_ENCRYPTION_KEY"
    var mockRepository: MockChargeCardRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeCardContainer = MockChargeCardContainer()
        mockRepository = MockChargeCardRepository()
        serviceUnderTest = CardDetailsViewModel(amountDetails: mockAmountCurrency,
                                                encryptionKey: mockEncryptionKey,
                                                chargeCardContainer: mockChargeCardContainer,
                                                repository: mockRepository)
    }

    func testWhenCardNumberChangesThatCardTypeUpdatesToReflectCorrectTypeAndFormatsCorrectly() {
        let mastercardCardNumber = "5366282937473838"
        serviceUnderTest.formatAndSetCardNumber(mastercardCardNumber)
        XCTAssertEqual(serviceUnderTest.cardNumber, "5366 2829 3747 3838")
        XCTAssertEqual(serviceUnderTest.cardType, .mastercard)
    }

    func testFormattingExpiryDateWhenThereIsOneDigitOrLessEnteredRemainsTheSame() {
        serviceUnderTest.formatAndSetCardExpiry("")
        XCTAssertEqual(serviceUnderTest.cardExpiry, "")
        serviceUnderTest.formatAndSetCardExpiry("1")
        XCTAssertEqual(serviceUnderTest.cardExpiry, "1")
    }

    func testFormattingExpiryDateWithTwoDigitsFormatsCorrectly() {
        serviceUnderTest.formatAndSetCardExpiry("08")
        XCTAssertEqual(serviceUnderTest.cardExpiry, "08 / ")
    }

    func testFormattingExpiryDateWithMoreThanTwoDigitsFormatsCorrectly() {
        serviceUnderTest.formatAndSetCardExpiry("0825")
        XCTAssertEqual(serviceUnderTest.cardExpiry, "08 / 25")
    }

    func testFormattingExpiryDateThatWasAlreadyFormattedFormatsCorrectly() {
        serviceUnderTest.formatAndSetCardExpiry("08 / 2")
        XCTAssertEqual(serviceUnderTest.cardExpiry, "08 / 2")
    }

    func testDeletingExpiryDateDoesNotForceFormatting() {
        serviceUnderTest.cardExpiry = "08 / 2"
        serviceUnderTest.formatAndSetCardExpiry("08 /")
        XCTAssertEqual(serviceUnderTest.cardExpiry, "08 /")
    }

    func testFormIsInvalidIfNoDataIsEntered() {
        XCTAssertFalse(serviceUnderTest.isValid)
    }

    func testFormIsInvalidWhenFieldsHaveDataButDoNotMatchLength() {
        serviceUnderTest.cardExpiry = "01 / "
        serviceUnderTest.cardNumber = "1234 5678 9"
        serviceUnderTest.cvv = "12"
        XCTAssertFalse(serviceUnderTest.isValid)
    }

    func testFormIsInvalidWhenOnlySomeFieldsMeetRequirements() {
        serviceUnderTest.cardExpiry = "01 / 23"
        serviceUnderTest.cardNumber = "1234 5678 9012 1234"
        serviceUnderTest.cvv = "1"
        XCTAssertFalse(serviceUnderTest.isValid)
    }

    func testFormIsValidWhenAllFieldsMatchRequirements() {
        serviceUnderTest.cardExpiry = "01 / 23"
        serviceUnderTest.cardNumber = "1234 5678 9012 1234"
        serviceUnderTest.cvv = "123"
        XCTAssertTrue(serviceUnderTest.isValid)
    }

    func testSwitchingToTestModeCardSelectionCallsContainerToChangeState() {
        serviceUnderTest.switchToTestModeCardSelection()
        XCTAssertTrue(mockChargeCardContainer.switchedToTestMode)
    }

    func testSubmittingCardDetailsBuildsCardModelAndForwardsRepositoryResponseToContainer() async throws {
        serviceUnderTest.cardExpiry = "01 / 25"
        serviceUnderTest.cardNumber = "1234 5678 9012 1234"
        serviceUnderTest.cvv = "123"

        mockRepository.expectedChargeCardTransaction = .example
        await serviceUnderTest.submitCardDetails()

        let expectedCard = CardCharge(number: "1234 5678 9012 1234",
                                      cvv: "123",
                                      expiryMonth: "01",
                                      expiryYear: "25")

        XCTAssertEqual(mockRepository.cardDetailsSubmitted.card, expectedCard)
        XCTAssertEqual(mockChargeCardContainer.transactionResponse, .example)
    }

    func testSubmittingCardDetailsWithErrorForwardsErrorToCardContainer() async {
        let expectedErrorMessage = "Error Message"
        let expectedError: PaystackError = .response(code: 400, message: expectedErrorMessage)
        mockRepository.expectedErrorResponse = expectedError

        serviceUnderTest.cardExpiry = "01 / 25"
        serviceUnderTest.cardNumber = "1234 5678 9012 1234"
        serviceUnderTest.cvv = "123"
        await serviceUnderTest.submitCardDetails()

        XCTAssertEqual(mockChargeCardContainer.transactionError,
                       .init(message: expectedErrorMessage))
    }

}
