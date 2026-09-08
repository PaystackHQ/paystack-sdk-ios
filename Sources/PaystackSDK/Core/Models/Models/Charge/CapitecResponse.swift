import Foundation

public struct CapitecResponse: Codable {
    public var status: Bool
    public var message: String
    public var data: CapitecResponseData
}
