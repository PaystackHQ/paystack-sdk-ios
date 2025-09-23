import Foundation

enum TestCard: CustomStringConvertible, Hashable, CaseIterable {
    case success
    case bankAuthentication
    case declined
}

// MARK: - Card Information
extension TestCard {

    var description: String {
        switch self {
        case .success:
            return "Success"
        case .bankAuthentication:
            return "Bank Authentication"
        case .declined:
            return "Declined"
        }
    }

    var cardNumber: String {
        switch self {
        case .success:
            return "4084084084084081"
        case .bankAuthentication:
            return "4084080000000409"
        case .declined:
            return "4084080000005408"
        }
    }

    var cvv: String {
        switch self {
        case .success:
            return "408"
        case .bankAuthentication:
            return "000"
        case .declined:
            return "001"
        }
    }

    var expiryMonth: String {
        switch self {
        case .success:
            return "08"
        case .bankAuthentication:
            return "08"
        case .declined:
            return "08"
        }
    }

    var expiryYear: String {
        let nextYear = Calendar.current.component(.year, from: Date()) + 1
        let lastTwoDigits = String(nextYear).suffix(2)
        return "\(lastTwoDigits)"
    }

    var cardType: CardType {
        CardType.fromNumber(cardNumber)
    }
}
