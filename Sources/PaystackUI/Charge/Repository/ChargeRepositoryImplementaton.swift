import PaystackCore

struct ChargeRepositoryImplementation: ChargeRepository {

    let paystack: Paystack

    init() {
        self.paystack = PaystackContainer.instance.retrieve()
    }

    func verifyAccessCode(_ code: String) async throws -> VerifyAccessCode {
        let response = try await paystack.verifyAccessCode(code).async()
        return VerifyAccessCode.from(response)
    }
}
