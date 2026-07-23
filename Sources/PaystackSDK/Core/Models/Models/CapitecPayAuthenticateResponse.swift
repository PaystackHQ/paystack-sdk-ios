import Foundation

public struct CapitecPayAuthenticateResponse: Decodable, Equatable {
    public let status: Bool
    public let type: String
    public let code: String
    public let data: CapitecPayAuthenticateData
    public let message: String

    public init(status: Bool,
                type: String,
                code: String,
                data: CapitecPayAuthenticateData,
                message: String) {
        self.status = status
        self.type = type
        self.code = code
        self.data = data
        self.message = message
    }
}

public struct CapitecPayAuthenticateData: Decodable, Equatable {
    public let status: String
    public let timeToLive: Int
    public let expiryDate: Date

    public init(status: String, timeToLive: Int, expiryDate: Date) {
        self.status = status
        self.timeToLive = timeToLive
        self.expiryDate = expiryDate
    }
}
