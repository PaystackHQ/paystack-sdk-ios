import XCTest
@testable import PaystackUI

class SimpleValidatorTests: XCTestCase {

    func testRequiredReturnsTrueForNonEmptyString() throws {
        let validator = SimpleValidator.required("Test", errorMessage: "Error")
        XCTAssert(validator.validate())
    }

    func testRequiredReturnsFalseForEmptyString() throws {
        let validator = SimpleValidator.required("", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testRequiredReturnsTrueForNonNilValue() throws {
        let test: Int? = 1
        let validator = SimpleValidator.required(test, errorMessage: "Error")
        XCTAssert(validator.validate())
    }

    func testRequiredReturnsFalseForNilValue() throws {
        let test: Int? = nil
        let validator = SimpleValidator.required(test, errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testRequiredReturnsTrueForNonEmptyArray() throws {
        let validator = SimpleValidator.required(["Test"], errorMessage: "Error")
        XCTAssert(validator.validate())
    }

    func testRequiredReturnsFalseForEmptyArray() throws {
        let validator = SimpleValidator.required([], errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testMinLengthReturnsTrue() throws {
        let validator = SimpleValidator.minLength(3, text: "123", errorMessage: "Error")
        XCTAssert(validator.validate())
    }

    func testMinLengthReturnsFalseForTextLessThanLength() throws {
        let validator = SimpleValidator.minLength(3, text: "12", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testGreaterThanReturnsTrue() throws {
        let validator = SimpleValidator.greaterThan(5, text: "6", errorMessage: "Error")
        XCTAssert(validator.validate())
    }

    func testGreaterThanReturnsFalseForNumberEqualToGreaterThan() throws {
        let validator = SimpleValidator.greaterThan(5, text: "5", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testGreaterThanReturnsFalseForNonNumberString() throws {
        let validator = SimpleValidator.greaterThan(5, text: "Test", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testLessThanReturnsTrue() throws {
        let validator = SimpleValidator.lessThan(5, text: "4", errorMessage: "Error")
        XCTAssert(validator.validate())
    }

    func testLessThanReturnsFalseForNumberEqualToLessThan() throws {
        let validator = SimpleValidator.lessThan(5, text: "5", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

    func testLessThanReturnsFalseForNonNumberString() throws {
        let validator = SimpleValidator.lessThan(5, text: "Test", errorMessage: "Error")
        XCTAssertFalse(validator.validate())
    }

}
