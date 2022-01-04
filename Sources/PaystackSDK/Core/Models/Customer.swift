import Foundation

public struct Customer: Decodable {
    public var id: Int?
    public var firstName: String?
    public var lastName: String?
    public var email: String?
    public var phone: String?
    public var customerCode: String
    public var metadata: Metadata?
    public var riskAction: String?
}
