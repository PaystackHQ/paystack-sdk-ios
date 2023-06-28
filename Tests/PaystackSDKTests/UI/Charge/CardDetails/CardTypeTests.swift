import XCTest
@testable import PaystackUI

final class CardTypeTests: XCTestCase {

    func testCorrectlyIdentifiesMastercardFromFirstFewDigits() {
        XCTAssertEqual(CardType.fromNumber("501"), .mastercard)
        XCTAssertEqual(CardType.fromNumber(" 5023"), .mastercard)
        XCTAssertEqual(CardType.fromNumber("506 578"), .mastercard)
        XCTAssertEqual(CardType.fromNumber("5900 1234 56"), .mastercard)
    }

    func testCorrectlyIdentifiesVisaFromFirstFewDigits() {
        XCTAssertEqual(CardType.fromNumber("4"), .visa)
        XCTAssertEqual(CardType.fromNumber(" 4123"), .visa)
        XCTAssertEqual(CardType.fromNumber("445 612"), .visa)
        XCTAssertEqual(CardType.fromNumber("4781 1234 56"), .visa)
    }

    func testCorrectlyIdentifiesVerveFromFirstFewDigits() {
        XCTAssertEqual(CardType.fromNumber(" 5060"), .verve)
        XCTAssertEqual(CardType.fromNumber("506 123"), .verve)
        XCTAssertEqual(CardType.fromNumber("6500 1234 56"), .verve)
    }

    func testCorrectlyIdentifiesDinersFromFirstFewDigits() {
        XCTAssertEqual(CardType.fromNumber("36"), .diners)
        XCTAssertEqual(CardType.fromNumber(" 3004"), .diners)
        XCTAssertEqual(CardType.fromNumber("305 123"), .diners)
        XCTAssertEqual(CardType.fromNumber("3091 1234 56"), .diners)
    }

    func testCorrectlyIdentifiesDiscoverFromFirstFewDigits() {
        XCTAssertEqual(CardType.fromNumber("64"), .discover)
        XCTAssertEqual(CardType.fromNumber(" 6223"), .discover)
        XCTAssertEqual(CardType.fromNumber("601 123"), .discover)
        XCTAssertEqual(CardType.fromNumber("6400 1234 56"), .discover)
    }

    func testCorrectlyIdentifiesAmexFromFirstFewDigits() {
        XCTAssertEqual(CardType.fromNumber("34"), .amex)
        XCTAssertEqual(CardType.fromNumber(" 3712"), .amex)
        XCTAssertEqual(CardType.fromNumber("341 123"), .amex)
        XCTAssertEqual(CardType.fromNumber("3700 1234 56"), .amex)
    }

    func testSetsTypeAsUnknownWhenNoTypeMatchFound() {
        XCTAssertEqual(CardType.fromNumber("123456"), .unknown)
    }

    func testFormatsAmexCardsCorrectly() {
        let numberWhilstTyping = "34123456789"
        XCTAssertEqual(CardType.fromNumber(numberWhilstTyping)
            .formatAndGroup(cardNumber: numberWhilstTyping), "3412 345678 9")

        let completedCardNumber = "341234567890123"
        XCTAssertEqual(CardType.fromNumber(completedCardNumber)
            .formatAndGroup(cardNumber: completedCardNumber), "3412 345678 90123")

        let cardNumberWithExtraDigits = "34123456789012345"
        XCTAssertEqual(CardType.fromNumber(cardNumberWithExtraDigits)
            .formatAndGroup(cardNumber: cardNumberWithExtraDigits), "3412 345678 90123 45")
    }

    func testFormatsDinersCardsCorrectly() {
        let numberWhilstTyping = "30023456789"
        XCTAssertEqual(CardType.fromNumber(numberWhilstTyping)
            .formatAndGroup(cardNumber: numberWhilstTyping), "3002 345678 9")

        let completedCardNumber = "30023456789012"
        XCTAssertEqual(CardType.fromNumber(completedCardNumber)
            .formatAndGroup(cardNumber: completedCardNumber), "3002 345678 9012")

        let cardNumberWithExtraDigits = "30023456789012345"
        XCTAssertEqual(CardType.fromNumber(cardNumberWithExtraDigits)
            .formatAndGroup(cardNumber: cardNumberWithExtraDigits), "3002 345678 9012 345")
    }

    func testFormatsStandardCardsCorrectly() {
        let numberWhilstTyping = "400234567"
        XCTAssertEqual(CardType.fromNumber(numberWhilstTyping)
            .formatAndGroup(cardNumber: numberWhilstTyping), "4002 3456 7")

        let completedCardNumber = "4002345678901234"
        XCTAssertEqual(CardType.fromNumber(completedCardNumber)
            .formatAndGroup(cardNumber: completedCardNumber), "4002 3456 7890 1234")

        let cardNumberWithExtraDigits = "400234567890123456"
        XCTAssertEqual(CardType.fromNumber(cardNumberWithExtraDigits)
            .formatAndGroup(cardNumber: cardNumberWithExtraDigits), "4002 3456 7890 1234 56")
    }

    func testFormattingEmptyStrings() {
        XCTAssertEqual(CardType.fromNumber("")
            .formatAndGroup(cardNumber: ""), "")

        XCTAssertEqual(CardType.fromNumber(" ")
            .formatAndGroup(cardNumber: " "), "")
    }

    func testMaximumCvvDigitsForAmexCards() {
        let amexCardNumber = "341234567890123"
        let cardType = CardType.fromNumber(amexCardNumber)
        XCTAssertEqual(cardType.maximumCvvDigits, 4)
    }

    func maximumCvvDigitsForAnyOtherCard() {
        let cardNumber = "4123456789012345"
        let cardType = CardType.fromNumber(cardNumber)
        XCTAssertEqual(cardType.maximumCvvDigits, 3)
    }

}
