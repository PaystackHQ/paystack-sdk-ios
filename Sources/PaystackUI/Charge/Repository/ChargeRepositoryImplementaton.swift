import PaystackCore

struct ChargeRepositoryImplementation: ChargeRepository {

    let paystack: Paystack

    init(paystack: Paystack) {
        self.paystack = paystack
    }

    func verifyAccessCode(_ code: String) async throws -> VerifyAccessCode {
        let response = try await paystack.verifyAccessCode(code).async()
        return VerifyAccessCode.from(response)
    }
}
