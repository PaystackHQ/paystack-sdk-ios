import Foundation

public struct InitializedTransaction: Decodable {
    public var authorizationUrl: URL
    public var accessCode: String
    public var reference: String
}
