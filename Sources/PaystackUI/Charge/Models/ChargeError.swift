import PaystackCore

public struct ChargeError: Error {
    public var innerError: Error?
    public var message: String

    init(error: Error) {
        if let error = error as? ChargeError {
            self = error
        } else if let error = error as? PaystackError,
                  case let .response(_, message) = error {
            self.innerError = error
            self.message = message
        } else {
            self.innerError = error
            self.message = "Something went wrong"
        }
    }

    init(message: String) {
        self.message = message
    }

    static var generic: Self {
        .init(message: "Something went wrong")
    }
    
}

extension ChargeError: Equatable {

    public static func == (lhs: ChargeError, rhs: ChargeError) -> Bool {
        lhs.message == rhs.message
    }

}
