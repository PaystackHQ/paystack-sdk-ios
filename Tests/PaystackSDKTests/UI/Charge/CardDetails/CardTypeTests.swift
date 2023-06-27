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

}
