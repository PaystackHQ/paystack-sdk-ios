import PaystackCore

protocol ChargeCardRepository {
    func submitBirthday(_ birthday: String, accessCode: String) async throws -> ChargeCardTransaction
    func submitPhone(_ phone: String, accessCode: String) async throws -> ChargeCardTransaction
    func submitOTP(_ otp: String, accessCode: String) async throws -> ChargeCardTransaction
}
