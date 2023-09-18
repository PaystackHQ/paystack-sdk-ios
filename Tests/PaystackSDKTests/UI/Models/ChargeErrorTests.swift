import XCTest
import PaystackCore
@testable import PaystackUI

final class ChargeErrorTests: PSTestCase {

    func testInitializingWithMessage() {
        let expectedMessage = "Error Message"
        let error = ChargeError(message: expectedMessage)
        XCTAssertEqual(error, .init(message: expectedMessage))
    }

    func testInitializingWithMessageAndCause() {
        let expectedMessage = "Error Message"
        let expectedCauseMessage = "Cause Message"

        let error = ChargeError(displayMessage: expectedMessage, causeMessage: expectedCauseMessage)
        XCTAssertEqual(error.message, expectedMessage)
        XCTAssertEqual(error.cause?.localizedDescription, expectedCauseMessage)
    }

    func testInitializingWithChargeErrorInitializesAsSelf() {
        let expectedMessage = "Error Message"
        let chargeError = ChargeError(message: expectedMessage)
        let error = ChargeError(error: chargeError)
        XCTAssertEqual(error, chargeError)
    }

    func testInitializingWithNonPaystackErrorAddsErrorToInnerErrorAndSetsGenericMessage() {
        let errorResponse = MockError.general
        let error = ChargeError(error: errorResponse)
        XCTAssertEqual(error.message, "Something went wrong")
        XCTAssertEqual(error.cause as? MockError, errorResponse)
    }

    func testInitializingWithPaystackErrorWithoutMessageAddsErrorToInnerErrorAndSetsGenericMessage() {
        let errorResponse = PaystackError.technical
        let error = ChargeError(error: errorResponse)
        XCTAssertEqual(error.message, "Something went wrong")
        XCTAssertEqual(error.cause as? PaystackError, errorResponse)
    }

    func testInitializingWithPaystackErrorWithMessageAddsErrorToInnerErrorAndSetsMessage() {
        let expectedMessage = "Error Message"
        let errorResponse = PaystackError.response(code: 400, message: expectedMessage)
        let error = ChargeError(error: errorResponse)
        XCTAssertEqual(error.message, expectedMessage)
        XCTAssertEqual(error.cause as? PaystackError, errorResponse)
    }

}
