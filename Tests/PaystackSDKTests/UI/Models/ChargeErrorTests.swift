import XCTest
import PaystackCore
@testable import PaystackUI

final class ChargeErrorTests: PSTestCase {

    func testInitializingWithMessageBuildsErrorAsCustom() {
        let expectedMessage = "Error Message"
        let error = ChargeError(message: expectedMessage)
        XCTAssertEqual(error, .custom(message: expectedMessage))
    }

    func testInitializingWithNonPaystackErrorBuildsErrorAsGeneric() {
        let errorResponse = MockError.general
        let error = ChargeError(error: errorResponse)
        XCTAssertEqual(error, .generic)
    }

    func testInitializingWithPaystackErrorWithoutMessageBuildsErrorAsGeneric() {
        let errorResponse = PaystackError.technical
        let error = ChargeError(error: errorResponse)
        XCTAssertEqual(error, .generic)
    }

    func testInitializingWithPaystackErrorWithMessageBuildsErrorAsPaystackResponse() {
        let expectedMessage = "Error Message"
        let errorResponse = PaystackError.response(code: 400, message: expectedMessage)
        let error = ChargeError(error: errorResponse)
        XCTAssertEqual(error, .paystackResponse(message: expectedMessage))
    }

}
