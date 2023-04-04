import Foundation

public struct ChargeAuthenticationResponse: Codable {
    var status: Bool
    var message: String
    var data: ChargeAuthentication
}
