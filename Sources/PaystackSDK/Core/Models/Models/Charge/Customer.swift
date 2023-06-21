import Foundation

public struct Customer: Codable {
    public var firstName: String?
    public var lastName: String?
    public var email: String?
    public var customerCode: String
    public var phone: String?
    public var riskAction: String
}
