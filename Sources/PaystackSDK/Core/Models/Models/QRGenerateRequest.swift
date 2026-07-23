import Foundation

public struct QRGenerateRequest: Encodable, Equatable {
    public let source: String
    public let reference: String
    public let channel: String

    public init(source: String = "mobile-pos",
                reference: String,
                channel: String) {
        self.source = source
        self.reference = reference
        self.channel = channel
    }
}
