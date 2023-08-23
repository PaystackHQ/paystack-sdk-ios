import PaystackCore

// TODO: Make actual calls here once we finalize API mocking
struct ChargeCardRepositoryImplementation: ChargeCardRepository {

    func submitBirthday(_ birthday: String, accessCode: String) async throws -> ChargeCardTransaction {
        ChargeCardTransaction.example
    }

}
