import Foundation

class CardInfoValidator: FormValidator {

    var validation: () -> Bool
    var errorMessage: String

    init(errorMessage: String, validation: @escaping () -> Bool) {
        self.validation = validation
        self.errorMessage = errorMessage
    }

    func validate() -> Bool {
        return validation()
    }
}

// MARK: - Card Number
extension CardInfoValidator {

    static func cardNumber(_ text: String, errorMessage: String) -> CardInfoValidator {
        return CardInfoValidator(errorMessage: errorMessage) {
            let sanitizedText = text.removingAllWhitespaces
            let cardType = CardType.fromNumber(sanitizedText)
            let regex = cardType.regularExpression
            return sanitizedText.range(of: regex, options: .regularExpression) != nil
            && luhnCheck(number: sanitizedText)
        }
    }

    private static func luhnCheck(number: String) -> Bool {
        var sum = 0
        let digitStrings = number.reversed().map { String($0) }

        for tuple in digitStrings.enumerated() {
            guard let digit = Int(tuple.element) else { return false }
            let odd = tuple.offset % 2 == 1

            switch (odd, digit) {
            case (true, 9):
                sum += 9
            case (true, 0...8):
                sum += (digit * 2) % 9
            default:
                sum += digit
            }
        }
        return sum % 10 == 0
    }
}

// MARK: - Card Expiry
extension CardInfoValidator {
    static func cardExpiry(_ text: String, errorMessage: String,
                           currentDateOverride currentDate: Date = Date()) -> CardInfoValidator {
        return CardInfoValidator(errorMessage: errorMessage) {
            guard text.count == 7 else { return false }

            guard let expiryDate = text.removingAllWhitespaces.toDate(.monthAndYearExpiry),
                  let endOfMonthExpiry = expiryDate.endOfMonth else { return false }
            return endOfMonthExpiry >= currentDate
        }
    }
}
