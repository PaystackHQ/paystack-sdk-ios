import Foundation

extension String {

    var removingAllWhitespaces: String {
        self.replacingOccurrences(of: " ", with: "")
    }

    func toDate(_ format: DateFormat, timeZone: TimeZone? = .current) -> Date? {
        return DateFormatter.toDate(usingFormat: format.rawValue,
                                    timeZone: timeZone,
                                    from: self)
    }

    func formatted(for provider: MobileMoneyChannel) -> String {
        let trimmed = self.removingAllWhitespaces
        let countryCode = provider.expectedCountryCode

        guard !countryCode.isEmpty else { return trimmed }

        if trimmed.hasPrefix("+\(countryCode)") {
            return trimmed
        }
        if trimmed.hasPrefix(countryCode) {
            return "+" + trimmed
        }
        if trimmed.hasPrefix("0") {
            return "+\(countryCode)" + trimmed.dropFirst()
        }
        return trimmed
    }
}
