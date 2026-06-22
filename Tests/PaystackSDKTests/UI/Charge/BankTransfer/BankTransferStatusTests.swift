import XCTest
@testable import PaystackUI

final class BankTransferStatusTests: XCTestCase {

    // MARK: - init(rawStatus:message:) — documented status strings

    func testInitMapsSuccessString() {
        XCTAssertEqual(
            BankTransferStatus(rawStatus: "success", message: nil),
            .success)
    }

    func testInitMapsTransferCreditRequestPendingString() {
        XCTAssertEqual(
            BankTransferStatus(rawStatus: "transfer-credit-request-pending", message: nil),
            .creditRequestPending)
    }

    func testInitMapsTransferCreditRequestReceivedString() {
        XCTAssertEqual(
            BankTransferStatus(rawStatus: "transfer-credit-request-received", message: nil),
            .creditRequestReceived)
    }

    func testInitMapsTransferCreditRequestRejectedString() {
        XCTAssertEqual(
            BankTransferStatus(rawStatus: "transfer-credit-request-rejected", message: nil),
            .creditRequestRejected)
    }

    func testInitMapsIncorrectAmountSentString() {
        XCTAssertEqual(
            BankTransferStatus(rawStatus: "incorrect-amount-sent", message: nil),
            .incorrectAmountSent)
    }

    func testInitMapsPendingString() {
        XCTAssertEqual(
            BankTransferStatus(rawStatus: "pending", message: nil),
            .pending)
    }

    func testInitMapsRequeryString() {
        XCTAssertEqual(
            BankTransferStatus(rawStatus: "requery", message: nil),
            .requery)
    }

    func testInitMapsFailedString() {
        XCTAssertEqual(
            BankTransferStatus(rawStatus: "failed", message: nil),
            .failed)
    }

    // MARK: - init(rawStatus:message:) — message field is ignored for disambiguation

    /// Regression: the legacy decoder used to route `failed` to
    /// `.incorrectAmount` when the message contained "incorrect amount".
    /// The new taxonomy maps `failed` directly to `.failed` regardless of
    /// message content — `incorrect-amount-sent` is the explicit status
    /// for the refund-initiated wrong-amount case.
    func testInitMapsFailedWithIncorrectAmountMessageToFailedNotIncorrectAmount() {
        XCTAssertEqual(
            BankTransferStatus(rawStatus: "failed", message: "incorrect amount sent"),
            .failed)
    }

    func testInitMapsFailedWithArbitraryMessageToFailed() {
        XCTAssertEqual(
            BankTransferStatus(rawStatus: "failed", message: "some other error"),
            .failed)
    }

    // MARK: - init(rawStatus:message:) — unknown strings

    func testInitWrapsUnknownRawStringInUnknownCase() {
        XCTAssertEqual(
            BankTransferStatus(rawStatus: "something-new-from-backend", message: nil),
            .unknown("something-new-from-backend"))
    }

    func testInitWrapsEmptyStringInUnknownCase() {
        XCTAssertEqual(
            BankTransferStatus(rawStatus: "", message: nil),
            .unknown(""))
    }

    // MARK: - isTerminal

    func testIsTerminalIsTrueForSuccess() {
        XCTAssertTrue(BankTransferStatus.success.isTerminal)
    }

    func testIsTerminalIsTrueForCreditRequestRejected() {
        XCTAssertTrue(BankTransferStatus.creditRequestRejected.isTerminal)
    }

    /// `incorrectAmountSent` flipped from non-terminal to terminal in the
    /// new taxonomy — the wrong-amount case is refund-initiated, not a
    /// retry-with-top-up case any more.
    func testIsTerminalIsTrueForIncorrectAmountSent() {
        XCTAssertTrue(BankTransferStatus.incorrectAmountSent.isTerminal)
    }

    func testIsTerminalIsTrueForFailed() {
        XCTAssertTrue(BankTransferStatus.failed.isTerminal)
    }

    func testIsTerminalIsFalseForCreditRequestReceived() {
        XCTAssertFalse(BankTransferStatus.creditRequestReceived.isTerminal)
    }

    func testIsTerminalIsFalseForCreditRequestPending() {
        XCTAssertFalse(BankTransferStatus.creditRequestPending.isTerminal)
    }

    func testIsTerminalIsFalseForPending() {
        XCTAssertFalse(BankTransferStatus.pending.isTerminal)
    }

    func testIsTerminalIsFalseForRequery() {
        XCTAssertFalse(BankTransferStatus.requery.isTerminal)
    }

    func testIsTerminalIsFalseForUnknown() {
        XCTAssertFalse(BankTransferStatus.unknown("anything").isTerminal)
    }
}
