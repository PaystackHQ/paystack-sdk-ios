import Foundation

struct SubmitOtpRequest: Codable {
    var otp: String
    var reference: String
}
