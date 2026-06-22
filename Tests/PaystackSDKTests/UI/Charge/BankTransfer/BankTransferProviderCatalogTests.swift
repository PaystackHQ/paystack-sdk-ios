import XCTest
@testable import PaystackUI

final class BankTransferProviderCatalogTests: XCTestCase {

    func testDisplayNameForWemaBankSlug() {
        XCTAssertEqual(
            BankTransferProviderCatalog.displayName(forSlug: "wema-bank"),
            "Wema Bank")
    }

    func testDisplayNameForTitanPaystackSlug() {
        XCTAssertEqual(
            BankTransferProviderCatalog.displayName(forSlug: "titan-paystack"),
            "Paystack-Titan")
    }

    func testDisplayNameForPaystackMfbSlug() {
        XCTAssertEqual(
            BankTransferProviderCatalog.displayName(forSlug: "paystack-mfb"),
            "Paystack MFB")
    }

    func testDisplayNameIsCaseInsensitiveOnKnownSlugs() {
        XCTAssertEqual(
            BankTransferProviderCatalog.displayName(forSlug: "WEMA-BANK"),
            "Wema Bank")
        XCTAssertEqual(
            BankTransferProviderCatalog.displayName(forSlug: "Titan-Paystack"),
            "Paystack-Titan")
    }

    func testDisplayNameForUnknownSingleWordSlug() {
        XCTAssertEqual(
            BankTransferProviderCatalog.displayName(forSlug: "kuda"),
            "Kuda")
    }

    func testDisplayNameForUnknownMultiWordSlug() {
        XCTAssertEqual(
            BankTransferProviderCatalog.displayName(forSlug: "new-bank-here"),
            "New Bank Here")
    }

    func testDisplayNameForEmptySlugReturnsEmptyString() {
        XCTAssertEqual(
            BankTransferProviderCatalog.displayName(forSlug: ""),
            "")
    }

    func testDisplayNameStripsExtraDashes() {
        XCTAssertEqual(
            BankTransferProviderCatalog.displayName(forSlug: "fancy--bank"),
            "Fancy Bank")
    }
}
