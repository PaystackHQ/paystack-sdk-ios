import Foundation

public enum PaystackError: Error, Equatable {
    case noAPIKey
    case technical
    case response(code: Int, message: String)
}
