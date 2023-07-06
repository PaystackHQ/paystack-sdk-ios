import XCTest
@testable import PaystackUI

final class DateTests: XCTestCase {

    func testMonthAndYearExpiryReturnsDateInExpectedStringRepresentation() {
        let date = Date(timeIntervalSince1970: 1688562061)
        let expectedRepresentation = "07/23"
        XCTAssertEqual(date.monthAndYearExpiry, expectedRepresentation)
    }

    func testStartOfMonthReturnsCorrectDate() {
        // 5 July 2023
        let randomDayInMonth = Date(timeIntervalSince1970: 1688562061)
        guard let firstDayInMonth = randomDayInMonth.startOfMonth else {
            XCTFail("Unable to calculate first day in month")
            return
        }

        let actualDateInCalendar = Calendar.current.dateComponents([.day, .month, .year], from: firstDayInMonth)
        let expectedCalendarDate = DateComponents(year: 2023, month: 7, day: 1)
        XCTAssertEqual(actualDateInCalendar, expectedCalendarDate)
    }

    func testStartfMonthReturnsFirstDayOfMonthFromFirstDayOfMonth() {
        // 1 July 2023
        let randomDayInMonth = Date(timeIntervalSince1970: 1688216461)
        guard let firstDayInMonth = randomDayInMonth.startOfMonth else {
            XCTFail("Unable to calculate first day in month")
            return
        }

        let actualDateInCalendar = Calendar.current.dateComponents([.day, .month, .year], from: firstDayInMonth)
        let expectedCalendarDate = DateComponents(year: 2023, month: 7, day: 1)
        XCTAssertEqual(actualDateInCalendar, expectedCalendarDate)
    }

    func testEndOfMonthReturnsCorrectDate() {
        // 5 July 2023
        let randomDayInMonth = Date(timeIntervalSince1970: 1688562061)
        guard let lastDayInMonth = randomDayInMonth.endOfMonth else {
            XCTFail("Unable to calculate last day in month")
            return
        }

        let actualDateInCalendar = Calendar.current.dateComponents([.day, .month, .year], from: lastDayInMonth)
        let expectedCalendarDate = DateComponents(year: 2023, month: 7, day: 31)
        XCTAssertEqual(actualDateInCalendar, expectedCalendarDate)
    }

    func testEndOfMonthReturnsLastDayOfMonthOnLastDayOfMonth() {
        // 31 July 2023
        let randomDayInMonth = Date(timeIntervalSince1970: 1690808461)
        guard let lastDayInMonth = randomDayInMonth.endOfMonth else {
            XCTFail("Unable to calculate last day in month")
            return
        }

        let actualDateInCalendar = Calendar.current.dateComponents([.day, .month, .year], from: lastDayInMonth)
        let expectedCalendarDate = DateComponents(year: 2023, month: 7, day: 31)
        XCTAssertEqual(actualDateInCalendar, expectedCalendarDate)
    }
}
