import Foundation

public struct Metadata: Codable {
    public var customFields: [CustomField]?

    public init(customFields: [CustomField]?) {
        self.customFields = customFields
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try? container.decode(String.self)
        guard let data = string?.data(using: .utf8), data.count > 0 else {
            return
        }

        let metadata = try JSONDecoder.decoder.decode(InnerMetadata.self, from: data)
        self.customFields = metadata.customFields
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let data = try JSONEncoder.encoder.encode(InnerMetadata(customFields: customFields))
        let string = String(data: data, encoding: .utf8) ?? ""
        try container.encode(string)
    }

    private struct InnerMetadata: Codable {
        var customFields: [CustomField]?
    }
}
