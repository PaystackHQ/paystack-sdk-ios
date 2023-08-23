import PaystackCore

protocol ChargeCardRepository {
    func submitBirthday(_ birthday: String, accessCode: String) async throws -> ChargeCardTransaction
}
