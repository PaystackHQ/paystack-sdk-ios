import Foundation

// MARK: - MobileMoney
public struct MobileMoney: Codable {
    public let key: String
    public let value: String
    public let isNew: Bool
    public let phoneNumberRegex: String

    enum CodingKeys: String, CodingKey {
        case key
        case value
        case isNew
        case phoneNumberRegex
    }
}
