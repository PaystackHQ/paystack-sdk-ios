import Foundation

// TODO: Add error states here once we identify further examples
enum ChargeCardError: Error {
    case incorrectStreetAddress
}

extension ChargeCardError {
    var message: String {
        switch self {
        case .incorrectStreetAddress:
            return "Street address does not match"
        }
    }
}
