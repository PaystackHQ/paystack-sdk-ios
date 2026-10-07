import XCTest
@testable import PaystackCore
@testable import PaystackUI

final class UIElementVisibilityTests: XCTestCase {

    private let futureAudience = DisplayAudience(id: "future")

    func testZapQRCodeReturnsFalseWhenCustomerFacing() {
        XCTAssertFalse(DisplayAudience.customerFacing.shows(.zapQRCode))
    }

    func testZapQRCodeReturnsTrueWhenMerchantFacing() {
        XCTAssertTrue(DisplayAudience.merchantFacing.shows(.zapQRCode))
    }

    func testZapQRCodeFollowsCustomerFacingForUnknownAudience() {
        XCTAssertFalse(futureAudience.shows(.zapQRCode))
    }

    func testZapOpenAppButtonReturnsTrueWhenCustomerFacing() {
        XCTAssertTrue(DisplayAudience.customerFacing.shows(.zapOpenAppButton))
    }

    func testZapOpenAppButtonReturnsFalseWhenMerchantFacing() {
        XCTAssertFalse(DisplayAudience.merchantFacing.shows(.zapOpenAppButton))
    }

    func testZapOpenAppButtonFollowsCustomerFacingForUnknownAudience() {
        XCTAssertTrue(futureAudience.shows(.zapOpenAppButton))
    }

    func testZapShowsExactlyOnePaymentAffordanceForEveryAudience() {
        for audience in [DisplayAudience.customerFacing, .merchantFacing, futureAudience] {
            let visible = [audience.shows(.zapQRCode), audience.shows(.zapOpenAppButton)]
                .filter { $0 }
            XCTAssertEqual(visible.count, 1, "Audience \(audience.id) must show exactly one Zap payment option")
        }
    }

    func testZapInstructionTextForCustomerFacing() {
        XCTAssertEqual(DisplayAudience.customerFacing.text(.zapInstruction),
                       "Open Zap to complete this payment")
    }

    func testZapInstructionTextForMerchantFacing() {
        XCTAssertEqual(DisplayAudience.merchantFacing.text(.zapInstruction),
                       "Scan this QR code with Zap to complete this payment")
    }

    func testZapInstructionTextFallsBackToCustomerWordingForUnknownAudience() {
        XCTAssertEqual(futureAudience.text(.zapInstruction),
                       DisplayAudience.customerFacing.text(.zapInstruction))
    }
}
