import Foundation

public enum CardType: String, Decodable {
    case visa
    case visaDebit = "visa DEBIT"
    case mastercardDebit = "mastercard DEBIT"

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        // Service returns card type with trailing whitespaces
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = CardType(rawValue: trimmedString) else {
            throw DecodingError.valueNotFound(CardType.self, .init(codingPath: decoder.codingPath,
                                                                   debugDescription: "Could not find value for \(trimmedString) in CardType",
                                                                   underlyingError: nil))
        }

        self = value
    }
}
