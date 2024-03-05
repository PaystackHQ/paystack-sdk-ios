import Foundation

/// Service sometimes returns a string for an integer field
public struct IntegerObject: Decodable {
    public var value: Int

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self.value = try container.decode(Int.self)
        } catch {
            self.value = Int(try container.decode(String.self)) ?? 0
        }
    }
}
