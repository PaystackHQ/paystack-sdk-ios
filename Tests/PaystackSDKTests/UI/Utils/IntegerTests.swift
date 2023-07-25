import XCTest
@testable import PaystackUI

final class IntegerTests: XCTestCase {

    func testFormattingAsMinutesAndSecondsWithSecondsUnderSixty() {
        let seconds = 42
        let expectedResult = "00:42"
        XCTAssertEqual(seconds.formatSecondsAsMinutesAndSeconds(), expectedResult)
    }

    func testFormattingAsMinutesAndSecondsWithSecondsOverSixty() {
        let seconds = 92
        let expectedResult = "01:32"
        XCTAssertEqual(seconds.formatSecondsAsMinutesAndSeconds(), expectedResult)
    }

    func testFormattingAsMinutesAndSecondsWithZeroSeconds() {
        let seconds = 0
        let expectedResult = "00:00"
        XCTAssertEqual(seconds.formatSecondsAsMinutesAndSeconds(), expectedResult)
    }

    func testFormattingAsMinutesAndSecondsWithANegativeNumber() {
        let seconds = -2
        let expectedResult = "00:00"
        XCTAssertEqual(seconds.formatSecondsAsMinutesAndSeconds(), expectedResult)
    }

}
