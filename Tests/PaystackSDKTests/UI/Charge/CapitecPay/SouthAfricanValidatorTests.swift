import XCTest
@testable import PaystackUI

final class SouthAfricanPhoneValidatorTests: XCTestCase {

    func testAcceptsValidCellphoneNumberStartingWith06() {
        XCTAssertTrue(SouthAfricanPhoneValidator.isValid("0609603632"))
    }

    func testAcceptsValidCellphoneNumberStartingWith07() {
        XCTAssertTrue(SouthAfricanPhoneValidator.isValid("0721234567"))
    }

    func testAcceptsValidCellphoneNumberStartingWith08() {
        XCTAssertTrue(SouthAfricanPhoneValidator.isValid("0821234567"))
    }

    func testRejectsCellphoneNumberStartingWithWrongPrefix() {
        XCTAssertFalse(SouthAfricanPhoneValidator.isValid("0509603632"))
    }

    func testRejectsCellphoneNumberThatIsTooShort() {
        XCTAssertFalse(SouthAfricanPhoneValidator.isValid("060960363"))
    }

    func testRejectsCellphoneNumberThatIsTooLong() {
        XCTAssertFalse(SouthAfricanPhoneValidator.isValid("06096036320"))
    }

    func testRejectsCellphoneNumberContainingLetters() {
        XCTAssertFalse(SouthAfricanPhoneValidator.isValid("06AB603632"))
    }

    func testRejectsEmptyString() {
        XCTAssertFalse(SouthAfricanPhoneValidator.isValid(""))
    }
}

final class SouthAfricanIDValidatorTests: XCTestCase {

    func testAcceptsAKnownValidSouthAfricanID() {
        XCTAssertTrue(SouthAfricanIDValidator.isValid("8001015009087"))
    }

    func testRejectsIDWithWrongLength() {
        XCTAssertFalse(SouthAfricanIDValidator.isValid("800101500908"))
        XCTAssertFalse(SouthAfricanIDValidator.isValid("80010150090870"))
    }

    func testRejectsIDWithNonNumericCharacters() {
        XCTAssertFalse(SouthAfricanIDValidator.isValid("8001015X09087"))
    }

    func testRejectsIDWithInvalidDatePortion() {
        XCTAssertFalse(SouthAfricanIDValidator.isValid("9902305009087"))
    }

    func testRejectsIDWithInvalidLuhnChecksum() {
        XCTAssertFalse(SouthAfricanIDValidator.isValid("8001015009088"))
    }

    func testRejectsEmptyString() {
        XCTAssertFalse(SouthAfricanIDValidator.isValid(""))
    }
}
