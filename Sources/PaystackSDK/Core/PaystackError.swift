import Foundation

public enum PaystackError: LocalizedError, Equatable {
    case noAPIKey
    case technical
    case response(code: Int, message: String)
    case custom(message: String)

    public var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "No API key was provided to initialize the SDK"
        case .technical:
            return "A technical error occurred. Please contact Paystack."
        case .response(let code, let message):
            return "Error response received with Code: \(code) and Message: \(message)"
        case .custom(let message):
            return message
        }
    }
}
