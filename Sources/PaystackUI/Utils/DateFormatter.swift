import Foundation

extension DateFormatter {

    static func toString(usingFormat format: String,
                         timeZone: TimeZone? = .current,
                         from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    static func toDate(usingFormat format: String,
                       timeZone: TimeZone? = .current,
                       from string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = format
        return formatter.date(from: string)
    }

}
