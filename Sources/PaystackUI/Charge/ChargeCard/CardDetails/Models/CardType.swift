import Foundation
import SwiftUI

enum CardType {
    case amex
    case discover
    case jcb
    case diners
    case visa
    case mastercard
    case verve
    case unknown

    static func fromNumber(_ number: String) -> CardType {
        let sanitizedNumber = number.removingAllWhitespaces
        return CardIdentifier.allTypes.first(where: {
            $0.prefixes.contains(where: sanitizedNumber.hasPrefix) }
        )?.type ?? .unknown
    }

}

extension CardType {

    var maximumCvvDigits: Int {
        switch self {
        case .amex:
            return 4
        default:
            return 3
        }
    }

    var minimumDigits: Int {
        switch self {
        case .amex:
            return 15
        case .diners:
            return 14
        default:
            return 16
        }
    }

    var regularExpression: String {
        switch self {
        case .amex:
            return "^3[47][0-9]{13}$"
        case .discover:
            return "^6(?:011|5[0-9]{2})[0-9]{12}$"
        case .jcb:
            return "^(?:2131|1800|35[0-9]{3})[0-9]{11}$"
        case .diners:
            return "^3(?:0[0-5]|[68][0-9])[0-9]{11}$"
        case .visa:
            return "^4[0-9]{12}(?:[0-9]{3})?$"
        case .mastercard:
            return "^(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}$"
        case .verve:
            return "^((506(0|1))|(507(8|9))|(6500))[0-9]{12,15}$"
        case .unknown:
            return "^[0-9]+$"
        }
    }
}

// MARK: - Formatting
extension CardType {

    func formatAndGroup(cardNumber: String) -> String {
        switch self {
        case .amex:
            return splitIntoChunks(cardNumber: cardNumber, chunkSizes: [4, 6, 5])
        case .diners:
            return splitIntoChunks(cardNumber: cardNumber, chunkSizes: [4, 6, 4])
        default:
            return splitIntoChunks(cardNumber: cardNumber, chunkSizes: [4, 4, 4, 4])
        }
    }

    private func splitIntoChunks(cardNumber: String, chunkSizes: [Int]) -> String {
        var remainingDigits = cardNumber.removingAllWhitespaces
        var splitCardNumbers = chunkSizes.compactMap { chunkSize -> String? in
            guard !remainingDigits.isEmpty else { return nil }
            let chunk = remainingDigits.prefix(chunkSize)
            remainingDigits = String(remainingDigits.dropFirst(chunkSize))
            return String(chunk)
        }

        if !remainingDigits.isEmpty {
            splitCardNumbers.append(remainingDigits)
        }
        return splitCardNumbers.joined(separator: " ")
    }
}

// MARK: - Card Logo View
extension CardType {

    @ViewBuilder
    var cardImage: some View {
        switch self {
        case .amex:
            Image.amexLogo
        case .diners:
            Image.dinersLogo
        case .discover:
            Image.discoverLogo
        case .jcb:
            Image.jcbLogo
        case .mastercard:
            Image.mastercardLogo
        case .verve:
            Image.verveLogo
        case .visa:
            Image.visaLogo
        default:
            EmptyView()
        }
    }

}
