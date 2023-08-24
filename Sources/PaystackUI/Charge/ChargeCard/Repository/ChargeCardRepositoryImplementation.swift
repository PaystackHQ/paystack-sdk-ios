import PaystackCore

// TODO: Make actual calls here once we finalize API mocking
struct ChargeCardRepositoryImplementation: ChargeCardRepository {

    func submitBirthday(_ birthday: String, accessCode: String) async throws -> ChargeCardTransaction {
        ChargeCardTransaction.example
    }

    func submitPhone(_ phone: String, accessCode: String) async throws -> ChargeCardTransaction {
        ChargeCardTransaction.example
    }

    func submitOTP(_ otp: String, accessCode: String) async throws -> ChargeCardTransaction {
        ChargeCardTransaction.example
    }
}
