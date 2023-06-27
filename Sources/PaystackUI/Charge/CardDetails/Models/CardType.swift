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
