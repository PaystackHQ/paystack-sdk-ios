import XCTest
@testable import PaystackUI

final class StringExtensionsTests: XCTestCase {

    // MARK: - formatted(for:)

    func testFormattedForKenyanProviderWithLeadingZeroReplacesZeroWithCountryCode() {
        let phone = "0703362111"
        XCTAssertEqual(phone.formatted(for: .mpesa), "+254703362111")
    }

    func testFormattedForKenyanProviderWithLeading254PrependsPlus() {
        let phone = "254703362111"
        XCTAssertEqual(phone.formatted(for: .mpesa), "+254703362111")
    }

    func testFormattedForKenyanProviderWithLeadingPlus254ReturnsSameNumber() {
        let phone = "+254703362111"
        XCTAssertEqual(phone.formatted(for: .mpesa), "+254703362111")
    }

    func testFormattedForStripsWhitespaceBeforeFormatting() {
        let phone = " 0703 362 111 "
        XCTAssertEqual(phone.formatted(for: .mpesa), "+254703362111")
    }

    func testFormattedForWithUnrecognisedPrefixReturnsInputWithoutWhitespace() {
        let phone = "7033 62111"
        XCTAssertEqual(phone.formatted(for: .mpesa), "703362111")
    }

    // MARK: - Cross-provider behaviour

    func testFormattedForGhanaianProviderUsesGhanaCountryCode() {
        let phone = "0241234567"
        XCTAssertEqual(phone.formatted(for: .mtn), "+233241234567")
    }

    func testFormattedForReturnsTrimmedInputWhenProviderHasNoCountryCode() {
        let unknownProvider = MobileMoneyChannel(key: "UNKNOWN",
                                                 value: "Unknown",
                                                 isNew: false,
                                                 phoneNumberRegex: "")
        let phone = "0703362111"
        XCTAssertEqual(phone.formatted(for: unknownProvider), "0703362111")
    }
}

// MARK: - Test fixtures

private extension MobileMoneyChannel {
    static let mpesa = MobileMoneyChannel(key: "MPESA",
                                          value: "M-PESA",
                                          isNew: true,
                                          phoneNumberRegex: "")
    static let mtn = MobileMoneyChannel(key: "MTN",
                                        value: "MTN",
                                        isNew: false,
                                        phoneNumberRegex: "")
}
