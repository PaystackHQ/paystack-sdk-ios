import Foundation

public struct CapitecPayAuthenticateRequest: Encodable, Equatable {
    public let clientdata: String
    public let trans: String
    public let device: String

    public init(clientdata: String, trans: String, device: String) {
        self.clientdata = clientdata
        self.trans = trans
        self.device = device
    }
}
