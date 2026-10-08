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

    func testBankTransferCopyButtonsReturnsTrueWhenCustomerFacing() {
        XCTAssertTrue(DisplayAudience.customerFacing.shows(.bankTransferCopyButtons))
    }

    func testBankTransferCopyButtonsReturnsFalseWhenMerchantFacing() {
        XCTAssertFalse(DisplayAudience.merchantFacing.shows(.bankTransferCopyButtons))
    }

    func testBankTransferCopyButtonsFollowsCustomerFacingForUnknownAudience() {
        XCTAssertTrue(futureAudience.shows(.bankTransferCopyButtons))
    }

    func testScanToPayQRCodeReturnsFalseWhenCustomerFacing() {
        XCTAssertFalse(DisplayAudience.customerFacing.shows(.scanToPayQRCode))
    }

    func testScanToPayQRCodeReturnsTrueWhenMerchantFacing() {
        XCTAssertTrue(DisplayAudience.merchantFacing.shows(.scanToPayQRCode))
    }

    func testScanToPayQRCodeFollowsCustomerFacingForUnknownAudience() {
        XCTAssertFalse(futureAudience.shows(.scanToPayQRCode))
    }

    func testScanToPayQRNumberReturnsTrueWhenCustomerFacing() {
        XCTAssertTrue(DisplayAudience.customerFacing.shows(.scanToPayQRNumber))
    }

    func testScanToPayQRNumberReturnsFalseWhenMerchantFacing() {
        XCTAssertFalse(DisplayAudience.merchantFacing.shows(.scanToPayQRNumber))
    }

    func testScanToPayQRNumberFollowsCustomerFacingForUnknownAudience() {
        XCTAssertTrue(futureAudience.shows(.scanToPayQRNumber))
    }

    func testScanToPaySeeAppsButtonReturnsTrueWhenCustomerFacing() {
        XCTAssertTrue(DisplayAudience.customerFacing.shows(.scanToPaySeeAppsButton))
    }

    func testScanToPaySeeAppsButtonReturnsFalseWhenMerchantFacing() {
        XCTAssertFalse(DisplayAudience.merchantFacing.shows(.scanToPaySeeAppsButton))
    }

    func testScanToPaySeeAppsButtonFollowsCustomerFacingForUnknownAudience() {
        XCTAssertTrue(futureAudience.shows(.scanToPaySeeAppsButton))
    }

    func testScanToPayShowsExactlyOnePaymentEntryPointForEveryAudience() {
        for audience in [DisplayAudience.customerFacing, .merchantFacing, futureAudience] {
            let visible = [audience.shows(.scanToPayQRCode), audience.shows(.scanToPaySeeAppsButton)]
                .filter { $0 }
            XCTAssertEqual(visible.count, 1, "Audience \(audience.id) must show exactly one Scan to Pay entry point")
        }
    }

    func testScanToPayInstructionTextForCustomerFacing() {
        XCTAssertEqual(DisplayAudience.customerFacing.text(.scanToPayInstruction),
                       "Open any Scan to Pay app to complete this payment")
    }

    func testScanToPayInstructionTextForMerchantFacing() {
        XCTAssertEqual(DisplayAudience.merchantFacing.text(.scanToPayInstruction),
                       "Open any Scan to Pay app on your phone to scan the QR code")
    }

    func testScanToPayInstructionTextFallsBackToCustomerWordingForUnknownAudience() {
        XCTAssertEqual(futureAudience.text(.scanToPayInstruction),
                       DisplayAudience.customerFacing.text(.scanToPayInstruction))
    }
}
