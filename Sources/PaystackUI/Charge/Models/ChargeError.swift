import PaystackCore

enum ChargeError: Error, Equatable {
    case paystackResponse(message: String)
    case custom(message: String)
    case generic

    init(error: Error) {
        if let error = error as? PaystackError,
           case let .response(_, message) = error {
            self = .paystackResponse(message: message)
        } else {
            self = .generic
        }
    }

    init(message: String) {
        self = .custom(message: message)
    }
}

extension ChargeError {
    var message: String {
        switch self {
        case .paystackResponse(let message):
            return message
        case .custom(let message):
            return message
        case .generic:
            return "Something went wrong"
        }
    }
}
