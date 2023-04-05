import Foundation

public struct SubmitAddressRequest: Codable {
    public var address: String
    public var city: String
    public var state: String
    public var zipCode: String
    public var reference: String

    enum CodingKeys: String, CodingKey {
        case address, city, state, reference
        case zipCode = "zip_code"
    }
}
