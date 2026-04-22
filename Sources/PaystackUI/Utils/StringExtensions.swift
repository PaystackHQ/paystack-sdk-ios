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

    var formattedKenyanPhoneNumber: String {
        let trimmed = self.removingAllWhitespaces
        if trimmed.hasPrefix("+254") {
            return trimmed
        }
        if trimmed.hasPrefix("254") {
            return "+" + trimmed
        }
        if trimmed.hasPrefix("0") {
            return "+254" + trimmed.dropFirst()
        }
        return trimmed
    }
}
