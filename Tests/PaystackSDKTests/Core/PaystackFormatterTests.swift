import XCTest
@testable import PaystackCore

final class PaystackFormatterTests: XCTestCase {

    func testParsesIso8601UtcStringAsAbsoluteUtcTime() throws {
        let parsed = DateFormatter.paystackFormatter.date(from: "2024-01-01T12:00:00.000Z")

        let unwrapped = try XCTUnwrap(parsed)
        XCTAssertEqual(unwrapped.timeIntervalSince1970, 1704110400, accuracy: 0.001)
    }

    func testParsesFractionalSecondsCorrectly() throws {
        let parsed = DateFormatter.paystackFormatter.date(from: "2024-01-01T12:00:00.500Z")

        let unwrapped = try XCTUnwrap(parsed)
        XCTAssertEqual(unwrapped.timeIntervalSince1970, 1704110400.5, accuracy: 0.001)
    }

    func testRoundTripsADate() throws {
        let original = Date(timeIntervalSince1970: 1704110400)
        let encoded = DateFormatter.paystackFormatter.string(from: original)
        let decoded = DateFormatter.paystackFormatter.date(from: encoded)

        let unwrapped = try XCTUnwrap(decoded)
        XCTAssertEqual(unwrapped.timeIntervalSince1970,
                       original.timeIntervalSince1970,
                       accuracy: 0.001)
    }

    func testParsesPayWithTransferAccountExpiryAsFutureInstant() {
        let parsed = DateFormatter.paystackFormatter.date(from: "2026-06-02T15:18:37.053Z")

        XCTAssertNotNil(parsed)
        let june1 = Date(timeIntervalSince1970: 1748736000)
        XCTAssertGreaterThan(parsed!.timeIntervalSince(june1), 0)
    }

    func testParsedExpiryDifferenceIsTimezoneIndependent() {
        let provisioned = DateFormatter.paystackFormatter.date(from: "2024-01-01T12:00:00.000Z")
        let expires = DateFormatter.paystackFormatter.date(from: "2024-01-01T12:30:00.000Z")

        XCTAssertNotNil(provisioned)
        XCTAssertNotNil(expires)
        XCTAssertEqual(expires!.timeIntervalSince(provisioned!), 30 * 60, accuracy: 0.001)
    }

    func testReturnsNilForUnparseableString() {
        XCTAssertNil(DateFormatter.paystackFormatter.date(from: "not a date"))
    }
}
