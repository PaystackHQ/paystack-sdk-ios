import Foundation

struct ScanToPayApp: Equatable, Identifiable {

    enum DeeplinkStyle: Equatable {
        case fnb
        case nedbank
        case generic
    }

    let name: String
    let iconAsset: String
    let deeplinkStyle: DeeplinkStyle

    var id: String { iconAsset }

    var initials: String {
        let words = name.split(separator: " ")
        if words.count >= 2 {
            return words.prefix(2).compactMap { $0.first }.map(String.init).joined().uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    func deeplink(for qrCode: String) -> URL? {
        guard let encoded = URIComponentEncoder.encode(qrCode) else { return nil }
        switch deeplinkStyle {
        case .fnb:
            return URL(string: "https://www.online.fnb.co.za/banking/mobileservices"
                       + "?codetype=masterpassdeeplink&urlencodedqr=\(encoded)")
        case .nedbank:
            return URL(string: "nedbank://masterpass.oltio.co.za/\(encoded)")
        case .generic:
            return URL(string: "masterpass.app.scheme://masterpass.oltio.co.za/\(encoded)")
        }
    }
}

enum ScanToPayAppDirectory {

    static let apps: [ScanToPayApp] = [
        ScanToPayApp(name: "Absa Scan to Pay", iconAsset: "scanToPayAppAbsa", deeplinkStyle: .generic),
        ScanToPayApp(name: "Avo", iconAsset: "scanToPayAppAvo", deeplinkStyle: .generic),
        ScanToPayApp(name: "Capitec", iconAsset: "scanToPayAppCapitec", deeplinkStyle: .generic),
        ScanToPayApp(name: "FNB Pay", iconAsset: "scanToPayAppFNB", deeplinkStyle: .fnb),
        ScanToPayApp(name: "Instapay", iconAsset: "scanToPayAppInstapay", deeplinkStyle: .generic),
        ScanToPayApp(name: "Nedbank Money", iconAsset: "scanToPayAppNedbankMoney", deeplinkStyle: .nedbank),
        ScanToPayApp(name: "Nedbank Scan to Pay", iconAsset: "scanToPayAppNedbankScanToPay", deeplinkStyle: .generic),
        ScanToPayApp(name: "RMB", iconAsset: "scanToPayAppRMB", deeplinkStyle: .fnb),
        ScanToPayApp(name: "Spot", iconAsset: "scanToPayAppSpot", deeplinkStyle: .generic),
        ScanToPayApp(name: "Standard Bank Scan to Pay", iconAsset: "scanToPayAppStandardBank", deeplinkStyle: .generic),
        ScanToPayApp(name: "Telkom Pay", iconAsset: "scanToPayAppTelkomPay", deeplinkStyle: .generic),
        ScanToPayApp(name: "Scan to Pay", iconAsset: "scanToPayAppScanToPay", deeplinkStyle: .generic),
        ScanToPayApp(name: "Vodapay", iconAsset: "scanToPayAppVodapay", deeplinkStyle: .generic)
    ]

    static func openFailedMessage(appName: String) -> String {
        "Couldn't open \(appName). Make sure it's installed."
    }
}

enum URIComponentEncoder {

    private static let allowed: CharacterSet = {
        var set = CharacterSet()
        set.insert(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.!~*'()")
        return set
    }()

    static func encode(_ value: String) -> String? {
        value.addingPercentEncoding(withAllowedCharacters: allowed)
    }
}
