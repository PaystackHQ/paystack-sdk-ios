import Foundation

public struct CustomField: Codable {
    public var displayName: String
    public var variableName: String
    public var value: String

    public init(displayName: String,
                variableName: String,
                value: String) {
        self.displayName = displayName
        self.variableName = variableName
        self.value = value
    }
}
