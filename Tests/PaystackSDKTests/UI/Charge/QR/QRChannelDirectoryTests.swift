import XCTest
@testable import PaystackUI

final class QRChannelDirectoryTests: XCTestCase {

    func testMPASSOLTIProducesScanToPayThenSnapScan() {
        let entries = QRChannelDirectory.entries(
            for: ["MPASS_OLTI"],
            transactionId: 5900549926)

        XCTAssertEqual(entries.count, 2)
        guard case .scanToPay(let scanConfig) = entries[0] else {
            XCTFail("Expected .scanToPay first, got \(entries[0])")
            return
        }
        guard case .snapScan(let snapConfig) = entries[1] else {
            XCTFail("Expected .snapScan second, got \(entries[1])")
            return
        }
        XCTAssertEqual(scanConfig.variant, .scanToPay)
        XCTAssertEqual(scanConfig.channelOption, "MPASS_OLTI")
        XCTAssertEqual(scanConfig.transactionId, 5900549926)
        XCTAssertEqual(snapConfig.variant, .snapScan)
        XCTAssertEqual(snapConfig.channelOption, "MPASS_OLTI")
        XCTAssertEqual(snapConfig.transactionId, 5900549926)
    }

    func testUnknownProviderCodeProducesEmpty() {
        let entries = QRChannelDirectory.entries(
            for: ["FUTURE_PROVIDER_XYZ"],
            transactionId: 1234)

        XCTAssertTrue(entries.isEmpty)
    }

    func testEmptyOptionsProducesEmpty() {
        let entries = QRChannelDirectory.entries(
            for: [],
            transactionId: 1234)

        XCTAssertTrue(entries.isEmpty)
    }

    func testForwardsTransactionIdIntoBothConfigs() {
        let entries = QRChannelDirectory.entries(
            for: ["MPASS_OLTI"],
            transactionId: 424242)

        for entry in entries {
            switch entry {
            case .scanToPay(let config), .snapScan(let config):
                XCTAssertEqual(config.transactionId, 424242)
            default:
                XCTFail("Unexpected channel type \(entry)")
            }
        }
    }
}
