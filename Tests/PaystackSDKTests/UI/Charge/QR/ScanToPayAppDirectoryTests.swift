import XCTest
@testable import PaystackUI

final class ScanToPayAppDirectoryTests: XCTestCase {

    private let qrCode = "1490884538"

    func testDirectoryListsAppsInAgreedOrder() {
        XCTAssertEqual(ScanToPayAppDirectory.apps.map(\.name), [
            "Absa Scan to Pay",
            "Avo",
            "Capitec",
            "FNB Pay",
            "Instapay",
            "Nedbank Money",
            "Nedbank Scan to Pay",
            "RMB",
            "Spot",
            "Standard Bank Scan to Pay",
            "Telkom Pay",
            "Scan to Pay",
            "Vodapay"
        ])
    }

    func testAppNamesAndIconAssetsAreUnique() {
        let apps = ScanToPayAppDirectory.apps
        XCTAssertEqual(Set(apps.map(\.name)).count, apps.count)
        XCTAssertEqual(Set(apps.map(\.iconAsset)).count, apps.count)
    }

    func testIconAssetsFollowNamingConvention() {
        for app in ScanToPayAppDirectory.apps {
            XCTAssertTrue(app.iconAsset.hasPrefix("scanToPayApp"), "\(app.name) has icon asset \(app.iconAsset)")
            XCTAssertGreaterThan(app.iconAsset.count, "scanToPayApp".count)
        }
    }

    func testFNBPayAndRMBUseFNBDeeplink() {
        XCTAssertEqual(styles(named: ["FNB Pay", "RMB"]), [.fnb, .fnb])
    }

    func testNedbankMoneyUsesNedbankDeeplink() {
        XCTAssertEqual(styles(named: ["Nedbank Money"]), [.nedbank])
    }

    func testAllOtherAppsUseGenericDeeplink() {
        let others = ScanToPayAppDirectory.apps.filter { !["FNB Pay", "RMB", "Nedbank Money"].contains($0.name) }
        XCTAssertEqual(others.count, 10)
        XCTAssertTrue(others.allSatisfy { $0.deeplinkStyle == .generic })
    }

    func testFNBDeeplinkURL() {
        let app = ScanToPayApp(name: "FNB Pay", iconAsset: "scanToPayAppFNB", deeplinkStyle: .fnb)
        XCTAssertEqual(app.deeplink(for: qrCode)?.absoluteString,
                       "https://www.online.fnb.co.za/banking/mobileservices"
                       + "?codetype=masterpassdeeplink&urlencodedqr=1490884538")
    }

    func testNedbankDeeplinkURL() {
        let app = ScanToPayApp(name: "Nedbank Money", iconAsset: "scanToPayAppNedbankMoney", deeplinkStyle: .nedbank)
        XCTAssertEqual(app.deeplink(for: qrCode)?.absoluteString,
                       "nedbank://masterpass.oltio.co.za/1490884538")
    }

    func testGenericDeeplinkURL() {
        let app = ScanToPayApp(name: "Capitec", iconAsset: "scanToPayAppCapitec", deeplinkStyle: .generic)
        XCTAssertEqual(app.deeplink(for: qrCode)?.absoluteString,
                       "masterpass.app.scheme://masterpass.oltio.co.za/1490884538")
    }

    func testEncoderEscapesReservedCharactersLikeEncodeURIComponent() {
        XCTAssertEqual(URIComponentEncoder.encode("a b/c?d&e=f"), "a%20b%2Fc%3Fd%26e%3Df")
        XCTAssertEqual(URIComponentEncoder.encode("#+:@,;$"), "%23%2B%3A%40%2C%3B%24")
    }

    func testEncoderLeavesUnreservedCharactersUnchanged() {
        XCTAssertEqual(URIComponentEncoder.encode("AZaz09-_.!~*'()"), "AZaz09-_.!~*'()")
    }

    func testEncoderPercentEncodesNonASCIIAsUTF8() {
        XCTAssertEqual(URIComponentEncoder.encode("é"), "%C3%A9")
    }

    func testDeeplinkEncodesQRCodeInEveryStyle() {
        for style in [ScanToPayApp.DeeplinkStyle.fnb, .nedbank, .generic] {
            let app = ScanToPayApp(name: "Test", iconAsset: "scanToPayAppTest", deeplinkStyle: style)
            let url = app.deeplink(for: "12 34")?.absoluteString
            XCTAssertEqual(url?.hasSuffix("12%2034"), true, "\(style) did not encode the QR code")
        }
    }

    func testOpenFailedMessage() {
        XCTAssertEqual(ScanToPayAppDirectory.openFailedMessage(appName: "FNB Pay"),
                       "Couldn't open FNB Pay. Make sure it's installed.")
    }

    func testInitialsUseFirstTwoWordsOrFirstTwoLetters() {
        XCTAssertEqual(app(named: "Absa Scan to Pay")?.initials, "AS")
        XCTAssertEqual(app(named: "FNB Pay")?.initials, "FP")
        XCTAssertEqual(app(named: "Avo")?.initials, "AV")
        XCTAssertEqual(app(named: "RMB")?.initials, "RM")
    }

    private func app(named name: String) -> ScanToPayApp? {
        ScanToPayAppDirectory.apps.first { $0.name == name }
    }

    private func styles(named names: [String]) -> [ScanToPayApp.DeeplinkStyle?] {
        names.map { app(named: $0)?.deeplinkStyle }
    }
}
