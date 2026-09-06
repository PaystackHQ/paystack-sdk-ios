import XCTest
@testable import PaystackCore
@testable import PaystackUI

final class ChargeCapitecTransactionTests: XCTestCase {

    // MARK: - Pusher envelope

    func testFromPusherResponseMapsNestedDataStatus() {
        let response = CapitecPusherResponse(
            status: true,
            type: "success",
            code: "ok",
            message: "Charge successful",
            data: CapitecPusherResponseData(status: "success"))

        XCTAssertEqual(ChargeCapitecTransaction.from(response),
                       ChargeCapitecTransaction(status: "success",
                                                message: "Charge successful"))
    }

    func testFromPusherResponseMapsFalseStatusToFailedRegardlessOfData() {
        let response = CapitecPusherResponse(
            status: false,
            message: "Bank declined",
            data: nil)

        XCTAssertEqual(ChargeCapitecTransaction.from(response),
                       ChargeCapitecTransaction(status: "failed",
                                                message: "Bank declined"))
    }

    func testFromPusherResponseWithFalseStatusIgnoresContradictoryData() {
        let response = CapitecPusherResponse(
            status: false,
            message: "Charge failed",
            data: CapitecPusherResponseData(status: "success"))

        XCTAssertEqual(ChargeCapitecTransaction.from(response).status, "failed")
    }

    func testFromPusherResponseWithMissingDataIsNonTerminal() {
        let response = CapitecPusherResponse(status: true,
                                             message: "Charge pending",
                                             data: nil)

        XCTAssertEqual(ChargeCapitecTransaction.from(response).status, "")
    }

    func testFromPusherResponseNormalisesCasingAndWhitespace() {
        let response = CapitecPusherResponse(
            status: true,
            data: CapitecPusherResponseData(status: " SUCCESS "))

        XCTAssertEqual(ChargeCapitecTransaction.from(response).status, "success")
    }

    // MARK: - Requery envelope

    func testFromRequeryResponseMapsStatusAndMessage() {
        let response = CapitecResponse(status: true,
                                       message: "Charge successful",
                                       data: CapitecResponseData(status: "success"))

        XCTAssertEqual(ChargeCapitecTransaction.from(response),
                       ChargeCapitecTransaction(status: "success",
                                                message: "Charge successful"))
    }
}
