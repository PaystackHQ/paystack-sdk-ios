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
}
