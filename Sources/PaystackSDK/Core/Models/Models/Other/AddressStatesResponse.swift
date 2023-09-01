import Foundation

public struct AddressStatesResponse: Codable {
    public var status: Bool?
    public var message: String?
    public var data: [AddressStateResponseData]
}
