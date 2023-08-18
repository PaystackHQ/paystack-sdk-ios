import Foundation

struct SubmitAddressRequest: Codable {
    var address: String
    var city: String
    var state: String
    var zipCode: String
    var accessCode: String

    init(address: Address, accessCode: String) {
        self.address = address.address
        self.city = address.city
        self.state = address.state
        self.zipCode = address.zipCode
        self.accessCode = accessCode
    }
}
