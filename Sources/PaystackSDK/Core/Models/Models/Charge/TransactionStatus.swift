import Foundation

public enum TransactionStatus: String, Codable {
    case success
    case failed
    case pending
    case timeout
    case sendOtp = "send_otp"
    case sendBirthday = "send_birthday"
    case sendPin = "send_pin"
    case sendPhone = "send_phone"
    case sendAddress = "send_address"
    case openUrl = "open_url"
}
