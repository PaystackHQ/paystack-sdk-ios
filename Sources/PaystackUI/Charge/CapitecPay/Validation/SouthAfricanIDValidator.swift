import Foundation

enum SouthAfricanIDValidator {

    static func isValid(_ input: String) -> Bool {
        guard input.count == 13,
              input.allSatisfy({ $0.isNumber }) else {
            return false
        }
        guard hasValidDatePortion(input) else {
            return false
        }
        return luhnChecksumPasses(input)
    }

    private static func hasValidDatePortion(_ input: String) -> Bool {
        let yy = String(input.prefix(2))
        let mm = String(input.dropFirst(2).prefix(2))
        let dd = String(input.dropFirst(4).prefix(2))

        guard let yyInt = Int(yy),
              let mmInt = Int(mm),
              let ddInt = Int(dd) else {
            return false
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .current

        let currentYearShort = calendar.component(.year, from: Date()) % 100
        let candidates = yyInt <= currentYearShort ? [2000, 1900] : [1900]

        for century in candidates {
            var components = DateComponents()
            components.year = century + yyInt
            components.month = mmInt
            components.day = ddInt
            if let date = calendar.date(from: components),
               calendar.component(.year, from: date) == century + yyInt,
               calendar.component(.month, from: date) == mmInt,
               calendar.component(.day, from: date) == ddInt,
               date <= Date() {
                return true
            }
        }
        return false
    }

    private static func luhnChecksumPasses(_ input: String) -> Bool {
        let digits = input.compactMap { Int(String($0)) }
        guard digits.count == 13 else { return false }

        var sum = 0
        for (index, digit) in digits.enumerated() {
            let positionFromRight = digits.count - 1 - index
            if positionFromRight % 2 == 1 {
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += digit
            }
        }
        return sum % 10 == 0
    }
}
