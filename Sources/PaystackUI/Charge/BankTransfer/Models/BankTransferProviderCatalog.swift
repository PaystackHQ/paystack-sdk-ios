import Foundation

enum BankTransferProviderCatalog {

    static func displayName(forSlug slug: String) -> String {
        switch slug.lowercased() {
        case "wema-bank":
            return "Wema Bank"
        case "titan-paystack":
            return "Paystack-Titan"
        case "paystack-mfb":
            return "Paystack MFB"
        default:
            return titleCased(slug)
        }
    }

    private static func titleCased(_ slug: String) -> String {
        slug.split(separator: "-")
            .map { segment -> String in
                let lowered = segment.lowercased()
                guard let first = lowered.first else { return "" }
                return first.uppercased() + lowered.dropFirst()
            }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
