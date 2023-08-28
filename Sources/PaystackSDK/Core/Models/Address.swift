import Foundation

public struct Address: Equatable {
    public var address: String
    public var city: String
    public var state: String
    public var zipCode: String

    public init(address: String, city: String, state: String, zipCode: String) {
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
    }
}
