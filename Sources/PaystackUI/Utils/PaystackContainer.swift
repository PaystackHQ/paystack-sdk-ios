import PaystackCore

class PaystackContainer {

    private var paystack: Paystack?
    private init() {}

    static let instance = PaystackContainer()

    func store(_ paystack: Paystack) {
        self.paystack = paystack
    }

    func retrieve() -> Paystack {
        guard let paystack = paystack else {
            preconditionFailure("Paystack object was not stored before attempted retrieval")
        }
        return paystack
    }
}
