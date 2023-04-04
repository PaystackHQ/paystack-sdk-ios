import Foundation

public struct SubmitOtpRequest: Codable {
    public var otp: String
    public var reference: String
}
