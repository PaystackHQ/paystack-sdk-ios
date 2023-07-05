import XCTest
@testable import PaystackUI

final class CardInfoValidationTests: XCTestCase {

    var cachedTimezone: TimeZone?

    override func setUpWithError() throws {
        try super.setUpWithError()
        cachedTimezone = TimeZone.current
        NSTimeZone.default = TimeZone(secondsFromGMT: 2 * 60 * 60) ?? .current
    }

    override func tearDownWithError() throws {
        NSTimeZone.default = cachedTimezone ?? .current
        try super.tearDownWithError()
    }

    // MARK: Card Expiry Validator

    func testCardExpiryReturnsFalseWhenDateIsNotCompleted() {
        let validator = CardInfoValidator.cardExpiry("07 / ", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testCardExpiryReturnsFalseWhenDateIsNotValid() {
        let validator = CardInfoValidator.cardExpiry("13 / 23", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testCardExpiryReturnsFalseWhenDateIsInThePast() {
        // 7 July 2023
        let currentDate = Date(timeIntervalSince1970: 1688216461)
        let validator = CardInfoValidator.cardExpiry("01 / 20", errorMessage: "Error",
                                                     currentDateOverride: currentDate)
        XCTAssertFalse(validator.validate())
    }

    func testCardExpiryReturnsFalseWhenDateIsOneDayAfterExpiry() {
        // 1 August 2023
        let currentDate = Date(timeIntervalSince1970: 1690894861)
        let validator = CardInfoValidator.cardExpiry("07 / 23", errorMessage: "Error",
                                                     currentDateOverride: currentDate)
        XCTAssertFalse(validator.validate())
    }

    func testCardExpiryReturnsTrueWhenDateIsValid() {
        // 7 July 2023
        let currentDate = Date(timeIntervalSince1970: 1688216461)
        let validator = CardInfoValidator.cardExpiry("01 / 24", errorMessage: "Error",
                                                     currentDateOverride: currentDate)
        XCTAssertTrue(validator.validate())
    }

    func testCardExpiryReturnsTrueWhenDateIsInFinalValidMonth() {
        // 31 July 2023
        let currentDate = Date(timeIntervalSince1970: 1690840799)
        let validator = CardInfoValidator.cardExpiry("07 / 23", errorMessage: "Error",
                                                     currentDateOverride: currentDate)
        XCTAssertTrue(validator.validate())
    }

    // MARK: Card Number Validator

    func testCardNumberReturnsFalseWhenVisaNumberDoesNotMatchRegex() {
        let validator = CardInfoValidator.cardNumber("4242 4242 42", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testCardNumberReturnsFalseWhenVisaNumberMatchesRegexButDoesNotPassLuhns() {
        let validator = CardInfoValidator.cardNumber("4242 4242 4242 4243", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testCardNumberReturnsTrueWhenVisaNumberIsValid() {
        let validator = CardInfoValidator.cardNumber("4242 4242 4242 4242", errorMessage: "Error")
        XCTAssertTrue(validator.validate())
    }

    func testCardNumberReturnsFalseWhenMastercardNumberDoesNotMatchRegex() {
        let validator = CardInfoValidator.cardNumber("5255 5555 5555 4444", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testCardNumberReturnsFalseWhenMastercardNumberMatchesRegexButDoesNotPassLuhns() {
        let validator = CardInfoValidator.cardNumber("5555 5555 5555 4445", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testCardNumberReturnsTrueWhenMastercardNumberIsValid() {
        let validator = CardInfoValidator.cardNumber("5555 5555 5555 4444", errorMessage: "Error")
        XCTAssertTrue(validator.validate())
    }

    func testCardNumberReturnsFalseWhenAmexNumberDoesNotMatchRegex() {
        let validator = CardInfoValidator.cardNumber("378 822463 10005", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testCardNumberReturnsFalseWhenAmexNumberMatchesRegexButDoesNotPassLuhns() {
        let validator = CardInfoValidator.cardNumber("3782 822463 10006", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testCardNumberReturnsTrueWhenAmexNumberIsValid() {
        let validator = CardInfoValidator.cardNumber("3782 822463 10005", errorMessage: "Error")
        XCTAssertTrue(validator.validate())
    }

    func testCardNumberReturnsFalseWhenDinersNumberDoesNotMatchRegex() {
        let validator = CardInfoValidator.cardNumber("378 822463 10005", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testCardNumberReturnsFalseWhenDinersNumberMatchesRegexButDoesNotPassLuhns() {
        let validator = CardInfoValidator.cardNumber("3622 72062 1668", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testCardNumberReturnsTrueWhenDinersNumberIsValid() {
        let validator = CardInfoValidator.cardNumber("3622 720627 1667", errorMessage: "Error")
        XCTAssertTrue(validator.validate())
    }

    func testCardNumberReturnsFalseWhenDiscoverNumberDoesNotMatchRegex() {
        let validator = CardInfoValidator.cardNumber("6011 0009 9013 942", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testCardNumberReturnsFalseWhenDiscoverNumberMatchesRegexButDoesNotPassLuhns() {
        let validator = CardInfoValidator.cardNumber("6011 0009 9013 9425", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testCardNumberReturnsTrueWhenDiscoverNumberIsValid() {
        let validator = CardInfoValidator.cardNumber("6011 0009 9013 9424", errorMessage: "Error")
        XCTAssertTrue(validator.validate())
    }

    func testCardNumberReturnsFalseWhenJCBNumberDoesNotMatchRegex() {
        let validator = CardInfoValidator.cardNumber("3566 0020 2036 050", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testCardNumberReturnsFalseWhenJCBNumberMatchesRegexButDoesNotPassLuhns() {
        let validator = CardInfoValidator.cardNumber("3566 0020 2036 0506", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testCardNumberReturnsTrueWhenJCBNumberIsValid() {
        let validator = CardInfoValidator.cardNumber("3566 0020 2036 0505", errorMessage: "Error")
        XCTAssertTrue(validator.validate())
    }

    func testCardNumberReturnsFalseWhenVerveNumberDoesNotMatchRegex() {
        let validator = CardInfoValidator.cardNumber("5061 3602 0433 2006 87", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testCardNumberReturnsFalseWhenVerveNumberMatchesRegexButDoesNotPassLuhns() {
        let validator = CardInfoValidator.cardNumber("5061 3602 0433 2006 808", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testCardNumberReturnsTrueWhenVerveNumberIsValid() {
        let validator = CardInfoValidator.cardNumber("5061 3602 0433 2006 807", errorMessage: "Error")
        XCTAssertTrue(validator.validate())
    }
}
