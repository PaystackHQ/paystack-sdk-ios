import Foundation

/// Service sometimes returns empty object instead of null string
public struct OptionalStringObject: Decodable {

    enum CodingKeys: String, CodingKey {
        case value
    }

    public var value: String?

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try? container.decode(String.self)
    }
}
