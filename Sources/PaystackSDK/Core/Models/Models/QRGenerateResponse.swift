import Foundation

public struct QRGenerateResponse: Decodable, Equatable {
    public let status: Bool
    public let message: String
    public let data: QRGenerateData

    public init(status: Bool, message: String, data: QRGenerateData) {
        self.status = status
        self.message = message
        self.data = data
    }
}

public struct QRGenerateData: Decodable, Equatable {
    public let errors: Bool
    public let url: String
    public let qrCode: String
    public let status: String
    public let channel: String

    public init(errors: Bool,
                url: String,
                qrCode: String,
                status: String,
                channel: String) {
        self.errors = errors
        self.url = url
        self.qrCode = qrCode
        self.status = status
        self.channel = channel
    }
}
