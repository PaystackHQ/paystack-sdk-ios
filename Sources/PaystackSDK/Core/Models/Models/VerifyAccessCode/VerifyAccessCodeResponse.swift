import Foundation

public struct VerifyAccessCodeResponse: Decodable {
    public var status: Bool
    public var message: String
    public var data: VerifyAccessCodeData

    public init(status: Bool, message: String, data: VerifyAccessCodeData) {
        self.status = status
        self.message = message
        self.data = data
    }
}
