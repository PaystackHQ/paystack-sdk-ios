import XCTest
@testable import PaystackUI

final class CardDetailsViewModelTests: XCTestCase {

    var serviceUnderTest: CardDetailsViewModel!
    var mockVerifyAccessCodeResponse = VerifyAccessCode(amount: 100, currency: "USD",
                                                        paymentChannels: ["card"], domain: .test)

    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceUnderTest = CardDetailsViewModel(transactionDetails: mockVerifyAccessCodeResponse)
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

}
