import XCTest
@testable import PaystackUI

final class MonthTests: XCTestCase {

    func testAllCasesReturnsAllCasesOfMonth() {
        let expectedCases: [Month] = [.january, .february, .march, .april, .may, .june,
                                      .july, .august, .september, .october, .november, .december]
        XCTAssertEqual(Month.allCases, expectedCases)
    }

    func testMonthDescription() {
        XCTAssertEqual(Month.january.description, "January")
        XCTAssertEqual(Month.february.description, "February")
        XCTAssertEqual(Month.march.description, "March")
        XCTAssertEqual(Month.april.description, "April")
        XCTAssertEqual(Month.may.description, "May")
        XCTAssertEqual(Month.june.description, "June")
        XCTAssertEqual(Month.july.description, "July")
        XCTAssertEqual(Month.august.description, "August")
        XCTAssertEqual(Month.september.description, "September")
        XCTAssertEqual(Month.october.description, "October")
        XCTAssertEqual(Month.november.description, "November")
        XCTAssertEqual(Month.december.description, "December")
    }

    func testMonthValue() {
        XCTAssertEqual(Month.january.rawValue, 1)
        XCTAssertEqual(Month.february.rawValue, 2)
        XCTAssertEqual(Month.march.rawValue, 3)
        XCTAssertEqual(Month.april.rawValue, 4)
        XCTAssertEqual(Month.may.rawValue, 5)
        XCTAssertEqual(Month.june.rawValue, 6)
        XCTAssertEqual(Month.july.rawValue, 7)
        XCTAssertEqual(Month.august.rawValue, 8)
        XCTAssertEqual(Month.september.rawValue, 9)
        XCTAssertEqual(Month.october.rawValue, 10)
        XCTAssertEqual(Month.november.rawValue, 11)
        XCTAssertEqual(Month.december.rawValue, 12)
    }

}
