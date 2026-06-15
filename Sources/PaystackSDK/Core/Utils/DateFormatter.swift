import Foundation

public extension DateFormatter {

    static var paystackFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = DateFormat.paystack.rawValue
        return formatter
    }

    static func toString(usingFormat format: String, from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    static func toDate(usingFormat format: String, from string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = format
        return formatter.date(from: string)
    }

}
