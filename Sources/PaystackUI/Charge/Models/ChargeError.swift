import PaystackCore

public struct ChargeError: Error {
    public var cause: Error?
    public var message: String

    private static var genericErrorMessage = "Something went wrong"

    init(error: Error) {
        if let error = error as? ChargeError {
            self = error
        } else if let error = error as? PaystackError,
                  case let .response(_, message) = error {
            self.cause = error
            self.message = message
        } else {
            self.cause = error
            self.message = Self.genericErrorMessage
        }
    }

    init(message: String) {
        self.message = message
    }

    /// Initializes a ChargeError with a seperate display message and cause message that will be initialized as a custom `PaystackError`
    /// This will cause an error to be marked as fatal and will terminate the payment flow
    init(displayMessage: String,
         causeMessage: String) {
        self.message = displayMessage
        self.cause = PaystackError.custom(message: causeMessage)
    }

    static var generic: Self {
        .init(message: Self.genericErrorMessage)
    }

    static func generic(withCause cause: String) -> Self {
        .init(displayMessage: Self.genericErrorMessage,
              causeMessage: cause)
    }

}

extension ChargeError: Equatable {

    public static func == (lhs: ChargeError, rhs: ChargeError) -> Bool {
        lhs.message == rhs.message
    }

}

// MARK: - Internal extension for determining fatality
extension ChargeError {
    var isFatal: Bool {
        cause != nil
    }
}
