import Foundation

enum DateFormat: String {
    case monthAndYearExpiry = "MM/yy"
}

extension Date {

    static var today: Date {
        return Date()
    }

    var startOfMonth: Date? {
        Calendar.current.date(from: Calendar.current.dateComponents(
            [.year, .month], from: self))
    }

    var endOfMonth: Date? {
        guard let startOfMonth = self.startOfMonth else { return nil }
        return Calendar.current.date(byAdding: DateComponents(month: 1, second: -1), to: startOfMonth)
    }

    func toString(_ format: DateFormat, timeZone: TimeZone? = .current) -> String {
        return DateFormatter.toString(usingFormat: format.rawValue,
                                      timeZone: timeZone,
                                      from: self)
    }

    var monthAndYearExpiry: String {
        return toString(.monthAndYearExpiry)
    }
}
