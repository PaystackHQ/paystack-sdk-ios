import PaystackCore

struct ChargeCardRepositoryImplementation: ChargeCardRepository {

    let paystack: Paystack

    init() {
        self.paystack = PaystackContainer.instance.retrieve()
    }

    func submitBirthday(_ birthday: String, accessCode: String) async throws -> ChargeCardTransaction {
        let response = try await paystack.authenticateCharge(withBirthday: birthday,
                                                             accessCode: accessCode).async()
        return ChargeCardTransaction.from(response)
    }

    func submitPhone(_ phone: String, accessCode: String) async throws -> ChargeCardTransaction {
        let response = try await paystack.authenticateCharge(withPhone: phone,
                                                             accessCode: accessCode).async()
        return ChargeCardTransaction.from(response)
    }

    func submitOTP(_ otp: String, accessCode: String) async throws -> ChargeCardTransaction {
        let response = try await paystack.authenticateCharge(withOtp: otp,
                                                             accessCode: accessCode).async()
        return ChargeCardTransaction.from(response)
    }

    func submitAddress(_ address: Address, accessCode: String) async throws -> ChargeCardTransaction {
        let response = try await paystack.authenticateCharge(withAddress: address,
                                                             accessCode: accessCode).async()
        return ChargeCardTransaction.from(response)
    }

    func submitPin(_ pin: String, accessCode: String) async throws -> ChargeCardTransaction {
        let response = try await paystack.authenticateCharge(withPin: pin,
                                                             accessCode: accessCode).async()
        return ChargeCardTransaction.from(response)
    }
}
