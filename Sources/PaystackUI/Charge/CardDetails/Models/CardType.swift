import Foundation

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

    func formatAndGroup(cardNumber: String) -> String {
        switch self {
        case .amex:
            return splitIntoChunks(cardNumber: cardNumber, chunkSizes: [4,6,5])
        case .diners:
            return splitIntoChunks(cardNumber: cardNumber, chunkSizes: [4,6,4])
        default:
            return splitIntoChunks(cardNumber: cardNumber, chunkSizes: [4,4,4,4])
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
