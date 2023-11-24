import Foundation

// MARK: - MobileMoney
public struct MobileMoney: Codable {
    let key: String
    let value: String
    let isNew: Bool
    let phoneNumberRegex: String
}
