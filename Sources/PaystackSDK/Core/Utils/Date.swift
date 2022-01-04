import Foundation

public enum DateFormat: String {
    case paystack = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
}

public extension Date {

    var paystackFormat: String {
        return DateFormatter.toString(usingFormat: DateFormat.paystack.rawValue, from: self)
    }

}
