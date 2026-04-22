import XCTest
@testable import PaystackUI

final class StringExtensionsTests: XCTestCase {

    // MARK: - formattedKenyanPhoneNumber

    func testFormattedKenyanPhoneNumberWithLeadingZeroReplacesZeroWithCountryCode() {
        let phone = "0703362111"
        XCTAssertEqual(phone.formattedKenyanPhoneNumber, "+254703362111")
    }

    func testFormattedKenyanPhoneNumberWithLeading254PrependsPlus() {
        let phone = "254703362111"
        XCTAssertEqual(phone.formattedKenyanPhoneNumber, "+254703362111")
    }

    func testFormattedKenyanPhoneNumberWithLeadingPlus254ReturnsSameNumber() {
        let phone = "+254703362111"
        XCTAssertEqual(phone.formattedKenyanPhoneNumber, "+254703362111")
    }

    func testFormattedKenyanPhoneNumberStripsWhitespaceBeforeFormatting() {
        let phone = " 0703 362 111 "
        XCTAssertEqual(phone.formattedKenyanPhoneNumber, "+254703362111")
    }

    func testFormattedKenyanPhoneNumberWithUnrecognisedPrefixReturnsInputWithoutWhitespace() {
        let phone = "7033 62111"
        XCTAssertEqual(phone.formattedKenyanPhoneNumber, "703362111")
    }
}
