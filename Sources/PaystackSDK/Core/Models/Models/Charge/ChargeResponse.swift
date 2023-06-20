import Foundation

public struct ChargeResponse: Codable {
    public var status: Bool
    public var message: String
    public var data: ChargeResponseData
}
