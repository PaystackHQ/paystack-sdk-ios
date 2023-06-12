import Foundation

struct SubmitAddressRequest: Codable {
    var address: String
    var city: String
    var state: String
    var zipCode: String
    var reference: String

    init(address: Address, reference: String) {
        self.address = address.address
        self.city = address.city
        self.state = address.state
        self.zipCode = address.zipCode
        self.reference = reference
    }

    enum CodingKeys: String, CodingKey {
        case address, city, state, reference
        case zipCode = "zip_code"
    }
}
